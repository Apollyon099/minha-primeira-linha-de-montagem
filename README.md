# DevFlow Solutions — atividade S23A1

Aplicação didática, independente do InsightPME. Requer Node.js 24 e npm.
Não implementa loja, pagamentos ou banco: demonstra uma rota, testes e deploy.

## Configuração neste computador

No PowerShell aberto nesta pasta, execute `./iniciar.ps1` para usar a porta 3083,
ou `./executar-pipeline.ps1` para repetir instalação, build e testes.
O endereço local é http://127.0.0.1:3083/ e a saúde está em /health.
O servidor local iniciado pelo assistente é um processo em segundo plano,
sem inicialização automática após reiniciar o Windows.

O deploy remoto começa desativado. Após configurar os servidores, ambientes
e secrets, crie a variável de repositório ENABLE_DEPLOY com valor true em
Settings > Secrets and variables > Actions > Variables.
Enquanto essa variável não estiver habilitada, o GitHub executará somente CI.

## Executar e validar localmente

```powershell
npm ci
npm run build
npm test
npm start
```

Abra http://127.0.0.1:3000/ e /health. Pare com Ctrl+C.
Build verifica a sintaxe; JavaScript não precisa de compilação neste exemplo.

## Preparar o GitHub

Crie um repositório vazio na sua conta e use a URL real no lugar do exemplo:

```powershell
git init -b main
git add .
git commit -m "Configura pipeline CI CD"
git remote add origin https://github.com/SEU_USUARIO/devflow-cicd.git
git push -u origin main
git switch -c develop
git push -u origin develop
git switch -c staging main
git push -u origin staging
```

Prepare servidores e secrets ANTES de habilitar ENABLE_DEPLOY.
Em Settings > Environments, crie development, staging e production.
Cada ambiente deve ter um servidor Linux de teste independente e estes secrets:

- DEPLOY_HOST: domínio ou IPv4 do servidor, sem protocolo, na porta SSH 22.
- DEPLOY_USER: usuário Linux dedicado, sem root.
- SSH_PRIVATE_KEY: chave privada exclusiva daquele ambiente, sem senha interativa.
- SSH_KNOWN_HOSTS: linha conhecida do host, validada com o administrador.

Não publique chaves privadas no código. Não copie secrets para o relatório.
Na sua máquina, gere uma chave dedicada com `ssh-keygen -t ed25519 -C "devflow-deploy"`.
Instale apenas a chave pública no authorized_keys do usuário de deploy do servidor.
Compare a impressão digital do host por um canal confiável antes de confiar na linha
known_hosts; uma coleta com ssh-keyscan sozinha não comprova a identidade do host.
Use permissões 700 na pasta .ssh e 600 no authorized_keys.

Environments e regras de aprovação dependem do plano GitHub e da visibilidade do
repositório. Confira a documentação oficial antes de escolher um repositório privado.
Quando disponível, exija aprovação no environment production e restrinja-o à main.
Configure proteção de branches e exija CI aprovada antes do merge.

## Preparar cada servidor Linux

Instale Node.js 24, npm, tar e PM2 de fonte oficial. Configure PM2 no usuário de deploy,
incluindo PATH em sessões SSH não interativas. Verifique com `node --version`,
`npm --version` e `pm2 --version` em uma conexão SSH não interativa.
Execute `pm2 startup` e siga a configuração indicada para o usuário, se quiser
restaurar os processos após reiniciar o servidor. O deploy executa `pm2 save`.

O workflow envia o pacote testado e o script via SSH. Não requer token GitHub
no servidor nem git pull. O script é executado com bash e não depende de chmod +x.
A aplicação escuta apenas em 127.0.0.1:3000. Para acesso público, configure um
proxy reverso (por exemplo, Nginx) com HTTPS encaminhando para esse endereço.
Não utilize credenciais reais ou dados de clientes neste exercício.

## Fluxo e verificação remota

PRs para develop, staging ou main executam CI sem publicar. Push para develop
publica em development, staging publica em staging e main publica em production.
Promova alterações por PRs, revisando os resultados em cada ambiente.
O job de deploy depende do sucesso de build-and-test. O pacote transferido é
o artefato que passou pelos testes. Deploys da mesma branch são serializados.
O script verifica /health e o SHA publicado e tenta restaurar a versão anterior
se a ativação ou a verificação falhar. No primeiro deploy não existe rollback.
O modo PM2 usado pode causar breve interrupção: zero downtime não é garantido.
Para produção, avaliar blue-green, monitoramento externo e rollback testado.

Na aba Actions, confira CI, deploy, ambiente e SHA. Confira também a URL pública.
Registre evidências reais, com secrets ocultos. Falha de SSH: verificar usuário,
chave pública, host conhecido, porta e conectividade. Falha do aplicativo: consultar
logs PM2, permissões e versão do Node. Há retenção de versões no servidor;
defina uma rotina de limpeza após validar a política de rollback e espaço em disco.

## Documentação oficial

- https://docs.github.com/pt/actions/get-started/quickstart
- https://docs.github.com/en/actions/how-tos/deploy/configure-and-manage-deployments/manage-environments
- https://nodejs.org/api/test.html
