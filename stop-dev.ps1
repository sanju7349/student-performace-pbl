$ports = 5173, 8000, 8001
##
foreach ($port in $ports) {
  $connections = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue
  foreach ($connection in $connections) {
    try {
      Stop-Process -Id $connection.OwningProcess -Force -ErrorAction Stop
      Write-Host "Stopped process $($connection.OwningProcess) on port $port"
    } catch {
      Write-Host "Unable to stop process $($connection.OwningProcess) on port $port"
    }
  }
}
