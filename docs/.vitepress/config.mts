import { defineConfig } from "vitepress";

// https://vitepress.dev/reference/site-config
export default defineConfig({
  base: "/musl/",
  title: "musl dyne compilers",
  description: "C/C++ toolchains ready to use",
  themeConfig: {
    footer: {
      copyright:
        'Copyright (C) 2025 <a href="https://dyne.org">Dyne.org</a> - MIT License',
    },
    // https://vitepress.dev/reference/default-theme-config
    nav: [
      { text: "Home", link: "/" },
      { text: "Dyne.org", link: "https://dyne.org" },
      { text: "Musl", link: "https://musl-libc.org" },
      { text: "GCC", link: "https://gcc.gnu.org" },
    ],
    sidebar: [
      {
        text: "Links",
        items: [
          {
            text: "Readme",
            link: "https://github.com/dyne/musl-dyne/blob/master/README.md",
          },
          {
            text: "Downloads",
            link: "https://github.com/dyne/musl-dyne/releases",
          },
          {
            text: "Security",
            link: "https://github.com/dyne/musl-dyne?tab=security-ov-file#readme",
          },
        ],
      },
    ],
    socialLinks: [
      { icon: "linkedin", link: "https://www.linkedin.com/company/dyne-org" },
      { icon: "mastodon", link: "https://toot.community/@dyne" },
      { icon: "github", link: "https://github.com/dyne/musl-dyne" },
      { icon: "maildotru", link: "mailto:info@dyne.org" },
    ],
  },
  markdown: {
    theme: {
      light: "catppuccin-latte",
      dark: "catppuccin-mocha",
    },
  },
});
