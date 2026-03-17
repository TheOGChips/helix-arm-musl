# Start from a container with Rust and Cargo pre-installed. Since we're
# cross-compiling for the MUSL target anyway, the architecture of the
# container doesn't actually matter.
FROM rust:latest

# Update APT repos and install needed utilities
RUN apt update && apt -y upgrade
RUN apt install -y wget git

# Add the ARMV6 MUSL target
RUN rustup target add arm-unknown-linux-musleabihf

WORKDIR /root

# Install the MUSL cross compilers. The musl-tools APT package only provides a
# C compiler, but some of the grammars for Helix require a C++ compiler.
RUN wget https://musl.cc/arm-linux-musleabihf-cross.tgz
RUN tar -xzf arm-linux-musleabihf-cross.tgz && rm arm-linux-musleabihf-cross.tgz
RUN mkdir -p /root/.local/bin && mv arm-linux-musleabihf-cross /root/.local/bin/
ENV PATH="$PATH:/root/.local/bin/arm-linux-musleabihf-cross/bin"

# Clone my fork of the Helix repository
RUN git clone https://github.com/TheOGChips/helix-arm-musl.git

# Build Helix for the Raspberry Pi Zero (or any ARMv6 target)
WORKDIR /root/helix-arm-musl
RUN cargo build --release

