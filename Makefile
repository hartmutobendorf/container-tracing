.PHONY: build run test clean help

help:
	@echo "Container Tracing Daemon - Build Commands"
	@echo "=========================================="
	@echo "make build       - Build the daemon Docker image"
	@echo "make run         - Run the daemon locally"
	@echo "make test        - Build and run tests with docker-compose"
	@echo "make clean       - Clean up Docker containers and images"
	@echo "make cargo-build - Build locally with cargo"
	@echo "make cargo-run   - Run locally with cargo"

build:
	docker build -f Dockerfile.build -t container-tracing-daemon .

run:
	docker run -p 8080:8080 --name tracing-daemon container-tracing-daemon

test:
	docker-compose up --build --abort-on-container-exit

clean:
	docker-compose down -v
	docker rm -f tracing-daemon 2>/dev/null || true
	docker rmi container-tracing-daemon 2>/dev/null || true

cargo-build:
	cargo build --release

cargo-run:
	cargo run
