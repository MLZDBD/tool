# Build Script for LuaTools Steam Plugin
param([string]$OutputName = "ltsteamplugin.zip", [switch]$Clean)
$ErrorActionPreference = "Stop"
$RootDir = $PSScriptRoot
$OutputPath = Join-Path $RootDir $OutputName
Write-Host "=== LuaTools Build Script ===" -ForegroundColor Cyan
if ($Clean -and (Test-Path $OutputPath)) { Remove-Item $OutputPath -Force }
Write-Host "Validating project structure..." -ForegroundColor Cyan
$RequiredFiles = @("plugin.json", "backend\main.py", "public\luatools.js")
foreach ($file in $RequiredFiles) {
    if (-not (Test-Path (Join-Path $RootDir $file))) { Write-Host "ERROR: $file not found" -ForegroundColor Red; exit 1 }
}
try {
    $version = (Get-Content (Join-Path $RootDir "plugin.json") | ConvertFrom-Json).version
    Write-Host "Plugin version: $version" -ForegroundColor Cyan
} catch { $version = "unknown" }
Write-Host "Creating ZIP file..." -ForegroundColor Cyan
Add-Type -AssemblyName System.IO.Compression.FileSystem
$TempZip = Join-Path $env:TEMP "luatools_build_$(Get-Date -Format 'yyyyMMddHHmmss').zip"
try {
    [System.IO.Compression.ZipFile]::CreateFromDirectory($RootDir, $TempZip)
    if (Test-Path $OutputPath) { Remove-Item $OutputPath -Force }
    Move-Item $TempZip $OutputPath
    Write-Host "Build completed successfully!" -ForegroundColor Green
} catch { Write-Host "ERROR: $_" -ForegroundColor Red }
Write-Host "=== Build Finished ===" -ForegroundColor Cyan
