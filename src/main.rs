use actix_web::{web, App, HttpServer, HttpRequest, HttpResponse, Responder};

#[tokio::main]
async fn main() -> Result<(), std::io::Error> {
    HttpServer::new(|| {
        App::new()
            .route("/", web::get().to(hello_world))
            .route("/{name}", web::get().to(hello_world))
            .route("/health_check", web::get().to(health_check))
    })
    .bind("127.0.0.1:8080")?
    .run()
    .await
}

async fn hello_world(req: HttpRequest) -> impl Responder {
    let name = req.match_info().get("name").unwrap_or("World");
    format!("Hello {}!\n", &name)
}

async fn health_check(_req: HttpRequest) -> impl Responder {
    HttpResponse::Ok()
}