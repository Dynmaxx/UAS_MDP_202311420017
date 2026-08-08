// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../database/database_helper.dart';

class TransactionFormPage extends StatefulWidget {
  // tambahkan code ini untuk edit data
  final Transaction? transaction;
  const TransactionFormPage({super.key, this.transaction});
  @override
  State<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends State<TransactionFormPage> {
  // GlobalKey untuk mengidentifikasi dan memvalidasi form
  final _formKey = GlobalKey<FormState>();
  // Controller untuk mengontrol input text field
  final _nominalController = TextEditingController();
  final _keteranganController = TextEditingController();
  // State default sebelum user input
  DateTime _selectedDate = DateTime.now();
  String _selectedJenis = 'pemasukan';
  bool _isSaving = false;
  bool _isEditing = false;
  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _isEditing = true;
      _selectedDate = widget.transaction!.tanggal;
      _nominalController.text = widget.transaction!.nominal.toStringAsFixed(0);
      _keteranganController.text = widget.transaction!.keterangan ?? '';
      _selectedJenis = widget.transaction!.jenis;
    }
  }

  @override
  void dispose() {
    // Penting! Selalu dispose controller untuk menghindari memory leak
    _nominalController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  // Menampilkan Date Picker untuk memilih tanggal.
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020), // Tanggal paling awal yang bisa dipilih
      lastDate: DateTime(2030), // Tanggal paling akhir yang bisa dipilih
      // Kustomisasi tema date picker
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF1565C0)),
          ),
          child: child!,
        );
      },
    );
    // Jika user memilih tanggal (tidak menekan Cancel)
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Fungsi untuk menyimpan data transaksi.
  Future<void> _saveTransaction() async {
    // Validasi form terlebih dahulu
    if (!_formKey.currentState!.validate()) {
      return; // Jika validasi gagal, hentikan proses
    }
    setState(() {
      _isSaving = true;
    });
    // Membuat objek Transaction dari input form
    Transaction transaction = Transaction(
      id: _isEditing ? widget.transaction!.id : null,
      tanggal: _selectedDate,
      nominal: double.parse(_nominalController.text),
      keterangan: _keteranganController.text.trim(),
      jenis: _selectedJenis,
    );
    // Simpan ke database SQLite memanggil fungsi insert atau update
    if (_isEditing) {
      await DatabaseHelper.instance.updateTransaction(transaction);
    } else {
      await DatabaseHelper.instance.insertTransaction(transaction);
    }
    // Beri delay singkat agar animasi loading
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _isSaving = false;
    });
    // Periksa apakah widget masih terpasang sebelum navigasi
    if (!mounted) return;
    // Tampilkan pesan sukses
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEditing
              ? 'Transaksi berhasil diperbarui!'
              : 'Transaksi berhasil ditambahkan!',
        ),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    // Kembali ke halaman sebelumnya
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Transaksi' : 'Tambah Transaksi',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          // Form key untuk validasi
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // =============================================================
              // Field 1: Tanggal
              // =============================================================
              const Text(
                'Tanggal',
                style: TextStyle(
                  fontSize: 14,

                  fontWeight: FontWeight.w600,
                  color: Color(0xFF424242),
                ),
              ),
              const SizedBox(height: 8),
              // InkWell membuat area bisa di-tap
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),

                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        color: Color(0xFF1565C0),
                        size: 20,
                      ),

                      const SizedBox(width: 12),
                      Text(
                        // Format tanggal: "12 Juni 2026"
                        DateFormat(
                          'dd MMMM yyyy',
                          'id_ID',
                        ).format(_selectedDate),

                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // =============================================================
              // Field 2: Nominal
              // =============================================================
              const Text(
                'Nominal (Rp)',
                style: TextStyle(
                  fontSize: 14,

                  fontWeight: FontWeight.w600,
                  color: Color(0xFF424242),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nominalController,
                // Keyboard khusus angka
                keyboardType: TextInputType.number,
                // Hanya memperbolehkan input berupa angka
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: 'Masukkan nominal',
                  prefixIcon: const Icon(
                    Icons.attach_money_rounded,
                    color: Color(0xFF1565C0),
                  ),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),

                    borderSide: const BorderSide(
                      color: Color(0xFF1565C0),

                      width: 2,
                    ),
                  ),
                ),
                // --- Validasi Nominal ---
                validator: (value) {
                  // Cek apakah field kosong

                  if (value == null || value.trim().isEmpty) {
                    return 'Nominal wajib diisi';
                  }

                  // Cek apakah input berupa angka
                  double? nominal = double.tryParse(value);
                  if (nominal == null) {
                    return 'Nominal harus berupa angka';
                  }

                  // Cek apakah nominal lebih dari 0
                  if (nominal <= 0) {
                    return 'Nominal harus lebih dari 0';
                  }

                  return null; // Validasi berhasil
                },
              ),
              const SizedBox(height: 20),
              // =============================================================
              // Field 3: Keterangan
              // =============================================================
              const Text(
                'Keterangan',
                style: TextStyle(
                  fontSize: 14,

                  fontWeight: FontWeight.w600,
                  color: Color(0xFF424242),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _keteranganController,
                // Memungkinkan input beberapa baris
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Contoh: Gaji bulan Juni',

                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: Icon(Icons.notes_rounded, color: Color(0xFF1565C0)),
                  ),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),

                    borderSide: const BorderSide(
                      color: Color(0xFF1565C0),

                      width: 2,
                    ),
                  ),
                ),
                // --- Validasi Keterangan ---
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Keterangan wajib diisi';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),
              // =============================================================
              // Field 4: Jenis Transaksi (Dropdown)
              // =============================================================
              const Text(
                'Jenis Transaksi',
                style: TextStyle(
                  fontSize: 14,

                  fontWeight: FontWeight.w600,
                  color: Color(0xFF424242),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedJenis,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.category_rounded,
                    color: Color(0xFF1565C0),
                  ),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),

                    borderSide: const BorderSide(
                      color: Color(0xFF1565C0),

                      width: 2,
                    ),
                  ),
                ),
                // Daftar pilihan jenis transaksi
                items: const [
                  DropdownMenuItem(
                    value: 'pemasukan',
                    child: Text('Pemasukan'),
                  ),

                  DropdownMenuItem(
                    value: 'pengeluaran',
                    child: Text('Pengeluaran'),
                  ),
                ],
                // Callback saat pilihan berubah
                onChanged: (value) {
                  setState(() {
                    _selectedJenis = value!;
                  });
                },
                // --- Validasi Dropdown ---
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jenis transaksi wajib dipilih';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 32),
              // =============================================================
              // Tombol Simpan
              // =============================================================
              ElevatedButton(
                onPressed: _isSaving ? null : _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),

                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),

                  elevation: 3,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Simpan Transaksi',
                        style: TextStyle(
                          fontSize: 16,

                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
