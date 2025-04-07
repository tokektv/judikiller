#!/bin/sh

# =============================================
# INSTALASI AWAL DNSMASQ BLOCKER (OPENWRT 24 COMPATIBLE)
# =============================================

echo "🔧 Memulai instalasi pemblokir situs judi..."

# 1. Install dependency
echo "📦 Menginstall dependensi..."
opkg update
opkg install coreutils-sort curl ca-bundle

# 2. Setup direktori
mkdir -p /etc/dnsmasq.d
echo "📁 Membuat /etc/dnsmasq.d"

# 3. Buat file konfigurasi manual
cat > /etc/dnsmasq.d/manual-block.conf <<EOF
# Daftar blokir manual
# Format: address=/domain.com/0.0.0.0
address=/judionline.id/0.0.0.0
address=/slotgacor777.com/0.0.0.0
EOF
echo "📝 Membuat file manual-block.conf"

# 4. Konfigurasi UCI untuk dnsmasq
echo "⚙️ Mengkonfigurasi UCI..."
uci delete dhcp.@dnsmasq[0].confdir 2>/dev/null
uci add_list dhcp.@dnsmasq[0].confdir='/etc/dnsmasq.d/'
uci commit dhcp

# 5. Buat file blokir utama
> /etc/dnsmasq.d/gambling-block.conf
chmod 644 /etc/dnsmasq.d/gambling-block.conf
echo "📄 Membuat file gambling-block.conf"

# 6. Buat skrip update
echo "📜 Mengunduh skrip update..."
wget -O /etc/update-blocklist.sh "https://raw.githubusercontent.com/tokektv/judikiller/refs/heads/main/update-blocklist.sh" || {
  echo "❌ Gagal mengunduh skrip update" >&2
  exit 1
}
chmod +x /etc/update-blocklist.sh

# 7. Jadwalkan update harian
echo "⏰ Menjadwalkan update otomatis..."
(crontab -l 2>/dev/null | grep -v "update-blocklist"; echo "0 3 * * * /etc/update-blocklist.sh >/dev/null 2>&1") | crontab -

# 8. Jalankan update pertama kali
echo "🔄 Menjalankan update pertama..."
/etc/update-blocklist.sh

# 9. Restart service
echo "♻️ Merestart dnsmasq..."
/etc/init.d/dnsmasq restart

echo ""
echo "🎉 Instalasi selesai!"
echo "ℹ️ File yang dibuat:"
echo "   - /etc/dnsmasq.d/manual-block.conf (untuk blokir manual)"
echo "   - /etc/dnsmasq.d/gambling-block.conf (blokir otomatis)"
echo "   - /etc/update-blocklist.sh (skrip update)"
echo ""
echo "⚠️ Pastikan:"
echo "   - Tidak ada konflik dengan odhcpd"
echo "   - Port 53 tidak digunakan oleh service lain"
echo "   - DNS Forwarding di LuCI dikosongkan"
