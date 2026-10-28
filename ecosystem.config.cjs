module.exports = {
  apps: [{
    name: 'devflow', script: 'src/server.js', cwd: __dirname,
    instances: 1, exec_mode: 'fork',
    env: { NODE_ENV: 'production', PORT: '3000', RELEASE_SHA: process.env.RELEASE_SHA }
  }]
};
