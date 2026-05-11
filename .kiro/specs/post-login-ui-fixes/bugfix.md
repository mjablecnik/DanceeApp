# Bugfix Requirements Document

## Introduction

This document addresses three related UI bugs that occur during and immediately after the login/logout flow in the Dancee Flutter app. All three bugs share a common root cause pattern: state transitions triggered by authentication changes are not properly synchronized with the UI, resulting in stale or incorrect visual states.

**Bug 1**: The Favorites (Saved Events) page shows an "Access denied" error immediately after login because the `FavoritesCubit.loadFavorites()` call fires before the Firebase → Directus token exchange completes, so the request goes out with the public role token. The favorites collection is the ONLY collection that fails because it is exclusively accessible to the authenticated user role — unlike Events and Courses collections, which are accessible to BOTH the public and user roles (so they load fine even with the old public token). The user profile also loads successfully because it is fetched after the token exchange completes. Since the favorites collection has no public role access, the request is rejected with a 403 "Access denied" response.

**Bug 2**: After logout, the user sees the generic "Sign in required" (`AuthGatePage`) instead of a logout success confirmation message.

**Bug 3**: After login, saved filter preferences from the user's profile are applied to the `FilterCubit` state, but the events list UI does not visually reflect the active filters until a manual page redraw occurs.

## Bug Analysis

### Current Behavior (Defect)

1.1 WHEN a user logs in and navigates to the Saved Events page THEN the `FavoritesCubit.loadFavorites()` fires before the Firebase → Directus token exchange completes, causing the API call to use the public role token. Since the favorites/saved events collection is ONLY accessible to the authenticated user role (not the public role), Directus returns a 403 "Access denied". Events and Courses collections do NOT exhibit this issue because they are accessible to both public and user roles, and the user profile does NOT exhibit this issue because it is fetched after the token exchange completes.

1.2 WHEN a user logs out while on a protected page (Profile or Saved) THEN the system displays the generic `AuthGatePage` with "Sign in required" text, providing no indication that the logout was successful.

1.3 WHEN a user logs in and filter preferences are prefilled from their profile THEN the system applies filters to the `EventCubit`/`CourseCubit` state but the events list page UI does not visually reflect the active filters (filter chips, active indicators) until the user navigates away and back.

### Expected Behavior (Correct)

2.1 WHEN a user logs in and navigates to the Saved Events page THEN the system SHALL ensure `FavoritesCubit` waits for the authenticated Directus token (from the Firebase → Directus token exchange) to be available before making the favorites API call — similar to how the profile loading already works. The system SHALL display a loading indicator while waiting for the token exchange, and the request SHALL succeed once the user token is available.

2.2 WHEN a user logs out THEN the system SHALL display a logout success message (e.g., "Logout was successful") on the resulting page, clearly confirming the logout action completed, rather than showing the generic "Sign in required" gate.

2.3 WHEN a user logs in and filter preferences are prefilled from their profile THEN the system SHALL force a UI rebuild of the events list page so that filter chips and active filter indicators are immediately visible without requiring manual navigation.

### Unchanged Behavior (Regression Prevention)

3.1 WHEN a user is already logged in and navigates to the Saved Events page THEN the system SHALL CONTINUE TO load and display favorites normally without additional delays.

3.2 WHEN a user is not logged in and visits a protected page THEN the system SHALL CONTINUE TO show the `AuthGatePage` with "Sign in required" and login/register buttons.

3.3 WHEN a user manually sets filters via the filter UI THEN the system SHALL CONTINUE TO apply and display those filters immediately as before.

3.4 WHEN a user logs in without any saved profile preferences (empty dance tags and no city) THEN the system SHALL CONTINUE TO show the events list with no active filters.

3.5 WHEN a user logs out and the snackbar logout success message is shown THEN the system SHALL CONTINUE TO display the snackbar notification as before.

3.6 WHEN a user logs in and navigates to Events or Courses pages THEN the system SHALL CONTINUE TO load those collections immediately (since they are accessible to both public and user roles) without waiting for the token exchange.

3.7 WHEN a user's profile is loaded after login THEN the system SHALL CONTINUE TO fetch the profile successfully (since it already loads after the token exchange completes).

---

## Bug Condition Derivation

### Bug 1: Favorites Access Denied After Login

```pascal
FUNCTION isBugCondition1(X)
  INPUT: X of type NavigationContext
  OUTPUT: boolean
  
  // Returns true when user just logged in but Directus client still holds the public role token
  // (Firebase → Directus token exchange not yet completed) AND the target collection
  // is ONLY accessible to the user role (not the public role) — i.e., favorites.
  // Events/Courses are NOT affected because they are accessible to both public and user roles.
  // Profile is NOT affected because it loads after the token exchange completes.
  RETURN X.authState = authenticated AND X.directusTokenType = 'public' AND X.targetCollection.requiresUserRole = true
END FUNCTION
```

```pascal
// Property: Fix Checking - FavoritesCubit waits for authenticated token before API call
FOR ALL X WHERE isBugCondition1(X) DO
  result ← loadFavorites'(X)
  ASSERT result != error(403) AND (result = loading OR result = loaded)
END FOR
```

```pascal
// Property: Preservation Checking
FOR ALL X WHERE NOT isBugCondition1(X) DO
  ASSERT loadFavorites(X) = loadFavorites'(X)
END FOR
```

### Bug 2: No Logout Success Message

```pascal
FUNCTION isBugCondition2(X)
  INPUT: X of type AuthTransition
  OUTPUT: boolean
  
  // Returns true when user just transitioned from authenticated to unauthenticated (logout)
  RETURN X.previousState = authenticated AND X.currentState = unauthenticated AND X.trigger = 'signOut'
END FUNCTION
```

```pascal
// Property: Fix Checking - Logout success shown
FOR ALL X WHERE isBugCondition2(X) DO
  result ← renderProtectedPage'(X)
  ASSERT result.containsLogoutSuccessMessage = true
END FOR
```

```pascal
// Property: Preservation Checking
FOR ALL X WHERE NOT isBugCondition2(X) DO
  ASSERT renderProtectedPage(X) = renderProtectedPage'(X)
END FOR
```

### Bug 3: Filters Not Visually Applied After Login

```pascal
FUNCTION isBugCondition3(X)
  INPUT: X of type LoginContext
  OUTPUT: boolean
  
  // Returns true when user just logged in and profile has filter preferences
  RETURN X.authState = justAuthenticated AND X.profileHasFilterPreferences = true
END FUNCTION
```

```pascal
// Property: Fix Checking - Filters visually reflected
FOR ALL X WHERE isBugCondition3(X) DO
  result ← eventsListUI'(X)
  ASSERT result.visibleFilters = X.appliedFilters AND result.filterChipsVisible = true
END FOR
```

```pascal
// Property: Preservation Checking
FOR ALL X WHERE NOT isBugCondition3(X) DO
  ASSERT eventsListUI(X) = eventsListUI'(X)
END FOR
```
