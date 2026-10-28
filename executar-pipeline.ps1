$ErrorActionPreference = 'Stop'
Push-Location $PSScriptRoot
try {
    & npm.cmd ci
    if ($LASTEXITCODE -ne 0) { throw 'Falha na instalação.' }
    & npm.cmd run build
    if ($LASTEXITCODE -ne 0) { throw 'Falha no build.' }
    & npm.cmd test
    if ($LASTEXITCODE -ne 0) { throw 'Falha nos testes.' }
    Write-Host 'Pipeline local aprovado.'
} finally {
    Pop-Location
}
