# Profile Page Completion Bugfix Design

## Overview

The `ProfileScreen` build method only renders 2 of 7 sections (Settings and Danger Zone/Logout). Five existing section widgets (`ProfileCardSection`, `AccountSection`, `PremiumBanner`, `SupportSection`, `AppInfoSection`) are fully implemented but never instantiated in the screen's widget tree. Additionally, `SettingsSection` is missing a Notifications toggle, and the `BackButtonHeader` lacks a trailing edit icon button. The fix wires all sections into the build method in design-specified order, adds the missing Notifications toggle, and passes an edit icon as the header's `trailing` widget.

## Glossary

- **Bug_Condition (C)**: The condition that triggers the bug — when the ProfileScreen is opened and sections are missing from the rendered widget tree despite their widgets existing as files
- **Property (P)**: The desired behavior — all 7 sections render in the correct order with proper data and navigation callbacks
- **Preservation**: Existing logout, delete account, language picker, back navigation, error banner, and loading overlay behavior that must remain unchanged
- **ProfileScreen**: The `StatefulWidget` in `lib/screens/profile/profile/profile_screen.dart` that renders the user's profile page
- **UserRepository**: The data class in `lib/data/user_repository.dart` that provides `getCurrentUser()` returning `UserData` with name, email, avatarUrl, and danceTags
- **BackButtonHeader**: Shared component in `lib/shared/components/back_button_header.dart` that accepts an optional `trailing` widget

## Bug Details

### Fault Condition

The bug manifests when a user opens the ProfileScreen. The `build` method's `Column` children list only contains `SettingsSection` and `LogoutSection`, omitting `ProfileCardSection`, `AccountSection`, `PremiumBanner`, `SupportSection`, and `AppInfoSection`. Additionally, `SettingsSection` only renders a language picker (no Notifications toggle), and `BackButtonHeader` is called without a `trailing` widget.

**Formal Specification:**
```
FUNCTION isBugCondition(input)
  INPUT: input of type ProfileScreenRenderState
  OUTPUT: boolean

  LET renderedSections = input.profileScreen.build().scrollableChildren
  LET expectedSections = [ProfileCardSection, AccountSection, SettingsSection,
                          PremiumBanner, SupportSection, AppInfoSection, LogoutSection]

  RETURN LENGTH(renderedSections) < LENGTH(expectedSections)
         OR NOT settingsSectionContainsNotificationsToggle(renderedSections)
         OR NOT headerHasTrailingEditIcon(input.profileScreen.build().header)
END FUNCTION
```

### Examples

- User opens Profile → sees only Language picker and Logout/Delete buttons; expected: all 7 sections visible
- User opens Profile → header shows only back button and title; expected: edit icon on the right side
- User opens Profile → Settings section shows only Language row; expected: Language row AND Notifications toggle
- User opens Profile → no profile card with name/email/avatar visible; expected: `ProfileCardSection` at top with user data
- User opens Profile → no Premium banner visible; expected: `PremiumBanner` between Settings and Support sections

## Expected Behavior

### Preservation Requirements

**Unchanged Behaviors:**
- Logout button shows confirmation dialog and signs out user upon confirmation via `AuthCubit.signOut()`
- Delete Account button shows confirmation dialog, requests re-authentication for email providers, and deletes account via `AuthCubit.deleteAccount()`
- Language picker in Settings section opens dialog and updates locale via `SettingsCubit.setLanguage()`
- Back button in header navigates back via `context.pop()`
- Auth error banner displays above the Danger Zone section when `_authError` is non-null
- Loading overlay with `AbsorbPointer` and `CircularProgressIndicator` displays during async auth operations
- `BlocConsumer<AuthCubit, AuthState>` listener redirects to `LoginRoute` on unauthenticated state

**Scope:**
All inputs that do NOT involve the missing sections should be completely unaffected by this fix. This includes:
- All auth-related flows (logout, delete account, re-authentication dialog)
- Language selection behavior
- Back navigation
- Error display and loading states
- The internal structure of each existing section widget (they are already built correctly)

## Hypothesized Root Cause

Based on the code analysis, the root causes are clear and confirmed:

1. **Incomplete Build Method**: The `ProfileScreen.build()` method's `Column` children list was never updated to include all section widgets. Only `SettingsSection` and `LogoutSection` are instantiated. The other 5 widgets exist as files but are not imported or used.

2. **Missing Imports**: `profile_screen.dart` only imports `settings_section.dart` and `logout_section.dart`. It does not import `profile_card_section.dart`, `account_section.dart`, `support_section.dart`, `app_info_section.dart`, or `premium_banner.dart`.

3. **No Data Loading**: The screen does not call `UserRepository.getCurrentUser()` to fetch user data needed by `ProfileCardSection`. A `FutureBuilder` or `initState` fetch is needed.

4. **Missing Notifications Toggle in SettingsSection**: The `SettingsSection.build()` only renders a single `ProfileMenuItem` for language. No notifications toggle row exists.

5. **Missing Trailing Widget in Header**: `BackButtonHeader` is called without the `trailing` parameter, so no edit icon renders on the right side of the header.

## Correctness Properties

Property 1: Fault Condition - All Profile Sections Rendered

_For any_ ProfileScreen render where the screen is opened by an authenticated user, the fixed build method SHALL render all 7 sections in order: ProfileCardSection, AccountSection, SettingsSection, PremiumBanner, SupportSection, AppInfoSection, and LogoutSection, with proper section labels, data bindings, and navigation callbacks.

**Validates: Requirements 2.1, 2.2, 2.3, 2.4, 2.5, 2.6**

Property 2: Preservation - Existing Auth and Settings Behavior

_For any_ interaction that does NOT involve the newly added sections (logout, delete account, language change, back navigation, error display, loading overlay), the fixed code SHALL produce exactly the same behavior as the original code, preserving all existing functionality for auth flows, settings, and navigation.

**Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5, 3.6**

## Fix Implementation

### Changes Required

**File**: `frontend/dancee_app/lib/screens/profile/profile/profile_screen.dart`

**Function**: `_ProfileScreenState.build()`

**Specific Changes**:
1. **Add Missing Imports**: Import `profile_card_section.dart`, `account_section.dart`, `support_section.dart`, `app_info_section.dart`, `premium_banner.dart`, and `user_repository.dart`
2. **Add User Data Loading**: Add a `_userData` field and load it in `initState()` via `UserRepository().getCurrentUser()`, using `setState` to trigger rebuild
3. **Add Trailing Edit Icon to Header**: Pass a `trailing` widget to `BackButtonHeader` — a circular icon button with `Icons.edit` (or `FontAwesomeIcons.pen`) that navigates to `ProfileEditRoute`
4. **Wire ProfileCardSection**: Add it as the first section in the scrollable column, passing `name`, `email`, `avatarUrl`, and `danceTags` from loaded `UserData`
5. **Wire AccountSection**: Add it after the profile card with `SectionLabel` for account, passing `onEditProfile: () => const ProfileEditRoute().push(context)` and `onChangePassword: () => const ChangePasswordRoute().push(context)`
6. **Move SettingsSection**: Keep it in its current position (after Account) with its existing `SectionLabel`
7. **Wire PremiumBanner**: Add it after Settings with `onTap: () => const PremiumRoute().push(context)`
8. **Wire SupportSection**: Add it after Premium with `SectionLabel` for support, passing `onContactAuthor: () => const AuthorContactRoute().push(context)`
9. **Wire AppInfoSection**: Add it after Support with `SectionLabel` for app info
10. **Keep LogoutSection**: Keep it in its current position (last) with its existing Danger Zone label and error banner

**File**: `frontend/dancee_app/lib/screens/profile/profile/sections/settings_section.dart`

**Function**: `SettingsSection.build()`

**Specific Changes**:
1. **Add Notifications Toggle**: Add a second `ProfileMenuItem` (or a `SwitchListTile`-style row) below the language row with a bell icon and a toggle switch for notifications
2. **Add Divider**: Set `showDivider: true` on the language row since it now has a sibling below it
3. **Wrap in Column**: The current single `ProfileMenuItem` needs to become a `Column` with both the language row and the notifications toggle row

## Testing Strategy

### Validation Approach

The testing strategy follows a two-phase approach: first, surface counterexamples that demonstrate the bug on unfixed code, then verify the fix works correctly and preserves existing behavior.

### Exploratory Fault Condition Checking

**Goal**: Surface counterexamples that demonstrate the bug BEFORE implementing the fix. Confirm the root cause analysis by verifying that sections are missing from the widget tree.

**Test Plan**: Write widget tests that pump `ProfileScreen` with required providers (`AuthCubit`, `SettingsCubit`) and assert the presence of each section widget type in the widget tree. Run on UNFIXED code to observe failures.

**Test Cases**:
1. **Missing ProfileCardSection Test**: Pump ProfileScreen, `find.byType(ProfileCardSection)` → expects 1, will find 0 on unfixed code
2. **Missing AccountSection Test**: Pump ProfileScreen, `find.byType(AccountSection)` → expects 1, will find 0 on unfixed code
3. **Missing PremiumBanner Test**: Pump ProfileScreen, `find.byType(PremiumBanner)` → expects 1, will find 0 on unfixed code
4. **Missing SupportSection Test**: Pump ProfileScreen, `find.byType(SupportSection)` → expects 1, will find 0 on unfixed code
5. **Missing AppInfoSection Test**: Pump ProfileScreen, `find.byType(AppInfoSection)` → expects 1, will find 0 on unfixed code
6. **Missing Header Edit Icon Test**: Pump ProfileScreen, find edit icon in header trailing position → will find 0 on unfixed code
7. **Missing Notifications Toggle Test**: Pump ProfileScreen, find notifications toggle in SettingsSection → will find 0 on unfixed code

**Expected Counterexamples**:
- `find.byType(ProfileCardSection)` returns 0 widgets (not imported, not in build tree)
- `find.byType(AccountSection)` returns 0 widgets
- No trailing widget rendered in BackButtonHeader

### Fix Checking

**Goal**: Verify that for all inputs where the bug condition holds, the fixed function produces the expected behavior.

**Pseudocode:**
```
FOR ALL input WHERE isBugCondition(input) DO
  result := buildProfileScreen_fixed(input)
  ASSERT result.containsAllSections([ProfileCardSection, AccountSection,
         SettingsSection, PremiumBanner, SupportSection, AppInfoSection, LogoutSection])
  ASSERT result.sectionOrder == expectedOrder
  ASSERT result.header.trailing IS editIconButton
  ASSERT result.settingsSection.contains(notificationsToggle)
END FOR
```

### Preservation Checking

**Goal**: Verify that for all inputs where the bug condition does NOT hold, the fixed function produces the same result as the original function.

**Pseudocode:**
```
FOR ALL input WHERE NOT isBugCondition(input) DO
  ASSERT buildProfileScreen_original(input).logoutBehavior == buildProfileScreen_fixed(input).logoutBehavior
  ASSERT buildProfileScreen_original(input).deleteAccountBehavior == buildProfileScreen_fixed(input).deleteAccountBehavior
  ASSERT buildProfileScreen_original(input).languagePickerBehavior == buildProfileScreen_fixed(input).languagePickerBehavior
  ASSERT buildProfileScreen_original(input).backNavigationBehavior == buildProfileScreen_fixed(input).backNavigationBehavior
END FOR
```

**Testing Approach**: Widget tests with mocked cubits are the primary approach since this is a pure UI wiring bug. Property-based testing has limited applicability here because the bug is about missing widget instantiation rather than data transformation logic. However, parameterized tests across different user data shapes can verify the ProfileCardSection renders correctly for various inputs.

**Test Cases**:
1. **Logout Preservation**: Tap logout button → verify confirmation dialog appears and `AuthCubit.signOut()` is called on confirmation (same as before fix)
2. **Delete Account Preservation**: Tap delete account → verify confirmation dialog and re-auth flow works (same as before fix)
3. **Language Picker Preservation**: Tap language row → verify dialog opens and `SettingsCubit.setLanguage()` is called on selection (same as before fix)
4. **Back Navigation Preservation**: Tap back button → verify `context.pop()` is called (same as before fix)
5. **Error Banner Preservation**: Set `_authError` state → verify error banner renders above Danger Zone (same as before fix)
6. **Loading Overlay Preservation**: Set loading auth state → verify overlay with progress indicator renders (same as before fix)

### Unit Tests

- Test that ProfileScreen widget tree contains all 7 section widget types
- Test that section order matches design specification
- Test that ProfileCardSection receives correct data from UserRepository
- Test that AccountSection navigation callbacks route to correct destinations
- Test that PremiumBanner onTap routes to PremiumRoute
- Test that SupportSection onContactAuthor routes to AuthorContactRoute
- Test that BackButtonHeader trailing edit icon routes to ProfileEditRoute
- Test that SettingsSection contains both language picker and notifications toggle
- Test edge case: UserRepository returns user with empty danceTags list
- Test edge case: UserRepository returns user with null avatarUrl

### Property-Based Tests

- Generate random UserData (varying name lengths, email formats, 0-10 dance tags, nullable fields) and verify ProfileCardSection renders without errors for all inputs
- Generate random notification toggle states and verify SettingsSection renders correctly

### Integration Tests

- Test full profile screen flow: open screen → verify all sections visible → tap Edit Profile → verify navigation to ProfileEditRoute
- Test full profile screen flow: open screen → tap Change Password → verify navigation to ChangePasswordRoute
- Test full profile screen flow: open screen → tap Premium banner → verify navigation to PremiumRoute
- Test full profile screen flow: open screen → tap Contact Author → verify navigation to AuthorContactRoute
- Test full profile screen flow: open screen → toggle notifications → verify state updates
