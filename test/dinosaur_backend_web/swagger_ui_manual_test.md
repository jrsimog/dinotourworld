# Manual Test for Swagger UI

## Steps to verify schemas are visible:

1. Start the server: `mix phx.server`
2. Visit: http://localhost:4000/api/doc
3. Look for the "Schemas" section in the bottom right
4. Click on "GET /api/dinosaurs"
5. Look at the "Responses" section

## Expected behavior:
- Should see schema details for 200, 400, and 500 responses
- Should see example responses
- "Try it out" should work with validation

## Current status:
The schemas are defined but may not be fully expanded in the OpenAPI spec.

## Alternative verification:
1. Check raw OpenAPI spec: http://localhost:4000/api/openapi
2. Look for expanded schema definitions in the components section