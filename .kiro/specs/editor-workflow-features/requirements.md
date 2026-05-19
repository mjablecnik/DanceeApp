# Requirements Document

## Introduction

This feature adds comprehensive editor workflow capabilities to the Dancee App. It introduces an editor/user mode toggle, publish/unpublish workflow, reviewed/unreviewed status tracking, dance style tag editing from a centralized list, price editing for events, additional info editing, editor-specific filtering, and course visibility rules for regular users. These features enable editors to manage content quality and publication lifecycle while keeping the user experience clean and focused on published content.

## Glossary

- **App**: The Dancee Flutter application (mobile and web)
- **Editor**: A user with editor permissions (role = "editor" in Directus)
- **User**: A regular user without editor permissions
- **Item**: A collective term for both events and courses in the system
- **Event**: A dance event with a start time, venue, and associated metadata
- **Course**: A dance course with schedule, instructor, and curriculum information
- **Dance_Style_Selector**: A page displaying all available dance styles as a multi-select checklist
- **Mode_Toggle**: A UI control in the profile that switches between Editor and User modes
- **Reviewed_Status**: A boolean flag indicating whether an editor has reviewed an item
- **Published_Status**: A boolean flag indicating whether an item is visible to regular users
- **Filter_Panel**: The existing filter UI extended with editor-specific filter options
- **Directus_CMS**: The backend content management system storing all items

## Requirements

### Requirement 1: Dance Style Tag Editing

**User Story:** As an editor, I want to select dance styles from a centralized list when editing an event or course, so that dance style tags are consistent across all items.

#### Acceptance Criteria

1. WHEN the editor taps the dance style edit button on the edit event or edit course screen, THE App SHALL navigate to the Dance_Style_Selector page displaying all available dance styles from Directus_CMS.
2. WHILE the Dance_Style_Selector page is displayed, THE App SHALL show each dance style with a checkbox indicating its current selection state.
3. WHEN the editor checks or unchecks a dance style on the Dance_Style_Selector page, THE App SHALL update the selection state immediately in the UI.
4. WHEN the editor navigates back from the Dance_Style_Selector page, THE App SHALL display the selected dance styles as tags in the edit detail screen.
5. WHEN the editor saves the item after modifying dance styles, THE App SHALL persist the updated dance style list to Directus_CMS.

### Requirement 2: Event Price Editing

**User Story:** As an editor, I want to set a price for events including the currency, so that users can see event pricing information.

#### Acceptance Criteria

1. WHEN the editor opens the edit event screen, THE App SHALL display a price input field and a currency indicator.
2. THE App SHALL store the price as a string value together with the currency (e.g., "500 CZK", "25 EUR").
3. WHEN the editor enters a price value and saves, THE App SHALL persist the price string to the event record in Directus_CMS.
4. WHEN a price is set for an event, THE App SHALL display the price in the event detail view for both editors and users.

### Requirement 3: Additional Information Editing

**User Story:** As an editor, I want to add optional additional information fields to events, so that I can provide extra context like dress code or special notes.

#### Acceptance Criteria

1. WHEN the editor opens the edit event screen, THE App SHALL display the existing additional info entries and an option to add new entries.
2. WHEN the editor adds a new info entry, THE App SHALL allow specifying a key (label) and a value for the entry.
3. WHEN the editor removes an existing info entry, THE App SHALL remove the entry from the list.
4. WHEN the editor saves the event with modified info entries, THE App SHALL persist the updated info list to Directus_CMS.
5. THE App SHALL display all additional info entries in the event detail view.

### Requirement 4: Editor/User Mode Toggle

**User Story:** As an editor, I want to switch between Editor and User modes in my profile, so that I can preview the app as a regular user or work in editor mode.

#### Acceptance Criteria

1. WHILE the logged-in user has editor permissions, THE App SHALL display a Mode_Toggle control on the profile page.
2. WHEN the editor activates User mode via the Mode_Toggle, THE App SHALL display the app as a regular user would see it (hiding editor-specific controls and showing only published items).
3. WHEN the editor activates Editor mode via the Mode_Toggle, THE App SHALL display editor-specific controls including reviewed status, publish/unpublish buttons, and editor filters.
4. THE App SHALL persist the selected mode locally so it is retained across app restarts.
5. WHILE the user does not have editor permissions, THE App SHALL hide the Mode_Toggle control entirely.

### Requirement 5: Reviewed/Checked Status

**User Story:** As an editor, I want to mark items as reviewed or unreviewed, so that I can track which items I have already checked for quality.

#### Acceptance Criteria

1. WHILE the app is in Editor mode, THE App SHALL display a checkbox icon on each item in the list view instead of the favorite/heart icon.
2. WHEN the checkbox icon is checked, THE App SHALL indicate that the item has been reviewed by an editor.
3. WHEN the checkbox icon is unchecked, THE App SHALL indicate that the item has not yet been reviewed.
4. WHEN the editor taps the review button in the item detail view, THE App SHALL toggle the reviewed status and persist the change to Directus_CMS.
5. WHILE the app is in User mode, THE App SHALL hide the reviewed status indicator and display the standard favorite/heart icon.
6. THE App SHALL set the reviewed status to false (unreviewed) for all newly created items by default.

### Requirement 6: Publish/Unpublish Workflow

**User Story:** As an editor, I want to publish or unpublish items, so that I can control which content is visible to regular users.

#### Acceptance Criteria

1. WHILE the app is in Editor mode, THE App SHALL display a publish/unpublish button in the item detail view.
2. WHEN the editor taps the publish button on an unpublished item, THE App SHALL set the item status to published and persist the change to Directus_CMS.
3. WHEN the editor taps the unpublish button on a published item, THE App SHALL set the item status to unpublished and persist the change to Directus_CMS.
4. WHILE the app is in Editor mode, THE App SHALL display both published and unpublished items in list views.
5. WHILE the app is in User mode, THE App SHALL display only published items in list views.
6. THE App SHALL visually distinguish unpublished items from published items in editor list views.
7. WHILE the app is in Editor mode, THE App SHALL display a clear published/unpublished status indicator on each item card in the list view.
8. WHILE the app is in Editor mode, THE App SHALL display a clear reviewed/unreviewed status indicator on each item card in the list view.

### Requirement 7: Editor Filtering

**User Story:** As an editor, I want to filter items by published/unpublished and reviewed/unreviewed status, so that I can quickly find items that need attention.

#### Acceptance Criteria

1. WHILE the app is in Editor mode, THE Filter_Panel SHALL display additional filter options for published status (published/unpublished) and reviewed status (reviewed/unreviewed).
2. WHEN the editor selects the "unpublished" filter, THE App SHALL display only unpublished items in the list.
3. WHEN the editor selects the "published" filter, THE App SHALL display only published items in the list.
4. WHEN the editor selects the "unreviewed" filter, THE App SHALL display only items that have not been reviewed.
5. WHEN the editor selects the "reviewed" filter, THE App SHALL display only items that have been reviewed.
6. THE App SHALL support combining published status and reviewed status filters simultaneously.
7. WHILE the app is in User mode, THE Filter_Panel SHALL hide the editor-specific filter options.

### Requirement 8: Default Status Logic

**User Story:** As a system administrator, I want newly ingested items to have correct default statuses, so that the editorial workflow is consistent.

#### Acceptance Criteria

1. WHEN a new event is scraped from Facebook by the workflow service, THE Directus_CMS SHALL store the event with published status set to true and reviewed status set to false.
2. WHEN a user submits a new event through the app, THE Directus_CMS SHALL store the event with published status set to false and reviewed status set to false.
3. WHEN an editor sets an item to unpublished and reviewed, THE App SHALL treat the item as "pulled down for fixing" (editor found issues).
4. WHEN an item has published status set to true and reviewed status set to true, THE App SHALL treat the item as fully approved content.

### Requirement 9: Course Visibility for Users

**User Story:** As a user, I want to see only courses that have not started yet, so that I only browse courses I can still join.

#### Acceptance Criteria

1. WHILE the app is in User mode, THE App SHALL display only courses whose start date is in the future (today or later).
2. WHILE the app is in User mode, THE App SHALL hide courses whose start date has already passed, even if the course end date is in the future.
3. WHILE the app is in Editor mode, THE App SHALL display all courses regardless of their start date.

### Requirement 10: User Visibility of Statuses

**User Story:** As a user, I want to see only published content without any editorial metadata, so that my experience is clean and focused on available events and courses.

#### Acceptance Criteria

1. WHILE the app is in User mode, THE App SHALL hide the reviewed status from all item views.
2. WHILE the app is in User mode, THE App SHALL hide the publish/unpublish controls from all item views.
3. WHILE the app is in User mode, THE App SHALL display only items with published status set to true.
4. THE App SHALL display the favorite/heart functionality for users regardless of the item's reviewed status.
