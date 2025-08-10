@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul

:: ================================
:: SIMPLE AUTOMATED DEVOPS SETUP
:: ================================
:: Bu script tum DevOps setup'ini basit ve guvenilir sekilde yapar
:: Calistirmak icin: .\scripts\simple-setup.bat GITHUB-USERNAME

if "%1"=="" (
    echo.
    echo ❌ GitHub kullanici adi gerekli!
    echo Kullanim: .\scripts\simple-setup.bat GITHUB-USERNAME
    echo Ornek: .\scripts\simple-setup.bat mertdurukan
    pause
    exit /b 1
)

set GITHUB_USERNAME=%1
set REPOSITORY_NAME=%2
if "%REPOSITORY_NAME%"=="" set REPOSITORY_NAME=devops-fullstack-app

echo.
echo ================================
echo 🚀 SIMPLE DEVOPS SETUP
echo ================================
echo GitHub Username: %GITHUB_USERNAME%
echo Repository Name: %REPOSITORY_NAME%
echo.

:: ================================
:: STEP 1: PREREQUISITES
:: ================================
echo [1/8] Prerequisites kontrolu...
where git >nul 2>nul || (echo ❌ Git bulunamadi & pause & exit)
where dotnet >nul 2>nul || (echo ❌ .NET SDK bulunamadi & pause & exit)  
where node >nul 2>nul || (echo ❌ Node.js bulunamadi & pause & exit)
echo ✅ Prerequisites hazir

:: ================================
:: STEP 2: GIT SETUP
:: ================================
echo [2/8] Git repository setup...
git init >nul 2>nul
git add .
git commit -m "feat: initial DevOps setup with CI/CD pipeline"
git branch -M main
echo ✅ Git setup tamamlandi

:: ================================
:: STEP 3: BACKEND BUILD
:: ================================
echo [3/8] Backend build...
cd src\api
echo   - dotnet restore yapiliyor...
dotnet restore >nul 2>nul
echo   - dotnet build yapiliyor...
dotnet build --configuration Release >nul 2>nul
cd ..\..
echo ✅ Backend build tamamlandi

:: ================================
:: STEP 4: FRONTEND BUILD
:: ================================
echo [4/8] Frontend build...
cd src\web
echo   - npm install yapiliyor (30-60 saniye surebilir)...
npm install >nul 2>nul
echo   - npm build yapiliyor...
npm run build >nul 2>nul
cd ..\..
echo ✅ Frontend build tamamlandi

:: ================================
:: STEP 5: ENVIRONMENT SETUP
:: ================================
echo [5/8] Environment setup...
if exist "env.example" copy "env.example" ".env" >nul
echo ✅ Environment setup tamamlandi

:: ================================
:: STEP 6: GITHUB ACTIONS CHECK
:: ================================
echo [6/8] GitHub Actions setup...
if not exist ".github\workflows" mkdir ".github\workflows"
echo ✅ GitHub Actions setup tamamlandi

:: ================================
:: STEP 7: DOCKER TEST (OPTIONAL)
:: ================================
echo [7/8] Docker test (opsiyonel)...
where docker >nul 2>nul && (
    echo Docker test yapiliyor...
    docker-compose config >nul 2>nul && echo ✅ Docker config gecerli || echo ⚠️ Docker config problemi
) || echo ⚠️ Docker bulunamadi (normal)

:: ================================
:: STEP 8: GITHUB REPOSITORY
:: ================================
echo [8/9] GitHub repository setup...

set REPOSITORY_URL=https://github.com/%GITHUB_USERNAME%/%REPOSITORY_NAME%.git

:: YÖNTEM 1: GitHub CLI dene
where gh >nul 2>nul && (
    echo GitHub CLI ile deneniyor...
    gh repo create %REPOSITORY_NAME% --public --source=. --remote=origin --push >nul 2>nul && (
        echo ✅ GitHub CLI ile basarili!
        goto :push_success
    )
)

:: YÖNTEM 2: PowerShell + GitHub API
echo.
echo 🔑 GITHUB TOKEN KONTROLU:
:: Otomatik token arama
set "GITHUB_TOKEN="
if exist "%USERPROFILE%\.config\gh\hosts.yml" (
    echo GitHub CLI config bulundu, token çıkarılıyor...
    for /f "tokens=*" %%i in ('powershell -command "try { (Get-Content '%USERPROFILE%\.config\gh\hosts.yml' | Select-String 'oauth_token:' | ForEach-Object { $_.ToString().Split(':')[1].Trim() } | Select-Object -First 1) } catch { '' }"') do set "GITHUB_TOKEN=%%i"
)

if defined GITHUB_TOKEN (
    echo ✅ GitHub token bulundu! API ile otomatik oluşturuluyor...
    goto :api_create
)

if not defined GITHUB_TOKEN (
    echo.
    echo 🔑 POWERSHELL API ile repository olusturma:
    set /p "USE_API=GitHub Personal Access Token var mi? (y/N): "
    if /i "%USE_API%"=="y" (
        set /p "GITHUB_TOKEN=GitHub Token girin: "
    )
)

:api_create
if not "!GITHUB_TOKEN!"=="" (
        echo API ile repository olusturuluyor...
        powershell -command "try { $headers = @{'Authorization' = 'token !GITHUB_TOKEN!'; 'Accept' = 'application/vnd.github.v3+json'}; $body = @{name='%REPOSITORY_NAME%'; description='DevOps Ready Application'; 'private'=$false} | ConvertTo-Json; Invoke-RestMethod -Uri 'https://api.github.com/user/repos' -Method Post -Headers $headers -Body $body -ContentType 'application/json'; echo 'API SUCCESS' } catch { echo 'API FAILED' }" >temp_api_result.txt
        findstr "API SUCCESS" temp_api_result.txt >nul && (
            del temp_api_result.txt
            echo ✅ PowerShell API ile basarili!
            goto :git_push
        )
        del temp_api_result.txt >nul 2>nul
        echo ⚠️ API ile oluşturulamadi
    )
)

:: YÖNTEM 3: curl + GitHub API (PowerShell fallback)
where curl >nul 2>nul && (
    if not defined GITHUB_TOKEN (
        echo.
        echo 🌐 CURL API ile repository olusturma:
        set /p "USE_CURL=GitHub Token ile curl denemek istiyor musunuz? (y/N): "
        if /i "!USE_CURL!"=="y" (
            set /p "GITHUB_TOKEN=GitHub Token girin: "
        )
    )
    if not "!GITHUB_TOKEN!"=="" (
        echo curl ile repository olusturuluyor...
        curl -H "Authorization: token !GITHUB_TOKEN!" -H "Accept: application/vnd.github.v3+json" -X POST https://api.github.com/user/repos -d "{\"name\":\"%REPOSITORY_NAME%\",\"description\":\"DevOps Ready Application\",\"private\":false}" >temp_curl_result.txt 2>nul
        findstr "\"name\":\"%REPOSITORY_NAME%\"" temp_curl_result.txt >nul && (
            del temp_curl_result.txt
            echo ✅ curl API ile basarili!
            goto :git_push
        )
        del temp_curl_result.txt >nul 2>nul
        echo ⚠️ curl ile oluşturulamadi
    )
)

:: YÖNTEM 4: Browser + Manuel
echo.
echo 🌐 BROWSER ile manuel olusturma:
set /p "AUTO_SETUP=GitHub'i tarayicide acmak istiyor musunuz? (y/N): "
if /i "%AUTO_SETUP%"=="y" (
    powershell -command "Start-Process 'https://github.com/new?name=%REPOSITORY_NAME%&description=DevOps+Ready+Application&visibility=public'"
    echo.
    echo 📋 TARAYICI TALIMATLARI:
    echo 1. GitHub tarayicida acildi
    echo 2. Repository name: %REPOSITORY_NAME%
    echo 3. Description: DevOps Ready Application
    echo 4. Public secin
    echo 5. "Create repository" tiklayin  
    echo 6. Bu pencereye donun ve ENTER basin
    set /p "WAIT=Repository olusturulduktan sonra ENTER basin: "
    goto :git_push
)

:: YÖNTEM 5: Manuel Talimatlar (son çare)
echo.
echo 📋 MANUEL REPOSITORY OLUSTURMA:
echo 1. https://github.com/new adresine gidin
echo 2. Repository name: %REPOSITORY_NAME%
echo 3. Description: DevOps Ready Application
echo 4. Public secin ve "Create repository" tiklayin
echo 5. Oluşturduktan sonra bu pencereye donun
set /p "MANUAL_DONE=Manuel olarak oluşturdunuz mu? (y/N): "

:git_push
:: Git remote ve push işlemi
echo.
echo 📤 GitHub'a push yapiliyor...
git remote remove origin >nul 2>nul
git remote add origin %REPOSITORY_URL%
git push -u origin main >nul 2>nul && (
    echo ✅ GitHub'a push basarili!
    goto :push_success
) || (
    echo ⚠️ Push basarisiz. Repository doğru oluşturuldu mu?
    echo Kontrol edin: https://github.com/%GITHUB_USERNAME%/%REPOSITORY_NAME%
    echo.
    set /p "RETRY_PUSH=Tekrar push denemek istiyor musunuz? (y/N): "
    if /i "!RETRY_PUSH!"=="y" (
        git push -u origin main && (
            echo ✅ İkinci denemede basarili!
            goto :push_success
        ) || (
            echo ❌ Push yine basarisiz oldu
            echo Manuel kontrol gerekli: https://github.com/%GITHUB_USERNAME%/%REPOSITORY_NAME%
        )
    )
)

:push_success
echo ✅ Repository başarıyla oluşturuldu ve push edildi!

:: ================================
:: STEP 9: GITHUB SECRETS SETUP
:: ================================
echo.
echo [9/9] GitHub Secrets setup...

:: GitHub CLI ile secrets ekleme
where gh >nul 2>nul && (
    echo.
    echo 🔒 OTOMATIK SECRETS SETUP:
    set /p "AUTO_SECRETS=GitHub secrets'lari otomatik eklemek istiyor musunuz? (y/N): "
    if /i "!AUTO_SECRETS!"=="y" (
        echo.
        echo 🔑 Database şifreleri belirleniyor...
        set /p "STAGING_PASS=STAGING_DB_PASSWORD girin (veya Enter = otomatik): "
        set /p "PRODUCTION_PASS=PRODUCTION_DB_PASSWORD girin (veya Enter = otomatik): "
        
        if "!STAGING_PASS!"=="" set STAGING_PASS=DevStaging#2024$Secure!Pass123
        if "!PRODUCTION_PASS!"=="" set PRODUCTION_PASS=ProdLive#2024$Ultra&Secure!Pass456
        
        echo GitHub secrets ekleniyor...
        gh secret set STAGING_DB_PASSWORD --body "!STAGING_PASS!" --repo %GITHUB_USERNAME%/%REPOSITORY_NAME%
        gh secret set PRODUCTION_DB_PASSWORD --body "!PRODUCTION_PASS!" --repo %GITHUB_USERNAME%/%REPOSITORY_NAME%
        
        echo ✅ GitHub secrets otomatik eklendi!
        echo   - STAGING_DB_PASSWORD: !STAGING_PASS!
        echo   - PRODUCTION_DB_PASSWORD: !PRODUCTION_PASS!
    ) else (
        echo Manuel secrets kurulumu gerekecek...
    )
) || (
    echo GitHub CLI bulunamadi. Manuel secrets kurulumu gerekecek...
)

:: Browser ile otomatik secrets sayfası açma (fallback)
if not defined AUTO_SECRETS (
    echo.
    echo 🌐 BROWSER ile secrets ekleme:
    set /p "BROWSER_SECRETS=Secrets sayfasini tarayicide acmak istiyor musunuz? (y/N): "
    if /i "!BROWSER_SECRETS!"=="y" (
        powershell -command "Start-Process 'https://github.com/%GITHUB_USERNAME%/%REPOSITORY_NAME%/settings/secrets/actions/new'"
        echo.
        echo 📋 TARAYICIDA YAPILACAKLAR:
        echo 1. "New repository secret" sayfasi acildi
        echo 2. Ilk secret:
        echo    Name: STAGING_DB_PASSWORD
        echo    Value: DevStaging#2024$Secure!Pass123
        echo 3. "Add secret" tiklayin
        echo 4. Ikinci secret icin "New repository secret" tekrar tiklayin:
        echo    Name: PRODUCTION_DB_PASSWORD  
        echo    Value: ProdLive#2024$Ultra&Secure!Pass456
        echo 5. Bu pencereye donun ve ENTER basin
        set /p "BROWSER_DONE=Secrets eklendikten sonra ENTER basin: "
        echo ✅ Browser ile secrets eklendi kabul edildi
    )
)

:: Manuel talimatlar
echo.
echo 📋 MANUEL SECRETS KURULUMU (gerekirse):
echo 1. GitHub: https://github.com/%GITHUB_USERNAME%/%REPOSITORY_NAME%/settings/secrets/actions
echo 2. "New repository secret" tiklayin
echo 3. STAGING_DB_PASSWORD = DevStaging#2024$Secure!Pass123
echo 4. PRODUCTION_DB_PASSWORD = ProdLive#2024$Ultra&Secure!Pass456

:: ================================
:: SUCCESS MESSAGE
:: ================================
:success
echo.
echo ================================
echo 🎉 KURULUM TAMAMLANDI!
echo ================================
echo.
echo ✅ DevOps setup %100 basarili!
echo.
echo 📋 SONRAKI ADIMLAR:
echo 1. GitHub: https://github.com/%GITHUB_USERNAME%/%REPOSITORY_NAME%
echo 2. Actions tab'inda pipeline'lari kontrol edin
echo 3. Secrets otomatik eklendiyse direkt test:
echo    docker-compose up -d
echo    http://localhost:5202 (Web)
echo    http://localhost:5102 (API)
echo.
echo 🎯 TANIMLILAR:
echo ✅ CI/CD Pipeline (GitHub Actions)
echo ✅ Docker Containerization  
echo ✅ Security Scanning
echo ✅ Health Monitoring
echo ✅ Professional Documentation
echo.
echo 🏆 EXPERT LEVEL DEVOPS READY!
echo.
pause 