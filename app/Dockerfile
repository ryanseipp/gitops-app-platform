FROM lukemathwalker/cargo-chef:0.1.72-rust-1.89.0-alpine3.22 AS chef
WORKDIR /app

FROM chef AS planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef as builder
COPY --from=planner /app/recipe.json recipe.json
RUN apk add --no-cache git && cargo chef cook --release --target x86_64-unknown-linux-musl --recipe-path recipe.json
COPY . .
RUN cargo build --release --target x86_64-unknown-linux-musl --bin hello-world

FROM alpine:3.22 AS runtime
RUN addgroup -S app && adduser -S app -G app
COPY --from=builder app/target/x86_64-unknown-linux-musl/release/hello-world /usr/local/bin/
USER app
EXPOSE 8080
CMD ["/usr/local/bin/hello-world"]
