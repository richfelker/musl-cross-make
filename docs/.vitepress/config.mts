import { defineConfig } from "vitepress";

export default defineConfig({
  base: "/musl/",
  title: "GNU / musl compilers by Dyne.org",
  description: "C/C++ toolchains ready to use",
  build: {
    sourcemap: false,
  },
  themeConfig: {
    aside: "left",
    footer: {
      copyright:
        'Brought to you by <a href="https://dyne.org">Dyne.org</a> - based on <a href="https://gnu.org">GNU</a> and <a href="https://musl-libc.org">musl-libc</a> - 100% Free and open source',
    },
    nav: [
      { text: "Home", link: "/" },
      { text: "Readme", link: "/readme" },
      { text: "Releases", link: "https://files.dyne.org/?dir=musl" },
    ],
    socialLinks: [
      { icon: "github", link: "https://github.com/dyne/musl" },
      { icon: "maildotru", link: "mailto:info@dyne.org" },
      { icon: "linkedin", link: "https://www.linkedin.com/company/dyne-org" },
    ],
  },
  markdown: {
    theme: {
      light: "catppuccin-latte",
      dark: "catppuccin-mocha",
    },
  },
});
