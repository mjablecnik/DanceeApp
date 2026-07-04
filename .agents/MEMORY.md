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

## Flutter SDK root-owned: requires writable wrapper directory
- Project: frontend/dancee_app
- Problem: `/opt/flutter` is owned by root. `flutter` always tries to write to its cache (engine.stamp, package_config.json, downloads, artifacts). All flutter commands fail with "Permission denied".
- Solution: Create `/tmp/flutter_root/` as a writable wrapper: copy the `bin/flutter` shell script there, symlink all top-level SDK directories, then make `bin/cache/` and `packages/flutter_tools/.dart_tool/` real writable directories. Add `/tmp/flutter_root/bin` to PATH. Copy needed artifacts manually (material_fonts, linux-x64 engine binaries, flutter_patched_sdk, shader_lib).
- Source: check-build, 2026-07-03

## Flutter widget tests need compiled shaders in build/unit_test_assets/shaders/
- Project: frontend/dancee_app
- Problem: Widget tests using Material widgets (MaterialApp / MaterialApp.router) fail with `Exception: Asset 'shaders/ink_sparkle.frag' not found` when an InkWell animation is triggered. The `build/unit_test_assets/shaders/` directory was empty.
- Solution: Compile shaders from `/opt/flutter/packages/flutter/lib/src/material/shaders/` using `impellerc` with `--runtime-stage-vulkan --iplr` flags. Both `ink_sparkle.frag` and `stretch_effect.frag` need to be compiled:
  ```bash
  impellerc --runtime-stage-vulkan --iplr --input=<sdk>/shaders/ink_sparkle.frag --sl=build/unit_test_assets/shaders/ink_sparkle.frag --spirv=/tmp/x.spirv --input-type=frag --include=<sdk>/engine/linux-x64/shader_lib
  ```
- Source: check-build, 2026-07-03

## Docker uses Flutter 3.29.2; activeThumbColor not available until 3.32.0
- Project: frontend/dancee_app
- Problem: The Dockerfile uses `ghcr.io/cirruslabs/flutter:3.29.2` for the web build. The `Switch.activeThumbColor` parameter was only introduced in Flutter 3.32.0+. Using it breaks the Docker web build even though it's the replacement for the deprecated `Switch.activeColor`.
- Solution: Keep `activeColor` on Switch widgets. Do NOT change it to `activeThumbColor` despite the deprecation warning — the Docker build uses an older SDK.
- Source: check-build, 2026-07-03

## cp -al fails on Docker overlay filesystem
- Project: frontend/dancee_app
- Problem: `cp -al` (hard link copy) fails on Docker overlay filesystems with "Invalid cross-device link". This caused Flutter SDK artifact directories to be created but empty when trying to set up the writable wrapper via hard links.
- Solution: Use regular `cp -r` (file copy, not hard links) for the Flutter SDK artifacts that need to be in the writable wrapper directory.
- Source: check-build, 2026-07-03

## Security audit: converting sync http.createServer handler to async for favorites JWT validation
- Project: backend/dancee_workflow
- Problem: The proxy's http.createServer handler was synchronous; making it async to validate Directus JWTs for favorites routes required adding an error-catching wrapper (`handleRequest` async function + createServer wrapper that calls `.catch()`).
- Solution: Extract `handleRequest` as an `async function`, then wrap with `http.createServer((req, res) => { handleRequest(req, res).catch(...) })`. Node.js buffers request data until consumed, so async operations before `req.pipe(proxyReq)` are safe.
- Source: security-audit, 2026-07-04

## Security audit: tests for old insecure error format need updating when sanitizing errors
- Project: backend/dancee_workflow
- Problem: `src/__tests__/clients/directus-client.test.ts` had a "POST/PATCH error messages include truncated request body" describe block that asserted `/body:/` appeared in error messages. After removing the body preview for security (Fix 7), these tests failed.
- Solution: Rename the describe block to "error messages are generic" and update assertions to check `/failed \(status NNN\)/` and verify `/body:/` is NOT present.
- Source: security-audit, 2026-07-04

## Flutter wrapper: packages/flutter_tools needs writable .dart_tool AND updated package_config.json
- Project: frontend/dancee_app
- Problem: After copying engine artifacts and creating the writable cache, flutter still failed with "Permission denied" trying to write `packages/flutter_tools/.dart_tool/package_config.json`. The symlink at `/tmp/fw/packages` pointed to `/opt/flutter/packages` (root-owned), so even creating a writable `.dart_tool` inside it failed.
- Solution: Remove the packages symlink. Create a real `/tmp/fw/packages/` directory. Symlink all subdirectories except `flutter_tools`. Create a real `flutter_tools` directory. Symlink all flutter_tools contents except `.dart_tool`. Create writable `.dart_tool/`. Use `sed 's|/opt/flutter|/tmp/fw|g'` to rewrite `package_config.json` paths. Also: the `artifacts/engine` directory must be created BEFORE copying linux-x64 into it — otherwise `cp -r .../linux-x64 /path/engine/` copies the contents directly into `engine/` rather than creating `engine/linux-x64/`.
- Source: security-audit, 2026-07-04
