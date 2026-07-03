import { config } from "../core/config";
import { getOpenAI } from "../core/openai";
import { getImageGenerationPrompt } from "../core/prompts";
import { uploadFile, findExpiredEventWithImage } from "../clients/directus-client";
import { log } from "../core/logger";

export interface ImageProcessResult {
  fileId: string | null;
  source: "facebook" | "ai_generated" | null;
}

/**
 * Downloads an image from a URL and returns the buffer, MIME type, and filename.
 * Throws on HTTP errors or timeouts.
 */
export async function downloadImage(
  url: string,
): Promise<{ buffer: Buffer; mimeType: string; filename: string }> {
  const response = await fetch(url, {
    signal: AbortSignal.timeout(30000),
  });
  if (!response.ok) {
    throw new Error(`Failed to download image from ${url}: HTTP ${response.status}`);
  }
  const contentType = response.headers.get("content-type") ?? "image/jpeg";
  const mimeType = contentType.split(";")[0].trim();
  const arrayBuffer = await response.arrayBuffer();
  const buffer = Buffer.from(arrayBuffer);
  const ext = mimeType === "image/png" ? "png" : mimeType === "image/webp" ? "webp" : "jpg";
  const filename = `event-image.${ext}`;
  return { buffer, mimeType, filename };
}

/**
 * Generates an AI image via the configured image generation model.
 * Uses the OpenAI images.generate API with b64_json response format.
 * Returns the image as a Buffer.
 */
export async function generateAiImage(
  title: string,
  primaryDance: string,
  eventType: string,
): Promise<Buffer> {
  const prompt = getImageGenerationPrompt(title, primaryDance, eventType);
  const openai = getOpenAI();
  const response = await openai.images.generate({
    model: config.imageGenerationModel,
    prompt,
    response_format: "b64_json",
    n: 1,
  });

  const b64 = response.data?.[0]?.b64_json;
  if (!b64) {
    throw new Error("AI image generation returned no image data");
  }
  return Buffer.from(b64, "base64");
}

/**
 * Processes an event/course image using the fallback chain:
 * 1. Download from Facebook URL (if provided)
 * 2. Reuse an AI-generated image from an expired event with matching dance/type
 * 3. Generate a new AI image via OpenRouter
 * 4. Return null if all steps fail
 */
export async function processEventImage(
  imageUrl: string | null | undefined,
  primaryDance: string,
  eventType: string,
  title: string,
): Promise<ImageProcessResult> {
  // Step 1: Download from Facebook URL
  if (imageUrl) {
    try {
      const { buffer, mimeType, filename } = await downloadImage(imageUrl);
      const fileId = await uploadFile(buffer, filename, mimeType);
      return { fileId, source: "facebook" };
    } catch (err) {
      log({ level: "warn", message: "Failed to download Facebook image, falling back", reason: err instanceof Error ? err.message : String(err) });
    }
  }

  // Step 2: Reuse AI-generated image from an expired event
  try {
    const reusableFileId = await findExpiredEventWithImage(primaryDance, eventType);
    if (reusableFileId) {
      return { fileId: reusableFileId, source: "ai_generated" };
    }
  } catch (err) {
    log({ level: "warn", message: "Failed to find reusable image, falling back to AI generation", reason: err instanceof Error ? err.message : String(err) });
  }

  // Step 3: Generate a new AI image
  try {
    const buffer = await generateAiImage(title, primaryDance, eventType);
    const fileId = await uploadFile(buffer, "ai-generated-event-image.jpg", "image/jpeg");
    return { fileId, source: "ai_generated" };
  } catch (err) {
    log({ level: "warn", message: "Failed to generate AI image, storing null", reason: err instanceof Error ? err.message : String(err) });
  }

  // Step 4: All fallbacks failed
  return { fileId: null, source: null };
}
