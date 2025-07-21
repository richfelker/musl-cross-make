---

layout: home

hero:
  name: "C / C++ toolchains"
  text: "For static builds."
  tagline: Direct downloads ~50 MB each<br/>Extract into /opt/musl-dyne
  image:
    src: musl-logo-infinity-optimized.svg
    alt: Hands-on, Dyne.org style
  actions:
    - theme: brand
      text: X86 64‑bit
      link: 'https://files.dyne.org/?dir=musl'
    - theme: brand
      text: ARM HF 32‑bit
      link: 'https://files.dyne.org/?dir=musl'
    - theme: brand
      text: ARM 64‑bit
      link: 'https://files.dyne.org/?dir=musl'
    - theme: brand
      text: RISC‑V 64‑bit
      link: 'https://files.dyne.org/?dir=musl'

features:
  - title: 👟 Zero dependencies
    details: Produce static ELF binaries that run on any Linux distribution

  - title: 🚀 GCC 14.2 / Binutils 2.44
    details: Built with recent GNU tools and musl-libc releases

  - title: 🤏 Optimized for size
    details: Stripped and compiled with -Os to fit anywhere

  - title: 🦾 Latest C++ support
    details: Includes libstdc++ and libatomic for modern C++20 builds


---

<!--
<p>&nbsp;</p>
#### One liner root install
```bash
curl -sL dyne.org/musl/install.sh | bash -
```
#### Wizard setup (interactive)
```bash
curl -sL dyne.org/musl/wizard.sh && bash wizard.sh
```
-->
