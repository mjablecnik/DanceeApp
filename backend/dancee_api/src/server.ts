/**
 * Express Server Setup
 * Main server configuration and lifecycle management
 * 
 * Requirements: 1.4, 1.5
 */

import express, { Application } from 'express';
import { Server as HttpServer } from 'http';
import swaggerUi from 'swagger-ui-express';
import { appConfig } from './config/app.config';
import { serviceConfig } from './config/services.config';
import { corsMiddleware } from './middleware/cors.middleware';
import { errorMiddleware } from './middleware/error.middleware';
import { SpecAggregator } from './aggregator/spec-aggregator';
import { createServicesRouter } from './routes/services.routes';
import { createSpecRouter } from './routes/spec.routes';
import { createHealthRouter } from './routes/health.routes';

/**
 * Server class
 * Manages Express application lifecycle
 */
export class Server {
  private app: Application;
  private httpServer: HttpServer | null = null;
  private specAggregator: SpecAggregator;

  /**
   * Create a new Server instance
   * @param specAggregator - Spec aggregator instance for serving OpenAPI specs
   */
  constructor(specAggregator: SpecAggregator) {
    this.app = express();
    this.specAggregator = specAggregator;
    this.setupMiddleware();
    this.setupRoutes();
    this.setupErrorHandling();
    this.setupGracefulShutdown();
  }

  /**
   * Set up middleware
   * Apply CORS and JSON body parser
   */
  private setupMiddleware(): void {
    // Apply CORS middleware
    this.app.use(corsMiddleware);

    // Apply JSON body parser
    this.app.use(express.json());

    // Apply URL-encoded body parser for form data
    this.app.use(express.urlencoded({ extended: true }));
  }

  /**
   * Set up routes
   * Mount all API routes and Swagger UI
   */
  private setupRoutes(): void {
    // Mount services routes
    this.app.use(createServicesRouter(this.specAggregator));

    // Mount spec routes
    this.app.use(createSpecRouter(this.specAggregator));

    // Mount health check routes
    this.app.use(createHealthRouter(this.specAggregator));

    // Configure Swagger UI with multi-spec support
    // Requirements: 4.1, 4.2 - Mount at root path with service selector
    const swaggerOptions = {
      explorer: true, // Enable explorer mode for service selector
      swaggerOptions: {
        // Configure URLs for all loaded services (dancee-workflow, dancee-cms, etc.)
        urls: this.specAggregator.getLoadedServiceIds().map(serviceId => ({
          url: `/api/spec/${serviceId}`,
          name: this.specAggregator.getServiceInfo(serviceId)?.name || serviceId,
        })),
        // Set default service from UI config
        'urls.primaryName': this.specAggregator.getServiceInfo(serviceConfig.ui.defaultService)?.name || serviceConfig.ui.defaultService,
      },
    };

    // Mount Swagger UI at root path `/`
    this.app.use('/', swaggerUi.serve, swaggerUi.setup(undefined, swaggerOptions));
  }

  /**
   * Set up error handling middleware
   * Must be applied after all routes
   */
  private setupErrorHandling(): void {
    this.app.use(errorMiddleware);
  }

  /**
   * Set up graceful shutdown handlers
   * Handle SIGTERM and SIGINT signals
   */
  private setupGracefulShutdown(): void {
    // Handle SIGTERM (e.g., from Docker, Kubernetes)
    process.on('SIGTERM', () => {
      console.log('SIGTERM signal received: closing HTTP server');
      this.stop();
    });

    // Handle SIGINT (e.g., Ctrl+C)
    process.on('SIGINT', () => {
      console.log('SIGINT signal received: closing HTTP server');
      this.stop();
    });
  }

  /**
   * Start the server
   * Bind to configured port and host
   */
  async start(): Promise<void> {
    return new Promise((resolve, reject) => {
      try {
        this.httpServer = this.app.listen(appConfig.port, appConfig.host, () => {
          console.log(`
╔════════════════════════════════════════════════════════════════╗
║  Dancee API Documentation Service                              ║
╚════════════════════════════════════════════════════════════════╝

  Server running at: http://${appConfig.host}:${appConfig.port}
  Environment: ${appConfig.nodeEnv}
  
  Swagger UI:       http://${appConfig.host}:${appConfig.port}/
  
  API Endpoints:
    - Health Check:   http://${appConfig.host}:${appConfig.port}/health
    - Service List:   http://${appConfig.host}:${appConfig.port}/api/services
    - OpenAPI Spec:   http://${appConfig.host}:${appConfig.port}/api/spec/:serviceId
  
  Loaded Services: ${this.specAggregator.getLoadedSpecCount()}
    ${this.specAggregator.getLoadedServiceIds().map(id => `- ${id}`).join('\n    ')}

  Press Ctrl+C to stop
          `);
          resolve();
        });

        this.httpServer.on('error', (error) => {
          reject(error);
        });
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * Stop the server
   * Gracefully close all connections
   */
  async stop(): Promise<void> {
    return new Promise((resolve, reject) => {
      if (!this.httpServer) {
        console.log('Server is not running');
        resolve();
        return;
      }

      console.log('Shutting down server gracefully...');

      this.httpServer.close((err) => {
        if (err) {
          console.error('Error during server shutdown:', err);
          reject(err);
          return;
        }

        console.log('Server closed successfully');
        this.httpServer = null;
        resolve();
        
        // Exit process after successful shutdown
        process.exit(0);
      });

      // Force shutdown after 10 seconds if graceful shutdown fails
      setTimeout(() => {
        console.error('Forced shutdown after timeout');
        process.exit(1);
      }, 10000);
    });
  }

  /**
   * Get the Express application instance
   * Useful for testing
   */
  getApp(): Application {
    return this.app;
  }

  /**
   * Check if server is running
   */
  isRunning(): boolean {
    return this.httpServer !== null;
  }
}
