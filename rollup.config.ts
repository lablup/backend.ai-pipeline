import resolve from 'rollup-plugin-node-resolve';
import { terser } from "rollup-plugin-terser";

export default {
  input: ['src/components/backend-ai-pipeline.js'],
  output: {
    dir: 'build/rollup/src/components',
    format: 'es',
    sourcemap: false
  },
  plugins: [
    terser(),
    resolve()
  ]
};
