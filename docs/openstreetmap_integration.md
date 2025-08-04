# Integración OpenStreetMap

Esta documentación describe la integración de OpenStreetMap en el proyecto DinosaurBackend.

## Arquitectura

La integración sigue los estándares de Elixir/Phoenix y está organizada en las siguientes capas:

### 1. Behaviour (`DinosaurBackend.OpenStreetMap.Behaviour`)
Define el contrato para los clientes de OpenStreetMap con las siguientes funciones:
- `geocode/2` - Convertir dirección a coordenadas
- `reverse_geocode/2` - Convertir coordenadas a dirección  
- `search/2` - Buscar lugares por nombre

### 2. Cliente HTTP (`DinosaurBackend.OpenStreetMap.Client`)
Implementación concreta que usa la API de Nominatim de OpenStreetMap:
- Manejo de errores HTTP
- Parsing de respuestas JSON
- Rate limiting y User-Agent apropiado
- Configuración flexible

### 3. Servicio (`DinosaurBackend.OpenStreetMap.Service`)
Capa de lógica de negocio que proporciona:
- Validación de coordenadas
- Geocodificación en lotes
- Búsqueda por proximidad con cálculo de distancias
- Manejo de errores específicos de la aplicación

### 4. Módulo Principal (`DinosaurBackend.OpenStreetMap`)
Interfaz unificada que delega al servicio y proporciona una API limpia.

## Configuración

La configuración se encuentra en `config/config.exs`:

```elixir
config :dinosaur_backend, :openstreetmap,
  base_url: "https://nominatim.openstreetmap.org",
  user_agent: "DinosaurBackend/1.0 (Elixir Phoenix Application)",
  default_limit: 5,
  timeout: 10_000,
  rate_limit_delay: 1000
```

## Uso Básico

### Geocodificación (dirección → coordenadas)

```elixir
# Encontrar coordenadas de una dirección
{:ok, %{lat: lat, lon: lon}} = DinosaurBackend.OpenStreetMap.find_coordinates("Madrid, Spain")
```

### Geocodificación Inversa (coordenadas → dirección)

```elixir
# Encontrar dirección de unas coordenadas
coordinates = %{lat: 40.4168, lon: -3.7038}
{:ok, address} = DinosaurBackend.OpenStreetMap.find_address(coordinates)
```

### Geocodificación en Lotes

```elixir
# Geocodificar múltiples direcciones
addresses = ["Madrid, Spain", "Barcelona, Spain", "Valencia, Spain"]
results = DinosaurBackend.OpenStreetMap.batch_geocode(addresses)
# Returns: %{"Madrid, Spain" => {:ok, coords}, ...}
```

### Búsqueda por Proximidad

```elixir
# Buscar museos cerca de Madrid en un radio de 5km
madrid_coords = %{lat: 40.4168, lon: -3.7038}
{:ok, results} = DinosaurBackend.OpenStreetMap.search_nearby(madrid_coords, "museum", 5)
```

### Validación de Coordenadas

```elixir
# Validar si las coordenadas están en rangos válidos
valid? = DinosaurBackend.OpenStreetMap.valid_coordinates?(%{lat: 40.4168, lon: -3.7038})
# Returns: true
```

## Testing

### Tests Unitarios

Los tests están organizados por módulo:
- `test/dinosaur_backend/open_street_map/behaviour_test.exs` - Tests del behaviour
- `test/dinosaur_backend/open_street_map/client_test.exs` - Tests del cliente HTTP
- `test/dinosaur_backend/open_street_map/service_test.exs` - Tests del servicio
- `test/dinosaur_backend/open_street_map_test.exs` - Tests del módulo principal

### Mock para Tests

Se incluye un mock (`DinosaurBackend.OpenStreetMapMock`) que implementa el behaviour para tests:

```elixir
# En tus tests
service = DinosaurBackend.OpenStreetMap.Service.new(DinosaurBackend.OpenStreetMapMock)
{:ok, coords} = DinosaurBackend.OpenStreetMap.Service.find_coordinates(service, "Madrid")
```

### Tests de Integración

Para ejecutar tests que hacen llamadas reales a la API:

```bash
INTEGRATION_TESTS=true mix test --include integration
```

### Ejecutar Tests

```bash
# Tests unitarios (sin llamadas a APIs externas)
mix test test/dinosaur_backend/open_street_map --exclude integration

# Todos los tests incluyendo integración
INTEGRATION_TESTS=true mix test test/dinosaur_backend/open_street_map
```

## Ejemplos

Consulta `DinosaurBackend.OpenStreetMap.Examples` para ejemplos completos de uso.

## Consideraciones de Producción

### Rate Limiting
OpenStreetMap Nominatim tiene límites de velocidad. La implementación incluye:
- User-Agent identificativo apropiado
- Configuración de timeout
- Manejo de errores HTTP

### Caching
Para producción, considera implementar caching de resultados para reducir llamadas a la API.

### Monitoreo
Implementa logging y métricas para monitorear el uso de la API externa.

### Alternativas
Para mayor rendimiento en producción, considera usar:
- Instancia privada de Nominatim
- Otros servicios de geocodificación (Google Maps, MapBox, etc.)
- Base de datos local de geocodificación

## Extensiones Futuras

- Soporte para múltiples proveedores de geocodificación
- Sistema de cache distribuido
- Métricas y observabilidad
- Soporte para búsqueda estructurada
- Integración con otros servicios de mapas