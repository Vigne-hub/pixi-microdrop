# Configuration: Enter the path to the folder where you want the command to run
# $targetPath = ".\microdrop-py"

# Optional: If you want to run it in the *same* folder where this script is saved, uncomment the line below:
$targetPath = "$PSScriptRoot\microdrop-py\src"

Write-Host "----------------------------------------" -ForegroundColor Cyan
Write-Host "      Pixi Microdrop Launcher           " -ForegroundColor Green
Write-Host "----------------------------------------" -ForegroundColor Cyan

# Check if the folder exists
if (Test-Path -Path $targetPath) {
    Write-Host "Navigating to: $targetPath" -ForegroundColor Yellow
    Set-Location -Path $targetPath

    # Check if Pixi is installed before trying any commands
    if (Get-Command "pixi" -ErrorAction SilentlyContinue) {

        # --- Step 1: Git Pull (via Pixi) ---
        Write-Host "Checking for updates (pixi run git pull)..." -ForegroundColor Cyan
        & pixi run git checkout main # always be in main branch
        & pixi run git pull
        Write-Host "----------------------------------------" -ForegroundColor Cyan

        # --- Step 2: Run Microdrop ---
        Write-Host "Running 'pixi run microdrop'..." -ForegroundColor Magenta
        & pixi run microdrop

    }
    else {
        Write-Host "Error: 'pixi' command not found. Is it installed and in your PATH?" -ForegroundColor Red
    }
}
else {
    Write-Host "Error: The folder path does not exist:" -ForegroundColor Red
    Write-Host "$targetPath" -ForegroundColor Red
    Write-Host "Please edit the script file to set the correct path." -ForegroundColor Gray
}

Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
