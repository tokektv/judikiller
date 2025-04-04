#!/bin/sh

# File output akhir untuk Dnsmasq
BLOCKLIST_FILE="/etc/dnsmasq.d/gambling-block.conf"

# Sumber daftar blokir (format: hosts atau plain text)
#SOURCE1="https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling-only/hosts"  # Daftar global
SOURCE1="https://raw.githubusercontent.com/tokektv/judikiller/refs/heads/main/blocklist.txt"               # Ganti dengan repo nyata
                                                          # Filter gambling OISD

# Bersihkan file output
> "$BLOCKLIST_FILE"

# Proses setiap sumber satu per satu
for url in "$SOURCE1" ; do
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
echo "✅ Daftar blokir telah diupdate (3 sumber + manual)"
