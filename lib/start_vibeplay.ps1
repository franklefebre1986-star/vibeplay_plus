# 🚀 VibePlay+ startscript voor Windows (zonder adminrechten)
Write-Host "== VibePlay+ IPTV wordt gestart ==" -ForegroundColor Cyan

# Stap 1: Ga naar projectmap
Set-Location "C:\Users\febref\mijn_iptv_app"

# Stap 2: Controleer of Flutter aanwezig is
$flutterPath = "C:\src\flutter\flutter\bin\flutter.bat"
if (-Not (Test-Path $flutterPath)) {
    Write-Host "❌ Flutter niet gevonden op $flutterPath"
    Write-Host "➡️  Controleer of Flutter uitgepakt is in C:\src\flutter"
    pause
    exit
}

# Stap 3: Dependencies ophalen
Write-Host "`n📦 Pakketten ophalen..." -ForegroundColor Yellow
& $flutterPath pub get

# Stap 4: App starten op web
Write-Host "`n🌍 App starten in webbrowser..." -ForegroundColor Green
& $flutterPath run -d web-server
