import { sveltekit } from "@sveltejs/kit/vite";
import { defineConfig } from "vite";
import { server } from "./dist/config/vite.js";

export default defineConfig({
  plugins: [sveltekit()],
  server,
});
