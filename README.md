# OSINT Stalker — Professional OSINT Toolkit

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?style=for-the-badge&logo=android)


**OSINT Stalker** adalah aplikasi *Open Source Intelligence* (OSINT) berbasis mobile yang dirancang untuk mempermudah investigasi digital. Aplikasi ini mengotomatisasi pembuatan *Google Dorks* yang kompleks dan menghubungkan peneliti dengan berbagai database publik untuk melacak jejak digital berdasarkan Nomor Telepon, Email, Username, Domain, IP Address, dan Nama.

> **Peringatan:** Alat ini dibuat untuk tujuan edukasi dan investigasi legal. Penyalahgunaan informasi untuk tindakan ilegal adalah tanggung jawab pengguna sepenuhnya.
---

**Status:** Production-ready UI – fitur dorking lanjutan, multi-engine search, dan QRIS dinamis.

**Author:** Xnuvers007

**Donate / Support:** https://trakteer.id/Xnuvers007

---

**Isi README ini:**
- Deskripsi singkat
- Fitur utama
- Cara instal & menjalankan
- Contoh penggunaan
- Penjelasan QRIS dinamis & tombol donate
- Keamanan, etika, dan batasan hukum
- Kontribusi dan kontak

## Fitur Utama

## ✨ Fitur Utama (Advanced Features)

### 🔍 1. Multi-Vector Reconnaissance
Melakukan pencarian mendalam berdasarkan 6 kategori target:
* **Phone Number:** Otomatisasi permutasi format (08xx, +62xx, 62-xx) untuk menemukan jejak di web, media sosial, dan database kontak (Truecaller/GetContact).
* **Email Address:** Cek kebocoran data (Data Breach), akun media sosial, dan file dokumen yang terekspos.
* **Username:** Melacak penggunaan username yang sama di ratusan platform media sosial.
* **Domain:** Subdomain finder, cek file konfigurasi bocor (.env, .git), dan analisis kerentanan.
* **IP Address:** Geolocation, analisis ancaman (VirusTotal/AbuseIPDB), dan port scanning (Shodan).
* **Real Name:** Mencari jejak digital personal, berita, dan dokumen resmi.

### 🚀 2. Advanced Dorking Engine
* **Smart Permutation Logic:** Algoritma pintar yang menyusun belasan variasi query pencarian secara otomatis.
* **Multi-Engine Support:** Tidak hanya Google, dukung pencarian via Bing, DuckDuckGo, Yandex, Brave, Startpage, dll.
* **Dork Templates:** Kumpulan *cheat sheet* dork siap pakai untuk kasus spesifik (mencari file PDF, password bocor, CCTV, dll).

### 💳 3. Utility: Dynamic QRIS Generator
Fitur unik untuk kebutuhan donasi atau pembayaran:
* Mengubah QRIS Statis menjadi Dinamis.
* Injeksi nominal transaksi secara otomatis.
* Perhitungan otomatis **CRC16 Checksum** (algoritma CCITT-FALSE) untuk validasi standar pembayaran Indonesia.

### 🎨 4. Modern Cyberpunk UI
* Desain antarmuka bertema *Hacker/Cyberpunk* (Dark Mode & Neon).
* Animasi fluid menggunakan `flutter_animate`.
* Haptic Feedback untuk pengalaman pengguna yang taktil.

## Struktur Proyek (singkat)

- `lib/main.dart` — titik masuk aplikasi.
- `lib/home_screen.dart` — UI utama dan kontrol pencarian.
- `lib/osint_logic.dart` — logika dorking / generation URL pencarian.
- `lib/utils/qris_converter.dart` — konverter QRIS statis -> dinamis + CRC16.
- `lib/screens/donate_screen.dart` — layar donate & QRIS generator.
- `lib/screens/dork_templates_screen.dart` — daftar template dork siap pakai.
- `pubspec.yaml` — dependencies & konfigurasi Flutter.

---

## 🛠️ Tech Stack

* **Framework:** [Flutter](https://flutter.dev/) (SDK >3.5.4)
* **Language:** Dart
* **State Management:** Native (`setState` & `StatefulWidget` optimization)
* **Packages:**
    * `url_launcher`: Membuka link eksternal.
    * `google_fonts`: Tipografi (*Source Code Pro*).
    * `flutter_animate`: Animasi UI.
    * `qr_flutter`: Render QR Code.
    * `share_plus`: Fitur berbagi konten.
    * `font_awesome_flutter`: Ikonografi.

---

## 🚀 Cara Instalasi

### Prasyarat
* Flutter SDK terinstal.
* Java JDK 17 (Disarankan).
* Android Studio / VS Code.

### Langkah-langkah
1.  **Clone Repository**
    ```bash
    git clone [https://github.com/Xnuvers007/osint_stalker.git](https://github.com/Xnuvers007/osint_stalker.git)
    cd osint_stalker
    ```

2.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

3.  **Jalankan Aplikasi**
    Pastikan emulator atau device terhubung.
    ```bash
    flutter run
    ```

4.  **Build APK (Release)**
    ```bash
    flutter build apk --release --no-tree-shake-icons
    ```
---

## Contoh Penggunaan

1. Pilih tipe pencarian (mis. Phone).
2. Masukkan nomor target (contoh: `085712345678`). Sistem akan otomatis menormalisasi menjadi format internasional.
3. (Opsional) Tambahkan `Custom Domain` untuk membatasi pencarian ke situs tertentu.
4. Pilih mesin pencari yang diinginkan (mis. Google + Bing).
5. Tekan `SEARCH` → hasil dork akan muncul pada list; tap item untuk membuka di browser.

## QRIS Dinamis (penjelasan singkat)

Aplikasi memiliki utilitas untuk mengubah QRIS statis menjadi QRIS dinamis (menyisipkan nominal dan optional biaya layanan), lalu menghitung CRC16 terakhir agar QR dapat dipindai.

- Lokasi util: `lib/utils/qris_converter.dart`.
- Fitur: input nominal (preset atau custom), generate QRIS string, tampilkan QR image, copy/share.

Contoh flow di UI:
- Masukkan nominal (mis. `15000`) → `GENERATE QRIS` → QR muncul → `COPY` atau `SHARE`.

> Catatan: Gunakan hanya pada kode QRIS milik Anda atau saat pemilik merchant telah memberi izin.

## Etika & Hukum

OSINT dapat dipakai untuk tujuan yang sah (investigasi, auditing, pemulihan akun, riset publik). Jangan gunakan alat ini untuk:
- Mengakses sistem atau data tanpa izin.
- Melakukan penipuan, stalking berbahaya, pelanggaran privasi.
- Melakukan tindakan ilegal atau merugikan pihak lain.

Penggunaan alat ini adalah tanggung jawab pengguna. Penulis tidak bertanggung jawab atas penyalahgunaan.

## Testing & Pengembangan

- Jalankan `flutter analyze` untuk analisa statis.
- Jalankan `flutter test` untuk unit test jika ada ditambahkan.

```bash
flutter analyze
flutter test
```

## Kontribusi

Kontribusi dibuka. Untuk kontribusi:
1. Fork repo
2. Buat branch fitur: `feature/your-feature`
3. Commit & push
4. Buat PR dengan deskripsi perubahan dan tujuan

Mohon sertakan tests untuk fungsi penting (contoh: konversi QRIS, generator dork).

## Troubleshooting

- Jika ada error dependency setelah `pub get`, jalankan:

```bash
flutter pub cache repair
flutter clean
flutter pub get
```

- Jika QR tidak terbaca: pastikan payload QRIS benar dan CRC16 dihasilkan dengan tepat.

## Lisensi

Sertakan lisensi yang Anda inginkan (mis. MIT). Jika belum, tambahkan file `LICENSE` sesuai pilihan.

---

Terima kasih telah menggunakan OSINT Stalker — kontribusi, saran, dan dukungan sangat dihargai.

Kontak & Social:
- Trakteer: https://trakteer.id/Xnuvers007
- Email: [email](mailto:xnuversh1kar4@gmail.com)

---

