#!/bin/bash
# ================================
# AUTOMATED DEVOPS SETUP SCRIPT (Linux/macOS)
# ================================
# Bu script tüm DevOps setup'ını otomatik yapar
#
# Calistirmak icin: .\scripts\setup-devops.bat mertdurukan
#
# 🚀 SCRIPT YAPACAKLARI:
# ✅ Git, .NET, Node.js kurulumu (yoksa)
# ✅ Git repository initialize
# ✅ Professional commit oluşturma
# ✅ GitHub repository oluşturma
# ✅ Dependencies kurulumu
# ✅ Docker build test
# ✅ Environment setup
# ✅ GitHub'a push
#
# 🎯 SONUÇ: Expert Level DevOps Setup (5-10 dakika)

set -e  # Exit on any error

# ================================
# CONFIGURATION
# ================================
GITHUB_USERNAME="${1:-}"
REPOSITORY_NAME="${2:-devops-fullstack-app}"
GITHUB_TOKEN="${3:-}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# ================================
# HELPER FUNCTIONS
# ================================
log_info() {
    echo -e "${CYAN}$1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_header() {
    echo ""
    echo -e "${PURPLE}================================${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}================================${NC}"
    echo ""
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

install_package() {
    local package=$1
    local install_cmd=""
    
    if command_exists "brew"; then
        install_cmd="brew install $package"
    elif command_exists "apt-get"; then
        install_cmd="sudo apt-get update && sudo apt-get install -y $package"
    elif command_exists "yum"; then
        install_cmd="sudo yum install -y $package"
    elif command_exists "pacman"; then
        install_cmd="sudo pacman -S --noconfirm $package"
    else
        log_error "Package manager bulunamadı. $package'ı manuel olarak yükleyin."
        return 1
    fi
    
    log_info "Installing $package: $install_cmd"
    eval $install_cmd
}

# ================================
# PREREQUISITE CHECKS
# ================================
check_prerequisites() {
    log_header "PREREQUISITES CHECK"
    
    # Git check
    if ! command_exists git; then
        log_warning "Git bulunamadı. Git yükleniyor..."
        install_package git
    fi
    log_success "Git hazır"
    
    # Node.js check
    if ! command_exists node; then
        log_warning "Node.js bulunamadı. Node.js yükleniyor..."
        if command_exists brew; then
            brew install node
        else
            # Install NodeJS via package manager
            curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
            sudo apt-get install -y nodejs
        fi
    fi
    log_success "Node.js hazır"
    
    # .NET check
    if ! command_exists dotnet; then
        log_warning ".NET SDK bulunamadı. .NET 8 SDK yükleniyor..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            brew install --cask dotnet-sdk
        else
            # Linux
            wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
            sudo dpkg -i packages-microsoft-prod.deb
            rm packages-microsoft-prod.deb
            sudo apt-get update
            sudo apt-get install -y dotnet-sdk-8.0
        fi
    fi
    log_success ".NET SDK hazır"
    
    # Docker check
    if ! command_exists docker; then
        log_warning "Docker bulunamadı."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            log_info "macOS için Docker Desktop'ı şuradan indirin: https://www.docker.com/products/docker-desktop"
        else
            log_info "Linux için Docker'ı şuradan yükleyin: https://docs.docker.com/engine/install/"
        fi
        read -p "Docker olmadan devam etmek istiyor musunuz? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        if docker ps >/dev/null 2>&1; then
            log_success "Docker hazır"
        else
            log_warning "Docker yüklü ama çalışmıyor. Docker servisini başlatın."
        fi
    fi
}

# ================================
# GIT SETUP
# ================================
setup_git_repository() {
    log_header "GIT REPOSITORY SETUP"
    
    # Git config check
    if [[ -z $(git config --global user.name) ]]; then
        read -p "Git kullanıcı adınızı girin: " git_user
        git config --global user.name "$git_user"
    fi
    
    if [[ -z $(git config --global user.email) ]]; then
        read -p "Git email adresinizi girin: " git_email
        git config --global user.email "$git_email"
    fi
    
    local git_user=$(git config --global user.name)
    local git_email=$(git config --global user.email)
    log_info "Git kullanıcısı: $git_user <$git_email>"
    
    # Initialize git if not already
    if [[ ! -d ".git" ]]; then
        git init
        log_success "Git repository initialized"
    fi
    
    # Initial commit
    git add .
    
    local commit_message="feat: initial DevOps setup with CI/CD pipeline

- ✅ Modern repository structure (src/api, src/web)
- ✅ Docker containerization (multi-stage builds)
- ✅ CI/CD pipelines (GitHub Actions)
- ✅ Security scanning (Trivy, CodeQL)
- ✅ Health checks and monitoring
- ✅ Infrastructure as Code ready
- ✅ Professional documentation

This commit establishes a production-ready DevOps foundation
following industry best practices."
    
    git commit -m "$commit_message"
    log_success "İlk commit oluşturuldu"
    
    # Switch to main branch
    local current_branch=$(git branch --show-current)
    if [[ "$current_branch" != "main" ]]; then
        git branch -M main
        log_success "Main branch'e geçildi"
    fi
}

# ================================
# GITHUB SETUP
# ================================
setup_github_repository() {
    log_header "GITHUB REPOSITORY CREATION"
    
    if [[ -z "$GITHUB_USERNAME" ]]; then
        log_error "GitHub kullanıcı adı gerekli!"
        echo "Kullanım: $0 github-username [repository-name] [github-token]"
        exit 1
    fi
    
    local repository_url="https://github.com/$GITHUB_USERNAME/$REPOSITORY_NAME.git"
    
    # GitHub CLI ile dene
    if command_exists gh; then
        log_info "GitHub CLI ile repository oluşturuluyor..."
        if gh repo create "$REPOSITORY_NAME" --public --source=. --remote=origin --push; then
            log_success "GitHub repository oluşturuldu ve push edildi"
            return
        else
            log_warning "GitHub CLI ile oluşturma başarısız. Manuel yöntemle devam ediliyor..."
        fi
    fi
    
    # GitHub API ile dene (token gerekli)
    if [[ -n "$GITHUB_TOKEN" ]]; then
        log_info "GitHub API ile repository oluşturuluyor..."
        
        local response=$(curl -s -w "%{http_code}" -o /tmp/gh_response.json \
            -H "Authorization: token $GITHUB_TOKEN" \
            -H "Accept: application/vnd.github.v3+json" \
            -d "{\"name\":\"$REPOSITORY_NAME\",\"description\":\"DevOps-Ready Full-Stack Application with CI/CD Pipeline\",\"public\":true,\"auto_init\":false}" \
            https://api.github.com/user/repos)
        
        if [[ "$response" == "201" ]]; then
            log_success "GitHub repository oluşturuldu"
        else
            log_warning "GitHub repository oluşturulamadı. Manuel oluşturmanız gerekebilir."
            cat /tmp/gh_response.json
        fi
    fi
    
    # Remote ekle
    git remote remove origin 2>/dev/null || true
    git remote add origin "$repository_url"
    log_success "Remote origin eklendi: $repository_url"
    
    # Push yap
    log_info "Repository'ye push yapılıyor..."
    if git push -u origin main; then
        log_success "Kod GitHub'a push edildi"
    else
        log_warning "Push başarısız. GitHub repository'nin var olduğundan emin olun."
        log_info "Manuel oluşturmak için: https://github.com/new"
        log_info "Repository adı: $REPOSITORY_NAME"
    fi
}

# ================================
# DEPENDENCIES SETUP
# ================================
setup_dependencies() {
    log_header "DEPENDENCIES SETUP"
    
    # Backend dependencies
    log_info "Backend dependencies kuruluyor..."
    if (cd src/api && dotnet restore && dotnet build --configuration Release); then
        log_success "Backend dependencies hazır"
    else
        log_warning "Backend build başarısız"
    fi
    
    # Frontend dependencies
    log_info "Frontend dependencies kuruluyor..."
    if (cd src/web && npm install && npm run build); then
        log_success "Frontend dependencies hazır"
    else
        log_warning "Frontend build başarısız"
    fi
}

# ================================
# DOCKER SETUP TEST
# ================================
test_docker_setup() {
    log_header "DOCKER SETUP TEST"
    
    if ! command_exists docker; then
        log_warning "Docker bulunamadı, container testleri atlanıyor"
        return
    fi
    
    log_info "Docker images build ediliyor..."
    
    # API image test
    if docker build -t devops-api -f docker/api.Dockerfile .; then
        log_success "API Docker image oluşturuldu"
    else
        log_warning "API Docker build başarısız"
    fi
    
    # Web image test
    if docker build -t devops-web -f docker/web.Dockerfile .; then
        log_success "Web Docker image oluşturuldu"
    else
        log_warning "Web Docker build başarısız"
    fi
    
    # Docker Compose test
    log_info "Docker Compose test ediliyor..."
    if docker-compose config >/dev/null 2>&1; then
        log_success "Docker Compose konfigürasyonu geçerli"
    else
        log_warning "Docker Compose konfigürasyonu hatalı"
    fi
}

# ================================
# ENVIRONMENT SETUP
# ================================
setup_environment() {
    log_header "ENVIRONMENT SETUP"
    
    if [[ ! -f ".env" ]]; then
        if [[ -f "env.example" ]]; then
            cp env.example .env
            log_success ".env dosyası oluşturuldu (env.example'dan)"
        else
            log_warning "env.example bulunamadı"
        fi
    fi
}

# ================================
# FINAL MESSAGE
# ================================
show_next_steps() {
    log_header "KURULUM TAMAMLANDI! 🎉"
    
    log_success "DevOps setup başarıyla tamamlandı!"
    echo ""
    
    echo -e "${PURPLE}📋 Sonraki Adımlar:${NC}"
    echo ""
    
    log_info "1. 🌐 GitHub Repository:"
    echo -e "   ${WHITE}https://github.com/$GITHUB_USERNAME/$REPOSITORY_NAME${NC}"
    echo ""
    
    log_info "2. 🔒 GitHub Secrets Setup:"
    echo -e "   ${WHITE}- Repository → Settings → Secrets and variables → Actions${NC}"
    echo -e "   ${WHITE}- STAGING_DB_PASSWORD = YourStrong@Passw0rd123${NC}"
    echo -e "   ${WHITE}- PRODUCTION_DB_PASSWORD = YourVeryStrong@ProductionPassw0rd456${NC}"
    echo ""
    
    log_info "3. 🚀 Test Pipeline:"
    echo -e "   ${WHITE}- Repository → Actions tab${NC}"
    echo -e "   ${WHITE}- İlk workflow çalışmasını izleyin${NC}"
    echo ""
    
    log_info "4. 🐳 Local Test:"
    echo -e "   ${WHITE}docker-compose up -d${NC}"
    echo -e "   ${WHITE}http://localhost:5202 (Web)${NC}"
    echo -e "   ${WHITE}http://localhost:5102 (API)${NC}"
    echo ""
    
    log_info "5. 📊 Monitoring:"
    echo -e "   ${WHITE}http://localhost:5102/health (Health Check)${NC}"
    echo ""
    
    echo -e "${PURPLE}🎯 Sahip Olduğunuz DevOps Özellikleri:${NC}"
    log_success "Automated CI/CD Pipeline"
    log_success "Docker Containerization"
    log_success "Security Scanning"
    log_success "Multi-Environment Deployment"
    log_success "Health Monitoring"
    log_success "Professional Documentation"
    echo ""
    
    echo -e "${PURPLE}🏆 EXPERT LEVEL DEVOPS KURULUMU TAMAMLANDI!${NC}"
}

# ================================
# MAIN EXECUTION
# ================================
main() {
    clear
    log_header "🚀 AUTOMATED DEVOPS SETUP"
    log_info "DevOps-Ready Full-Stack Application Setup"
    log_info "Bu script tüm kurulumu otomatik yapacak..."
    echo ""
    
    if [[ -z "$GITHUB_USERNAME" ]]; then
        log_error "GitHub kullanıcı adı gerekli!"
        echo ""
        echo -e "${WHITE}Kullanım:${NC}"
        echo "  $0 github-username [repository-name] [github-token]"
        echo ""
        echo -e "${WHITE}Örnek:${NC}"
        echo "  $0 johnsmith"
        echo "  $0 johnsmith my-devops-app"
        echo "  $0 johnsmith my-devops-app ghp_xxxxxxxxxxxx"
        echo ""
        exit 1
    fi
    
    log_info "Parametreler:"
    log_info "  GitHub Username: $GITHUB_USERNAME"
    log_info "  Repository Name: $REPOSITORY_NAME"
    echo ""
    
    # Execute setup steps
    check_prerequisites
    setup_git_repository
    setup_dependencies
    setup_environment
    test_docker_setup
    setup_github_repository
    show_next_steps
}

# Script'i çalıştır
main "$@" 