$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
$projectDir = "C:\Users\kennu\KiloTap-Prototype-062426"
$zipPath = "$projectDir\flutter_sdk.zip"
$extractPath = "$projectDir\flutter_sdk"

Write-Host "Removing partial zip..."
Remove-Item $zipPath -Force -ErrorAction SilentlyContinue

Write-Host "Downloading Flutter SDK..."
Invoke-WebRequest -Uri "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.5-stable.zip" -OutFile $zipPath -UseBasicParsing

Write-Host "Extracting Flutter SDK..."
Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

Write-Host "Setting PATH..."
$env:Path += ";$extractPath\flutter\bin"

Write-Host "Running flutter pub get..."
Set-Location $projectDir
flutter pub get

Write-Host "Running flutter analyze..."
flutter analyze

Write-Host "Done!"
