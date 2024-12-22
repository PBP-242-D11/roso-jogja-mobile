# RosoJogja Mobile

[![Staging](https://github.com/PBP-242-D11/roso-jogja-mobile/actions/workflows/staging.yml/badge.svg)](https://github.com/PBP-242-D11/roso-jogja-mobile/actions/workflows/staging.yml)
[![Staging](https://github.com/PBP-242-D11/roso-jogja-mobile/actions/workflows/staging.yml/badge.svg)](https://github.com/PBP-242-D11/roso-jogja-mobile/actions/workflows/staging.yml)
[![Staging](https://github.com/PBP-242-D11/roso-jogja-mobile/actions/workflows/staging.yml/badge.svg)](https://github.com/PBP-242-D11/roso-jogja-mobile/actions/workflows/staging.yml)
[![Build status](https://build.appcenter.ms/v0.1/apps/42cb4aac-3bd6-4dd4-a12e-e77eb18135bf/branches/main/badge)](https://appcenter.ms)

---
Promotional Video:
[YouTube](https://youtu.be/gvJ41rK6REs)
---

## Nama Anggota Kelompok PBP-D11:
1. Akhdan Taufiq Syofyan (2306152475)
2. Fadhli Raihan Ardiansyah (2306207594)
3. Makarim Zufar Prambudyo (2306241751)
4. Nadia Rahmadina Aristawati (2306207972)
5. Yudayana Arif Prasojo (2306215160)

## Deskripsi Aplikasi
RosoJogja adalah aplikasi kuliner yang dirancang khusus untuk membantu Anda menemukan dan memesan makanan atau minuman dari berbagai restoran dan tempat makan di Yogyakarta. Dengan antarmuka yang intuitif, RosoJogja memberikan kemudahan dalam mencari restoran, melihat menu, hingga memesan makanan atau minuman.

## Daftar Modul yang Diimplementasikan

### 1. Restoran dan Makanan
**Yang mengerjakan**: Yudayana Arif Prasojo

| Peran       | Fitur                                                                                           |
|-------------|-------------------------------------------------------------------------------------------------|
| **Guest**   | Melihat daftar restoran dan makanan (tidak bisa memesan makanan jika belum login)               |
| **Pembeli** | Melihat daftar restoran dan makanan dari setiap restoran (memasukkan ke dalam cart dan membuat order). |
| **Penjual** | Membuat, memodifikasi, dan menghapus informasi dari restoran ataupun makanan yang dimiliki oleh penjual |

### 2. Cart dan Order
**Yang mengerjakan**: Akhdan Taufiq Syofyan

| Peran       | Fitur                                                                                           |
|-------------|-------------------------------------------------------------------------------------------------|
| **Guest**   | Tidak dapat mengakses cart ataupun order (tidak ada akses ke cart dan order)                    |
| **Pembeli** | Memasukkan makanan ke dalam cart dan melakukan checkout untuk membuat order.                    |
| **Penjual** | Tidak dapat mengakses cart ataupun order                                                        |

### 3. Promo
**Yang mengerjakan**: Nadia Rahmadina Aristawati

| Peran       | Fitur                                                                                           |
|-------------|-------------------------------------------------------------------------------------------------|
| **Guest**   | Tidak dapat mengakses pembuatan promo                                                           |
| **Pembeli** | Menggunakan voucher yang telah ditambahkan oleh admin dengan memasukkan sebuah kode untuk meng-claim voucher tersebut. |
| **Penjual** | Membuat, memodifikasi, dan menghapus promo yang terdapat pada restoran yang dimiliki oleh penjual |

### 4. Wishlist
**Yang mengerjakan**: Makarim Zufar Prambudyo

| Peran       | Fitur                                                                                           |
|-------------|-------------------------------------------------------------------------------------------------|
| **Guest**   | Tidak dapat mengakses wishlist                                                                  |
| **Pembeli** | Menambahkan makanan yang ingin dibeli kepada wishlist (list makanan yang ingin dicoba).         |
| **Penjual** | Tidak dapat mengakses wishlist                                                                  |

### 5. Review
**Yang mengerjakan**: Fadhli Raihan Ardiansyah

| Peran       | Fitur                                                                                           |
|-------------|-------------------------------------------------------------------------------------------------|
| **Guest**   | Dapat membaca review yang terdapat di restoran                                                  |
| **Pembeli** | Menambahkan dan menghapus reviewnya kepada restoran yang sebelumnya sudah pernah dipesan.       |
| **Penjual** | Dapat membaca review yang terdapat di restorannya                                               |

## Role atau Peran
**1. Pembeli**

Peran utama di aplikasi, pembeli dapat membeli makanan dari sebuah restoran, menambahkan makanan kepada wishlist, dan menulis review terhadap suatu restoran.

**2. Penjual**

Penjual dapat memodifikasi makanan yang terdapat di restoran yang dimilikinya.

## Sumber dataset kuliner Jogja

[Kaggle](https://www.kaggle.com/datasets/yudhaislamisulistya/places-to-eat-in-the-jogja-region)

## Alur pengintegrasian dengan web service untuk terhubung dengan aplikasi web yang sudah dibuat saat Proyek Tengah Semester

1. Menyesuaikan dan menyiapkan project Django untuk integrasi dengan menambahkan library `django-cors-headers` dan konfigurasi yang berkaitan dengannya. 
2. Menambahkan depedensi http dengan menjalankan perintah `flutter pub add http`, `flutter pub add provider`, dan `flutter add pub pbp_django_auth` pada terminal proyek agar dapat digunakan untuk bertukar HTTP Request.
3. Membuat model yang sesuai dengan respons JSON dari web service, kami menggunakan quicktype untuk membantu pembuatan model-model app kami (tercantum pada direktori models).
4. Untuk menyesuaikan return yang dibutuhkan app yang dibuat, kami memodifikasi beberapa views code web service kami (proyek TK UTS Django).
5. Data yang didapat kemudian diolah atau dipetakan ke dalam suatu struktur data, baik Map maupun List. Kemudian, data yang sudah dikonversi ke aplikasi ditampilkan melalui FutureBuilder.

Melalui langkah-langkah pengintegrasian tersebut, kita akan mendapatkan alur pengajuan request hingga mendapatkan response sebagai berikut, contohnya untuk aplikasi Promo:
1. Request dari aplikasi Flutter:

- Aplikasi RosoJogja Mobile mengirim request ke server Django melalui internet untuk melakukan pemasangan promo.
- Request ditujukan ke endpoint API /api/promo sesuai konfigurasi urls.py Django.

2. Pemrosesan Request di Django:

- Django menangani request dengan melakukan mapping ke fungsi yang sesuai dalam views.py, yaitu use_promo.
- Fungsi ini memproses data, mengakses database user melalui objek User yang telah dibuat pada models.py, dan menjalankan logika bisnis yang diperlukan pada setiap fiturnya, semisal memotong harga belanja setelah memasang promo.

3. Pembuatan Response:

- Setelah pemrosesan selesai, Django menyusun response sukses atau tidaknya dalam format JSON sebelum mengembalikan data ke Flutter.

4. Pengiriman Response kepada aplikasi Flutter:

- Django mengirim response kembali ke aplikasi Flutter.
- Flutter menerima response dan mengolah data yang diterima.

5. Update tampilan di Flutter:

- Data yang diterima dari response dapat digunakan untuk memperbarui tampilan, informasi, dan memicu aksi lain berdasarkan data tersebut, seperti menampilkan harga setelah pemasangan promo.

---

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
