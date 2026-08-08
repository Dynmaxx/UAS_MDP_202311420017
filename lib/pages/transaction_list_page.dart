import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/database_helper.dart';
import '../models/transaction.dart';
import 'transaction_form_page.dart';

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  List<Transaction> _transactions = [];

  bool _isLoading = true;

  // =========================================================
  // FILTER
  // =========================================================

  DateTime? _startDate;
  DateTime? _endDate;

  String _selectedJenis = 'Semua';

  final List<String> _jenisOptions = ['Semua', 'Pemasukan', 'Pengeluaran'];

  @override
  void initState() {
    super.initState();

    loadTransactions();
  }

  // =========================================================
  // LOAD TRANSAKSI
  // =========================================================

  Future<void> loadTransactions() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final List<Transaction> transactions = await DatabaseHelper.instance
          .getAllTransactions(
            startDate: _startDate,
            endDate: _endDate,
            jenis: _selectedJenis,
          );

      if (!mounted) return;

      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat transaksi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =========================================================
  // MODAL FILTER
  // =========================================================

  Future<void> _showFilterModal() async {
    // Menyimpan nilai sementara.
    DateTime? tempStartDate = _startDate;
    DateTime? tempEndDate = _endDate;
    String tempJenis = _selectedJenis;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                20 + MediaQuery.of(modalContext).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Garis kecil di atas modal.
                    Center(
                      child: Container(
                        width: 45,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Row(
                      children: [
                        Icon(
                          Icons.filter_alt_outlined,
                          color: Color(0xFF1565C0),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Filter Transaksi',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF263238),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ===============================
                    // TANGGAL AWAL
                    // ===============================
                    const Text(
                      'Tanggal Awal',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: modalContext,
                          initialDate: tempStartDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );

                        if (picked != null) {
                          setModalState(() {
                            tempStartDate = picked;
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              color: Color(0xFF1565C0),
                              size: 20,
                            ),

                            const SizedBox(width: 12),

                            Text(
                              tempStartDate == null
                                  ? 'Pilih tanggal awal'
                                  : _formatTanggal(tempStartDate!),
                              style: TextStyle(
                                color: tempStartDate == null
                                    ? Colors.grey
                                    : Colors.black87,
                              ),
                            ),

                            const Spacer(),

                            if (tempStartDate != null)
                              GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    tempStartDate = null;
                                  });
                                },
                                child: const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ===============================
                    // TANGGAL AKHIR
                    // ===============================
                    const Text(
                      'Tanggal Akhir',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: modalContext,
                          initialDate:
                              tempEndDate ?? tempStartDate ?? DateTime.now(),
                          firstDate: tempStartDate ?? DateTime(2000),
                          lastDate: DateTime(2100),
                        );

                        if (picked != null) {
                          setModalState(() {
                            tempEndDate = picked;
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.event_available_outlined,
                              color: Color(0xFF1565C0),
                              size: 20,
                            ),

                            const SizedBox(width: 12),

                            Text(
                              tempEndDate == null
                                  ? 'Pilih tanggal akhir'
                                  : _formatTanggal(tempEndDate!),
                              style: TextStyle(
                                color: tempEndDate == null
                                    ? Colors.grey
                                    : Colors.black87,
                              ),
                            ),

                            const Spacer(),

                            if (tempEndDate != null)
                              GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    tempEndDate = null;
                                  });
                                },
                                child: const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ===============================
                    // KATEGORI
                    // ===============================
                    const Text(
                      'Kategori Transaksi',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    DropdownButtonFormField<String>(
                      initialValue: tempJenis,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.category_outlined,
                          color: Color(0xFF1565C0),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      items: _jenisOptions
                          .map(
                            (jenis) => DropdownMenuItem<String>(
                              value: jenis,
                              child: Text(jenis),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        setModalState(() {
                          tempJenis = value;
                        });
                      },
                    ),

                    const SizedBox(height: 28),

                    // ===============================
                    // BUTTON RESET & TERAPKAN
                    // ===============================
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setModalState(() {
                                tempStartDate = null;
                                tempEndDate = null;
                                tempJenis = 'Semua';
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Reset'),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Validasi rentang tanggal
                              if (tempStartDate != null &&
                                  tempEndDate != null &&
                                  tempStartDate!.isAfter(tempEndDate!)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Tanggal awal tidak boleh melebihi tanggal akhir.',
                                    ),
                                  ),
                                );

                                return;
                              }

                              _startDate = tempStartDate;
                              _endDate = tempEndDate;
                              _selectedJenis = tempJenis;

                              Navigator.pop(modalContext);

                              loadTransactions();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1565C0),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Terapkan Filter'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // =========================================================
  // RESET FILTER
  // =========================================================

  Future<void> _resetFilter() async {
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedJenis = 'Semua';
    });

    await loadTransactions();
  }

  // =========================================================
  // EDIT
  // =========================================================

  Future<void> handleEdit(Transaction transaction) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionFormPage(transaction: transaction),
      ),
    );

    if (!mounted) return;

    await loadTransactions();
  }

  // =========================================================
  // DELETE
  // =========================================================

  Future<void> handleDelete(Transaction transaction) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text('Konfirmasi Hapus'),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus transaksi "${transaction.keterangan}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      if (transaction.id == null) {
        return;
      }

      await DatabaseHelper.instance.deleteTransaction(transaction.id!);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Transaksi berhasil dihapus!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      await loadTransactions();
    }
  }

  // =========================================================
  // FORMAT RUPIAH
  // =========================================================

  String _formatRupiah(double value) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return formatter.format(value);
  }

  // =========================================================
  // FORMAT TANGGAL
  // =========================================================

  String _formatTanggal(DateTime date) {
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }

  // =========================================================
  // FORMAT NOMINAL
  // =========================================================

  String _formatNominal(Transaction transaction) {
    bool isPemasukan = transaction.jenis.toLowerCase() == 'pemasukan';

    return '${isPemasukan ? '+' : '-'}${_formatRupiah(transaction.nominal)}';
  }

  // =========================================================
  // STATUS FILTER
  // =========================================================

  bool get _filterAktif {
    return _startDate != null || _endDate != null || _selectedJenis != 'Semua';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      // =====================================================
      // APP BAR
      // =====================================================
      appBar: AppBar(
        title: const Text(
          'Daftar Transaksi',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),

        // Tombol filter
        actions: [
          Stack(
            children: [
              IconButton(
                tooltip: 'Filter Transaksi',
                onPressed: _showFilterModal,
                icon: const Icon(
                  Icons.filter_alt_outlined,
                  color: Colors.white,
                ),
              ),

              // Indikator filter aktif
              if (_filterAktif)
                Positioned(
                  right: 9,
                  top: 9,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),

      // =====================================================
      // BODY
      // =====================================================
      body: Column(
        children: [
          // ===============================================
          // INFORMASI FILTER AKTIF
          // ===============================================
          if (_filterAktif)
            Container(
              width: double.infinity,
              color: const Color(0xFFE3F2FD),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.filter_alt,
                    color: Color(0xFF1565C0),
                    size: 18,
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      _getFilterDescription(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1565C0),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  TextButton(
                    onPressed: _resetFilter,
                    child: const Text(
                      'Reset',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),

          // ===============================================
          // LIST
          // ===============================================
          Expanded(child: _buildBody()),
        ],
      ),

      // =====================================================
      // TOMBOL TAMBAH
      // =====================================================
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TransactionFormPage(),
            ),
          );

          if (!mounted) return;

          await loadTransactions();
        },
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  // =========================================================
  // BODY LIST TRANSAKSI
  // =========================================================

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_transactions.isEmpty) {
      return RefreshIndicator(
        onRefresh: loadTransactions,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_rounded,
                      size: 80,
                      color: Colors.grey[300],
                    ),

                    const SizedBox(height: 16),

                    Text(
                      _filterAktif
                          ? 'Tidak ada transaksi yang sesuai filter'
                          : 'Belum ada transaksi',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    if (_filterAktif)
                      TextButton(
                        onPressed: _resetFilter,
                        child: const Text('Hapus Filter'),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadTransactions,
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: _transactions.length,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          thickness: 1,
          indent: 70,
          color: Color(0xFFEEEEEE),
        ),
        itemBuilder: (context, index) {
          final Transaction transaction = _transactions[index];

          final bool isPemasukan =
              transaction.jenis.toLowerCase() == 'pemasukan';

          final Color jenisColor = isPemasukan
              ? const Color(0xFF2E7D32)
              : const Color(0xFFC62828);

          final IconData jenisIcon = isPemasukan
              ? Icons.arrow_downward_rounded
              : Icons.arrow_upward_rounded;

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),

            leading: CircleAvatar(
              radius: 24,
              backgroundColor: jenisColor.withValues(alpha: 0.1),
              child: Icon(jenisIcon, color: jenisColor, size: 24),
            ),

            title: Text(
              transaction.keterangan ?? '',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 12, color: Colors.grey[500]),

                  const SizedBox(width: 4),

                  Text(
                    _formatTanggal(transaction.tanggal),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatNominal(transaction),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: jenisColor,
                  ),
                ),

                const SizedBox(height: 4),

                SizedBox(
                  height: 24,
                  width: 24,
                  child: PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.more_vert,
                      size: 18,
                      color: Colors.grey,
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        handleEdit(transaction);
                      }

                      if (value == 'delete') {
                        handleDelete(transaction);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 18),
                            SizedBox(width: 8),
                            Text('Hapus', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // =========================================================
  // DESKRIPSI FILTER
  // =========================================================

  String _getFilterDescription() {
    List<String> filter = [];

    if (_startDate != null && _endDate != null) {
      filter.add(
        '${_formatTanggal(_startDate!)} - ${_formatTanggal(_endDate!)}',
      );
    } else if (_startDate != null) {
      filter.add('Mulai ${_formatTanggal(_startDate!)}');
    } else if (_endDate != null) {
      filter.add('Sampai ${_formatTanggal(_endDate!)}');
    }

    if (_selectedJenis != 'Semua') {
      filter.add(_selectedJenis);
    }

    return filter.join(' • ');
  }
}
