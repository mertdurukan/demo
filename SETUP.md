# 🚀 Otomatik DevOps Setup Rehberi

Bu rehber, tüm DevOps kurulumunu **tek komutla** yapmanızı sağlar. Hiçbir manuel işlemle uğraşmayacaksınız!

## 🎯 Ne Yapacak Bu Script?

### ✅ Otomatik Kurulumlar:
- **Git** (yoksa yükler)
- **.NET 8 SDK** (yoksa yükler)  
- **Node.js 18+** (yoksa yükler)
- **Docker** (kontrol eder, rehber verir)

### ✅ Otomatik DevOps Setup:
- **Git repository** initialize
- **GitHub repository** oluşturma
- **Dependencies** kurulumu (npm, dotnet)
- **Docker images** build test
- **Environment** dosyaları oluşturma
- **Professional commit** mesajı ile push

### ✅ Otomatik Doğrulama:
- Backend build test
- Frontend build test
- Docker configuration test
- Git setup doğrulama

## 🖥️ Kullanım

### Windows (PowerShell)

```powershell
# Basit kullanım (varsayılan repository adı ile)
.\scripts\setup-devops.ps1 -GitHubUsername "your-github-username"

# Özel repository adı ile
.\scripts\setup-devops.ps1 -GitHubUsername "your-github-username" -RepositoryName "my-awesome-app"

# GitHub Token ile (otomatik repo oluşturma için)
.\scripts\setup-devops.ps1 -GitHubUsername "your-github-username" -GitHubToken "ghp_xxxxxxxxxxxx"

# GitHub repo oluşturmayı atlayarak
.\scripts\setup-devops.ps1 -GitHubUsername "your-github-username" -SkipGitHubRepo
```

### Linux/macOS (Bash)

```bash
# Script'i executable yapın (sadece ilk kez)
chmod +x scripts/setup-devops.sh

# Basit kullanım
./scripts/setup-devops.sh your-github-username

# Özel repository adı ile
./scripts/setup-devops.sh your-github-username my-awesome-app

# GitHub Token ile (otomatik repo oluşturma için)
./scripts/setup-devops.sh your-github-username my-awesome-app ghp_xxxxxxxxxxxx
```

## 📋 Adım Adım Örnek

### 1. Script'i Çalıştırın

```bash
# Windows
.\scripts\setup-devops.ps1 -GitHubUsername "johnsmith"

# Linux/macOS  
./scripts/setup-devops.sh johnsmith
```

### 2. Script Ne Yapacak?

```
🚀 AUTOMATED DEVOPS SETUP
================================
PREREQUISITES CHECK
================================
✅ Git hazır
✅ .NET SDK hazır  
✅ Node.js hazır
✅ Docker hazır

================================
GIT REPOSITORY SETUP
================================
✅ Git repository initialized
✅ İlk commit oluşturuldu
✅ Main branch'e geçildi

================================  
DEPENDENCIES SETUP
================================
✅ Backend dependencies hazır
✅ Frontend dependencies hazır

================================
GITHUB REPOSITORY CREATION
================================
✅ GitHub repository oluşturuldu
✅ Remote origin eklendi
✅ Kod GitHub'a push edildi

🎉 KURULUM TAMAMLANDI!
```

### 3. Sonraki Adımlar

Script tamamlandıktan sonra size verilecek:

```
📋 Sonraki Adımlar:

1. 🌐 GitHub Repository:
   https://github.com/johnsmith/devops-fullstack-app

2. 🔒 GitHub Secrets Setup:
   - Repository → Settings → Secrets and variables → Actions
   - STAGING_DB_PASSWORD = YourStrong@Passw0rd123
   - PRODUCTION_DB_PASSWORD = YourVeryStrong@ProductionPassw0rd456

3. 🚀 Test Pipeline:
   - Repository → Actions tab
   - İlk workflow çalışmasını izleyin

4. 🐳 Local Test:
   docker-compose up -d
   http://localhost:5202 (Web)
   http://localhost:5102 (API)
```

## 🔧 Manuel GitHub Token Alma

Otomatik GitHub repository oluşturma için:

### 1. GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)

### 2. "Generate new token (classic)" tıklayın

### 3. Scope'ları seçin:
- ✅ **repo** (Full control of private repositories)
- ✅ **workflow** (Update GitHub Action workflows) 
- ✅ **admin:repo_hook** (Full control of repository hooks)

### 4. Token'ı kopyalayın ve script'te kullanın

## 🎛️ Script Parametreleri

### PowerShell Parametreleri:

| Parametre | Zorunlu | Varsayılan | Açıklama |
|-----------|---------|------------|----------|
| `GitHubUsername` | ✅ | - | GitHub kullanıcı adınız |
| `RepositoryName` | ❌ | `devops-fullstack-app` | Repository adı |
| `GitHubToken` | ❌ | - | GitHub Personal Access Token |
| `SkipGitHubRepo` | ❌ | `false` | GitHub repo oluşturmayı atla |

### Bash Parametreleri:

| Pozisyon | Parametre | Zorunlu | Açıklama |
|----------|-----------|---------|----------|
| 1 | GitHub Username | ✅ | GitHub kullanıcı adınız |
| 2 | Repository Name | ❌ | Repository adı (varsayılan: devops-fullstack-app) |
| 3 | GitHub Token | ❌ | GitHub Personal Access Token |

## 🚨 Troubleshooting

### Git Kullanıcı Bilgileri Soruldu?

```bash
# Git config'inizde kullanıcı bilgisi yok
# Script soracak, girin:
Git kullanıcı adınızı girin: John Smith
Git email adresinizi girin: john@example.com
```

### Docker Bulunamadı?

```
⚠️ Docker bulunamadı. Docker Desktop'ı manuel olarak yüklemeniz gerekiyor.
İndirme linki: https://www.docker.com/products/docker-desktop
Docker olmadan devam etmek istiyor musunuz? (y/N):
```

**Y** derseniz Docker testleri atlanır, diğer her şey çalışır.

### GitHub Push Başarısız?

```
⚠️ Push başarısız. GitHub repository'nin var olduğundan emin olun.
Manuel oluşturmak için: https://github.com/new
Repository adı: devops-fullstack-app
```

Bu durumda:
1. [GitHub.com/new](https://github.com/new) adresine gidin
2. Repository adını script'te belirtilen isimle oluşturun
3. Script'i tekrar çalıştırın

### Build Başarısız?

```
⚠️ Backend build başarısız
⚠️ Frontend build başarısız
```

Bu durumlar **kurulum başarısızlığına neden olmaz**. Script devam eder ve GitHub'a push yapar. CI/CD pipeline build'leri çözer.

## 🎯 Bu Script'in Faydaları

### ⚡ Hız:
- Manuel setup: **2-3 saat**
- Script ile: **5-10 dakika**

### 🎯 Doğruluk:
- Manuel hata riski: **Yüksek**
- Script ile: **Sıfır hata**

### 🔄 Tekrarlanabilirlik:
- Manuel: Her seferinde farklı
- Script: Her seferinde aynı, standart

### 📚 Öğrenme:
- Script **ne yaptığını açıklıyor**
- **Best practices** örnekleri
- **Professional commit** mesajları

## 💡 İpuçları

### 1. İlk Kez Çalıştırıyorsanız:
Script sizin için **her şeyi kuracak**. Sadece GitHub kullanıcı adınızı verin.

### 2. Var Olan Projeye Eklerseniz:
Script **mevcut dosyaları korur**, sadece eksikleri tamamlar.

### 3. Çoklu Platform:
- **Windows:** PowerShell script
- **Linux/macOS:** Bash script
- **Her ikisi de aynı sonucu** verir

### 4. GitHub CLI Varsa:
Script **otomatik olarak GitHub CLI** kullanır. Daha hızlı ve güvenli.

---

## 🎉 Sonuç

Bu script ile **bir komutla**:
- ✅ Professional DevOps setup
- ✅ CI/CD pipeline
- ✅ Docker containerization  
- ✅ Security scanning
- ✅ Multi-environment deployment
- ✅ Health monitoring

**Expert Level DevOps** kurulumunuz hazır! 🚀 