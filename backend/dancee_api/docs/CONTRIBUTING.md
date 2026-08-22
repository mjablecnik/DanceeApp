# Contributing Guide - Dancee API Documentation Service

This guide explains how to add new service specifications, update existing ones, and maintain the centralized API documentation service.

## Table of Contents

- [Overview](#overview)
- [Adding a New Service](#adding-a-new-service)
- [Updating Existing Specifications](#updating-existing-specifications)
- [OpenAPI Specification Standards](#openapi-specification-standards)
- [Code Style Guidelines](#code-style-guidelines)
- [Testing Requirements](#testing-requirements)
- [Documentation Standards](#documentation-standards)
- [Pull Request Process](#pull-request-process)
- [Common Issues and Solutions](#common-issues-and-solutions)

## Overview

The Dancee API Documentation Service follows the **Single Source of Truth** principle. All OpenAPI specifications are stored exclusively in `backend/dancee_api/specs/`. Individual backend services do NOT maintain their own OpenAPI specs.

### Key Principles

1. **Centralized Documentation**: All API specs live in `backend/dancee_api/specs/`
2. **OpenAPI 3.0 Standard**: All specs must comply with OpenAPI 3.0 specification
3. **Consistency**: Follow established patterns and naming conventions
4. **Completeness**: Document all endpoints, parameters, and responses
5. **Examples**: Include realistic examples for all requests and responses
6. **English Only**: All documentation must be written in English

## Adding a New Service

### Step 1: Create the OpenAPI Specification

Create a new YAML file in the `specs/` directory:

```bash
cd backend/dancee_api/specs/
touch my-service.openapi.yaml
```

**Naming Convention**: Use kebab-case with `.openapi.yaml` extension
- ✅ Good: `user-auth.openapi.yaml`, `payment-service.openapi.yaml`
- ❌ Bad: `UserAuth.yaml`, `payment_service.yml`, `api-spec.yaml`

### Step 2: Define Basic Information

Start with the required OpenAPI structure:

```yaml
openapi: 3.0.0
info:
  title: My Service API
  version: 1.0.0
  description: |
    Brief description of what this API does.
    
    Provide more details about the service's purpose, key features,
    and any important information developers should know.
  contact:
    name: Dancee API Support
    email: support@dancee.app

servers:
  - url: http://localhost:PORT
    description: Development server
  - url: https://my-service.fly.dev
    description: Production server

tags:
  - name: Health
    description: Health check endpoints
  - name: Resource
    description: Resource management endpoints
```

**Required Fields**:
- `openapi`: Must be "3.0.0"
- `info.title`: Service name
- `info.version`: Semantic version (e.g., "1.0.0")
- `info.description`: Detailed service description
- `servers`: Both development and production URLs
- `tags`: Logical grouping of endpoints

### Step 3: Document Endpoints

Add your API endpoints under the `paths` section:

```yaml
paths:
  /health:
    get:
      tags:
        - Health
      summary: Health check
      description: Check if the server is running and healthy
      operationId: healthCheck
      responses:
        '200':
          description: Server is healthy
          content:
            application/json:
              schema:
                type: object
                properties:
                  status:
                    type: string
                    example: ok
              example:
                status: ok

  /api/resources:
    get:
      tags:
        - Resource
      summary: List all resources
      description: |
        Retrieve a list of all resources with optional filtering.
        
        Supports pagination and filtering by various criteria.
      operationId: listResources
      parameters:
        - name: limit
          in: query
          description: Maximum number of results to return
          required: false
          schema:
            type: integer
            minimum: 1
            maximum: 100
            default: 20
          example: 10
        - name: offset
          in: query
          description: Number of results to skip for pagination
          required: false
          schema:
            type: integer
            minimum: 0
            default: 0
          example: 0
      responses:
        '200':
          description: List of resources retrieved successfully
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/Resource'
        '400':
          description: Invalid request parameters
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
        '500':
          description: Internal server error
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'

    post:
      tags:
        - Resource
      summary: Create a new resource
      description: Create a new resource with the provided data
      operationId: createResource
      requestBody:
        required: true
        description: Resource data to create
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ResourceInput'
            example:
              name: My Resource
              description: A sample resource
              type: standard
      responses:
        '201':
          description: Resource created successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Resource'
        '400':
          description: Invalid input data
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
        '500':
          description: Internal server error
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'

  /api/resources/{id}:
    get:
      tags:
        - Resource
      summary: Get resource by ID
      description: Retrieve detailed information about a specific resource
      operationId: getResourceById
      parameters:
        - name: id
          in: path
          description: Resource identifier
          required: true
          schema:
            type: string
          example: resource-123
      responses:
        '200':
          description: Resource retrieved successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Resource'
        '404':
          description: Resource not found
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
        '500':
          description: Internal server error
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
```

### Step 4: Define Data Models

Add reusable schemas in the `components` section:

```yaml
components:
  schemas:
    Resource:
      type: object
      required:
        - id
        - name
        - type
        - createdAt
      properties:
        id:
          type: string
          description: Unique resource identifier
          example: resource-123
        name:
          type: string
          description: Resource name
          example: My Resource
        description:
          type: string
          description: Optional resource description
          example: A sample resource for demonstration
        type:
          type: string
          enum:
            - standard
            - premium
            - enterprise
          description: Resource type
          example: standard
        createdAt:
          type: string
          format: date-time
          description: Resource creation timestamp
          example: "2024-01-15T10:30:00Z"
        updatedAt:
          type: string
          format: date-time
          description: Last update timestamp
          example: "2024-01-15T14:20:00Z"

    ResourceInput:
      type: object
      required:
        - name
        - type
      properties:
        name:
          type: string
          description: Resource name
          example: My Resource
        description:
          type: string
          description: Optional resource description
          example: A sample resource
        type:
          type: string
          enum:
            - standard
            - premium
            - enterprise
          description: Resource type
          example: standard

    Error:
      type: object
      required:
        - error
      properties:
        error:
          type: string
          description: Error message
          example: Invalid request parameters
        details:
          type: string
          description: Additional error details
          example: The 'limit' parameter must be between 1 and 100
```

### Step 5: Register the Service

Update `src/config/services.config.ts` to include your new service:

```typescript
export const servicesConfig: ServiceConfig = {
  services: [
    // ... existing services ...
    {
      id: 'my-service',
      name: 'My Service API',
      version: '1.0.0',
      description: 'Brief description of the service',
      baseUrl: process.env.MY_SERVICE_URL || 'http://localhost:PORT',
      specFile: 'my-service.openapi.yaml',
      enabled: true,
    },
  ],
  ui: {
    title: 'Dancee API Documentation',
    description: 'Unified API documentation for all Dancee backend services',
    defaultService: 'dancee-workflow',
    theme: 'light',
  },
};
```

### Step 6: Add Environment Variables

Update `.env.example` with the new service URL:

```bash
# My Service Configuration
MY_SERVICE_URL=http://localhost:PORT
# MY_SERVICE_URL=https://my-service.fly.dev  # Production
```

### Step 7: Test the Specification

1. **Validate the spec**:
   ```bash
   # Install validator if needed
   npm install -g @apidevtools/swagger-cli
   
   # Validate your spec
   swagger-cli validate specs/my-service.openapi.yaml
   ```

2. **Start the documentation service**:
   ```bash
   task dev
   ```

3. **Verify in Swagger UI**:
   - Open http://localhost:3003
   - Select your service from the dropdown
   - Verify all endpoints are displayed correctly
   - Check that examples render properly

4. **Test the API endpoint**:
   ```bash
   curl http://localhost:3003/api/spec/my-service
   ```

### Step 8: Update Documentation

Update the main `README.md` to include your new service:

```markdown
### My Service API (my-service)

Brief description of the service.

- **Development**: http://localhost:PORT
- **Production**: https://my-service.fly.dev
- **Spec File**: `specs/my-service.openapi.yaml`

**Key Features**:
- Feature 1
- Feature 2
- Feature 3
```

## Updating Existing Specifications

### When to Update

Update OpenAPI specifications when:
- Adding new endpoints to a backend service
- Modifying existing endpoint parameters or responses
- Changing data models or schemas
- Deprecating endpoints
- Fixing documentation errors

### Update Process

1. **Locate the spec file**:
   ```bash
   cd backend/dancee_api/specs/
   ls -la
   ```

2. **Edit the specification**:
   ```bash
   # Open in your editor
   vim events.openapi.yaml
   # or
   code events.openapi.yaml
   ```

3. **Make your changes**:
   - Add new endpoints under `paths`
   - Update existing endpoint documentation
   - Modify schemas in `components/schemas`
   - Update version number if making breaking changes

4. **Validate the changes**:
   ```bash
   swagger-cli validate specs/events.openapi.yaml
   ```

5. **Test in Swagger UI**:
   ```bash
   task dev
   ```
   - Verify changes appear correctly
   - Test affected endpoints

6. **Update version if needed**:
   ```yaml
   info:
     version: 1.1.0  # Increment for new features
     # or
     version: 2.0.0  # Increment for breaking changes
   ```

### Versioning Guidelines

Follow semantic versioning (MAJOR.MINOR.PATCH):

- **MAJOR** (2.0.0): Breaking changes (removed endpoints, changed response structure)
- **MINOR** (1.1.0): New features (new endpoints, new optional parameters)
- **PATCH** (1.0.1): Bug fixes (documentation corrections, example updates)

## OpenAPI Specification Standards

### Required Elements

Every OpenAPI specification MUST include:

1. **Basic Information**:
   ```yaml
   openapi: 3.0.0
   info:
     title: Service Name
     version: 1.0.0
     description: Detailed description
     contact:
       name: Dancee API Support
       email: support@dancee.app
   ```

2. **Server URLs**:
   ```yaml
   servers:
     - url: http://localhost:PORT
       description: Development server
     - url: https://service.fly.dev
       description: Production server
   ```

3. **Tags** (for organization):
   ```yaml
   tags:
     - name: Category1
       description: Description of category
     - name: Category2
       description: Description of category
   ```

4. **Paths** (endpoints):
   - At least one endpoint documented
   - All HTTP methods documented
   - All parameters documented
   - All responses documented

5. **Components** (reusable schemas):
   - Data models defined
   - Error schemas defined
   - Common parameters defined (if applicable)

### Endpoint Documentation Standards

For EVERY endpoint, include:

1. **Tags**: Assign to appropriate category
   ```yaml
   tags:
     - Resource
   ```

2. **Summary**: Brief one-line description
   ```yaml
   summary: List all resources
   ```

3. **Description**: Detailed explanation with usage notes
   ```yaml
   description: |
     Retrieve a list of all resources with optional filtering.
     
     Supports pagination using limit and offset parameters.
     Results are sorted by creation date in descending order.
   ```

4. **Operation ID**: Unique identifier (camelCase)
   ```yaml
   operationId: listResources
   ```

5. **Parameters**: Document ALL parameters
   ```yaml
   parameters:
     - name: limit
       in: query  # or path, header, cookie
       description: Maximum number of results
       required: false
       schema:
         type: integer
         minimum: 1
         maximum: 100
         default: 20
       example: 10
   ```

6. **Request Body**: For POST/PUT/PATCH
   ```yaml
   requestBody:
     required: true
     description: Data to create the resource
     content:
       application/json:
         schema:
           $ref: '#/components/schemas/ResourceInput'
         example:
           name: Example
           type: standard
   ```

7. **Responses**: Document ALL possible responses
   ```yaml
   responses:
     '200':
       description: Success response
       content:
         application/json:
           schema:
             $ref: '#/components/schemas/Resource'
     '400':
       description: Bad request
       content:
         application/json:
           schema:
             $ref: '#/components/schemas/Error'
     '404':
       description: Not found
       content:
         application/json:
           schema:
             $ref: '#/components/schemas/Error'
     '500':
       description: Internal server error
       content:
         application/json:
           schema:
             $ref: '#/components/schemas/Error'
   ```

### Schema Documentation Standards

For EVERY schema, include:

1. **Type and Required Fields**:
   ```yaml
   Resource:
     type: object
     required:
       - id
       - name
       - type
     properties:
       # ...
   ```

2. **Property Documentation**:
   ```yaml
   properties:
     id:
       type: string
       description: Unique identifier
       example: resource-123
     name:
       type: string
       description: Resource name
       minLength: 1
       maxLength: 100
       example: My Resource
     type:
       type: string
       enum:
         - standard
         - premium
       description: Resource type
       example: standard
     createdAt:
       type: string
       format: date-time
       description: Creation timestamp
       example: "2024-01-15T10:30:00Z"
   ```

3. **Validation Rules**:
   - Use `minLength`, `maxLength` for strings
   - Use `minimum`, `maximum` for numbers
   - Use `pattern` for regex validation
   - Use `enum` for fixed values
   - Use `format` for special types (date-time, email, uri, etc.)

4. **Examples**: Provide realistic examples for every property

### Best Practices

#### DO:

✅ Use descriptive, clear names for operations and schemas
✅ Include detailed descriptions with usage notes
✅ Provide realistic examples for all requests and responses
✅ Document all possible error responses
✅ Use `$ref` to reuse common schemas
✅ Group related endpoints with tags
✅ Include validation rules (min, max, pattern, enum)
✅ Use proper HTTP status codes (200, 201, 400, 404, 500)
✅ Document optional vs. required parameters clearly
✅ Include both development and production server URLs
✅ Use semantic versioning for API versions
✅ Write all documentation in English

#### DON'T:

❌ Leave descriptions empty or use generic text like "TODO"
❌ Forget to document error responses
❌ Use inconsistent naming conventions
❌ Hardcode URLs in examples (use server variables)
❌ Include sensitive data in examples (API keys, passwords)
❌ Duplicate schemas instead of using `$ref`
❌ Use vague descriptions like "Gets data" or "Returns result"
❌ Forget to update version numbers when making changes
❌ Mix languages (use English only)
❌ Leave out examples for complex schemas

### Common Patterns

#### Pagination

```yaml
parameters:
  - name: limit
    in: query
    description: Maximum number of results to return
    required: false
    schema:
      type: integer
      minimum: 1
      maximum: 100
      default: 20
    example: 10
  - name: offset
    in: query
    description: Number of results to skip
    required: false
    schema:
      type: integer
      minimum: 0
      default: 0
    example: 0
```

#### Filtering

```yaml
parameters:
  - name: status
    in: query
    description: Filter by status
    required: false
    schema:
      type: string
      enum:
        - active
        - inactive
        - pending
    example: active
  - name: search
    in: query
    description: Search term for filtering results
    required: false
    schema:
      type: string
      minLength: 1
    example: dance
```

#### Timestamps

```yaml
createdAt:
  type: string
  format: date-time
  description: Resource creation timestamp in ISO 8601 format
  example: "2024-01-15T10:30:00Z"
updatedAt:
  type: string
  format: date-time
  description: Last update timestamp in ISO 8601 format
  example: "2024-01-15T14:20:00Z"
```

#### Error Responses

```yaml
Error:
  type: object
  required:
    - error
  properties:
    error:
      type: string
      description: Human-readable error message
      example: Invalid request parameters
    details:
      type: string
      description: Additional error details
      example: The 'limit' parameter must be between 1 and 100
    code:
      type: string
      description: Machine-readable error code
      example: INVALID_PARAMETER
```

## Code Style Guidelines

### TypeScript Code Standards

When modifying the documentation service code:

1. **Use TypeScript strict mode**: All code must pass strict type checking
2. **Follow naming conventions**:
   - Classes: PascalCase (`SpecAggregator`)
   - Functions/methods: camelCase (`loadSpecs`)
   - Constants: UPPER_SNAKE_CASE (`DEFAULT_PORT`)
   - Interfaces: PascalCase with descriptive names (`ServiceConfig`)
   - Files: kebab-case (`spec-aggregator.ts`)

3. **Add type annotations**:
   ```typescript
   // ✅ Good
   function getSpec(serviceId: string): OpenAPISpec | null {
     return specs.get(serviceId) ?? null;
   }
   
   // ❌ Bad
   function getSpec(serviceId) {
     return specs.get(serviceId) ?? null;
   }
   ```

4. **Use interfaces for data structures**:
   ```typescript
   interface ServiceInfo {
     id: string;
     name: string;
     version: string;
     description: string;
     baseUrl: string;
     specPath: string;
   }
   ```

5. **Document complex functions**:
   ```typescript
   /**
    * Load and validate all OpenAPI specifications from the specs directory.
    * Invalid specs are logged and excluded from the service list.
    * 
    * @throws {Error} If the specs directory cannot be read
    */
   async loadSpecs(): Promise<void> {
     // Implementation
   }
   ```

6. **Use async/await** instead of callbacks or raw promises

7. **Handle errors properly**:
   ```typescript
   try {
     const spec = await loadSpec(filePath);
     return spec;
   } catch (error) {
     logger.error(`Failed to load spec: ${error.message}`);
     return null;
   }
   ```

### YAML Style Guidelines

For OpenAPI specification files:

1. **Use 2-space indentation** (not tabs)
2. **Use lowercase for keys** except proper nouns
3. **Use quotes for strings** containing special characters
4. **Use pipe `|` for multi-line descriptions**:
   ```yaml
   description: |
     This is a multi-line description.
     
     It can include multiple paragraphs and formatting.
   ```

5. **Organize sections in this order**:
   - `openapi`
   - `info`
   - `servers`
   - `tags`
   - `paths`
   - `components`

6. **Keep line length under 100 characters** when possible

7. **Use consistent spacing**:
   ```yaml
   # ✅ Good
   paths:
     /api/resources:
       get:
         summary: List resources
         
   # ❌ Bad
   paths:
     /api/resources:
        get:
          summary: List resources
   ```

### Linting and Formatting

Before committing code:

1. **Run ESLint**:
   ```bash
   task lint
   # or
   task lint-fix  # Auto-fix issues
   ```

2. **Run Prettier**:
   ```bash
   task format
   # or
   task format-check  # Check without modifying
   ```

3. **Validate OpenAPI specs**:
   ```bash
   swagger-cli validate specs/*.yaml
   ```

## Testing Requirements

### Unit Tests

When adding new functionality to the service:

1. **Write tests for new functions**:
   ```typescript
   describe('SpecAggregator', () => {
     describe('loadSpecs', () => {
       it('should load valid YAML specs', async () => {
         const aggregator = new SpecAggregator();
         await aggregator.loadSpecs();
         expect(aggregator.getServiceList()).toHaveLength(2);
       });
       
       it('should exclude invalid specs', async () => {
         // Test implementation
       });
     });
   });
   ```

2. **Test error handling**:
   ```typescript
   it('should handle missing spec files gracefully', async () => {
     // Test implementation
   });
   ```

3. **Test edge cases**:
   - Empty inputs
   - Invalid formats
   - Missing required fields
   - Boundary values

4. **Run tests before committing**:
   ```bash
   task test
   ```

### Integration Tests

For API endpoints:

1. **Test successful responses**:
   ```typescript
   describe('GET /api/services', () => {
     it('should return list of services', async () => {
       const response = await request(app).get('/api/services');
       expect(response.status).toBe(200);
       expect(response.body).toBeInstanceOf(Array);
     });
   });
   ```

2. **Test error scenarios**:
   ```typescript
   describe('GET /api/spec/:serviceId', () => {
     it('should return 404 for invalid service', async () => {
       const response = await request(app).get('/api/spec/invalid');
       expect(response.status).toBe(404);
       expect(response.body).toHaveProperty('error');
     });
   });
   ```

3. **Run integration tests**:
   ```bash
   task test
   ```

### Manual Testing Checklist

Before submitting changes:

- [ ] Start the documentation service (`task dev`)
- [ ] Open Swagger UI (http://localhost:3003)
- [ ] Verify all services appear in the selector
- [ ] Select each service and verify endpoints load
- [ ] Expand several endpoints and check documentation
- [ ] Test "Try it out" functionality (if backend is running)
- [ ] Check that examples render correctly
- [ ] Verify error responses are documented
- [ ] Test the `/api/services` endpoint
- [ ] Test the `/api/spec/:serviceId` endpoint
- [ ] Check the `/health` endpoint
- [ ] Verify no console errors in browser
- [ ] Check server logs for errors

## Documentation Standards

### README Updates

When adding a new service, update `README.md`:

1. Add service to the "Documented Services" section
2. Include development and production URLs
3. List key features
4. Update any relevant examples

### Inline Documentation

1. **Add JSDoc comments** for public functions:
   ```typescript
   /**
    * Retrieve the OpenAPI specification for a service.
    * 
    * @param serviceId - Unique service identifier
    * @returns OpenAPI spec or null if not found
    */
   getSpec(serviceId: string): OpenAPISpec | null {
     return this.specs.get(serviceId) ?? null;
   }
   ```

2. **Comment complex logic**:
   ```typescript
   // Validate spec against OpenAPI 3.0 schema
   // Invalid specs are logged but don't stop the loading process
   if (!this.validateSpec(spec)) {
     logger.warn(`Invalid spec: ${fileName}`);
     continue;
   }
   ```

3. **Use English only** for all comments and documentation

### Commit Messages

Follow conventional commit format:

```
type(scope): brief description

Detailed explanation of the changes (if needed).

Fixes #123
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples**:
```
feat(specs): add user authentication API specification

docs(contributing): add section on versioning guidelines

fix(aggregator): handle missing spec files gracefully
```

## Pull Request Process

### Before Submitting

1. **Ensure all tests pass**:
   ```bash
   task test
   ```

2. **Run linting and formatting**:
   ```bash
   task lint-fix
   task format
   ```

3. **Validate OpenAPI specs**:
   ```bash
   swagger-cli validate specs/*.yaml
   ```

4. **Test manually** using the checklist above

5. **Update documentation** if needed

6. **Write clear commit messages** following conventional commit format

### Submitting a Pull Request

1. **Create a feature branch**:
   ```bash
   git checkout -b feat/add-auth-api-spec
   ```

2. **Make your changes** following the guidelines in this document

3. **Commit your changes**:
   ```bash
   git add .
   git commit -m "feat(specs): add authentication API specification"
   ```

4. **Push to your branch**:
   ```bash
   git push origin feat/add-auth-api-spec
   ```

5. **Create a pull request** with:
   - Clear title describing the change
   - Detailed description of what was added/changed
   - Screenshots of Swagger UI (if applicable)
   - Reference to related issues

### Pull Request Template

```markdown
## Description

Brief description of the changes.

## Type of Change

- [ ] New service specification
- [ ] Update to existing specification
- [ ] Bug fix in documentation
- [ ] Code improvement
- [ ] Documentation update

## Changes Made

- Added/Updated X endpoint
- Modified Y schema
- Fixed Z issue

## Testing

- [ ] All tests pass
- [ ] Linting passes
- [ ] OpenAPI specs validated
- [ ] Manual testing completed
- [ ] Swagger UI displays correctly

## Screenshots

(If applicable, add screenshots of Swagger UI)

## Related Issues

Fixes #123
Related to #456
```

### Review Process

Pull requests will be reviewed for:

1. **Compliance with OpenAPI 3.0 standard**
2. **Completeness of documentation** (all endpoints, parameters, responses)
3. **Code quality** (TypeScript standards, error handling)
4. **Test coverage** (unit and integration tests)
5. **Documentation updates** (README, inline comments)
6. **Consistency** with existing specifications
7. **English language** usage throughout

### After Approval

Once approved and merged:

1. **Delete your feature branch**:
   ```bash
   git branch -d feat/add-auth-api-spec
   ```

2. **Pull the latest changes**:
   ```bash
   git checkout main
   git pull origin main
   ```

3. **Verify the changes** in the deployed documentation service

## Common Issues and Solutions

### Issue: Spec Validation Fails

**Symptom**: `swagger-cli validate` reports errors

**Common Causes**:
- Missing required fields (`openapi`, `info`, `paths`)
- Invalid YAML syntax (indentation, quotes)
- Incorrect schema references (`$ref` pointing to non-existent schema)
- Invalid data types or formats

**Solutions**:

1. **Check YAML syntax**:
   ```bash
   yamllint specs/my-service.openapi.yaml
   ```

2. **Verify required fields** are present:
   ```yaml
   openapi: 3.0.0  # Required
   info:           # Required
     title: ...
     version: ...
   paths: {}       # Required (can be empty)
   ```

3. **Validate schema references**:
   - Ensure referenced schemas exist in `components/schemas`
   - Check spelling and case sensitivity
   - Use correct path format: `#/components/schemas/SchemaName`

4. **Use an online validator**: https://editor.swagger.io/

### Issue: Service Not Appearing in Swagger UI

**Symptom**: New service doesn't show in the service selector

**Solutions**:

1. **Check service configuration** in `src/config/services.config.ts`:
   ```typescript
   {
     id: 'my-service',
     enabled: true,  // Must be true
     specFile: 'my-service.openapi.yaml',  // Must match filename
   }
   ```

2. **Verify spec file exists**:
   ```bash
   ls -la specs/my-service.openapi.yaml
   ```

3. **Check server logs** for loading errors:
   ```bash
   task dev
   # Look for "Error loading spec" messages
   ```

4. **Restart the server**:
   ```bash
   # Stop the server (Ctrl+C)
   task dev
   ```

### Issue: Examples Not Rendering

**Symptom**: Examples don't appear in Swagger UI

**Solutions**:

1. **Use correct example format**:
   ```yaml
   # For simple values
   schema:
     type: string
     example: "example value"
   
   # For objects
   content:
     application/json:
       schema:
         $ref: '#/components/schemas/Resource'
       example:
         id: "123"
         name: "Example"
   ```

2. **Ensure examples match schema**:
   - Check data types (string vs. number)
   - Include all required fields
   - Use valid enum values

3. **Clear browser cache** and reload

### Issue: CORS Errors When Testing

**Symptom**: Browser shows CORS policy errors

**Solutions**:

1. **Verify CORS configuration** in `.env`:
   ```bash
   CORS_ORIGINS=*
   ```

2. **Check backend service** has CORS enabled

3. **Restart documentation service** after changing `.env`

### Issue: TypeScript Compilation Errors

**Symptom**: `task dev` fails with TypeScript errors

**Solutions**:

1. **Check type definitions**:
   ```bash
   npm install --save-dev @types/express @types/node
   ```

2. **Verify imports** are correct:
   ```typescript
   import express from 'express';  // ✅ Good
   import * as express from 'express';  // ❌ May cause issues
   ```

3. **Run type checking**:
   ```bash
   npx tsc --noEmit
   ```

4. **Clean and rebuild**:
   ```bash
   task clean
   task build
   ```

### Issue: Tests Failing

**Symptom**: `task test` reports failures

**Solutions**:

1. **Run tests in watch mode** to see details:
   ```bash
   task test-watch
   ```

2. **Check test environment**:
   - Ensure test data is set up correctly
   - Verify mock configurations
   - Check for async timing issues

3. **Update snapshots** if needed:
   ```bash
   npm test -- -u
   ```

4. **Run specific test file**:
   ```bash
   npm test -- spec-aggregator.test.ts
   ```

### Getting Help

If you encounter issues not covered here:

1. **Check existing issues** in the project repository
2. **Review the documentation**:
   - [Setup Guide](./SETUP.md)
   - [Usage Guide](./USAGE.md)
   - [Project README](../README.md)
3. **Ask the team** in the project's communication channel
4. **Create an issue** with:
   - Clear description of the problem
   - Steps to reproduce
   - Expected vs. actual behavior
   - Relevant logs or error messages
   - Your environment (Node.js version, OS, etc.)

## Additional Resources

### OpenAPI Specification

- [OpenAPI 3.0 Specification](https://swagger.io/specification/)
- [OpenAPI Examples](https://github.com/OAI/OpenAPI-Specification/tree/main/examples)
- [Swagger Editor](https://editor.swagger.io/) - Online spec editor and validator
- [OpenAPI Generator](https://openapi-generator.tech/) - Generate client code from specs

### Tools

- [swagger-cli](https://github.com/APIDevTools/swagger-cli) - Validate and bundle OpenAPI specs
- [yamllint](https://github.com/adrienverge/yamllint) - YAML linter
- [Postman](https://www.postman.com/) - API testing tool (can import OpenAPI specs)
- [Insomnia](https://insomnia.rest/) - API client (supports OpenAPI)

### TypeScript

- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/intro.html)
- [TypeScript Style Guide](https://google.github.io/styleguide/tsguide.html)
- [Express with TypeScript](https://expressjs.com/en/advanced/best-practice-performance.html)

### Testing

- [Jest Documentation](https://jestjs.io/docs/getting-started)
- [Supertest](https://github.com/visionmedia/supertest) - HTTP testing library
- [Testing Best Practices](https://github.com/goldbergyoni/javascript-testing-best-practices)

## Feedback and Improvements

This contributing guide is a living document. If you have suggestions for improvements:

1. **Open an issue** describing the improvement
2. **Submit a pull request** with your proposed changes
3. **Discuss with the team** in the project's communication channel

Thank you for contributing to the Dancee API Documentation Service!

