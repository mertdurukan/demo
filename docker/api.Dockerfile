# ================================
# STAGE 1: BUILD ENVIRONMENT
# ================================
# Neden SDK kullanıyoruz: Build için gerekli toollar
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# ================================
# DEPENDENCY RESTORATION
# ================================
# Neden önce .csproj: Docker layer caching için
# Dependencies değişmezse bu layer cache'ten gelir
COPY src/api/dev-api.csproj ./
RUN dotnet restore dev-api.csproj

# ================================
# SOURCE CODE COPY & BUILD
# ================================
# Source code'u en son kopyalıyoruz çünkü en sık değişen kısım
COPY src/api/ ./

# Release modunda build - Optimizasyonlar aktif
RUN dotnet publish dev-api.csproj -c Release -o /app/publish \
    --no-restore \
    --verbosity minimal

# ================================
# STAGE 2: RUNTIME ENVIRONMENT
# ================================
# Neden aspnet runtime: Sadece çalışma zamanı, SDK yok
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

# ================================
# SECURITY: NON-ROOT USER
# ================================
# Neden: Root olarak çalıştırmak güvenlik riski
RUN groupadd -r appuser && useradd -r -g appuser appuser

# ================================
# HEALTH CHECK ENDPOINT
# ================================
# Neden: Container'ın sağlıklı olup olmadığını Docker'a söyle
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:80/health || exit 1

# ================================
# COPY PUBLISHED APPLICATION
# ================================
# Build stage'den sadece publish edilmiş dosyalar
COPY --from=build /app/publish .

# ================================
# SET OWNERSHIP & PERMISSIONS
# ================================
RUN chown -R appuser:appuser /app
USER appuser

# ================================
# EXPOSE PORT & START
# ================================
EXPOSE 80
ENTRYPOINT ["dotnet", "dev-api.dll"] 