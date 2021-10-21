FROM rust:1.43 as builder

RUN USER=root cargo new --bin rust-hello
WORKDIR ./rust-hello
COPY ./Cargo.toml ./Cargo.toml
RUN cargo build --release
RUN rm src/*.rs

ADD . ./

RUN rm ./target/release/deps/rust_hello*
RUN cargo build --release


FROM debian:buster-slim
ARG APP=/usr/src/app

ENV TZ=Etc/UTC \
    APP_USER=appuser

RUN groupadd $APP_USER \
    && useradd -g $APP_USER $APP_USER \
    && mkdir -p ${APP}

COPY --from=builder /rust-hello/target/release/rust-hello ${APP}/rust-hello

RUN chown -R $APP_USER:$APP_USER ${APP}

USER $APP_USER
WORKDIR ${APP}

CMD ["./rust-hello"]
