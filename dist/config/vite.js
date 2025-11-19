import dirname from "./dirname.js";
/**
 * @type {import('vite').UserConfig['server']}
 */
export const server = {
  host: "0.0.0.0",
  fs: {
    allow: [dirname],
  },
};

/**
 * @type {import('vite').UserConfig}
 */
export default { server };
