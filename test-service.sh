#!/bin/bash
set -e

DAEMON_URL="http://${DAEMON_HOST}:${DAEMON_PORT}"

echo "Testing Container Tracing Daemon at ${DAEMON_URL}"
echo "================================================"

# Wait for service to be ready
echo -n "Waiting for service to be ready..."
for i in {1..30}; do
    if curl -s "${DAEMON_URL}/health" > /dev/null 2>&1; then
        echo " OK"
        break
    fi
    if [ $i -eq 30 ]; then
        echo " FAILED"
        echo "Service did not become ready in time"
        exit 1
    fi
    sleep 1
done

# Test 1: Health check
echo ""
echo "Test 1: Health check"
HEALTH=$(curl -s "${DAEMON_URL}/health")
if [ "$HEALTH" = "OK" ]; then
    echo "✓ Health check passed"
else
    echo "✗ Health check failed: $HEALTH"
    exit 1
fi

# Test 2: Get initial events (should be empty)
echo ""
echo "Test 2: Get initial events"
EVENTS=$(curl -s "${DAEMON_URL}/events")
if [ "$EVENTS" = "[]" ]; then
    echo "✓ Initial events list is empty"
else
    echo "✗ Initial events list is not empty: $EVENTS"
    exit 1
fi

# Test 3: Add a trace event
echo ""
echo "Test 3: Add trace event"
TIMESTAMP=$(date +%s)
curl -s -X POST "${DAEMON_URL}/events" \
    -H "Content-Type: application/json" \
    -d "{
        \"id\": \"event-001\",
        \"timestamp\": ${TIMESTAMP},
        \"container_id\": \"container-abc123\",
        \"event_type\": \"start\",
        \"data\": \"Container started successfully\"
    }" > /dev/null

echo "✓ Event added"

# Test 4: Verify event was stored
echo ""
echo "Test 4: Verify event was stored"
EVENTS=$(curl -s "${DAEMON_URL}/events")
EVENT_COUNT=$(echo "$EVENTS" | jq 'length')
if [ "$EVENT_COUNT" = "1" ]; then
    echo "✓ Event count is correct: 1"
else
    echo "✗ Event count is incorrect: $EVENT_COUNT"
    exit 1
fi

# Test 5: Add more events
echo ""
echo "Test 5: Add multiple events"
for i in {2..5}; do
    TIMESTAMP=$(date +%s)
    curl -s -X POST "${DAEMON_URL}/events" \
        -H "Content-Type: application/json" \
        -d "{
            \"id\": \"event-00${i}\",
            \"timestamp\": ${TIMESTAMP},
            \"container_id\": \"container-xyz789\",
            \"event_type\": \"log\",
            \"data\": \"Log entry ${i}\"
        }" > /dev/null
done
echo "✓ Multiple events added"

# Test 6: Check stats
echo ""
echo "Test 6: Check statistics"
STATS=$(curl -s "${DAEMON_URL}/stats")
TOTAL_EVENTS=$(echo "$STATS" | jq '.total_events')
UNIQUE_CONTAINERS=$(echo "$STATS" | jq '.unique_containers')

if [ "$TOTAL_EVENTS" = "5" ]; then
    echo "✓ Total events: $TOTAL_EVENTS"
else
    echo "✗ Expected 5 events, got $TOTAL_EVENTS"
    exit 1
fi

if [ "$UNIQUE_CONTAINERS" = "2" ]; then
    echo "✓ Unique containers: $UNIQUE_CONTAINERS"
else
    echo "✗ Expected 2 unique containers, got $UNIQUE_CONTAINERS"
    exit 1
fi

echo ""
echo "================================================"
echo "All tests passed! ✓"
echo "================================================"
