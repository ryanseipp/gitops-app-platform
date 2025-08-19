FROM lukemathwalker/cargo-chef:0.1.72-rust-1.89.0-alpine3.22@sha256:6535d651f5987d74e6850681cc0edd0fc44e22198d223243510c85abe08d1efd AS chef
WORKDIR /app

FROM chef AS planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef AS builder
COPY --from=planner /app/recipe.json recipe.json
RUN apk add --no-cache git && cargo chef cook --release --target x86_64-unknown-linux-musl --recipe-path recipe.json
COPY . .
RUN cargo build --release --target x86_64-unknown-linux-musl --bin hello-world


FROM alpine:3.22@sha256:4bcff63911fcb4448bd4fdacec207030997caf25e9bea4045fa6c8c44de311d1 AS runtime
RUN addgroup --gid 1000 -S app && adduser --uid 1000 -S app -G app
COPY --from=builder app/target/x86_64-unknown-linux-musl/release/hello-world /usr/local/bin/
USER 1000
EXPOSE 8080
CMD ["/usr/local/bin/hello-world"]
