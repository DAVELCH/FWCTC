$reconnectCount = 0
$startTime = Get-Date

while ($true) {

    $now = Get-Date
    $uptime = $now - $startTime
    $ip = (Get-NetIPAddress -AddressFamily IPv4 |
           Where-Object {$_.IPAddress -notlike "169.*" -and $_.IPAddress -ne "127.0.0.1"} |
           Select-Object -First 1 -ExpandProperty IPAddress)

    # --- DETECCIÓN REAL DE INTERNET ---
    try {
        $response = Invoke-WebRequest `
            -Uri "http://clients3.google.com/generate_204" `
            -UseBasicParsing `
            -TimeoutSec 5 `
            -ErrorAction Stop

        $online = ($response.StatusCode -eq 204)
    }
    catch {
        $online = $false
    }

    Clear-Host

    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host " DAVELCH'S FREE CLUB TOTALPLAY CONNECTOR " -ForegroundColor Cyan
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Hora: $($now.ToString('HH:mm:ss'))"
    Write-Host "IP Local: $ip"
    Write-Host "Reconexiones: $reconnectCount"
    Write-Host "Tiempo activo script: $([int]$uptime.TotalMinutes) min $([int]$uptime.Seconds) seg"
    Write-Host ""
    Write-Host "-----------------------------------------"
    Write-Host ""

    if ($online) {

        Write-Host "STATUS: CONNECTED" -ForegroundColor Green
        Write-Host "Internet real detectado (204 OK)."

    }
    else {

        Write-Host "STATUS: CONNECTING..." -ForegroundColor Red
        Write-Host "Lanzando portal (msedge.exe) minimizado..."

        Start-Process "msedge.exe" "http://10.1.1.1" -WindowStyle Minimized

        Start-Sleep -Seconds 8

        Write-Host "Cerrando msedge.exe..."
        TASKKILL /F /IM msedge.exe | Out-Null

        $reconnectCount++
    }

    Start-Sleep -Seconds 2
}
