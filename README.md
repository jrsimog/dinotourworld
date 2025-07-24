# DinosaurBackend

A comprehensive Phoenix-based API for managing and searching dinosaur data with support for both REST and GraphQL interfaces. Perfect for mobile applications and web integrations.

## 🦕 Features

- **Dual API Architecture**: Complete REST and GraphQL APIs
- **Advanced Search**: Filter dinosaurs by name and discovery location
- **Comprehensive Testing**: 59 tests with 100% coverage on core modules
- **OpenAPI Documentation**: Interactive Swagger UI with detailed schemas
- **Robust Validation**: Parameter validation with detailed error responses
- **Developer Tools**: GraphiQL interface and comprehensive documentation
- **Production Ready**: Error handling, request tracking, and metadata responses

## 🚀 Quick Start

### Prerequisites
- Elixir 1.14+
- Phoenix Framework
- PostgreSQL

### Installation

1. Install dependencies:
```bash
mix setup
```

2. Start the Phoenix server:
```bash
mix phx.server
```

3. Visit the application:
- **API Documentation**: [http://localhost:4000/api/doc](http://localhost:4000/api/doc)
- **GraphiQL Interface**: [http://localhost:4000/api/graphiql](http://localhost:4000/api/graphiql)
- **OpenAPI Spec**: [http://localhost:4000/api/openapi](http://localhost:4000/api/openapi)

## 📡 API Endpoints

### REST API

#### Get All Dinosaurs
```bash
curl -X GET "http://localhost:4000/api/dinosaurs" \
  -H "Accept: application/json"
```

**Response:**
```json
{
  "data": [
    {
      "id": 1,
      "name": "Tyrannosaurus Rex",
      "description": "Large carnivorous dinosaur from the Late Cretaceous period",
      "species": "T. rex",
      "era": "Cretaceous",
      "latitude": 47.0,
      "longitude": -106.0
    }
  ],
  "meta": {
    "total": 1,
    "filters": {
      "name": null,
      "city": null
    }
  }
}
```

#### Search by Dinosaur Name
```bash
curl -X GET "http://localhost:4000/api/dinosaurs?name=rex" \
  -H "Accept: application/json"
```

#### Search by Discovery City
```bash
curl -X GET "http://localhost:4000/api/dinosaurs?city=gobi" \
  -H "Accept: application/json"
```

#### Combined Search (Name + City)
```bash
curl -X GET "http://localhost:4000/api/dinosaurs?name=tyrannosaurus&city=hell creek" \
  -H "Accept: application/json"
```

#### Validation Error Example
```bash
curl -X GET "http://localhost:4000/api/dinosaurs?name=a" \
  -H "Accept: application/json"
```

**Error Response (400):**
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Los parámetros proporcionados no son válidos",
    "details": [
      {
        "field": "name",
        "reason": "debe tener al menos 2 caracteres",
        "value": "a"
      }
    ]
  }
}
```

### GraphQL API

#### Basic Query
```bash
curl -X POST "http://localhost:4000/api/graphql" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "query": "{ dinosaurs { id name species era } }"
  }'
```

#### Query with Filters
```bash
curl -X POST "http://localhost:4000/api/graphql" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "query": "query getDinosaurs($name: String, $city: String) { dinosaurs(name: $name, city: $city) { id name species era locations { city country } } }",
    "variables": {
      "name": "rex",
      "city": "gobi"
    }
  }'
```

#### Query with Locations
```bash
curl -X POST "http://localhost:4000/api/graphql" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "query": "{ dinosaurs { id name locations { city country latitude longitude } } }"
  }'
```

#### Single Dinosaur Query
```bash
curl -X POST "http://localhost:4000/api/graphql" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "query": "query getDinosaur($id: ID!) { dinosaur(id: $id) { id name description species era latitude longitude } }",
    "variables": {
      "id": "1"
    }
  }'
```

## 🏗️ Architecture

### Database Schema
- **Dinosaurs**: Core dinosaur information (name, species, era, coordinates)
- **Locations**: Discovery locations (city, country, coordinates)
- **Findings**: Links dinosaurs to their discovery locations
- **Images**: Dinosaur images (optional)

### API Design
- **REST**: Traditional HTTP methods with query parameters
- **GraphQL**: Flexible queries with field selection and nested relationships
- **Validation**: Consistent parameter validation across both APIs
- **Error Handling**: Structured error responses with codes and details

## 🧪 Testing

Run the comprehensive test suite:

```bash
# Run all tests
mix test

# Run with coverage
mix test --cover

# Run specific test files
mix test test/dinosaur_backend_web/controllers/api/dinosaur_controller_test.exs
```

**Test Coverage:**
- Context layer (CRUD operations)
- REST API endpoints (all filters and edge cases)
- GraphQL resolvers and schema
- OpenAPI documentation generation
- Validation and error handling

## 📚 Documentation

### Interactive Documentation
- **Swagger UI**: [http://localhost:4000/api/doc](http://localhost:4000/api/doc)
  - Try API endpoints interactively
  - View detailed request/response schemas
  - See validation examples

- **GraphiQL**: [http://localhost:4000/api/graphiql](http://localhost:4000/api/graphiql) (development only)
  - Interactive GraphQL queries
  - Schema exploration
  - Query builder with autocompletion

### API Specifications
- **OpenAPI 3.0**: [http://localhost:4000/api/openapi](http://localhost:4000/api/openapi)
  - Machine-readable API specification
  - Complete schema definitions
  - Example requests and responses

## 🔧 Configuration

### Environment Variables
- `DATABASE_URL`: PostgreSQL connection string
- `SECRET_KEY_BASE`: Phoenix secret key
- `PHX_HOST`: Host configuration for production

### Development Setup
1. Copy `.env.example` to `.env` (if available)
2. Configure database connection in `config/dev.exs`
3. Run migrations: `mix ecto.migrate`
4. Seed database: `mix run priv/repo/seeds.exs`

## 🚢 Deployment

### Production Checklist
- [ ] Set environment variables
- [ ] Run database migrations
- [ ] Compile assets
- [ ] Configure reverse proxy (nginx/apache)
- [ ] Set up SSL certificates
- [ ] Configure monitoring and logging

### Docker Support
```dockerfile
# Basic Dockerfile example
FROM elixir:1.14-alpine
WORKDIR /app
COPY mix.exs mix.lock ./
RUN mix deps.get --only prod
COPY . .
RUN mix compile
EXPOSE 4000
CMD ["mix", "phx.server"]
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Write tests for your changes
4. Ensure all tests pass (`mix test`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

- **Issues**: Report bugs and feature requests via GitHub Issues
- **Documentation**: Check `/api/doc` for interactive API documentation
- **Community**: Phoenix Framework community resources

---

**Built with** ❤️ **using Phoenix Framework, GraphQL, and modern API best practices**
