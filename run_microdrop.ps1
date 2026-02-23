# Define the expected arguments
param (
    [ValidateSet("dropbot", "opendrop")]
    [string]$Device = "dropbot", # Sets dropbot as the default if no argument is provided

    # Add a flag to safely stash uncommitted work before updating
    [switch]$Stash
)

# --- Determine Branch based on Device ---
if ($Device -eq "opendrop") {
    $Branch = "opendrop" # <-- CHANGE THIS if your OpenDrop branch has a different name
} else {
    $Branch = "main"
}

# Configuration: Paths
# Parent module path (microdrop-py)
$parentPath = Join-Path -Path $PSScriptRoot -ChildPath "microdrop-py"
# Application source path (microdrop-py\src)
$targetPath = Join-Path -Path $parentPath -ChildPath "src"

Write-Host "----------------------------------------" -ForegroundColor Cyan
Write-Host "      Pixi Microdrop Launcher           " -ForegroundColor Green
Write-Host "----------------------------------------" -ForegroundColor Cyan

# Check if Pixi is installed before trying any commands
if (-not (Get-Command "pixi" -ErrorAction SilentlyContinue)) {
    Write-Host "Error: 'pixi' command not found. Is it installed and in your PATH?" -ForegroundColor Red
    exit
}

# --- Step 1: Update Parent Module (microdrop-py) ---
if (Test-Path -Path $parentPath) {
    Write-Host "Updating Parent Module: $parentPath" -ForegroundColor Yellow
    Set-Location -Path $parentPath

    if ($Stash) {
        Write-Host "Stashing uncommitted changes in parent module..." -ForegroundColor DarkYellow
        & pixi run git stash
    }

    # We attempt to pull the parent repo
    Write-Host "Running 'pixi run git pull' on parent..." -ForegroundColor Cyan
    try {
        & pixi run git pull
    }
    catch {
        Write-Host "Warning: Could not pull parent module. Continuing..." -ForegroundColor DarkYellow
    }
    Write-Host "----------------------------------------" -ForegroundColor Cyan
}
else {
    Write-Host "Warning: Parent path not found at $parentPath" -ForegroundColor DarkYellow
}

# --- Step 2: Update Source & Run Microdrop (microdrop-py/src) ---
if (Test-Path -Path $targetPath) {
    Write-Host "Navigating to Source: $targetPath" -ForegroundColor Yellow
    Set-Location -Path $targetPath

    # Git Operations on src
    if ($Stash) {
        Write-Host "Stashing uncommitted changes in src module..." -ForegroundColor DarkYellow
        & pixi run git stash
    }

    # dynamically checking out the correct branch
    Write-Host "Checking for src updates on '$Branch' branch..." -ForegroundColor Cyan
    & pixi run git checkout $Branch
    & pixi run git pull
    Write-Host "----------------------------------------" -ForegroundColor Cyan

    # Use a switch statement exclusively to route the launch command
    switch ($Device) {
        "opendrop" {
            Write-Host "Starting OpenDrop Microdrop..." -ForegroundColor Green
            & pixi run opendrop-microdrop
        }
        "dropbot" {
            Write-Host "Starting DropBot Microdrop..." -ForegroundColor Magenta
            & pixi run microdrop
        }
    }
}
else {
    Write-Host "Error: The source folder path does not exist:" -ForegroundColor Red
    Write-Host "$targetPath" -ForegroundColor Red
}

# Pause at the end so the window doesn't close immediately if run via click
Write-Host "----------------------------------------" -ForegroundColor Cyan
Write-Host "Done." -ForegroundColor Gray
Read-Host "Press Enter to exit" # Uncomment if you want the window to stay open