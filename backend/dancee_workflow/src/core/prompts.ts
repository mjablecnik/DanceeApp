export function getEventTypeClassificationPrompt(): string {
  return `You are an expert in dance events. Your task is to classify the type of a dance event based on its description.

Classify the event into exactly one of the following types:
- party: A social dance party or ball
- workshop: A dance workshop or masterclass
- lesson: A regular dance lesson or class
- course: A multi-session dance course
- festival: A dance festival spanning multiple days
- holiday: A dance holiday or dance camp
- other: Any other type of event that does not fit the above categories

Respond with only the type name (lowercase), nothing else.`;
}

export function getEventPartsExtractionPrompt(outputLanguage: string, eventStartTime: string, eventEndTime: string | null, danceStyleCodes: string[] = []): string {
  const timeContext = eventEndTime
    ? `The event starts at ${eventStartTime} and ends at ${eventEndTime}.`
    : `The event starts at ${eventStartTime}.`;

  const danceStyleContext = danceStyleCodes.length > 0
    ? `\nAvailable dance style codes: ${danceStyleCodes.join(", ")}`
    : "";

  return `You are an expert in dance events. Your task is to extract structured information from a dance event description.

${timeContext}
All part times MUST fall within the event's start and end time range. Do NOT invent dates from the description text — use the provided event times as reference.${danceStyleContext}

Extract the event into a JSON object with the following structure:
{
  "title": "string - event title in ${outputLanguage}",
  "description": "string - concise event description in ${outputLanguage}",
  "parts": [
    {
      "name": "string - part name in ${outputLanguage}",
      "description": "string - part description in ${outputLanguage}",
      "type": "party | workshop | openLesson",
      "dances": ["string - dance style codes ordered by relevance (most prominent first)"],
      "date_time_range": {
        "start": "ISO 8601 datetime string (same date as event) or null if unknown",
        "end": "ISO 8601 datetime string (same date as event) or null if unknown"
      },
      "lectors": ["string - lector names (keep original names)"],
      "djs": ["string - DJ names (keep original names)"]
    }
  ]
}

Important rules:
- Output title and description in ${outputLanguage}
- Output part names and descriptions in ${outputLanguage}
- For dances, use only dance style codes from the available list above; if no list is provided, use the original dance names
- Order dances by relevance (most prominent dance style first)
- Part date_time_range values MUST use the same date as the event start time (${eventStartTime})
- If the description mentions specific hours (e.g. "20:00-02:00"), combine them with the event date
- If no specific times are mentioned for a part, set date_time_range start and end to null
- If no specific parts can be identified, create one part representing the whole event
- Respond with only valid JSON, no markdown fences or additional text`;
}

export function getEventInfoExtractionPrompt(): string {
  return `You are an expert in dance events. Your task is to extract additional information (prices, registration URLs, dresscode) from a dance event description.

Extract the event info into a JSON array with the following structure:
[
  {
    "type": "url | price | dresscode",
    "key": "string - label describing the info item (e.g., 'Registration', 'Early bird price', 'Dresscode')",
    "value": "string - the actual URL, price, or dresscode value"
  }
]

Examples:
- { "type": "url", "key": "Registration", "value": "https://example.com/register" }
- { "type": "price", "key": "Early bird price", "value": "500 CZK" }
- { "type": "dresscode", "key": "Dresscode", "value": "Elegant / semi-formal" }

Important rules:
- Only include items with non-empty values
- For URLs, include the full URL as the value
- For prices, include the full price string including currency
- For dresscode, extract the dress code or clothing requirements from the event description
- If no dresscode information is found, do not include a dresscode item
- Do not include empty or null values
- Respond with only valid JSON, no markdown fences or additional text
- If no relevant info is found, respond with an empty array []`;
}

export function getTranslationPrompt(targetLanguage: string): string {
  return `You are a professional translator specializing in dance events. Translate the provided event content into ${targetLanguage}.

You will receive a JSON object with the following structure:
{
  "title": "string",
  "description": "string",
  "parts_translations": [
    {
      "name": "string",
      "description": "string"
    }
  ],
  "info_translations": [
    {
      "key": "string"
    }
  ]
}

Translate all text fields into ${targetLanguage} and return the same JSON structure.

Important rules:
- Translate: title, description, part names, part descriptions, and info keys
- Do NOT translate: dates, times, coordinates, URLs, price values, dance names, lector names, DJ names, organizer names, venue names
- Preserve the exact JSON structure including all field names
- Preserve all array lengths (parts_translations and info_translations must have the same number of items as the input)
- Respond with only valid JSON, no markdown fences or additional text`;
}

export function getCourseExtractionPrompt(outputLanguage: string, eventStartTime: string, eventEndTime: string | null, danceStyleCodes: string[] = []): string {
  const timeContext = eventEndTime
    ? `The course starts at ${eventStartTime} and ends at ${eventEndTime}.`
    : `The course starts at ${eventStartTime}.`;

  const danceStyleContext = danceStyleCodes.length > 0
    ? `\nAvailable dance style codes: ${danceStyleCodes.join(", ")}`
    : "";

  return `You are an expert in dance courses. Your task is to extract structured course information from a dance event description.

${timeContext}
This event has been classified as a course or lesson (a multi-session or recurring dance class).${danceStyleContext}

Extract the course data into a JSON object with the following structure:
{
  "title": "string - course title in ${outputLanguage}",
  "description": "string - full course description in ${outputLanguage}",
  "instructor_name": "string or null - name of the instructor/teacher",
  "level": "beginner | intermediate | advanced | all_levels",
  "schedule_day": "string or null - day(s) of the week the course takes place (e.g. 'Tuesday')",
  "schedule_time": "string or null - time range of each lesson (e.g. '19:00 - 20:30')",
  "lesson_count": "integer or null - total number of lessons in the course",
  "lesson_duration_minutes": "integer or null - duration of each lesson in minutes",
  "max_participants": "integer or null - maximum number of participants",
  "price": "string or null - price of the course including currency",
  "price_note": "string or null - additional pricing notes (e.g. early bird, per lesson)",
  "learning_items": ["string - skill or topic taught in this course, in ${outputLanguage}"],
  "registration_url": "string or null - URL for course registration/sign-up if found in the description",
  "dances": ["string - dance style codes ordered by relevance (most prominent first)"]
}

Important rules:
- Output title, description, and learning_items in ${outputLanguage}
- For dances, use only dance style codes from the available list above; if no list is provided, use the original dance names
- Order dances by relevance (most prominent dance style first)
- If instructor name cannot be determined, set instructor_name to null
- Default level to "all_levels" if not explicitly mentioned
- learning_items should be a list of specific skills, techniques, or topics students will learn
- If no learning items can be extracted, return an empty array []
- Respond with only valid JSON, no markdown fences or additional text`;
}

export function getTranslationPromptForCourse(targetLanguage: string): string {
  return `You are a professional translator specializing in dance courses. Translate the provided course content into ${targetLanguage}.

You will receive a JSON object with the following structure:
{
  "title": "string",
  "description": "string",
  "learning_items": ["string"]
}

Translate all text fields into ${targetLanguage} and return the same JSON structure.

Important rules:
- Translate: title, description, and all items in the learning_items array
- Do NOT translate: dance names, instructor names, prices, dates, times, or URLs
- Preserve the exact JSON structure including all field names
- Respond with only valid JSON, no markdown fences or additional text`;
}

export function getImageGenerationPrompt(title: string, primaryDance: string, eventType: string): string {
  return `Create a vibrant, professional photograph-style image for a dance event.

Event context (for visual style reference only — do NOT include any text):
- Event title: ${title}
- Primary dance style: ${primaryDance}
- Event type: ${eventType}

The image should:
- Visually represent the ${primaryDance} dance style through dancers and movement
- Be energetic, colorful, and appealing to dancers
- Feature dancers or dance-related imagery in action
- Have a professional, modern aesthetic suitable for event promotion
- ABSOLUTELY NO TEXT, NO WORDS, NO LETTERS, NO TITLES, NO CAPTIONS, NO WATERMARKS anywhere in the image
- Pure visual content only — treat this as a background/hero image where text will be overlaid by the app`;
}
