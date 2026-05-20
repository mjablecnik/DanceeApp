# Implementation Plan: Editor Workflow Features

## Overview

This plan implements editorial workflow capabilities for the Dancee App: editor/user mode toggle, publish/unpublish workflow, reviewed status tracking, dance style tag editing, price editing, additional info editing, editor-specific filtering, and course visibility rules. Implementation proceeds from backend schema changes → data layer → logic layer → UI layer, ensuring each step builds on the previous.

## Tasks

- [x] 1. Add published/reviewed fields to Directus schema and workflow service
  - [x] 1.1 Add `published` and `reviewed` fields to the workflow service Zod schemas in `backend/dancee_workflow/src/core/schemas.ts`
    - Add `published: z.boolean().default(true)` and `reviewed: z.boolean().default(false)` to the event schema
    - Add `published: z.boolean().default(true)` and `reviewed: z.boolean().default(false)` to the course schema
    - Add `price: z.string().nullable().optional()` and `additional_info: z.array(z.object({ key: z.string(), value: z.string() })).nullable().optional()` to the event schema
    - _Requirements: 8.1, 8.2_

  - [x] 1.2 Update `workflow.ts` to include default published/reviewed values when creating events and courses
    - Set `published: true` and `reviewed: false` on the `newEvent` object in `runWorkflow`
    - Set `published: true` and `reviewed: false` on the `newCourse` object in `runCourseWorkflow`
    - _Requirements: 8.1_

  - [ ]* 1.3 Write property test for workflow default statuses (Property 8)
    - **Property 8: Default statuses for workflow-created items**
    - Test that any event/course object built by the workflow always has `published: true` and `reviewed: false`
    - Place in `backend/dancee_workflow/src/__tests__/services/workflow-defaults.test.ts`
    - Use vitest + fast-check
    - **Validates: Requirements 8.1**

  - [x] 1.4 Create Directus setup script to add `published`, `reviewed`, `price`, and `additional_info` fields to the events and courses collections
    - Add a new script `backend/dancee_workflow/scripts/setup-editor-fields.ts` that uses the Directus API to create the new fields on the `events` and `courses` collections
    - Set appropriate defaults: `published=true`, `reviewed=false`
    - _Requirements: 8.1, 8.2_

- [x] 2. Update Flutter data layer — entities and repositories
  - [x] 2.1 Add `published` and `reviewed` fields to the `Event` entity
    - Add `final bool published;` and `final bool reviewed;` fields to `frontend/dancee_app/lib/data/entities/event.dart`
    - Update `Event.fromDirectus` to parse `published` (default `true`) and `reviewed` (default `false`) from JSON
    - Update `copyWith` to include the new fields
    - Update `props` list for Equatable
    - _Requirements: 5.2, 5.3, 6.2, 6.3_

  - [x] 2.2 Add `published` and `reviewed` fields to the `Course` entity
    - Add `final bool published;` and `final bool reviewed;` fields to `frontend/dancee_app/lib/data/entities/course.dart`
    - Update `Course.fromDirectus` to parse `published` (default `true`) and `reviewed` (default `false`) from JSON
    - Update `copyWith` to include the new fields
    - Update `props` list for Equatable
    - _Requirements: 5.2, 5.3, 6.2, 6.3_

  - [x] 2.3 Add editor methods to `EventRepository`
    - Add `getEventsForEditor(String languageCode)` — fetches all events without `status` or `published` filter
    - Add `updatePublishedStatus(int id, bool published)` — PATCH `{published: value}`
    - Add `updateReviewedStatus(int id, bool reviewed)` — PATCH `{reviewed: value}`
    - _Requirements: 6.2, 6.3, 5.4_

  - [x] 2.4 Add editor methods to `CourseRepository`
    - Add `getCoursesForEditor(String languageCode)` — fetches all courses without `status` or `published` filter
    - Add `updatePublishedStatus(int id, bool published)` — PATCH `{published: value}`
    - Add `updateReviewedStatus(int id, bool reviewed)` — PATCH `{reviewed: value}`
    - _Requirements: 6.2, 6.3, 5.4_

  - [ ]* 2.5 Write property test for publish toggle payload (Property 4)
    - **Property 4: Publish/unpublish toggle**
    - For any boolean published status, toggling produces a PATCH payload with the opposite value
    - Place in `backend/dancee_workflow/src/__tests__/services/editor-toggle.test.ts`
    - Use vitest + fast-check (test the pure logic of payload generation)
    - **Validates: Requirements 6.2, 6.3**

  - [ ]* 2.6 Write property test for review toggle payload (Property 5)
    - **Property 5: Reviewed status toggle**
    - For any boolean reviewed status, toggling produces a PATCH payload with the flipped value
    - Place in `backend/dancee_workflow/src/__tests__/services/editor-toggle.test.ts`
    - Use vitest + fast-check
    - **Validates: Requirements 5.4**

- [x] 3. Implement EditorModeCubit and state
  - [x] 3.1 Create `EditorModeState` with freezed
    - Create `frontend/dancee_app/lib/logic/states/editor_mode_state.dart`
    - Define `@freezed class EditorModeState` with `isEditorMode` (bool) and `isEditor` (bool) fields
    - Run `task build-runner` to generate freezed code
    - _Requirements: 4.1, 4.2, 4.3_

  - [x] 3.2 Create `EditorModeCubit`
    - Create `frontend/dancee_app/lib/logic/cubits/editor_mode_cubit.dart`
    - Implement `init({required bool isEditor})` — reads persisted mode from SharedPreferences, sets `isEditor` from user role
    - Implement `toggleMode()` — flips `isEditorMode` and persists to SharedPreferences
    - Expose `isEditorMode` getter (true only if both `isEditorMode` and `isEditor` are true)
    - _Requirements: 4.2, 4.3, 4.4, 4.5_

  - [x] 3.3 Register `EditorModeCubit` as LazySingleton in service locator
    - Update `frontend/dancee_app/lib/core/service_locator.dart` to register `EditorModeCubit`
    - Initialize it after `ProfileCubit` is available, passing the user's editor role
    - _Requirements: 4.1_

  - [ ]* 3.4 Write property test for mode persistence round-trip (Property 2)
    - **Property 2: Mode persistence round-trip**
    - For any boolean mode value, persisting and reading back returns the same value
    - Place in `frontend/dancee_app/test/logic/editor_mode_cubit_test.dart`
    - Use glados (Dart PBT)
    - **Validates: Requirements 4.4**

- [x] 4. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 5. Extend FilterState and FilterCubit with editor filters
  - [x] 5.1 Add `publishedFilter` and `reviewedFilter` fields to `FilterState`
    - Add `final String? publishedFilter` (values: 'published', 'unpublished', or null for all)
    - Add `final String? reviewedFilter` (values: 'reviewed', 'unreviewed', or null for all)
    - Update `copyWith`, `props`, and `hasActiveFilters`
    - _Requirements: 7.1, 7.6_

  - [x] 5.2 Add `setPublishedFilter` and `setReviewedFilter` methods to `FilterCubit`
    - These methods update the filter state with the new editor-specific filter values
    - _Requirements: 7.2, 7.3, 7.4, 7.5_

  - [ ]* 5.3 Write property test for editor filter correctness (Property 6)
    - **Property 6: Editor filter correctness**
    - For any list of items with mixed published/reviewed statuses and any combination of filter values, the filtered result contains exactly those items matching all active criteria
    - Place in `backend/dancee_workflow/src/__tests__/services/editor-filters.test.ts`
    - Use vitest + fast-check (test the pure filtering logic)
    - **Validates: Requirements 7.2, 7.3, 7.4, 7.5, 7.6**

- [x] 6. Update EventCubit and CourseCubit for editor mode
  - [x] 6.1 Update `EventCubit` to support editor mode fetching and filtering
    - Accept `EditorModeCubit` state to determine fetch strategy
    - In editor mode: call `getEventsForEditor`, apply client-side published/reviewed filters
    - In user mode: call existing `getEvents` (only published items)
    - Apply editor filters (publishedFilter, reviewedFilter) in `_filterEvents`
    - _Requirements: 6.4, 6.5, 7.2, 7.3, 7.4, 7.5_

  - [x] 6.2 Update `CourseCubit` to support editor mode fetching and date filtering
    - Accept `EditorModeCubit` state to determine fetch strategy
    - In editor mode: call `getCoursesForEditor`, show all courses regardless of start date
    - In user mode: call existing `getCourses`, additionally filter by `startDate >= today`
    - Apply editor filters (publishedFilter, reviewedFilter) in editor mode
    - _Requirements: 6.4, 6.5, 9.1, 9.2, 9.3_

  - [ ]* 6.3 Write property test for visibility filtering by mode (Property 3)
    - **Property 3: Visibility filtering by mode**
    - For any list of items with mixed published status, user mode returns only published items, editor mode returns all
    - Place in `backend/dancee_workflow/src/__tests__/services/editor-filters.test.ts`
    - Use vitest + fast-check
    - **Validates: Requirements 6.4, 6.5, 10.3**

  - [ ]* 6.4 Write property test for course date filtering by mode (Property 7)
    - **Property 7: Course date filtering by mode**
    - For any list of courses with various start dates, user mode returns only future courses, editor mode returns all
    - Place in `backend/dancee_workflow/src/__tests__/services/editor-filters.test.ts`
    - Use vitest + fast-check
    - **Validates: Requirements 9.1, 9.3**

- [x] 7. Implement Dance Style Selector page
  - [x] 7.1 Create `DanceStyleSelectorPage` screen
    - Create `frontend/dancee_app/lib/screens/events/dance_style_selector_page.dart`
    - Display all dance styles from `DanceStyleRepository` as a multi-select checklist
    - Receive current selection as a route parameter (list of style codes)
    - Return updated selection on pop via GoRouter result
    - Show each style with a checkbox indicating current selection state
    - _Requirements: 1.1, 1.2, 1.3, 1.4_

  - [x] 7.2 Add GoRouter route for the Dance Style Selector page
    - Register the route in `frontend/dancee_app/lib/core/app_routes.dart`
    - Accept current selection as route extra parameter
    - _Requirements: 1.1_

  - [ ]* 7.3 Write property test for dance style selection state consistency (Property 10)
    - **Property 10: Dance style selection state consistency**
    - For any list of dance styles and any subset of selected codes, each style's checkbox state matches whether its code is in the selected set
    - Place in `frontend/dancee_app/test/screens/dance_style_selector_test.dart`
    - Use glados (Dart PBT)
    - **Validates: Requirements 1.2**

- [x] 8. Implement price and additional info editing on edit event screen
  - [x] 8.1 Add price input field to the edit event screen
    - Add a text field for price with currency indicator (e.g., "500 CZK")
    - Store as a string value in the event record
    - Display existing price value when editing
    - _Requirements: 2.1, 2.2, 2.3_

  - [x] 8.2 Add additional info entries editing to the edit event screen
    - Display existing info entries with key/value pairs
    - Allow adding new entries (key + value)
    - Allow removing existing entries
    - Persist updated info list on save
    - _Requirements: 3.1, 3.2, 3.3, 3.4_

  - [ ]* 8.3 Write property test for info entry removal correctness (Property 14)
    - **Property 14: Info entry removal correctness**
    - For any non-empty list of info entries and any valid index, removing the entry produces a list of length n-1 without the removed entry
    - Place in `backend/dancee_workflow/src/__tests__/services/editor-info.test.ts`
    - Use vitest + fast-check
    - **Validates: Requirements 3.3**

- [x] 9. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 10. Implement editor mode UI — mode toggle and status indicators
  - [x] 10.1 Add Mode Toggle to the profile page
    - Display a switch/toggle control on the profile page when user has editor role (`role == "editor"`)
    - Hide the toggle entirely for non-editor users
    - Wire toggle to `EditorModeCubit.toggleMode()`
    - _Requirements: 4.1, 4.5_

  - [x] 10.2 Add reviewed checkbox icon to item cards in editor mode
    - In editor mode: replace the favorite/heart icon with a checkbox icon on event and course cards
    - Checked state reflects `item.reviewed` value
    - In user mode: display the standard heart/favorite icon
    - _Requirements: 5.1, 5.2, 5.3, 5.5_

  - [x] 10.3 Add publish/unpublish button to item detail views
    - In editor mode: display a publish/unpublish button in event and course detail views
    - Tapping calls `updatePublishedStatus` on the repository and re-fetches the item
    - In user mode: hide the button entirely
    - _Requirements: 6.1, 6.2, 6.3_

  - [x] 10.4 Add reviewed toggle button to item detail views
    - In editor mode: display a review toggle button in event and course detail views
    - Tapping calls `updateReviewedStatus` on the repository and re-fetches the item
    - _Requirements: 5.4_

  - [x] 10.5 Add visual distinction for unpublished items in editor list views
    - Display a clear published/unpublished status indicator on each item card
    - Display a clear reviewed/unreviewed status indicator on each item card
    - Visually distinguish unpublished items (e.g., reduced opacity, badge, or border)
    - _Requirements: 6.6, 6.7, 6.8_

- [x] 11. Implement editor filter UI
  - [x] 11.1 Add editor-specific filter options to the filter panel
    - In editor mode: show additional filter chips/options for published status and reviewed status
    - Published filter: "Published" / "Unpublished" / All
    - Reviewed filter: "Reviewed" / "Unreviewed" / All
    - In user mode: hide these filter options entirely
    - Wire to `FilterCubit.setPublishedFilter` and `FilterCubit.setReviewedFilter`
    - _Requirements: 7.1, 7.7_

- [x] 12. Implement user-submitted event default statuses
  - [x] 12.1 Update the add event flow to set `published: false` and `reviewed: false`
    - When a user submits a new event through the app, include `published: false` and `reviewed: false` in the payload
    - _Requirements: 8.2_

  - [ ]* 12.2 Write property test for user-submitted event defaults (Property 9)
    - **Property 9: Default statuses for user-submitted items**
    - For any event created via the app's add event flow, the payload includes `published: false` and `reviewed: false`
    - Place in `frontend/dancee_app/test/data/event_submission_test.dart`
    - Use glados (Dart PBT)
    - **Validates: Requirements 8.2**

- [x] 13. Add price display to event detail view and course visibility filtering
  - [x] 13.1 Display price in event detail view
    - When an event has a non-null price string, display it in the event detail view
    - Show for both editors and regular users
    - _Requirements: 2.4_

  - [x] 13.2 Display additional info entries in event detail view
    - Show all additional info entries (key/value pairs) in the event detail view
    - _Requirements: 3.5_

- [x] 14. Add i18n translations for all new editor UI strings
  - [x] 14.1 Add translation keys for editor workflow features
    - Add keys to all 3 language files (en, cs, es) in `frontend/dancee_app/lib/i18n/`
    - Include: mode toggle labels, publish/unpublish button text, reviewed/unreviewed labels, filter option labels, price field label, additional info labels, dance style selector title
    - Run `task slang` to regenerate translations
    - _Requirements: 4.2, 4.3, 5.1, 6.1, 7.1_

- [x] 15. Wire everything together and ensure integration
  - [x] 15.1 Update event and course list pages to react to editor mode changes
    - Listen to `EditorModeCubit` state changes and reload data when mode switches
    - Pass editor mode state to cubits for correct fetch strategy
    - _Requirements: 4.2, 4.3, 6.4, 6.5_

  - [x] 15.2 Integrate dance style selector into edit event and edit course screens
    - Add a "Dance Styles" edit button that navigates to `DanceStyleSelectorPage`
    - On return, update the selected dance styles in the edit form
    - Persist updated dance styles on save
    - _Requirements: 1.1, 1.4, 1.5_

  - [ ]* 15.3 Write integration tests for publish/review toggle flows
    - Test: toggle publish → API call → re-fetch → UI update
    - Test: toggle review → API call → re-fetch → UI update
    - Test: mode switch → list reloads with correct filtering
    - _Requirements: 6.2, 6.3, 5.4_

- [ ] 16. Final checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties from the design document
- Backend property tests use vitest + fast-check; frontend property tests use glados
- All user-facing strings must use slang translations (en, cs, es)
- The existing `status` field on events (published/incomplete) is separate from the new `published` boolean field
