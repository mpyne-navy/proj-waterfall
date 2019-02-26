extern crate actix_web;
extern crate askama;

use std::collections::HashMap; // seems implicit for HTTP request queries in actix-web?
use actix_web::{http, server, App, fs, Query, Result, HttpResponse};
use askama::Template;

#[derive(Template)]
#[template(path = "login.html")]
struct LoginTemplate {
}

#[derive(Template)]
#[template(path = "logout.html")]
struct LogoutTemplate {
}

enum PageToShow {
    Login,
    Logout,
}

fn generate_page(page: PageToShow)
    -> Result<HttpResponse>
{
    let s = match page {
        PageToShow::Login  => LoginTemplate {}.render().unwrap(),
        PageToShow::Logout => LogoutTemplate{}.render().unwrap(),
    };

    Ok(HttpResponse::Ok().content_type("text/html").body(s))
}

fn show_login_page(_query: Query<HashMap<String, String>>)
    -> Result<HttpResponse>
{
    generate_page(PageToShow::Login)
}

fn show_logout_page(_query: Query<HashMap<String, String>>)
    -> Result<HttpResponse>
{
    generate_page(PageToShow::Logout)
}

fn main() {
    server::new(|| App::new()
                    .handler("/static", fs::StaticFiles::new("static").unwrap())
                    .resource("/", |r| r.method(http::Method::GET).with(show_login_page))
                    .resource("/logged_in", |r| r.method(http::Method::GET).with(show_logout_page))
                )
        .bind("127.0.0.1:8088")
        .unwrap()
        .run();
}
