# Requirements Document

## Introduction

This feature adds event program (schedule/timetable) editing capability to the editor's event edit form in the Dancee App. Currently, event programs are extracted automatically by the AI workflow service from scraped event descriptions, but editors have no way to manually add, edit, or remove program entries (parts) when editing an event. This feature enables editors to manage the event program directly — adding days, adding time slots within each day, naming them, assigning types, dance styles, lectors, and DJs — so that the displayed event schedule is always accurate and complete.

Programs can span multiple days (e.g., a weekend festival with Friday, Saturday, and Sunday). Each day can have multiple time entries (slots), and each entry has its own name, description, type, lectors, and DJs. The UI must present this hierarchical structure (days → time slots) clearly and intuitively.

## Glossary

- **App**: The Dancee Flutter application (mobile and web)
- **Editor**: A user with editor permissions (role = "editor" in Directus)
- **Event**: A dance event stored in Directus with metadata including a program
- **Program**: The schedule/timetable of an event, composed of one or more Program_Days, each containing one or more Program_Entries
- **Program_Day**: A logical grouping of Program_Entries that share the same date. Displayed as a card/section in the UI with a date label and its own list of entries
- **Program_Entry**: A single time slot within a Program_Day (stored as an element in the `parts` JSON array on the event). Contains a name, description, type, dance styles, time range, lectors, and DJs
- **Edit_Event_Screen**: The existing editor screen for modifying event details
- **Program_Section**: The new UI section within the Edit_Event_Screen for managing the multi-day program hierarchy
- **Directus_CMS**: The backend content management system storing all event data
- **EventPart**: The backend schema name for a Program_Entry (Zod schema: `EventPartSchema`). The `date_time_range.start` field determines which Program_Day the entry belongs to
- **Add_Day_Button**: The UI control that adds a new Program_Day to the program
- **Add_Entry_Button**: The UI control within a Program_Day that adds a new Program_Entry to that day

## Requirements

### Requirement 1: Multi-Day Program Structure Display

**User Story:** As an editor, I want to see the event program organized by day, so that I can easily understand and navigate the schedule of multi-day events.

#### Acceptance Criteria

1. WHEN the editor opens the Edit_Event_Screen for an event with existing program entries spanning multiple dates, THE App SHALL group Program_Entries by date and display them under separate Program_Day sections.
2. THE App SHALL determine the grouping date for each Program_Entry from the date component of the entry's date_time_range.start field.
3. WHEN the editor opens the Edit_Event_Screen for an event with existing program entries that have no date_time_range.start value, THE App SHALL display those entries in a separate ungrouped section at the end.
4. THE App SHALL display Program_Days in chronological order based on their date.
5. THE App SHALL display each Program_Day with a visible date label and a day number indicator (e.g., "Day 1", "Day 2").
6. WHEN the editor opens the Edit_Event_Screen for an event with no program entries, THE App SHALL display the Program_Section with an empty state and an Add_Day_Button.

### Requirement 2: Add and Remove Program Days

**User Story:** As an editor, I want to add and remove days from the event program, so that I can define the multi-day structure of the event schedule.

#### Acceptance Criteria

1. THE App SHALL display an Add_Day_Button in the Program_Section header that allows the editor to add a new Program_Day.
2. WHEN the editor taps the Add_Day_Button, THE App SHALL append a new empty Program_Day with a date picker and an empty entry list.
3. THE App SHALL allow the editor to select a date for each Program_Day using a date picker.
4. THE App SHALL display a remove button on each Program_Day card.
5. WHEN the editor taps the remove button on a Program_Day, THE App SHALL remove the day and all its Program_Entries from the program.
6. WHEN the editor removes all Program_Days, THE App SHALL display the empty state with the Add_Day_Button.

### Requirement 3: Add New Program Entry Within a Day

**User Story:** As an editor, I want to add new time slots within a specific day, so that I can build the detailed schedule for each day of the event.

#### Acceptance Criteria

1. THE App SHALL display an Add_Entry_Button within each Program_Day card.
2. WHEN the editor taps the Add_Entry_Button within a Program_Day, THE App SHALL append a new empty Program_Entry form to that day's entry list.
3. THE App SHALL allow the editor to specify the following fields for each Program_Entry: name (required), description (optional), type (required, one of: party, workshop, openLesson), start time (optional), end time (optional), lectors (optional, comma-separated list), and DJs (optional, comma-separated list).
4. WHEN the editor adds a new Program_Entry, THE App SHALL set the type field to "workshop" as the default value.
5. THE App SHALL allow each Program_Entry within the same Program_Day to have different values for name, description, type, lectors, and DJs independently.

### Requirement 4: Display Existing Program Entries Within Days

**User Story:** As an editor, I want to see the existing program entries displayed within their respective days, so that I can review and modify the current schedule in context.

#### Acceptance Criteria

1. WHEN the editor opens the Edit_Event_Screen for an event with existing program entries, THE App SHALL display each Program_Entry within its corresponding Program_Day showing the entry's name, type, start time, and end time.
2. THE App SHALL display Program_Entries within each Program_Day in chronological order based on their start time, with entries lacking a start time displayed at the end of the day.
3. THE App SHALL visually distinguish individual Program_Entries within a Program_Day using cards or bordered containers.

### Requirement 5: Edit Existing Program Entry

**User Story:** As an editor, I want to modify existing program entries, so that I can correct or update the event schedule.

#### Acceptance Criteria

1. WHILE the Edit_Event_Screen is displayed, THE App SHALL allow the editor to modify any field of any existing Program_Entry directly in the Program_Section.
2. WHEN the editor modifies a Program_Entry field, THE App SHALL update the field value immediately in the UI.
3. THE App SHALL allow the editor to modify the lectors and DJs fields of each Program_Entry independently from other entries in the same day.

### Requirement 6: Remove Program Entry

**User Story:** As an editor, I want to remove individual program entries from a day, so that I can delete incorrect or cancelled schedule items without removing the entire day.

#### Acceptance Criteria

1. THE App SHALL display a remove button on each Program_Entry within a Program_Day.
2. WHEN the editor taps the remove button on a Program_Entry, THE App SHALL remove the entry from the day's list immediately.
3. WHEN the editor removes all Program_Entries from a Program_Day, THE App SHALL keep the Program_Day visible with an empty entry list and the Add_Entry_Button.

### Requirement 7: Save Program Changes

**User Story:** As an editor, I want to save my program changes together with other event edits, so that the updated multi-day schedule is persisted to the backend.

#### Acceptance Criteria

1. WHEN the editor saves the event after modifying program entries, THE App SHALL include the updated parts array in the PATCH payload sent to Directus_CMS.
2. THE App SHALL serialize each Program_Entry into the EventPart JSON format with fields: name, description, type, dances (empty array), date_time_range (object with start and end as ISO 8601 strings or null), lectors (array of strings), and djs (array of strings).
3. THE App SHALL set the date component of date_time_range.start and date_time_range.end for each Program_Entry to the date of the Program_Day the entry belongs to.
4. IF the program entries have not been modified compared to the original event data, THEN THE App SHALL omit the parts field from the PATCH payload.
5. WHEN the editor saves program changes, THE App SHALL also include a parts_translations array in the translation payload containing the name and description of each entry for the current language.

### Requirement 8: Time Picker for Program Entry Times

**User Story:** As an editor, I want to pick start and end times for program entries using a time picker, so that I can set accurate schedule times without typing.

#### Acceptance Criteria

1. WHEN the editor taps the start time or end time field of a Program_Entry, THE App SHALL display a time picker dialog.
2. WHEN the editor selects a time from the picker, THE App SHALL update the corresponding time field with the selected value.
3. THE App SHALL combine the selected time with the Program_Day's date to form the full date_time_range value for the entry.
4. WHEN the editor clears a time field, THE App SHALL set the corresponding time value to null.

### Requirement 9: Program Entry Validation

**User Story:** As an editor, I want the app to validate program entries before saving, so that incomplete or invalid entries are not persisted.

#### Acceptance Criteria

1. WHEN the editor attempts to save the event with a Program_Entry that has an empty name field, THE App SHALL display a validation error indicating the name is required.
2. IF a Program_Entry has an end time earlier than its start time within the same Program_Day, THEN THE App SHALL display a validation error indicating the time range is invalid.
3. THE App SHALL prevent saving the event until all validation errors in the Program_Section are resolved.
4. WHEN the editor attempts to save the event with a Program_Day that has no date selected, THE App SHALL display a validation error indicating the date is required.

### Requirement 10: Clear and Intuitive Hierarchical UI

**User Story:** As an editor, I want the program editing UI to clearly show the days-to-entries hierarchy, so that I can manage complex multi-day programs without confusion.

#### Acceptance Criteria

1. THE App SHALL visually nest Program_Entries inside their parent Program_Day using indentation, card nesting, or container hierarchy consistent with the Add_Event_Screen pattern.
2. THE App SHALL display the Add_Day_Button at the Program_Section level (outside any day card) and the Add_Entry_Button inside each Program_Day card.
3. THE App SHALL use distinct visual styling for Program_Day cards versus Program_Entry cards so the hierarchy is immediately apparent.
4. THE App SHALL follow the same UI pattern as the AddEventProgramSection component used in the Add Event screen (day cards containing item cards with "Add Day" at section level and "Add Item" within each day).
