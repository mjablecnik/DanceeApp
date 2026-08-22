/**
 * Spec Routes
 * Handles OpenAPI specification retrieval endpoint
 * 
 * Requirements: 3.1, 3.2, 3.4, 3.5, 7.1, 7.4
 */

import { Router, Request, Response } from 'express';
import { SpecAggregator } from '../aggregator/spec-aggregator';

/**
 * Create spec router
 * @param specAggregator - Spec aggregator instance for retrieving OpenAPI specs
 * @returns Express router with spec routes
 */
export function createSpecRouter(specAggregator: SpecAggregator): Router {
  const router = Router();

  /**
   * GET /api/spec/:serviceId
   * Get OpenAPI specification for a specific service
   * 
   * Parameters:
   * - serviceId (path): Service identifier (e.g., "dancee-workflow")
   * 
   * Returns:
   * - 200 OK: OpenAPI spec as JSON
   * - 400 Bad Request: Invalid service ID (contains invalid characters)
   * - 404 Not Found: Service not found
   * 
   * Security:
   * - Validates serviceId to prevent path traversal attacks
   * - Only allows alphanumeric characters and hyphens (kebab-case)
   * 
   * Performance:
   * - Serves specs from memory cache (no file system access)
   * - Response time target: < 100ms
   * 
   * Requirements: 3.1, 3.2, 3.4, 3.5, 7.1, 7.4
   */
  router.get('/api/spec/:serviceId', (req: Request, res: Response) => {
    const { serviceId } = req.params;

    // Validate serviceId to prevent path traversal attacks
    // Only allow alphanumeric characters and hyphens (kebab-case)
    // This prevents attacks like: ../../../etc/passwd
    if (!isValidServiceId(serviceId)) {
      res.status(400).json({
        error: 'Invalid service ID',
        message: 'Service ID contains invalid characters',
      });
      return;
    }

    // Get spec from aggregator (cached in memory, fast retrieval)
    const spec = specAggregator.getSpec(serviceId);

    // Return 404 if service not found
    if (!spec) {
      res.status(404).json({
        error: 'Service not found',
        serviceId: serviceId,
      });
      return;
    }

    // Return OpenAPI spec as JSON
    res.json(spec);
  });

  return router;
}

/**
 * Validate service ID to prevent path traversal attacks
 * Only allows alphanumeric characters and hyphens (kebab-case)
 * 
 * Examples:
 * - Valid: "dancee-workflow", "dancee-cms", "my-service-123"
 * - Invalid: "../etc/passwd", "./config", "service/path", "service\\path"
 * 
 * @param serviceId - Service ID to validate
 * @returns true if valid, false otherwise
 * 
 * Requirement: 7.4 (Path traversal prevention)
 */
function isValidServiceId(serviceId: string): boolean {
  // Only allow alphanumeric characters and hyphens (kebab-case)
  // This prevents path traversal sequences like ../, ./, ..\\, .\\
  const validPattern = /^[a-z0-9-]+$/;
  return validPattern.test(serviceId);
}
