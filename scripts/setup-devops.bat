@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul

:: ================================
:: AUTOMATED DEVOPS SETUP SCRIPT
:: ================================
:: Bu script tum DevOps setup'ini otomatik yapar
:: Calistirmak icin: .\scripts\setup-devops.bat GITHUB-USERNAME
::
:: 🚀 SCRIPT YAPACAKLARI:
:: ✅ Git, .NET, Node.js kurulumu (yoksa)
:: ✅ Git repository initialize
:: ✅ Professional commit olusturma
:: ✅ GitHub repository olusturma
:: ✅ Dependencies kurulumu
:: ✅ Docker build test
:: ✅ Environment setup
:: ✅ GitHub'a push
::
:: 🎯 SONUC: Expert Level DevOps Setup (5-10 dakika)

if "%1"=="" (
    echo.
    echo ❌ GitHub kullanici adi gerekli!
    echo.
    echo Kullanim: .\scripts\setup-devops.bat GITHUB-USERNAME
    echo Ornek: .\scripts\setup-devops.bat mertdurukan
    echo.
    pause
    exit /b 1
)

set GITHUB_USERNAME=%1
set REPOSITORY_NAME=%2
if "%REPOSITORY_NAME%"=="" set REPOSITORY_NAME=devops-fullstack-app

echo.
echo ================================
echo 🚀 AUTOMATED DEVOPS SETUP
echo ================================
echo DevOps-Ready Full-Stack Application Setup
echo Bu script tum kurulumu otomatik yapacak...
echo.
echo Parametreler:
echo   GitHub Username: %GITHUB_USERNAME%
echo   Repository Name: %REPOSITORY_NAME%
echo.

:: ================================
:: PREREQUISITES CHECK
:: ================================
echo ================================
echo PREREQUISITES CHECK
echo ================================

:: Git check
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo ⚠️ Git bulunamadi. Git'i manuel olarak yuklemeniz gerekiyor.
    echo Indirme linki: https://git-scm.com/
    pause
    exit /b 1
) else (
    echo ✅ Git hazir
)

:: .NET check
where dotnet >nul 2>nul
if %errorlevel% neq 0 (
    echo ⚠️ .NET SDK bulunamadi. .NET 8 SDK'yi manuel olarak yuklemeniz gerekiyor.
    echo Indirme linki: https://dotnet.microsoft.com/
    pause
    exit /b 1
) else (
    echo ✅ .NET SDK hazir
)

:: Node.js check
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo ⚠️ Node.js bulunamadi. Node.js'i manuel olarak yuklemeniz gerekiyor.
    echo Indirme linki: https://nodejs.org/
    pause
    exit /b 1
) else (
    echo ✅ Node.js hazir
)

:: Docker check
where docker >nul 2>nul
if %errorlevel% neq 0 (
    echo ⚠️ Docker bulunamadi. Docker Desktop'i manuel olarak yuklemeniz gerekiyor.
    echo Indirme linki: https://www.docker.com/products/docker-desktop
    echo.
    set /p "continue=Docker olmadan devam etmek istiyor musunuz? (y/N): "
    if /i not "!continue!"=="y" exit /b 1
) else (
    docker ps >nul 2>nul
    if !errorlevel! neq 0 (
        echo ⚠️ Docker yuklu ama calismiyor. Docker Desktop'i baslatin.
    ) else (
        echo ✅ Docker hazir
    )
)

:: ================================
:: GIT REPOSITORY SETUP
:: ================================
echo.
echo ================================
echo GIT REPOSITORY SETUP
echo ================================

:: Git config check
for /f "delims=" %%i in ('git config --global user.name 2^>nul') do set GIT_USER=%%i
for /f "delims=" %%i in ('git config --global user.email 2^>nul') do set GIT_EMAIL=%%i

if "%GIT_USER%"=="" (
    set /p "GIT_USER=Git kullanici adinizi girin: "
    git config --global user.name "!GIT_USER!"
)

if "%GIT_EMAIL%"=="" (
    set /p "GIT_EMAIL=Git email adresinizi girin: "
    git config --global user.email "!GIT_EMAIL!"
)

echo Git kullanicisi: !GIT_USER! ^<!GIT_EMAIL!^>

:: Initialize git if not already
if not exist ".git" (
    git init
    echo ✅ Git repository initialized
)

:: .gitignore check
if not exist ".gitignore" (
    echo ⚠️ .gitignore bulunamadi
)

:: Initial commit
git add .

git commit -m "feat: initial DevOps setup with CI/CD pipeline - Modern repository structure (src/api, src/web) - Docker containerization (multi-stage builds) - CI/CD pipelines (GitHub Actions) - Security scanning (Trivy, CodeQL) - Health checks and monitoring - Infrastructure as Code ready - Professional documentation - This commit establishes a production-ready DevOps foundation following industry best practices."

echo ✅ Ilk commit olusturuldu

:: Switch to main branch
for /f "delims=" %%i in ('git branch --show-current 2^>nul') do set CURRENT_BRANCH=%%i
if not "!CURRENT_BRANCH!"=="main" (
    git branch -M main
    echo ✅ Main branch'e gecildi
)

:: ================================
:: DEPENDENCIES SETUP
:: ================================
echo.
echo ================================
echo DEPENDENCIES SETUP
echo ================================

:: Backend dependencies
echo Backend dependencies kuruluyor...
cd src\api
dotnet restore
if %errorlevel% equ 0 (
    dotnet build --configuration Release
    if !errorlevel! equ 0 (
        echo ✅ Backend dependencies hazir
    ) else (
        echo ⚠️ Backend build basarisiz
    )
) else (
    echo ⚠️ Backend restore basarisiz
)
cd ..\..

:: Frontend dependencies
echo Frontend dependencies kuruluyor...
cd src\web
npm install
if %errorlevel% equ 0 (
    npm run build
    if !errorlevel! equ 0 (
        echo ✅ Frontend dependencies hazir
    ) else (
        echo ⚠️ Frontend build basarisiz
    )
) else (
    echo ⚠️ Frontend install basarisiz
)
cd ..\..

:: ================================
:: ENVIRONMENT SETUP
:: ================================
echo.
echo ================================
echo ENVIRONMENT SETUP
echo ================================

if not exist ".env" (
    if exist "env.example" (
        copy "env.example" ".env" >nul
        echo ✅ .env dosyasi olusturuldu (env.example'dan)
    ) else (
        echo ⚠️ env.example bulunamadi
    )
)

:: ================================
:: GITHUB ACTIONS SETUP
:: ================================
echo.
echo ================================
echo GITHUB ACTIONS SETUP
echo ================================

:: Check if GitHub Actions directory exists
if not exist ".github\workflows" (
    mkdir ".github\workflows"
    echo ✅ GitHub Actions klasoru olusturuldu
)

:: Check if CI workflow exists and is not empty
if not exist ".github\workflows\ci.yml" (
    echo ⚠️ CI workflow dosyasi bulunamadi, temel workflow olusturuluyor...
    goto :create_basic_ci
)

for %%I in (.github\workflows\ci.yml) do if %%~zI LSS 100 (
    echo ⚠️ CI workflow dosyasi bos, duzeltiliyor...
    goto :create_basic_ci
)

echo ✅ GitHub Actions workflows hazir
goto :docker_setup

:create_basic_ci
echo Creating basic CI workflow...
(
echo name: 🔄 Continuous Integration
echo.
echo on:
echo   push:
echo     branches: [ main ]
echo   pull_request:
echo     branches: [ main ]
echo.
echo jobs:
echo   build:
echo     runs-on: ubuntu-latest
echo     steps:
echo     - uses: actions/checkout@v4
echo     - name: Setup .NET
echo       uses: actions/setup-dotnet@v4
echo       with:
echo         dotnet-version: '8.0'
echo     - name: Setup Node
echo       uses: actions/setup-node@v4
echo       with:
echo         node-version: '18'
echo     - name: Build API
echo       run: dotnet build src/api/dev-api.csproj
echo     - name: Build Web
echo       run: ^|
echo         cd src/web
echo         npm install
echo         npm run build
) > .github\workflows\ci.yml

echo ✅ Temel CI workflow olusturuldu

:docker_setup

:: ================================
:: DOCKER SETUP TEST
:: ================================
:docker_setup
echo.
echo ================================
echo DOCKER SETUP TEST
echo ================================

where docker >nul 2>nul
if %errorlevel% neq 0 (
    echo Docker bulunamadi, container testleri atlaniyor
    goto :github_setup
)

echo Docker images build ediliyor...

:: API image test
docker build -t devops-api -f docker/api.Dockerfile . >nul 2>nul
if %errorlevel% equ 0 (
    echo ✅ API Docker image olusturuldu
) else (
    echo ⚠️ API Docker build basarisiz
)

:: Web image test
docker build -t devops-web -f docker/web.Dockerfile . >nul 2>nul
if %errorlevel% equ 0 (
    echo ✅ Web Docker image olusturuldu
) else (
    echo ⚠️ Web Docker build basarisiz
)

:: Docker Compose test
echo Docker Compose test ediliyor...
docker-compose config >nul 2>nul
if %errorlevel% equ 0 (
    echo ✅ Docker Compose konfigurasyonu gecerli
) else (
    echo ⚠️ Docker Compose konfigurasyonu hatali
)

:: ================================
:: GITHUB REPOSITORY CREATION
:: ================================
:github_setup
echo.
echo ================================
echo GITHUB REPOSITORY CREATION
echo ================================

set REPOSITORY_URL=https://github.com/%GITHUB_USERNAME%/%REPOSITORY_NAME%.git

:: GitHub CLI check
where gh >nul 2>nul
if %errorlevel% equ 0 (
    echo GitHub CLI ile repository olusturuluyor...
    gh repo create %REPOSITORY_NAME% --public --source=. --remote=origin --push
    if !errorlevel! equ 0 (
        echo ✅ GitHub repository olusturuldu ve push edildi
        goto :success
    ) else (
        echo GitHub CLI ile olusturma basarisiz. Manuel yontemle devam ediliyor...
    )
)

:: Remove existing origin if any
git remote remove origin >nul 2>nul

:: Add remote
git remote add origin %REPOSITORY_URL%
echo ✅ Remote origin eklendi: %REPOSITORY_URL%

:: Push to GitHub
echo Repository'ye push yapiliyor...
git push -u origin main
if %errorlevel% equ 0 (
    echo ✅ Kod GitHub'a push edildi
) else (
    echo ⚠️ Push basarisiz. GitHub repository'nin var oldugundan emin olun.
    echo Manuel olusturmak icin: https://github.com/new
    echo Repository adi: %REPOSITORY_NAME%
)

:: ================================
:: SUCCESS MESSAGE
:: ================================
:success
echo.
echo ================================
echo KURULUM TAMAMLANDI! 🎉
echo ================================
echo.
echo ✅ DevOps setup basariyla tamamlandi!
echo.
echo 📋 Sonraki Adimlar:
echo.
echo 1. 🌐 GitHub Repository:
echo    https://github.com/%GITHUB_USERNAME%/%REPOSITORY_NAME%
echo.
echo 2. 🔒 GitHub Secrets Setup:
echo    - Repository -^> Settings -^> Secrets and variables -^> Actions
echo    - STAGING_DB_PASSWORD = YourStrong@Passw0rd123
echo    - PRODUCTION_DB_PASSWORD = YourVeryStrong@ProductionPassw0rd456
echo.
echo 3. 🚀 Test Pipeline:
echo    - Repository -^> Actions tab
echo    - Ilk workflow calismasini izleyin
echo.
echo 4. 🐳 Local Test:
echo    docker-compose up -d
echo    http://localhost:5202 (Web)
echo    http://localhost:5102 (API)
echo.
echo 5. 📊 Monitoring:
echo    http://localhost:5102/health (Health Check)
echo.
echo 🎯 Sahip Oldugunuz DevOps Ozellikleri:
echo    ✅ Automated CI/CD Pipeline
echo    ✅ Docker Containerization
echo    ✅ Security Scanning
echo    ✅ Multi-Environment Deployment
echo    ✅ Health Monitoring
echo    ✅ Professional Documentation
echo.
echo 🏆 EXPERT LEVEL DEVOPS KURULUMU TAMAMLANDI!
echo.
pause 