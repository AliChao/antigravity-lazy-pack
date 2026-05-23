param (
    [Parameter(Mandatory=$true)]
    [ValidateSet("Init", "Start", "Stop")]
    [string]$Action
)

$WorkDir = [System.IO.Path]::GetFullPath(".")

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "   Antigravity SOP Automation Control Centre" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Action: $Action"
Write-Host "Directory: $WorkDir"
Write-Host ""

switch ($Action) {
    "Init" {
        Write-Host "[SOP] Initializing Project..." -ForegroundColor Green
        
        # 1. Git Init
        if (-not (Test-Path ".git")) {
            Write-Host "Initializing Git Repository..." -ForegroundColor Gray
            git init
        } else {
            Write-Host "Git already initialized." -ForegroundColor Gray
        }

        # 2. Basic .gitignore
        if (-not (Test-Path ".gitignore")) {
            Write-Host "Creating .gitignore..." -ForegroundColor Gray
            $GitIgnoreContent = @(
                "node_modules/",
                "dist/",
                "build/",
                "bin/",
                "obj/",
                "*.log",
                ".env",
                ".system_generated/",
                "brain/",
                "scratch/"
            )
            Set-Content -Path ".gitignore" -Value $GitIgnoreContent
        }

        # 3. Git commit
        Write-Host "Staging files..." -ForegroundColor Gray
        git add .
        Write-Host "Creating initial commit..." -ForegroundColor Gray
        git commit -m "Initial commit by Antigravity SOP"

        # 4. GitHub Remote
        Write-Host "Creating GitHub Repository..." -ForegroundColor Gray
        $Folder = Split-Path $WorkDir -Leaf
        & "C:\Users\STONE\.gemini\antigravity\bin\gh.exe" repo create $Folder --public --source=. --push --remote=origin
        
        Write-Host "==================================================" -ForegroundColor Green
        Write-Host "Project Initialization Successful!" -ForegroundColor Green
        Write-Host "==================================================" -ForegroundColor Green
    }

    "Start" {
        Write-Host "[SOP] Starting Work Session..." -ForegroundColor Green
        
        # 1. Check Git Status
        if (Test-Path ".git") {
            Write-Host "--- Git Repository Status ---" -ForegroundColor Yellow
            git status -s
            Write-Host ""
            Write-Host "--- Recent commits ---" -ForegroundColor Yellow
            git log -n 3 --oneline
            Write-Host ""
        } else {
            Write-Host "Warning: Current directory is not a Git repository." -ForegroundColor Red
        }

        # 2. Parse ANTIGRAVITY.md Todo List
        if (Test-Path "ANTIGRAVITY.md") {
            Write-Host "--- Today's Todo List (from ANTIGRAVITY.md) ---" -ForegroundColor Yellow
            $Lines = Get-Content -Path "ANTIGRAVITY.md"
            $InTodoSection = $false
            $FoundTodos = $false
            
            foreach ($Line in $Lines) {
                if ($Line.StartsWith("## ") -and $Line -match "待辦清單|Todo") {
                    $InTodoSection = $true
                    continue
                }
                if ($InTodoSection -and $Line.StartsWith("## ")) {
                    $InTodoSection = $false
                }
                if ($InTodoSection -and $Line.Trim().Length -gt 0) {
                    Write-Host $Line -ForegroundColor Cyan
                    $FoundTodos = $true
                }
            }
            if (-not $FoundTodos) {
                Write-Host "No pending tasks found in ANTIGRAVITY.md." -ForegroundColor Gray
            }
            Write-Host ""
        } else {
            Write-Host "Warning: ANTIGRAVITY.md cockpit file not found." -ForegroundColor Red
        }

        Write-Host "SOP Start completed. Ready to write code! 🚀" -ForegroundColor Green
    }

    "Stop" {
        Write-Host "[SOP] Stopping Work Session..." -ForegroundColor Green

        # 1. Security scan for credentials
        Write-Host "Scanning codebase for active credentials/secrets..." -ForegroundColor Yellow
        $ScanPatterns = @("api_key", "secret_key", "passwd", "password", "token")
        $Files = Get-ChildItem -Recurse -File | Where-Object { 
            $_.FullName -notmatch "node_modules|.git|sop-actions.ps1|package-project.ps1|ANTIGRAVITY.md|.png|.jpg|.m4a"
        }
        
        $LeakFound = $false
        foreach ($File in $Files) {
            try {
                $FileContent = Get-Content -Path $File.FullName -Raw
                foreach ($Pattern in $ScanPatterns) {
                    if ($FileContent -match "(?i)$Patterns*=s*['`"]w+['`"]" -or $FileContent -match "(?i)$Patterns*:s*['`"]w+['`"]") {
                        Write-Host "CRITICAL WARNING: Potential credential leak found in $($File.FullName) matching pattern '$Pattern'!" -ForegroundColor Red
                        $LeakFound = $true
                    }
                }
            } catch {}
        }
        
        if ($LeakFound) {
            Write-Host "SOP execution stopped to prevent secret leakage. Please remove secrets before pushing." -ForegroundColor Red
            exit 1
        }
        Write-Host "Security scan passed. No exposed secrets found." -ForegroundColor Gray
        Write-Host ""

        # 2. Git Status Check & Auto Commit
        if (Test-Path ".git") {
            $Changes = git status --porcelain
            if ([string]::IsNullOrEmpty($Changes)) {
                Write-Host "No changes to commit." -ForegroundColor Gray
            } else {
                Write-Host "Changes detected. Committing..." -ForegroundColor Yellow
                git add .
                
                # Build descriptive message
                $CommitMsg = "Auto-commit by Antigravity SOP: Updated files"
                git commit -m $CommitMsg
                
                Write-Host "Pushing to GitHub..." -ForegroundColor Yellow
                git push origin
                Write-Host "GitHub synchronization complete!" -ForegroundColor Green
            }
        } else {
            Write-Host "Warning: Not a Git repository, skipping push." -ForegroundColor Red
        }
        Write-Host ""

        # 3. Sync to Google Drive / NotebookLM
        $PackagerPath = "C:\Users\STONE\.gemini\antigravity\scratch\package-project.ps1"
        if (Test-Path $PackagerPath) {
            Write-Host "Triggering NotebookLM Google Drive Packager..." -ForegroundColor Yellow
            powershell -ExecutionPolicy Bypass -File $PackagerPath -SourceDir "."
        } else {
            # Try workspace fallback
            if (Test-Path "package-project.ps1") {
                Write-Host "Triggering NotebookLM Google Drive Packager (fallback)..." -ForegroundColor Yellow
                powershell -ExecutionPolicy Bypass -File "package-project.ps1" -SourceDir "."
            } else {
                Write-Host "Warning: NotebookLM packager script not found." -ForegroundColor Red
            }
        }

        Write-Host ""
        Write-Host "==================================================" -ForegroundColor Green
        Write-Host "SOP Stop Completed Successfully. Excellent work today! ☕" -ForegroundColor Green
        Write-Host "==================================================" -ForegroundColor Green
    }
}
