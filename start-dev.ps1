$ErrorActionPreference = "Stop"1

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$backend = Join-Path $root "backend"
$frontend = Join-Path $root "frontend"
$mlService = Join-Path $root "ml-service"
$logs = Join-Path $root ".logs"

$backendPython = Join-Path $backend ".venv\Scripts\python.exe"
$mlPython = Join-Path $mlService ".venv\Scripts\python.exe"
$npmCmd = "npm.cmd"

if (-not (Test-Path $logs)) {
  New-Item -ItemType Directory -Path $logs | Out-Null
}

if (-not (Test-Path $backendPython)) {
  throw "Backend Python not found at $backendPython"
}

if (-not (Test-Path $mlPython)) {
  throw "ML service Python not found at $mlPython"
}

function Test-PortInUse($port) {
  return [bool](Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue)
}

function Start-ServiceProcess($name, $filePath, $arguments, $workingDirectory, $port, $stdoutLog, $stderrLog) {
  if (Test-PortInUse $port) {
    Write-Host "$name already running on port $port"
    return
  }

  if (Test-Path $stdoutLog) { Remove-Item $stdoutLog -Force }
  if (Test-Path $stderrLog) { Remove-Item $stderrLog -Force }

  Start-Process `
    -FilePath $filePath `
    -ArgumentList $arguments `
    -WorkingDirectory $workingDirectory `
    -WindowStyle Hidden `
    -RedirectStandardOutput $stdoutLog `
    -RedirectStandardError $stderrLog | Out-Null
}

Start-ServiceProcess `
  -name "Backend" `
  -filePath $backendPython `
  -arguments "manage.py runserver 127.0.0.1:8000 --noreload" `
  -workingDirectory $backend `
  -port 8000 `
  -stdoutLog (Join-Path $logs "backend.out.log") `
  -stderrLog (Join-Path $logs "backend.err.log")

Start-ServiceProcess `
  -name "ML service" `
  -filePath $mlPython `
  -arguments "-m uvicorn app.main:app --host 127.0.0.1 --port 8001 --reload" `
  -workingDirectory $mlService `
  -port 8001 `
  -stdoutLog (Join-Path $logs "ml-service.out.log") `
  -stderrLog (Join-Path $logs "ml-service.err.log")

Start-ServiceProcess `
  -name "Frontend" `
  -filePath $npmCmd `
  -arguments "run dev -- --host 127.0.0.1 --strictPort" `
  -workingDirectory $frontend `
  -port 5173 `
  -stdoutLog (Join-Path $logs "frontend.out.log") `
  -stderrLog (Join-Path $logs "frontend.err.log")

Write-Host ""
Write-Output "Development services started."
Write-Output "Frontend:  http://127.0.0.1:5173"
Write-Output "Backend:   http://127.0.0.1:8000/api"
Write-Output "ML Health: http://127.0.0.1:8001/health"
Write-Output "Logs:      $logs"
Write-Host ""
Write-Output "If a service was already running, stop the older process and rerun this script."
