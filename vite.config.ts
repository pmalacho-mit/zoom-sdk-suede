import { sveltekit } from "@sveltejs/kit/vite";
import { defineConfig } from "vite";
import path from "node:path";

export default defineConfig({
  plugins: [sveltekit()],
  server: {
    host: "0.0.0.0",
    fs: {
      allow: [
        path.resolve(__dirname, "dist"),
        path.resolve(__dirname, "dockview-svelte-suede"),
      ],
    },
  },
});
