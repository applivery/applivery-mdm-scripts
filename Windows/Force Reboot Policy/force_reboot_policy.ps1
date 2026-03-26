# --- CONFIGURACIÓN DE PRUEBA ---
$SimulatedUptime = 15  # <--- CAMBIA ESTE VALOR (5, 10, 15) PARA PROBAR CADA AVISO
$ForceRestart = $true  # Cambiar a $false si solo quieres ver el mensaje sin reiniciar el PC

# --- LÓGICA DEL SCRIPT ---
Write-Host "Iniciando prueba de eficiencia de reinicio..." -ForegroundColor Cyan

if ($SimulatedUptime -ge 15) {
    Write-Host "FASE: Límite alcanzado (Día 15). Ejecutando cuenta atrás." -ForegroundColor Red
    if ($ForceRestart) {
        # Comando oficial de Windows: /r (reinicio), /f (forzar), /t (segundos), /c (mensaje)
        shutdown /r /f /t 300 /c "PRUEBA APPLIVERY: El equipo ha alcanzado el limite de 15 dias. Reinicio automatico en 5 minutos."
    }
}
elseif ($SimulatedUptime -ge 10) {
    Write-Host "FASE: Aviso crítico (Día 10)." -ForegroundColor Yellow
    $msg = "AVISO DE SEGURIDAD (TEST): Su equipo lleva $SimulatedUptime dias sin reiniciar. Por favor, reinicie antes del dia 15."
    msg * $msg
}
elseif ($SimulatedUptime -ge 5) {
    Write-Host "FASE: Recordatorio inicial (Día 5)." -ForegroundColor Green
    $msg = "RECORDATORIO (TEST): Para mejorar el rendimiento, se recomienda reiniciar. Uptime actual: $SimulatedUptime dias."
    msg * $msg
}
else {
    Write-Host "El equipo cumple con la politica de reinicio (Uptime: $SimulatedUptime dias)." -ForegroundColor White
}