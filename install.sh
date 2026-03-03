#!/usr/bin/env bash
set -e

ENV_EXAMPLE=".env.example"
ENV_FILE=".env"

# --------------------------------------------------
# Kontroller
# --------------------------------------------------
if [ ! -f "$ENV_EXAMPLE" ]; then
  echo "❌ $ENV_EXAMPLE bulunamadı."
  exit 1
fi

if [ ! -f "$ENV_FILE" ]; then
  cp "$ENV_EXAMPLE" "$ENV_FILE"
  echo "✅ $ENV_EXAMPLE → $ENV_FILE kopyalandı"
else
  echo "ℹ️  $ENV_FILE mevcut, güncellenecek"
fi

# --------------------------------------------------
# Yardımcı Fonksiyonlar
# --------------------------------------------------
set_env() {
  local key="$1"
  local value="$2"

  if grep -q "^${key}=" "$ENV_FILE"; then
    sed -i "s|^${key}=.*|${key}=${value}|" "$ENV_FILE"
  else
    echo "${key}=${value}" >> "$ENV_FILE"
  fi
}

# --------------------------------------------------
# Kullanıcıdan Gerekli Bilgiler
# --------------------------------------------------
read -rp "SHLINK_HOSTNAME — kısa linkler için domain (örn: links.example.com): " SHLINK_HOSTNAME
read -rp "SHLINK_ADMIN_HOSTNAME — yönetim paneli için domain (örn: shlink.example.com): " SHLINK_ADMIN_HOSTNAME

echo
echo "--- Veritabanı ---"
read -rp "DB host (boş bırakılırsa: postgres): " INPUT_DB_HOST
DB_HOST="${INPUT_DB_HOST:-postgres}"
read -rp "DB user (boş bırakılırsa: shlink): " INPUT_DB_USER
DB_USER="${INPUT_DB_USER:-shlink}"
read -rp "DB name (boş bırakılırsa: shlink): " INPUT_DB_NAME
DB_NAME="${INPUT_DB_NAME:-shlink}"
read -rsp "DB password: " DB_PASSWORD
echo

echo
echo "--- GeoLite2 (isteğe bağlı) ---"
echo "Ülke/şehir takibi için MaxMind ücretsiz lisans gerekir."
echo "https://www.maxmind.com/en/geolite2/signup"
read -rp "GEOLITE_LICENSE_KEY (boş bırakılırsa atlanır): " GEOLITE_LICENSE_KEY

# --------------------------------------------------
# .env Güncelle
# --------------------------------------------------
set_env SHLINK_HOSTNAME     "$SHLINK_HOSTNAME"
set_env SHLINK_ADMIN_HOSTNAME "$SHLINK_ADMIN_HOSTNAME"
set_env DB_HOST             "$DB_HOST"
set_env DB_USER             "$DB_USER"
set_env DB_NAME             "$DB_NAME"
set_env DB_PASSWORD         "$DB_PASSWORD"
set_env GEOLITE_LICENSE_KEY "$GEOLITE_LICENSE_KEY"

# --------------------------------------------------
# Sonuçları Göster
# --------------------------------------------------
echo
echo "==============================================="
echo "✅ Shlink .env başarıyla hazırlandı!"
echo "-----------------------------------------------"
echo "🔗 Kısa linkler : https://$SHLINK_HOSTNAME"
echo "🖥️  Yönetim      : https://$SHLINK_ADMIN_HOSTNAME"
echo "🗄️  DB           : $DB_DRIVER://$DB_USER@$DB_HOST:5432/$DB_NAME"
echo "-----------------------------------------------"
echo "📌 Sonraki adım: API key oluştur"
echo "   docker exec shlink shlink api-key:generate"
echo "==============================================="
