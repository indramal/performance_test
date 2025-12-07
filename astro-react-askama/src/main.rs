use askama::Template;
use axum::{
    response::{Html, IntoResponse},
    routing::get,
    Router,
};
use std::net::SocketAddr;
use tower_http::services::ServeDir;

#[derive(Template)]
#[template(path = "index.html")]
struct IndexTemplate {
    title: String,
    description: String,
}

async fn index() -> impl IntoResponse {
    let template = IndexTemplate {
        title: "Tuono - Astro React Askama".to_string(),
        description: "The react / rust fullstack framework".to_string(),
    };
    Html(template.render().unwrap())
}

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt::init();

    let app = Router::new()
        .route("/", get(index))
        .nest_service("/assets", ServeDir::new("src/dist/assets"))
        .nest_service("/", ServeDir::new("public"));

    let addr = SocketAddr::from(([0, 0, 0, 0], 3007));
    println!("🚀 Server running on http://localhost:3007");

    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
