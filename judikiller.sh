#!/bin/sh

# File output akhir untuk Dnsmasq
BLOCKLIST_FILE="/etc/dnsmasq.d/gambling-block.conf"

# Sumber daftar blokir (format: hosts atau plain text)
SOURCES=(
  "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling-only/hosts"  # Daftar global
  "https://raw.githubusercontent.com/anonimized/repo-indo-judi/main/blocklist.txt"            # Contoh repo khusus Indonesia
  "https://small.oisd.nl/gambling"                                                           # Filter gambling OISD
)

# Bersihkan file output
> "$BLOCKLIST_FILE"

# Download & proses setiap sumber
for url in "${SOURCES[@]}"; do
  echo "Memproses: $url"
  wget -qO- "$url" | \
    awk '/^0\.0\.0\.0|^127\.0\.0\.1/ {print "address=/"$2"/0.0.0.0"}' \
    >> "$BLOCKLIST_FILE"
done

# Gabungkan dengan daftar manual
cat /etc/dnsmasq.d/manual-block.conf >> "$BLOCKLIST_FILE"

# Hapus duplikat & urutkan
sort -u -o "$BLOCKLIST_FILE" "$BLOCKLIST_FILE"

# Restart Dnsmasq
/etc/init.d/dnsmasq restart
echo "✅ Daftar blokir telah diupdate (${#SOURCES[@]} sumber + manual)"
