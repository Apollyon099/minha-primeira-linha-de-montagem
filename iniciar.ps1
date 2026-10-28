$ErrorActionPreference = 'Stop'
Push-Location $PSScriptRoot
$portaAnterior = $env:PORT
try {
    $env:PORT = '3083'
    Write-Host 'DevFlow local em http://127.0.0.1:3083 - Ctrl+C para encerrar'
    & node src/server.js
    if ($LASTEXITCODE -ne 0) { throw 'A aplicação não iniciou. Confira se a porta 3083 está livre.' }
} finally {
    $env:PORT = $portaAnterior
    Pop-Location
}
