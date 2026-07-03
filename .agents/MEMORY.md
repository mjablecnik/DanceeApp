# Memory

## facebook-event-scraper missing dist/
- Project: backend/dancee_workflow
- Problem: The `facebook-event-scraper` dependency is installed from GitHub (not npm). It has no pre-built `dist/` folder, so vitest/vite can't resolve the package entry and `api.test.ts` fails with "Failed to resolve entry for package". The Dockerfile already handles this with `RUN cd node_modules/facebook-event-scraper && /app/node_modules/.bin/tsc`.
- Solution: Run `npx tsc` from inside `node_modules/facebook-event-scraper/` to build the package locally before running tests.
- Source: check-build, 2026-07-03

## CourseExtractionSchema registration_url was required but tests omit it
- Project: backend/dancee_workflow
- Problem: `registration_url: z.string().nullable()` was not `.optional()`, so all CourseExtractionSchema tests that didn't include the field failed with `result.success === false`.
- Solution: Changed to `z.string().nullable().optional()` in `src/core/schemas.ts`.
- Source: check-build, 2026-07-03

## generateAiImage used OpenRouter chat modality instead of images.generate
- Project: backend/dancee_workflow
- Problem: `src/services/image-processor.ts` used `openai.chat.completions.create` with `modalities: ["image"]` (OpenRouter-specific). Tests mocked `openai.images.generate` and expected `{ data: [{ b64_json }] }` format. Also: error message was "no valid image data" vs expected "no image data"; upload used `.png`/`image/png` but tests expected `.jpg`/`image/jpeg`.
- Solution: Replaced implementation with `openai.images.generate({ response_format: "b64_json" })` and fixed error message and filename.
- Source: check-build, 2026-07-03
