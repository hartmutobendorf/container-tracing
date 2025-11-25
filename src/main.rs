use axum::{
    extract::State,
    http::StatusCode,
    response::Json,
    routing::{get, post},
    Router,
};
use serde::{Deserialize, Serialize};
use std::sync::Arc;
use tokio::sync::Mutex;
use tracing::{info, Level};
use tracing_subscriber;

#[derive(Clone, Debug, Serialize, Deserialize)]
struct TraceEvent {
    id: String,
    timestamp: u64,
    container_id: String,
    event_type: String,
    data: String,
}

#[derive(Clone)]
struct AppState {
    events: Arc<Mutex<Vec<TraceEvent>>>,
}

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt()
        .with_max_level(Level::INFO)
        .init();

    info!("Starting container tracing daemon");

    let state = AppState {
        events: Arc::new(Mutex::new(Vec::new())),
    };

    let app = Router::new()
        .route("/health", get(health_check))
        .route("/events", get(get_events))
        .route("/events", post(add_event))
        .route("/stats", get(get_stats))
        .with_state(state);

    let addr = "0.0.0.0:8080";
    info!("Listening on {}", addr);

    let listener = tokio::net::TcpListener::bind(addr)
        .await
        .expect("Failed to bind to address");

    axum::serve(listener, app)
        .await
        .expect("Server failed to start");
}

async fn health_check() -> &'static str {
    "OK"
}

async fn get_events(State(state): State<AppState>) -> Json<Vec<TraceEvent>> {
    let events = state.events.lock().await;
    Json(events.clone())
}

async fn add_event(
    State(state): State<AppState>,
    Json(event): Json<TraceEvent>,
) -> StatusCode {
    let mut events = state.events.lock().await;
    info!("Adding trace event: {:?}", event);
    events.push(event);
    StatusCode::CREATED
}

#[derive(Serialize)]
struct Stats {
    total_events: usize,
    unique_containers: usize,
}

async fn get_stats(State(state): State<AppState>) -> Json<Stats> {
    let events = state.events.lock().await;
    let unique_containers: std::collections::HashSet<_> = 
        events.iter().map(|e| e.container_id.clone()).collect();
    
    Json(Stats {
        total_events: events.len(),
        unique_containers: unique_containers.len(),
    })
}
