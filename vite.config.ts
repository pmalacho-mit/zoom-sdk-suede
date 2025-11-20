import { sveltekit } from "@sveltejs/kit/vite";
import { defineConfig } from "vite";
import { server, plugins, build } from "./dist/config/vite.js";

export default defineConfig({
  plugins: [sveltekit(), ...plugins({ assetDir: "static" })],
  server,
  build,
});
