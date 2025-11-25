#!/bin/bash
set -e

echo "Container Tracing Daemon - Quick Start"
echo "======================================"
echo ""

# Check if docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed"
    exit 1
fi

# Check if docker-compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "Error: docker-compose is not installed"
    exit 1
fi

echo "Building and starting services..."
docker-compose up --build --abort-on-container-exit

echo ""
echo "======================================"
echo "To run the daemon standalone:"
echo "  make build && make run"
echo ""
echo "To test manually:"
echo "  curl http://localhost:8080/health"
echo "======================================"
