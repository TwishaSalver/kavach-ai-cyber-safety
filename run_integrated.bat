@echo off
echo ========================================
echo  KAVACH AI - INTEGRATED STARTUP
echo ========================================
echo.

echo Building frontend...
cd kavach_frontend
call npm run build
if %errorlevel% neq 0 (
    echo Frontend build failed!
    pause
    exit /b 1
)

echo Copying frontend to backend static directory...
if exist ..\kavach_backend\static rmdir /s /q ..\kavach_backend\static
mkdir ..\kavach_backend\static
xcopy dist\* ..\kavach_backend\static\ /E /I /Y >nul

echo.
echo Starting integrated server on port 8000...
cd ..\kavach_backend
python main.py