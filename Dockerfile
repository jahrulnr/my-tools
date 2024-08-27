ARG baseImage=alpine:3.20

FROM $baseImage AS mountpoint-s3
ENV RUSTFLAGS="-C target-feature=-crt-static"
WORKDIR /builder
# hadolint ignore=DL3018
RUN apk add --no-cache \
    gcc curl git zlib g++ cmake make pkgconfig fuse fuse-dev \
    pkgconf alpine-sdk clang-dev fuse3-dev libunwind-dev \
    && curl -sSf https://sh.rustup.rs -o /builder/rustup.sh && sh /builder/rustup.sh -y \
    && git clone --recurse-submodules https://github.com/awslabs/mountpoint-s3.git
WORKDIR /builder/mountpoint-s3
# hadolint ignore=SC1091
RUN . "$HOME/.cargo/env" \
    && sed --in-place 's/aws_thread_id_t = 0/aws_thread_id_t = std::ptr::null_mut()/' mountpoint-s3-crt/src/s3/client.rs \
    && cargo build --release \
    && mv 

FROM $baseImage
ENV TZ=Asia/Jakarta
RUN apk add --no-cache g++ fuse3
COPY --from=mountpoint-s3 /builder/mountpoint-s3/target/release/mount-s3 /usr/sbin/mount-s3