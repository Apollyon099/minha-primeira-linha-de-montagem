import test from 'node:test';
import assert from 'node:assert/strict';
import { once } from 'node:events';
import { createApp } from '../src/app.js';
test('contrato HTTP da aplicacao', async (t) => {
  const server = createApp();
  server.listen(0, '127.0.0.1');
  await once(server, 'listening');
  t.after(() => new Promise((resolve) => server.close(resolve)));
  const url = `http://127.0.0.1:${server.address().port}`;
  await t.test('rota inicial retorna JSON e status 200', async () => {
    const response = await fetch(url);
    assert.equal(response.status, 200);
    assert.match(response.headers.get('content-type'), /application\/json/);
    assert.match((await response.json()).message, /DevFlow/);
  });
  await t.test('health informa que o servico esta ativo', async () => {
    const response = await fetch(`${url}/health`);
    assert.equal(response.status, 200);
    assert.equal((await response.json()).status, 'ok');
  });
  await t.test('rota desconhecida retorna 404', async () => {
    assert.equal((await fetch(`${url}/inexistente`)).status, 404);
  });
  await t.test('metodo nao suportado retorna 405', async () => {
    const response = await fetch(url, { method: 'POST' });
    assert.equal(response.status, 405);
    assert.equal(response.headers.get('allow'), 'GET');
  });
});
