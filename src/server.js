import { createApp } from './app.js';
const server = createApp();
server.listen(Number(process.env.PORT || 3000), '127.0.0.1', () => console.log('DevFlow iniciada'));
for (const signal of ['SIGTERM', 'SIGINT']) {
  process.on(signal, () => server.close(() => process.exit(0)));
}
