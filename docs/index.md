---
# https://vitepress.dev/reference/default-theme-home-page
layout: home

hero:
  name: "musl dyne compilers"
  text: "C / C++ toolchains ready to use"
  tagline: Direct downloads (~50 MB each) to extract into /opt/musl-dyne
  image:
    src: https://dyne.org/images/logos/black-transparent-Icon.svg
    alt: Hands-on, Dyne.org style
  actions:
    - theme: brand
      text: X86 64‑bit
      link: 'https://github.com/dyne/musl-dyne/releases/download/0.2.2/musl-dyne-x86_64_hf.tar.xz'
    - theme: alt
      text: ARM HF 32‑bit
      link: 'https://github.com/dyne/musl-dyne/releases/download/0.2.2/musl-dyne-arm_hf.tar.xz'
    - theme: alt
      text: ARM 64‑bit
      link: 'https://github.com/dyne/musl-dyne/releases/download/0.2.2/musl-dyne-arm_64.tar.xz'
    - theme: alt
      text: RISC‑V 64‑bit
      link: 'https://github.com/dyne/musl-dyne/releases/download/0.2.2/musl-dyne-riscv_64.tar.xz'

features:
  - title: X86 64‑bit
    details: GCC 13.2.0 + Binutils 2.42 targeting **x86_64‑linux‑musl**; tuned for AVX2, PIE/static by default—perfect for scratch Docker images and minimal containers. :contentReference[oaicite:0]{index=0}
  - title: ARM 32‑bit (HF)
    details: Hard‑float toolchain for **armv7‑a** with Thumb‑2, NEON and VFPv4 enabled; produces small, fully static binaries that run on boards like Raspberry Pi 2/3 with zero external deps. :contentReference[oaicite:1]{index=1}
  - title: ARM 64‑bit
    details: AArch64 cross‑compiler aligned with Alpine‑style **aarch64‑musl** ABI; tuned for Cortex‑A53/A72, includes libstdc++ and libatomic for modern C++17/20 builds. :contentReference[oaicite:2]{index=2}
  - title: RISC‑V 64‑bit
    details: Multilib **rv64gc‑lp64d** suite verified on QEMU and VisionFive 2; static‑linked output boots on most 64‑bit RISC‑V SBCs and servers with no glibc baggage. :contentReference[oaicite:3]{index=3}

---
