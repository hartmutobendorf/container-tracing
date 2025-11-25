# Container Tracing Daemon

A Rust-based daemon service for collecting and managing container tracing events.

## Components

- **Daemon Service**: An HTTP API service that collects and stores trace events
- **Docker Build**: Multi-stage Dockerfile for optimized builds
- **Test Suite**: Automated tests running in a container

## API Endpoints

- `GET /health` - Health check endpoint
- `GET /events` - Retrieve all trace events
- `POST /events` - Add a new trace event
- `GET /stats` - Get statistics (total events, unique containers)

## Building and Running

### Build the daemon
```bash
docker build -f Dockerfile.build -t container-tracing-daemon .
```

### Run the daemon
```bash
docker run -p 8080:8080 container-tracing-daemon
```

### Build and run with docker-compose
```bash
docker-compose up --build
```

This will:
1. Build the daemon service
2. Start the daemon
3. Run the test suite automatically
4. Display test results

### Clean up
```bash
docker-compose down
```

## Manual Testing

Once the daemon is running, you can test it manually:

```bash
# Health check
curl http://localhost:8080/health

# Add an event
curl -X POST http://localhost:8080/events \
  -H "Content-Type: application/json" \
  -d '{
    "id": "evt-001",
    "timestamp": 1234567890,
    "container_id": "container-abc",
    "event_type": "start",
    "data": "Container started"
  }'

# Get all events
curl http://localhost:8080/events

# Get statistics
curl http://localhost:8080/stats
```

## Development

### Local build (without Docker)
```bash
cargo build --release
cargo run
```

### Run tests
```bash
./test-service.sh
```
