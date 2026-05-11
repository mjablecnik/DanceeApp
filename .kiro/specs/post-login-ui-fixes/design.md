# Post-Login UI Fixes Bugfix Design

## Overview

This design addresses three related UI bugs that occur during authentication state transitions in the Dancee Flutter app. All three bugs share a common pattern: actions triggered by the `AuthCubit` state change fire before dependent asynchronous operations (Directus token exchange, profile loading) have completed, or fail to propagate state changes to the UI layer.

**Bug 1** — `FavoritesCubit.loadFavorites()` fires immediately on `authenticated` state, before the Firebase → Directus token exchange completes. Since the favorites collection requires the `user` role (unlike Events/Courses which are public), the request fails with 403.

**Bug 2** — After logout, the `AuthGatePage` shows generic "Sign in required" with no indication that the user just successfully logged out. The existing snackbar (`t.common.logoutSuccess`) is shown but disappears quickly and may be missed.

**Bug 3** — After login, `prefillFiltersFromProfile` sets filter state on `FilterCubit`, and the `BlocListener` calls `applyFilters` on `EventCubit`/`CourseCubit`. However, the `EventsListScreen` uses `context.read<FilterCubit>()` in some places instead of `BlocBuilder`, so those parts don't rebuild when filter state changes.

## Glossary

- **Bug_Condition (C)**: The condition that triggers each bug — timing/state mismatch during auth transitions
- **Property (P)**: The desired behavior — favorites load after token exchange; logout shows confirmation; filters visually reflect state
- **Preservation**: Existing behavior that must remain unchanged — normal favorites loading, generic auth gate for unauthenticated users, manual filter application
- **FavoritesCubit**: Cubit in `lib/logic/cubits/favorites_cubit.dart` that manages saved events/courses
- **AuthCubit**: Cubit in `lib/logic/cubits/auth_cubit.dart` that manages Firebase auth state and Directus token linking
- **FilterCubit**: Cubit in `lib/logic/cubits/filter_cubit.dart` that manages dance style, region, and duration type filters
- **DirectusAuthService**: Service in `lib/services/directus_auth_service.dart` that exchanges Firebase tokens for Directus session tokens
- **directusLinkedNotifier**: `ValueNotifier<bool>` on `AuthCubit` that toggles when Directus token exchange completes
- **AuthGatePage**: Shared page in `lib/shared/pages/auth_gate_page.dart` shown on protected routes for unauthenticated users

## Bug Details

### Bug Condition

The three bugs manifest during authentication state transitions:

1. **Favorites 403**: When `AuthCubit` emits `authenticated`, `FavoritesCubit._onAuthStateChanged` immediately calls `loadFavorites()`. But `DirectusClient`'s token provider calls `DirectusAuthService.getAccessToken()` which returns `null` (tokens not yet obtained), so the request goes out without an Authorization header, hitting Directus as the public role. The favorites collection has no public access → 403.

2. **No logout message**: When `AuthCubit` emits `unauthenticated` after sign-out, the `SavedRoute`/`ProfileRoute` `BlocBuilder` switches from the authenticated screen to `AuthGatePage`. The snackbar fires but the page itself gives no persistent visual confirmation.

3. **Filters not visible**: After login, `prefillFiltersFromProfile` updates `FilterCubit` state. The `BlocListener<FilterCubit>` calls `EventCubit.applyFilters()` which re-emits `EventState.loaded`. However, in `EventsListScreen`, the `FeaturedEventsSection` and `UpcomingEventsSection` read `context.read<FilterCubit>().state.selectedDanceStyles` directly (not via `BlocBuilder`), so they don't rebuild with the new filter highlight state.

**Formal Specification:**

```
FUNCTION isBugCondition1(input)
  INPUT: input of type FavoritesLoadContext
  OUTPUT: boolean
  
  RETURN input.authState = authenticated
         AND input.directusAuthService.hasTokens = false
         AND input.targetCollection = 'favorites'
END FUNCTION

FUNCTION isBugCondition2(input)
  INPUT: input of type AuthTransition
  OUTPUT: boolean
  
  RETURN input.previousState = authenticated
         AND input.currentState = unauthenticated
         AND input.trigger = 'signOut'
         AND input.currentRoute IN ['/saved', '/profile']
END FUNCTION

FUNCTION isBugCondition3(input)
  INPUT: input of type PostLoginContext
  OUTPUT: boolean
  
  RETURN input.authTransition = (unauthenticated → authenticated)
         AND input.profileHasFilterPreferences = true
         AND input.filterCubit.hasActiveFilters = false (before prefill)
END FUNCTION
```

### Examples

- **Bug 1**: User logs in → navigates to Saved tab → sees "Access denied" error because `loadFavorites()` fired with public token. Expected: loading indicator, then favorites list.
- **Bug 1**: User restarts app while logged in → `_onAuthStateChanged` fires `loadFavorites()` before `ensureDirectusLinked()` completes → same 403. Expected: wait for token, then load.
- **Bug 2**: User taps "Sign out" on Profile page → sees `AuthGatePage` with "Sign in required" and lock icon. Expected: a visible confirmation that logout succeeded.
- **Bug 3**: User logs in, profile has `danceTags: ['Salsa', 'Bachata']` and `city: 'Praha'` → events list shows all events with no filter chips highlighted. Expected: Salsa and Bachata chips highlighted, Praha region shown in header.

## Expected Behavior

### Preservation Requirements

**Unchanged Behaviors:**
- When a user is already logged in with valid Directus tokens and navigates to Saved, favorites load immediately without extra delay
- When a user is not logged in and visits /saved or /profile, the generic `AuthGatePage` with "Sign in required" is shown (no logout message)
- When a user manually selects filters via the filter UI, they are applied and displayed immediately
- Events and Courses collections continue to load immediately (public role access) without waiting for token exchange
- The existing snackbar logout message (`t.common.logoutSuccess`) continues to fire
- Mouse/touch interactions with filter chips continue to work as before
- Profile loading after login continues to work (it already waits for Directus link)

**Scope:**
All inputs that do NOT involve the specific auth transition timing issues should be completely unaffected by these fixes. This includes:
- Normal authenticated browsing (tokens already available)
- Anonymous browsing of public collections
- Manual filter selection/deselection
- Navigation between tabs when already logged in

## Hypothesized Root Cause

Based on the code analysis, the confirmed root causes are:

1. **Favorites 403 — Race condition in `_onAuthStateChanged`**:
   - `AuthCubit._onAuthStateChanged` emits `authenticated` state immediately when Firebase reports a user
   - `FavoritesCubit._onAuthStateChanged` listens to `AuthCubit.stream` and calls `loadFavorites()` on `authenticated`
   - But `ensureDirectusLinked()` is called asynchronously in `AuthCubit._onAuthStateChanged` and hasn't completed yet
   - `DirectusClient`'s interceptor calls `directusTokenProvider()` → `DirectusAuthService.getAccessToken()` → returns `null` (no tokens stored)
   - Request goes out without Authorization header → Directus treats it as public role → 403 on favorites collection

2. **No logout message — `AuthGatePage` is stateless and context-unaware**:
   - `AuthGatePage` receives only `intendedRoute` parameter
   - It has no way to know whether the user arrived here because they were never logged in, or because they just logged out
   - The snackbar fires but may be missed; the page itself shows no confirmation

3. **Filters not visible — `context.read` instead of `BlocBuilder` for filter state**:
   - In `EventsListScreen`, `FeaturedEventsSection` and `UpcomingEventsSection` receive `activeFilterCodes: context.read<FilterCubit>().state.selectedDanceStyles`
   - `context.read` does not subscribe to changes — it reads the value once at build time
   - When `prefillFiltersFromProfile` updates `FilterCubit`, the `EventCubit` re-emits (via `BlocListener`), but the filter codes passed to child sections are stale
   - The outer `BlocBuilder<FilterCubit>` only wraps the header section, not the event sections

## Correctness Properties

Property 1: Bug Condition - Favorites Wait for Directus Token

_For any_ authentication transition where `FavoritesCubit` attempts to load favorites, the cubit SHALL wait for `DirectusAuthService.hasTokens` to be true (or for `directusLinkedNotifier` to fire) before making the API call, ensuring the request uses the authenticated user token.

**Validates: Requirements 2.1**

Property 2: Bug Condition - Logout Confirmation Displayed

_For any_ sign-out transition where the user was previously authenticated and lands on `AuthGatePage`, the page SHALL display a logout success message that is visually distinct from the generic "Sign in required" state.

**Validates: Requirements 2.2**

Property 3: Bug Condition - Filters Visually Applied After Login Prefill

_For any_ login transition where profile filter preferences are prefilled into `FilterCubit`, the events list UI SHALL rebuild to reflect the active filter state (highlighted chips, filtered header) without requiring manual navigation.

**Validates: Requirements 2.3**

Property 4: Preservation - Normal Favorites Loading Unchanged

_For any_ favorites load where `DirectusAuthService.hasTokens` is already true (user already has valid tokens), the `FavoritesCubit` SHALL load favorites immediately without additional delay, preserving existing behavior.

**Validates: Requirements 3.1, 3.6**

Property 5: Preservation - Generic Auth Gate for Non-Logout

_For any_ navigation to a protected route where the user was never authenticated (no sign-out transition occurred), the `AuthGatePage` SHALL display the generic "Sign in required" message without any logout confirmation.

**Validates: Requirements 3.2**

Property 6: Preservation - Manual Filter Application Unchanged

_For any_ manual filter selection via the filter UI (not triggered by login prefill), the system SHALL continue to apply and display filters immediately as before.

**Validates: Requirements 3.3, 3.4**

## Fix Implementation

### Changes Required

#### Bug 1: Favorites Wait for Directus Token

**File**: `lib/logic/cubits/favorites_cubit.dart`

**Function**: `_onAuthStateChanged` and `loadFavorites`

**Specific Changes**:
1. **Listen to `directusLinkedNotifier`**: Instead of calling `loadFavorites()` immediately on `authenticated`, wait for the `directusLinkedNotifier` to fire (indicating Directus tokens are available).
2. **Add `directusLinkedNotifier` listener in constructor**: Subscribe to `AuthCubit.directusLinkedNotifier` and trigger `loadFavorites()` when it fires (only if authenticated).
3. **Guard `loadFavorites` with token check**: Before making the API call, check `DirectusAuthService.hasTokens`. If false, emit loading state and return (the notifier listener will retry).
4. **Remove direct `loadFavorites()` call from `_onAuthStateChanged`**: The notifier-based approach handles both fresh login and app restart scenarios.

**Implementation approach**:
```dart
// In constructor, add listener:
_directusLinkedListener = () {
  if (_authCubit.state.maybeMap(authenticated: (_) => true, orElse: () => false)) {
    loadFavorites();
  }
};
_authCubit.directusLinkedNotifier.addListener(_directusLinkedListener);

// In _onAuthStateChanged:
authenticated: (_) {
  // Don't load immediately — wait for directusLinkedNotifier
  // Only emit loading so UI shows spinner
  emit(const FavoritesState.loading());
},
```

#### Bug 2: Logout Confirmation on AuthGatePage

**File**: `lib/shared/pages/auth_gate_page.dart`

**Specific Changes**:
1. **Add `showLogoutSuccess` parameter**: A boolean flag that indicates the user just logged out.
2. **Show logout success message**: When `showLogoutSuccess` is true, display a success message (checkmark icon, green accent, "Logout was successful" text) above or instead of the generic lock icon and "Sign in required" text.
3. **Auto-dismiss**: After a few seconds or on any interaction, transition to the normal auth gate state.

**File**: `lib/core/app_routes.dart`

**Specific Changes**:
1. **Track logout state**: Add a mechanism to detect that the user just logged out. Use a simple flag on `AuthCubit` (e.g., `didJustLogOut`) that is set in `signOut()` and cleared after being consumed.
2. **Pass flag to `AuthGatePage`**: In `ProfileRoute` and `SavedRoute`, read the flag and pass `showLogoutSuccess: true` to `AuthGatePage`.

**File**: `lib/logic/cubits/auth_cubit.dart`

**Specific Changes**:
1. **Add `didJustLogOut` flag**: Set to `true` in `signOut()` before emitting loading, cleared when consumed by UI.

**Translation files** (`strings.i18n.json`, `strings_cs.i18n.json`, `strings_es.i18n.json`):
1. **Add `authGate.logoutTitle`**: "Signed out successfully" / "Odhlášení proběhlo úspěšně" / "Sesión cerrada correctamente"
2. **Add `authGate.logoutMessage`**: "You can sign in again anytime." / "Můžete se kdykoli znovu přihlásit." / "Puedes iniciar sesión de nuevo en cualquier momento."

#### Bug 3: Filters Visually Applied After Login

**File**: `lib/screens/events/events_list/events_list_screen.dart`

**Specific Changes**:
1. **Wrap event sections in `BlocBuilder<FilterCubit>`**: Move the `activeFilterCodes` parameter to be read inside a `BlocBuilder<FilterCubit, FilterState>` so it rebuilds when filter state changes.
2. **Replace `context.read<FilterCubit>().state` with builder's state**: The `FeaturedEventsSection` and `UpcomingEventsSection` already receive `activeFilterCodes` and `hasActiveFilters` — they just need to be inside a reactive builder.

**Implementation approach**:
```dart
// Current (broken):
FeaturedEventsSection(
  activeFilterCodes: context.read<FilterCubit>().state.selectedDanceStyles,
  ...
),

// Fixed:
BlocBuilder<FilterCubit, FilterState>(
  builder: (context, filterState) => Column(
    children: [
      FeaturedEventsSection(
        activeFilterCodes: filterState.selectedDanceStyles,
        ...
      ),
      UpcomingEventsSection(
        activeFilterCodes: filterState.selectedDanceStyles,
        hasActiveFilters: filterState.hasActiveFilters,
        ...
      ),
    ],
  ),
),
```

Alternatively, since there's already a `BlocBuilder<EventCubit, EventState>` wrapping the content, and `EventCubit` re-emits on filter changes, the issue is that `context.read<FilterCubit>()` captures a stale reference. Wrapping the sections that need filter state in their own `BlocBuilder<FilterCubit>` ensures reactivity.

## Testing Strategy

### Validation Approach

The testing strategy follows a two-phase approach: first, surface counterexamples that demonstrate the bugs on unfixed code, then verify the fixes work correctly and preserve existing behavior.

### Exploratory Bug Condition Checking

**Goal**: Surface counterexamples that demonstrate the bugs BEFORE implementing the fix. Confirm or refute the root cause analysis.

**Test Plan**: Write unit tests that simulate the auth state transitions and verify the timing of API calls and UI state.

**Test Cases**:
1. **Favorites Race Condition Test**: Emit `authenticated` on `AuthCubit` without completing Directus link → verify `FavoritesCubit` attempts API call → observe 403/error state (will fail on unfixed code)
2. **Logout Message Test**: Trigger sign-out → verify `AuthGatePage` shows logout confirmation (will fail on unfixed code — shows generic message)
3. **Filter Prefill Visibility Test**: Simulate login with profile preferences → verify `EventsListScreen` rebuilds with active filter codes (will fail on unfixed code — stale `context.read`)
4. **Token Timing Test**: Mock `DirectusAuthService.hasTokens = false` → call `loadFavorites()` → verify it doesn't make API call (will fail on unfixed code)

**Expected Counterexamples**:
- `FavoritesCubit` emits error state with 403 message when `loadFavorites` fires before token exchange
- `AuthGatePage` renders identical UI regardless of whether user just logged out or was never logged in
- `EventsListScreen` passes stale empty `selectedDanceStyles` to child sections after prefill

### Fix Checking

**Goal**: Verify that for all inputs where the bug condition holds, the fixed function produces the expected behavior.

**Pseudocode:**
```
FOR ALL input WHERE isBugCondition1(input) DO
  result := loadFavorites_fixed(input)
  ASSERT result.state IN {loading, loaded} AND result.state != error(403)
END FOR

FOR ALL input WHERE isBugCondition2(input) DO
  result := renderAuthGatePage_fixed(input)
  ASSERT result.showsLogoutConfirmation = true
END FOR

FOR ALL input WHERE isBugCondition3(input) DO
  result := eventsListUI_fixed(input)
  ASSERT result.activeFilterCodes = input.prefilledCodes
END FOR
```

### Preservation Checking

**Goal**: Verify that for all inputs where the bug condition does NOT hold, the fixed function produces the same result as the original function.

**Pseudocode:**
```
FOR ALL input WHERE NOT isBugCondition1(input) DO
  // User already has tokens — favorites load immediately
  ASSERT loadFavorites_original(input) = loadFavorites_fixed(input)
END FOR

FOR ALL input WHERE NOT isBugCondition2(input) DO
  // User was never logged in — generic auth gate shown
  ASSERT renderAuthGatePage_original(input) = renderAuthGatePage_fixed(input)
END FOR

FOR ALL input WHERE NOT isBugCondition3(input) DO
  // Manual filter selection — immediate application unchanged
  ASSERT eventsListUI_original(input) = eventsListUI_fixed(input)
END FOR
```

**Testing Approach**: Property-based testing is recommended for preservation checking because:
- It generates many combinations of auth states and token availability
- It catches edge cases like rapid login/logout cycles
- It provides strong guarantees that non-buggy paths are unchanged

**Test Plan**: Observe behavior on UNFIXED code first for normal operations, then write property-based tests capturing that behavior.

**Test Cases**:
1. **Normal Favorites Load Preservation**: Verify that when `hasTokens = true`, `loadFavorites()` executes immediately without delay
2. **Generic Auth Gate Preservation**: Verify that `AuthGatePage` without `showLogoutSuccess` flag shows the standard "Sign in required" UI
3. **Manual Filter Preservation**: Verify that toggling filters via `FilterCubit.toggleDanceType()` immediately reflects in `EventsListScreen`
4. **Anonymous Browsing Preservation**: Verify Events/Courses load without waiting for any token exchange

### Unit Tests

- Test `FavoritesCubit` does not call repository when `hasTokens = false`
- Test `FavoritesCubit` calls repository when `directusLinkedNotifier` fires
- Test `AuthGatePage` renders logout success UI when `showLogoutSuccess = true`
- Test `AuthGatePage` renders generic UI when `showLogoutSuccess = false`
- Test `AuthCubit.didJustLogOut` is set on sign-out and cleared after consumption
- Test `EventsListScreen` rebuilds filter codes when `FilterCubit` state changes

### Property-Based Tests

- Generate random sequences of auth state transitions and verify `FavoritesCubit` never calls API without valid tokens
- Generate random profile data (with/without dance tags, with/without city) and verify filter prefill produces correct `FilterState`
- Generate random filter states and verify `EventsListScreen` always reflects current `FilterCubit.state.selectedDanceStyles`

### Integration Tests

- Test full login flow → navigate to Saved → verify favorites load successfully
- Test logout from Profile → verify logout confirmation shown → verify can log back in
- Test login with profile preferences → verify filter chips highlighted on events page
- Test rapid login/logout/login cycle → verify no stale state
