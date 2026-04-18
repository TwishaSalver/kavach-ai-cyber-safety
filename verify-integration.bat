@echo off
REM Integration Verification Script for Cyber Safety Simulator

setlocal enabledelayedexpansion

echo.
echo ====================================
echo Integration Verification Checklist
echo ====================================
echo.

REM Colors for output (using ANSI codes)
set "SUCCESS=[OK]"
set "ERROR=[FAIL]"
set "WARNING=[WARN]"

REM Counter for issues
set ISSUES=0

REM ============ BACKEND CHECKS ============
echo.
echo ---- BACKEND INTEGRATION ----
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo %ERROR% Python not found. Install from: https://www.python.org/downloads/
    set /a ISSUES+=1
) else (
    for /f "tokens=*" %%i in ('python --version') do echo %SUCCESS% Python: %%i
)

REM Check main.py exists
if exist "kavach_backend\main.py" (
    echo %SUCCESS% kavach_backend\main.py found
) else (
    echo %ERROR% kavach_backend\main.py NOT found
    set /a ISSUES+=1
)

REM Check main.py has correct host
findstr /C:"host=" kavach_backend\main.py | findstr "0.0.0.0" >nul
if errorlevel 1 (
    echo %ERROR% main.py host is not "0.0.0.0"
    set /a ISSUES+=1
) else (
    echo %SUCCESS% main.py uses correct host (0.0.0.0)
)

REM Check main.py reload is False
findstr /C:"reload=" kavach_backend\main.py | findstr "False" >nul
if errorlevel 1 (
    echo %ERROR% main.py reload is not False
    set /a ISSUES+=1
) else (
    echo %SUCCESS% main.py reload is False (production mode)
)

REM Check requirements.txt
if exist "kavach_backend\requirements.txt" (
    echo %SUCCESS% kavach_backend\requirements.txt found
) else (
    echo %ERROR% kavach_backend\requirements.txt NOT found
    set /a ISSUES+=1
)

REM Check agents requirements.txt doesn't have streamlit
findstr /C:"streamlit" kavach_backend\agents\requirements.txt >nul
if not errorlevel 1 (
    echo %ERROR% agents\requirements.txt contains streamlit (should be removed)
    set /a ISSUES+=1
) else (
    echo %SUCCESS% agents\requirements.txt cleaned (no streamlit)
)

REM Check database.py
if exist "kavach_backend\database.py" (
    echo %SUCCESS% kavach_backend\database.py found
) else (
    echo %ERROR% kavach_backend\database.py NOT found
    set /a ISSUES+=1
)

REM Check schemas.py
if exist "kavach_backend\schemas.py" (
    echo %SUCCESS% kavach_backend\schemas.py found
) else (
    echo %ERROR% kavach_backend\schemas.py NOT found
    set /a ISSUES+=1
)

REM Check agent files
if exist "kavach_backend\agents\agent_manager.py" (
    echo %SUCCESS% kavach_backend\agents\agent_manager.py found
) else (
    echo %ERROR% kavach_backend\agents\agent_manager.py NOT found
    set /a ISSUES+=1
)

REM Check .env.example
if exist "kavach_backend\.env.example" (
    echo %SUCCESS% kavach_backend\.env.example found
) else (
    echo %ERROR% kavach_backend\.env.example NOT found
    set /a ISSUES+=1
)

REM ============ FRONTEND CHECKS ============
echo.
echo ---- FRONTEND INTEGRATION ----
echo.

REM Check Node.js is installed
node --version >nul 2>&1
if errorlevel 1 (
    echo %ERROR% Node.js not found. Install from: https://nodejs.org/
    set /a ISSUES+=1
) else (
    for /f "tokens=*" %%i in ('node --version') do echo %SUCCESS% Node.js: %%i
)

REM Check npm is installed
npm --version >nul 2>&1
if errorlevel 1 (
    echo %ERROR% npm not found
    set /a ISSUES+=1
) else (
    for /f "tokens=*" %%i in ('npm --version') do echo %SUCCESS% npm: %%i
)

REM Check frontend package.json
if exist "kavach_frontend\package.json" (
    echo %SUCCESS% kavach_frontend\package.json found
) else (
    echo %ERROR% kavach_frontend\package.json NOT found
    set /a ISSUES+=1
)

REM Check vite.config.ts
if exist "kavach_frontend\vite.config.ts" (
    echo %SUCCESS% kavach_frontend\vite.config.ts found
) else (
    echo %ERROR% kavach_frontend\vite.config.ts NOT found
    set /a ISSUES+=1
)

REM Check main.tsx
if exist "kavach_frontend\src\main.tsx" (
    echo %SUCCESS% kavach_frontend\src\main.tsx found
) else (
    echo %ERROR% kavach_frontend\src\main.tsx NOT found
    set /a ISSUES+=1
)

REM ============ DOCKER CHECKS ============
echo.
echo ---- DOCKER INTEGRATION ----
echo.

REM Check Dockerfile exists
if exist "Dockerfile" (
    echo %SUCCESS% Dockerfile found
) else (
    echo %ERROR% Dockerfile NOT found
    set /a ISSUES+=1
)

REM Check Docker is installed
docker --version >nul 2>&1
if errorlevel 1 (
    echo %WARNING% Docker not installed. Install from: https://www.docker.com/products/docker-desktop
) else (
    for /f "tokens=*" %%i in ('docker --version') do echo %SUCCESS% Docker: %%i
)

REM Check .dockerignore
if exist ".dockerignore" (
    echo %SUCCESS% .dockerignore found
) else (
    echo %ERROR% .dockerignore NOT found
    set /a ISSUES+=1
)

REM ============ CLOUD RUN CHECKS ============
echo.
echo ---- CLOUD RUN INTEGRATION ----
echo.

REM Check gcloud is installed
gcloud --version >nul 2>&1
if errorlevel 1 (
    echo %ERROR% gcloud CLI not installed. Install from: https://cloud.google.com/sdk/docs/install
    set /a ISSUES+=1
) else (
    echo %SUCCESS% gcloud CLI installed
    
    REM Check if authenticated
    gcloud auth list 2>&1 | findstr "ACTIVE" >nul
    if errorlevel 1 (
        echo %ERROR% Not authenticated with gcloud. Run: gcloud auth login
        set /a ISSUES+=1
    ) else (
        echo %SUCCESS% gcloud authenticated
    )
    
    REM Check project is set
    for /f "tokens=*" %%i in ('gcloud config get-value project 2^>nul') do (
        if "%%i"=="cyber-agent-492615" (
            echo %SUCCESS% Project set to cyber-agent-492615
        ) else (
            echo %WARNING% Project is "%%i", should be "cyber-agent-492615"
        )
    )
)

REM Check deployment scripts
if exist "deploy-cloud-run.bat" (
    echo %SUCCESS% deploy-cloud-run.bat found
) else (
    echo %ERROR% deploy-cloud-run.bat NOT found
    set /a ISSUES+=1
)

if exist "deploy-cloud-run.sh" (
    echo %SUCCESS% deploy-cloud-run.sh found
) else (
    echo %ERROR% deploy-cloud-run.sh NOT found
    set /a ISSUES+=1
)

REM ============ DOCUMENTATION CHECKS ============
echo.
echo ---- DOCUMENTATION ----
echo.

if exist "CLOUD_RUN_DEPLOYMENT.md" (
    echo %SUCCESS% CLOUD_RUN_DEPLOYMENT.md found
) else (
    echo %ERROR% CLOUD_RUN_DEPLOYMENT.md NOT found
    set /a ISSUES+=1
)

if exist "DEPLOYMENT_STEPS.md" (
    echo %SUCCESS% DEPLOYMENT_STEPS.md found
) else (
    echo %ERROR% DEPLOYMENT_STEPS.md NOT found
    set /a ISSUES+=1
)

if exist "RUN_INSTRUCTIONS.txt" (
    echo %SUCCESS% RUN_INSTRUCTIONS.txt found
) else (
    echo %ERROR% RUN_INSTRUCTIONS.txt NOT found
    set /a ISSUES+=1
)

REM ============ SUMMARY ============
echo.
echo ====================================
echo INTEGRATION VERIFICATION SUMMARY
echo ====================================
echo.

if %ISSUES% equ 0 (
    echo %SUCCESS% All checks passed! Application is ready for deployment.
    echo.
    echo Next steps:
    echo 1. Install Docker Desktop if not already installed
    echo 2. Add GEMINI_API_KEY to kavach_backend\.env
    echo 3. Run: deploy-cloud-run.bat
    echo.
) else (
    echo %ERROR% %ISSUES% issue(s) found. Please review above.
    echo.
)

echo ====================================
echo.
pause
