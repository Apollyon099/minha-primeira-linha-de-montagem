import { createServer } from 'node:http';
export function createApp() {
  return createServer((req, res) => {
    res.setHeader('Content-Type', 'application/json; charset=utf-8');
    if (req.method !== 'GET') {
      res.writeHead(405, { Allow: 'GET' });
      return res.end(JSON.stringify({ error: 'Metodo nao permitido' }));
    }
    if (req.url === '/') {
      return res.end(JSON.stringify({ message: 'DevFlow Solutions - demonstracao CI/CD' }));
    }
    if (req.url === '/health') {
      return res.end(JSON.stringify({ status: 'ok', version: process.env.RELEASE_SHA || 'local' }));
    }
    res.writeHead(404);
    res.end(JSON.stringify({ error: 'Rota nao encontrada' }));
  });
}
