---
title: Power
description: Mengelola tindakan daya, perilaku menganggur, dan mode tetap aktif.
---

`argvus-power` mengintegrasikan tindakan daya, waktu habis menganggur, pengelolaan kunci/DPMS, dan status tetap aktif dengan sesi. Pusat Kontrol dan Panel Kontrol menampilkan kontrol yang dapat diakses pengguna.

Gunakan pembantu yang terpasang dan `--help` untuk opsi mereka yang tepat. Daftar layanan sesi dan perintah restart didokumentasikan dalam [Services](/docs/reference/services/).

Gunakan **Control Center → Power** untuk halaman kebijakan daya/sesi yang tersedia dan **Control Panel → Session/Power** untuk tindakan langsung seperti mengunci, menangguhkan, keluar, atau mematikan saat tindakan tersebut tersedia. Tindakan pada panel tidak menggantikan konfigurasi idle atau DPMS yang persisten.

## Tetap Terjaga

Keep Awake tersedia di **Control Center → Power**, **Control Panel → Session/Power**, dan melalui `SUPER + ALT + W`. Kontrol tersebut berbagi status sesi yang sama, jadi mengubahnya di satu tempat akan memperbarui perilaku di tempat lain. Setiap aktivasi atau deaktivasi menampilkan notifikasi.

Ketika diaktifkan, Tetap Terjaga mencegah kebijakan menganggur ARGVUS memulai penguncian layar otomatis dan penghitung daya tampilan. Tetap Terjaga adalah preferensi `/power/keep_awake` yang persisten: `argvus-config` memproyeksikan penanda `data/power/keep-awake`, dan saat file itu diaktifkan sesi tidak memulai `argvus-hypridle.service`. Nonaktifkan Tetap Terjaga untuk mengembalikan perilaku menganggur dan kunci normal.

:::caution
Jika layar tidak terkunci secara otomatis, periksa apakah Tetap Terjaga diaktifkan dan nonaktifkan jika perlu.
:::
