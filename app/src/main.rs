use actix_web::{App, HttpResponse, HttpServer, Responder, middleware::Logger, web};
use chrono::Utc;
use serde::Serialize;

#[derive(Serialize)]
pub struct HelloResponse {
    message: &'static str,
    app_name: &'static str,
    build_sha: &'static str,
    timestamp: String,
}

#[derive(Serialize)]
pub struct HealthcheckResponse {
    message: String,
}

async fn hello() -> impl Responder {
    let response = HelloResponse {
        message: "Hello, World!",
        app_name: env!("CARGO_PKG_NAME"),
        build_sha: env!("GIT_SHA"),
        timestamp: Utc::now().to_string(),
    };

    HttpResponse::Ok().json(response)
}

async fn livez() -> impl Responder {
    HttpResponse::Ok().json(HealthcheckResponse {
        message: "Ok".to_string(),
    })
}

async fn healthz() -> impl Responder {
    // TODO: Check dependencies like DB is ok
    HttpResponse::Ok().json(HealthcheckResponse {
        message: "Ok".to_string(),
    })
}

#[tokio::main]
async fn main() -> std::io::Result<()> {
    env_logger::init_from_env(env_logger::Env::new().default_filter_or("info"));

    // Bind to localhost in debug builds, or to any ipv4 port in release mode
    let bind_addr = if cfg!(debug_assertions) {
        "localhost"
    } else {
        "0.0.0.0"
    };

    HttpServer::new(|| {
        App::new()
            .wrap(Logger::default())
            .route("/", web::get().to(hello))
            .route("/livez", web::get().to(livez))
            .route("/healthz", web::get().to(healthz))
    })
    .bind((bind_addr, 8080))?
    .run()
    .await
}
