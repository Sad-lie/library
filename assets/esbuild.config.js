const esbuild = require('esbuild');

esbuild.build({
  entryPoints: ['src/index.js'], // adjust this based on your project structure
  bundle: true,
  outfile: 'dist/bundle.js', // adjust the output file path as needed
}).catch(() => process.exit(1));
