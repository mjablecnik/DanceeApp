# Setup Guide - Dancee API Documentation Service

This guide provides detailed instructions for setting up and running the Centralized API Documentation Service locally or in production.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Running the Service](#running-the-service)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)
- [Production Deployment](#production-deployment)

## Prerequisites

Before setting up the API documentation service, ensure you have the following installed:

### Required Software

- **Node.js**: Version 18.0.0 or higher
- **npm**: Version 9.0.0 or higher
- **Task**: Task automation tool (optional but recommended)

### Verify Prerequisites

Check your installed versions:

```bash
# Check Node.js version
node --version
# Should output: v18.0.0 or higher

# Check npm version
npm --version
# Should output: 9.0.0 or higher

# Check if Task is installed (optional)
task --version
```

### Installing Prerequisites

**Node.js and npm:**

- **Ubuntu/Debian (WSL or Linux):**
  ```bash
  # Using NodeSource repository
  curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
  sudo apt-get install -y nodejs
  ```

- **macOS:**
  ```bash
  # Using Homebrew
  brew install node@18
  ```

- **Alternative (all platforms):**
  Download from [nodejs.org](https://nodejs.org/)

**Task (optional):**

```bash
# Ubuntu/Debian
sudo snap install task --classic

# macOS
brew install go-task/tap/go-task

# Alternative: npm global install
npm install -g @go-task/cli
```

## Installation

### Step 1: Navigate to Project Directory

```bash
cd backend/dancee_api
```

### Step 2: Install Dependencies

Using Task (recommended):

```bash
task install
```

Or using npm directly:

```bash
npm install
```

This will install all runtime and development dependencies defined in `package.json`:

**Runtime Dependencies:**
- `express` - Web server framework
- `swagger-ui-express` - Swagger UI middleware
- `js-yaml` - YAML parsing for OpenAPI specs
- `cors` - CORS middleware
- `dotenv` - Environment variable management

**Development Dependencies:**
- `typescript` - TypeScript compiler
- `ts-node` - TypeScript execution
- `nodemon` - Development auto-reload
- `jest` - Testing framework
- `eslint` - Code linting
- `prettier` - Code formatting

### Step 3: Verify Installation

Check that dependencies were installed successfully:

```bash
# Check if node_modules directory exists
ls -la node_modules/

# Verify key packages are installed
npm list express swagger-ui-express js-yaml
```

## Configuration

### Step 1: Create Environment File

Copy the example environment file:

```bash
cp .env.example .env
```

### Step 2: Configure Environment Variables

Edit the `.env` file with your preferred settings:

```bash
# Open in your editor
nano .env
# or
vim .env
# or
code .env
```

### Environment Variables Reference

#### Server Configuration

```bash
# Port for the documentation service
PORT=3003

# Host address (use 0.0.0.0 to allow external connections)
HOST=localhost

# Environment mode (development, production, test)
NODE_ENV=development
```

#### Service URLs - Development

Configure URLs for backend services in development:

```bash
# Dancee Workflow API (TypeScript/Restate service, HTTP proxy)
WORKFLOW_SERVICE_URL=http://localhost:8080

# Dancee CMS API (Directus headless CMS)
CMS_SERVICE_URL=http://localhost:8055
```

**Note:** Ensure these services are running on the specified ports when testing API endpoints from Swagger UI.

#### Service URLs - Production

For production deployment, uncomment and use production URLs:

```bash
# Production URLs (uncomment for production)
WORKFLOW_SERVICE_URL=https://dancee-workflow.fly.dev
CMS_SERVICE_URL=https://dancee-cms.fly.dev
```

#### CORS Configuration

```bash
# Allowed origins for CORS
# Use * for all origins in development
# Use comma-separated list for production: https://app.dancee.com,https://admin.dancee.com
CORS_ORIGINS=*
```

#### UI Configuration

```bash
# Swagger UI title
UI_TITLE=Dancee API Documentation

# Swagger UI description
UI_DESCRIPTION=Unified API documentation for all Dancee backend services

# Default service to display on load
DEFAULT_SERVICE=dancee-workflow

# UI theme (light, dark, auto)
UI_THEME=light
```

### Step 3: Verify Configuration

Check that your `.env` file is properly formatted:

```bash
# Display environment variables (without sensitive data)
cat .env | grep -v "^#" | grep -v "^$"
```

## Running the Service

### Development Mode

Development mode includes hot-reload functionality - the server automatically restarts when you modify source files.

Using Task (recommended):

```bash
task dev
```

Or using npm:

```bash
npm run dev
```

**Expected Output:**

```
[nodemon] starting `ts-node src/index.ts`
Loading OpenAPI specifications...
✓ Loaded spec: dancee-workflow (Dancee Workflow API v1.0.0)
✓ Loaded spec: dancee-cms (Dancee CMS API v1.0.0)
Dancee API Documentation Service running on http://localhost:3003
Available services: dancee-workflow, dancee-cms
```

### Production Mode

For production deployment, first build the TypeScript code:

Using Task:

```bash
# Build the project
task build

# Start production server
task start
```

Or using npm:

```bash
# Build the project
npm run build

# Start production server
npm start
```

### Available Task Commands

The project includes several task commands for common operations:

```bash
# Development
task install          # Install dependencies
task dev              # Start development server with hot reload
task build            # Build TypeScript to JavaScript
task start            # Start production server

# Testing
task test             # Run all tests
task test-watch       # Run tests in watch mode
task test-coverage    # Run tests with coverage report

# Code Quality
task lint             # Run ESLint
task lint-fix         # Run ESLint and fix issues
task format           # Format code with Prettier
task format-check     # Check code formatting

# Maintenance
task clean            # Clean build artifacts
task clean-build      # Clean and rebuild
```

## Verification

### Step 1: Check Server Health

Once the server is running, verify it's healthy:

```bash
# Using curl
curl http://localhost:3003/health

# Expected response:
# {
#   "status": "ok",
#   "services": {
#     "dancee-workflow": "loaded",
#     "dancee-cms": "loaded"
#   }
# }
```

### Step 2: Access Swagger UI

Open your web browser and navigate to:

```
http://localhost:3003
```

You should see the Swagger UI interface with a service selector dropdown.

### Step 3: Verify Service List

Check that all services are available:

```bash
# Using curl
curl http://localhost:3003/api/services

# Expected response: JSON array with service information
```

### Step 4: Verify Spec Retrieval

Test retrieving a specific service specification:

```bash
# Get dancee-workflow spec
curl http://localhost:3003/api/spec/dancee-workflow

# Get dancee-cms spec
curl http://localhost:3003/api/spec/dancee-cms
```

### Step 5: Test API Endpoints

From the Swagger UI:

1. Select a service from the dropdown (e.g., "Dancee Workflow API")
2. Expand an endpoint (e.g., GET `/events`)
3. Click "Try it out"
4. Fill in any required parameters
5. Click "Execute"

**Note:** The backend service must be running for API testing to work.

## Troubleshooting

### Issue: Port Already in Use

**Symptom:**
```
Error: listen EADDRINUSE: address already in use :::3003
```

**Solution:**

1. Check what's using port 3003:
   ```bash
   # Linux/WSL
   lsof -i :3003
   
   # Or using netstat
   netstat -tulpn | grep 3003
   ```

2. Kill the process or change the port in `.env`:
   ```bash
   PORT=3004
   ```

### Issue: OpenAPI Spec Not Loading

**Symptom:**
```
Error loading spec: dancee-workflow
```

**Solution:**

1. Verify the spec file exists:
   ```bash
   ls -la specs/events.openapi.yaml
   ```

2. Validate the YAML syntax:
   ```bash
   # Install yamllint if needed
   sudo apt-get install yamllint
   
   # Validate spec
   yamllint specs/events.openapi.yaml
   ```

3. Check the spec file permissions:
   ```bash
   chmod 644 specs/events.openapi.yaml
   ```

### Issue: Module Not Found

**Symptom:**
```
Error: Cannot find module 'express'
```

**Solution:**

1. Reinstall dependencies:
   ```bash
   rm -rf node_modules/
   rm package-lock.json
   npm install
   ```

2. Verify Node.js version:
   ```bash
   node --version
   # Should be >= 18.0.0
   ```

### Issue: TypeScript Compilation Errors

**Symptom:**
```
error TS2307: Cannot find module 'express' or its corresponding type declarations
```

**Solution:**

1. Install type definitions:
   ```bash
   npm install --save-dev @types/express @types/node
   ```

2. Clean and rebuild:
   ```bash
   task clean-build
   ```

### Issue: CORS Errors in Browser

**Symptom:**
```
Access to fetch at 'http://localhost:8080/events' from origin 'http://localhost:3003' has been blocked by CORS policy
```

**Solution:**

1. Verify CORS configuration in `.env`:
   ```bash
   CORS_ORIGINS=*
   ```

2. Ensure the backend service has CORS enabled

3. Check browser console for specific CORS error details

### Issue: Backend Service Unavailable

**Symptom:**
```
Failed to fetch: net::ERR_CONNECTION_REFUSED
```

**Solution:**

1. Verify the backend service is running:
   ```bash
   # For dancee_workflow (port 8080)
   curl http://localhost:8080/health
   
   # For dancee_cms (port 3002)
   curl http://localhost:8055/health
   ```

2. Check service URLs in `.env` match actual service ports

3. Start the required backend service before testing

### Issue: Environment Variables Not Loading

**Symptom:**
Service starts with default values instead of `.env` values

**Solution:**

1. Verify `.env` file exists in project root:
   ```bash
   ls -la .env
   ```

2. Check file format (no spaces around `=`):
   ```bash
   # Correct
   PORT=3003
   
   # Incorrect
   PORT = 3003
   ```

3. Restart the server after modifying `.env`

### Getting Help

If you encounter issues not covered here:

1. Check the logs for detailed error messages
2. Verify all prerequisites are installed correctly
3. Ensure all backend services are running
4. Review the [USAGE.md](./USAGE.md) guide for usage examples
5. Check the project's issue tracker or contact the development team

## Production Deployment

### Pre-Deployment Checklist

- [ ] Update `.env` with production URLs
- [ ] Set `NODE_ENV=production`
- [ ] Configure production CORS origins (not `*`)
- [ ] Build the TypeScript code (`task build`)
- [ ] Run tests (`task test`)
- [ ] Verify all OpenAPI specs are valid

### Build for Production

```bash
# Clean previous builds
task clean

# Install production dependencies only
npm ci --production

# Build TypeScript
task build

# Verify build output
ls -la dist/
```

### Environment Configuration

Update `.env` for production:

```bash
NODE_ENV=production
PORT=3003
HOST=0.0.0.0

# Production service URLs
WORKFLOW_SERVICE_URL=https://dancee-workflow.fly.dev
CMS_SERVICE_URL=https://dancee-cms.fly.dev

# Restrict CORS to your domains
CORS_ORIGINS=https://app.dancee.com,https://admin.dancee.com
```

### Running in Production

```bash
# Start the production server
task start

# Or use a process manager like PM2
npm install -g pm2
pm2 start dist/index.js --name dancee-api-docs
pm2 save
pm2 startup
```

### Health Monitoring

Set up health check monitoring:

```bash
# Health check endpoint
curl https://your-domain.com/health

# Monitor with cron job
*/5 * * * * curl -f https://your-domain.com/health || alert-script.sh
```

### Security Considerations

1. **CORS**: Restrict origins to your actual domains
2. **HTTPS**: Use HTTPS in production (configure reverse proxy)
3. **Rate Limiting**: Consider adding rate limiting middleware
4. **Secrets**: Never commit `.env` file to version control
5. **Updates**: Keep dependencies updated for security patches

### Deployment Platforms

The service can be deployed to various platforms:

- **Fly.io**: `fly launch` and `fly deploy`
- **Heroku**: `git push heroku main`
- **Docker**: Build and deploy container
- **VPS**: Run with PM2 or systemd service

Refer to your platform's documentation for specific deployment instructions.

## Next Steps

After successful setup:

1. Read the [USAGE.md](./USAGE.md) guide to learn how to use the service
2. Explore the Swagger UI at `http://localhost:3003`
3. Test API endpoints from the interactive interface
4. Review the OpenAPI specifications in the `specs/` directory
5. Learn how to add new services in [CONTRIBUTING.md](./CONTRIBUTING.md)

## Additional Resources

- [Project README](../README.md) - Project overview
- [USAGE.md](./USAGE.md) - Usage guide and examples
- [OpenAPI Specification](https://swagger.io/specification/) - OpenAPI 3.0 documentation
- [Express.js Documentation](https://expressjs.com/) - Express framework docs
- [Swagger UI Documentation](https://swagger.io/tools/swagger-ui/) - Swagger UI guide
