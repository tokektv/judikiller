#!/bin/sh

# =============================================
# INSTALASI AWAL DNSMASQ BLOCKER (REVISED)
# =============================================

echo "🔧 Memulai instalasi pemblokir situs judi..."

# 1. Buat direktori jika belum ada
mkdir -p /etc/dnsmasq.d
echo "📁 Membuat /etc/dnsmasq.d"

# 2. Buat file konfigurasi manual
cat > /etc/dnsmasq.d/manual-block.conf <<EOF
# Daftar blokir manual
# Format: address=/domain.com/0.0.0.0
address=/judionline.id/0.0.0.0
address=/slotgacor777.com/0.0.0.0
EOF
echo "📝 Membuat file manual-block.conf"

# 3. Buat file blokir utama (kosong dulu)
> /etc/dnsmasq.d/gambling-block.conf
chmod 644 /etc/dnsmasq.d/gambling-block.conf
echo "📄 Membuat file gambling-block.conf"

# 4. Edit dnsmasq.conf
if ! grep -q "conf-dir=/etc/dnsmasq.d/,*.conf" /etc/dnsmasq.conf; then
  echo -e "\n# Blokir situs judi\nconf-dir=/etc/dnsmasq.d/,*.conf" >> /etc/dnsmasq.conf
  echo "⚙️ Menambahkan conf-dir ke dnsmasq.conf"
else
  echo "ℹ️ Konfigurasi dnsmasq.conf sudah ada"
fi

# 5. Buat skrip update
wget -O /etc/update-blocklist.sh "https://raw.githubusercontent.com/tokektv/judikiller/refs/heads/main/update-blocklist.sh" || {
     echo "Error: Gagal download" >&2
     exit 1
   }

chmod +x /etc/update-blocklist.sh
echo "📜 Membuat skrip update-blocklist.sh"

# 6. Jadwalkan update harian
(crontab -l 2>/dev/null | grep -v "update-blocklist"; echo "0 3 * * * /etc/update-blocklist.sh >/dev/null 2>&1") | crontab -
echo "⏰ Menjadwalkan update otomatis jam 3 pagi setiap hari"

# 7. Jalankan update pertama kali
echo "🔄 Menjalankan update pertama..."
/etc/update-blocklist.sh

echo "🎉 Instalasi selesai!"
echo "ℹ️ File yang dibuat:"
echo "   - /etc/dnsmasq.d/manual-block.conf (untuk blokir manual)"
echo "   - /etc/dnsmasq.d/gambling-block.conf (blokir otomatis)"
echo "   - /etc/update-blocklist.sh (skrip update)"
