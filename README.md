# Taratech App

Aplikasi manajemen transaksi keuangan sederhana berbasis Flutter yang terhubung dengan Supabase sebagai backend.

## Fitur

- **Lihat Transaksi** — Menampilkan daftar transaksi dari Supabase, diurutkan dari terbaru
- **Tambah Transaksi** — Form untuk menginput nama, jumlah (dengan thousand separator), tanggal & waktu, dan kategori (Debit/Credit)
- **Edit Transaksi** — Ubah data transaksi yang sudah ada
- **Hapus Transaksi** — Hapus transaksi dengan konfirmasi dialog
- **Filter Rentang Tanggal** — Filter transaksi berdasarkan tanggal mulai dan tanggal akhir, query langsung ke Supabase

## Tech Stack

- **Flutter** — UI framework
- **Supabase** — Backend (PostgreSQL + REST API)
- **supabase_flutter** — Dart SDK untuk Supabase
- **intl** — Format tanggal dan angka

## Struktur Tabel Supabase

```sql
create table transactions (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  amount numeric not null,
  date timestamptz not null,
  category text not null,
  created_at timestamptz default now()
);
```

## Demo

- [Demo Video](assets/2026-05-13%2020-00-15.mp4)
