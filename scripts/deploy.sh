#!/usr/bin/env bash
set -Eeuo pipefail
sha="${1:?Informe o SHA da versao}"
[[ "$sha" =~ ^[a-f0-9]{40}$ ]] || exit 2
base="$HOME/devflow"
release="$base/releases/$sha"
previous="$(readlink -f "$base/current" 2>/dev/null || true)"
mkdir -p "$release"
tar -xzf "$base/incoming/$sha.tgz" -C "$release"
cd "$release"
npm ci --omit=dev
node --check src/server.js
rollback() {
  trap - ERR
  echo 'Falha na publicacao; tentando restaurar a versao anterior.' >&2
  if [[ -n "$previous" && -f "$previous/ecosystem.config.cjs" ]]; then
    ln -sfn "$previous" "$base/current"
    RELEASE_SHA="$(basename "$previous")" pm2 startOrReload "$previous/ecosystem.config.cjs" --update-env
    pm2 save
  else
    echo 'Primeira publicacao: nao existe versao anterior para restaurar.' >&2
  fi
  exit 1
}
trap rollback ERR
ln -sfn "$release" "$base/current"
export RELEASE_SHA="$sha"
pm2 startOrReload "$release/ecosystem.config.cjs" --update-env
healthy=0
for attempt in {1..15}; do
  if node --input-type=module -e 'const r=await fetch("http://127.0.0.1:3000/health", {signal:AbortSignal.timeout(1500)});const j=await r.json();if(!r.ok||j.status!=="ok"||j.version!==process.env.RELEASE_SHA)process.exit(1)' ; then
    healthy=1; break
  fi
  sleep 1
done
[[ "$healthy" == 1 ]]
pm2 save
echo "Versao $sha publicada e verificada."
