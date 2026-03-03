# Shlink – Docker + Traefik + PostgreSQL

**Shlink**, self-hosted açık kaynaklı bir URL kısaltma ve tıklama takip platformudur. Kısa link oluşturma, tıklama istatistikleri, tag bazlı raporlama ve REST API sunar.

---

## Mimari

```
E-posta / Sosyal Medya
        ↓
links.example.com/abc123   ← Shlink (kısa link, herkese açık)
        ↓
urun-siten.com/urun/xyz    ← Asıl ürün sayfası

shlink.example.com         ← Shlink Web Client (yönetim paneli, IP kısıtlamalı)
```

---

## Gereksinimler

- Docker Engine + Docker Compose v2
- Çalışır durumda Traefik (`traefik-network` external network)
- Paylaşımlı PostgreSQL sunucusu (`postgres-network` external network)

---

## Proje Yapısı

```
shlink/
├── .env.example
├── docker-compose.yml
├── docker-compose.production.yml
├── install.sh
└── README.md
```

---

## Kurulum

### 1. Veritabanı Oluşturma

PostgreSQL sunucusunda Shlink için kullanıcı ve veritabanı oluştur. Bunun için paylaşımlı `postgres` servisinin sağladığı scripti kullan:

```bash
bash ~/.x-dockerize/postgres/scripts/create-db.sh
```

Script DB adı, kullanıcı adı ve şifreyi interaktif olarak sorar; şifreyi boş bırakırsan otomatik güçlü bir şifre üretir. İşlem sonunda bağlantı bilgilerini ekrana basar — `.env` dosyasını doldururken bu bilgileri kullan.

---

### 2. Ortam Değişkenlerini Hazırla

`install.sh` çalıştır — hostname, DB bilgileri ve isteğe bağlı GeoLite2 anahtarını sorar:

```bash
bash install.sh
```

Ya da manuel:

```bash
cp .env.example .env
# .env dosyasını düzenle
```

`.env` içinde doldurulması gereken alanlar:

| Değişken | Açıklama |
|---|---|
| `SHLINK_HOSTNAME` | Kısa linklerin sunulacağı domain (örn: `links.example.com`) |
| `SHLINK_ADMIN_HOSTNAME` | Yönetim panelinin sunulacağı domain (örn: `shlink.example.com`) |
| `DB_HOST` | PostgreSQL sunucu adresi |
| `DB_USER` | Veritabanı kullanıcısı |
| `DB_NAME` | Veritabanı adı |
| `DB_PASSWORD` | Veritabanı şifresi |
| `GEOLITE_LICENSE_KEY` | MaxMind GeoLite2 lisans anahtarı (isteğe bağlı) |

---

### 3. Servisi Başlat

```bash
docker compose -f docker-compose.production.yml up -d
```

---

### 4. API Key Oluştur

Shlink Web Client'ı kullanabilmek için bir API key gerekir:

```bash
docker exec shlink shlink api-key:generate
```

Çıktıdaki API key'i kopyala. Shlink Web Client'a ilk girişte şu bilgileri gir:

| Alan | Değer |
|---|---|
| Server URL | `https://links.example.com` |
| API Key | Yukarıda üretilen key |

---

## Traefik Entegrasyonu

| Servis | Domain | Erişim |
|---|---|---|
| Shlink (API + redirects) | `SHLINK_HOSTNAME` | Herkese açık |
| Shlink Web Client | `SHLINK_ADMIN_HOSTNAME` | IP kısıtlamalı (`trusted@file`) |

---

## Firma Bazlı Raporlama — Tag Sistemi

Her link oluştururken firmayı tag olarak ekle:

```
links.example.com/samsung-tv    → tag: samsung
links.example.com/samsung-phone → tag: samsung
links.example.com/lg-buzdolabi  → tag: lg
```

Web Client'ta **Tags** filtresini kullanarak firma bazlı toplam tıklama raporunu görebilirsin.

---

## GeoLite2 (Ülke / Şehir Takibi)

Tıklamanın hangi ülkeden ve şehirden geldiğini görmek için MaxMind ücretsiz hesabı gerekir:

1. https://www.maxmind.com/en/geolite2/signup adresinden kayıt ol
2. Lisans anahtarını al
3. `.env` içinde `GEOLITE_LICENSE_KEY` değerini güncelle
4. Servisi yeniden başlat

---

## Güncelleme

```bash
docker compose -f docker-compose.production.yml pull
docker compose -f docker-compose.production.yml up -d
```

`.env` içinde `SHLINK_VERSION` ve `SHLINK_WEB_VERSION` değerlerini güncellemeyi unutma.

---

## Faydalı Linkler

- [Shlink Docs](https://shlink.io/documentation)
- [Shlink GitHub](https://github.com/shlinkio/shlink)
- [Shlink Web Client GitHub](https://github.com/shlinkio/shlink-admin-client)
- [Docker Hub — shlink](https://hub.docker.com/r/shlinkio/shlink)
- [Docker Hub — shlink-admin-client](https://hub.docker.com/r/shlinkio/shlink-admin-client)
