import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../database/database_helper.dart';
import '../models/transaction.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'login_page.dart';
import 'transaction_form_page.dart';
import 'transaction_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Color primaryColor = Color(0xFF1565C0);
  static const Color backgroundColor = Color(0xFFF5F7FA);

  final AuthService _authService = AuthService();

  // ================= DATA USER =================
  Map<String, String> profileMhs = {
    'nama': 'Pengguna',
    'username': '-',
    'email': '-',
  };

  // ================= DATA TRANSAKSI =================
  List<Transaction> _recentTransactions = [];

  bool _isLoadingTransactions = true;

  @override
  void initState() {
    super.initState();

    _loadUserProfile();
    _loadRecentTransactions();
  }

  // ================= LOAD USER =================
  Future<void> _loadUserProfile() async {
    final UserModel? user = await _authService.getUser();

    if (!mounted) return;

    if (user != null) {
      setState(() {
        profileMhs = {
          'nama': user.name,
          'username': user.username,
          'email': user.email,
        };
      });
    }
  }

  // ================= LOAD 5 TRANSAKSI TERBARU =================
  Future<void> _loadRecentTransactions() async {
    try {
      final List<Transaction> transactions = await DatabaseHelper.instance
          .getRecentTransactions(limit: 5);

      if (!mounted) return;

      setState(() {
        _recentTransactions = transactions;
        _isLoadingTransactions = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingTransactions = false;
      });

      debugPrint('Gagal mengambil transaksi terbaru: $e');
    }
  }

  // ================= BUKA DAFTAR TRANSAKSI =================
  Future<void> tampilkanDaftarTransaksi() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TransactionListPage()),
    );

    if (!mounted) return;

    // Memuat ulang transaksi setelah kembali ke HomePage.
    await _loadRecentTransactions();
  }

  // ================= TAMBAH TRANSAKSI =================
  Future<void> tambahTransaksi() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TransactionFormPage()),
    );

    if (!mounted) return;

    // Memuat ulang 5 transaksi terbaru setelah tambah data.
    await _loadRecentTransactions();
  }

  // ================= LOGOUT =================
  Future<void> _logout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Keluar'),
          content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Keluar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await _authService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String nama = profileMhs['nama'] ?? 'Pengguna';

    final String username = profileMhs['username'] ?? '-';

    final String email = profileMhs['email'] ?? '-';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: primaryColor,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: backgroundColor,

        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =================================================
            // HEADER
            // =================================================
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 15, 14, 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul dan tombol logout
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Doni Pay',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          IconButton(
                            onPressed: _logout,
                            tooltip: 'Keluar',
                            icon: const Icon(
                              Icons.logout_rounded,
                              color: Colors.white,
                              size: 23,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // ================= PROFIL =================
                      Row(
                        children: [
                          Container(
                            width: 66,
                            height: 66,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 37,
                            ),
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Nama
                                Text(
                                  nama,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                // Username
                                Text(
                                  'Username: $username',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.72),
                                    fontSize: 13,
                                  ),
                                ),

                                const SizedBox(height: 3),

                                // Email
                                Text(
                                  'Email: $email',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.72),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // =================================================
            // KONTEN
            // =================================================
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadRecentTransactions,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ================= AKSES CEPAT =================
                      const Text(
                        'Akses Cepat',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A237E),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ================= LIHAT TRANSAKSI =================
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(17),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: tampilkanDaftarTransaksi,
                            borderRadius: BorderRadius.circular(17),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 45,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      color: primaryColor.withValues(
                                        alpha: 0.12,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.receipt_long_outlined,
                                      color: primaryColor,
                                      size: 24,
                                    ),
                                  ),

                                  const SizedBox(width: 14),

                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Lihat Transaksi',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF263238),
                                          ),
                                        ),
                                        SizedBox(height: 3),
                                        Text(
                                          'History Transaksi',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: Colors.grey.shade400,
                                    size: 26,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // =================================================
                      // 5 TRANSAKSI TERAKHIR
                      // =================================================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Transaksi Terakhir',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A237E),
                            ),
                          ),

                          TextButton(
                            onPressed: tampilkanDaftarTransaksi,
                            child: const Text(
                              'Lihat Semua',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // ================= LOADING =================
                      if (_isLoadingTransactions)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      // ================= DATA KOSONG =================
                      else if (_recentTransactions.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(17),
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 45,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Belum ada transaksi',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      // ================= LIST TRANSAKSI =================
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _recentTransactions.length,
                          itemBuilder: (context, index) {
                            final Transaction transaction =
                                _recentTransactions[index];

                            return _buildTransactionCard(transaction);
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        // =================================================
        // TOMBOL TAMBAH
        // =================================================
        floatingActionButton: FloatingActionButton(
          onPressed: tambahTransaksi,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(Icons.add, size: 29),
        ),
      ),
    );
  }

  // =================================================
  // CARD TRANSAKSI
  // =================================================
  Widget _buildTransactionCard(Transaction transaction) {
    final bool isPemasukan = transaction.jenis.toLowerCase() == 'pemasukan';

    final NumberFormat currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final DateFormat dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon jenis transaksi
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: isPemasukan
                  ? Colors.green.withValues(alpha: 0.12)
                  : Colors.red.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPemasukan
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: isPemasukan ? Colors.green : Colors.red,
              size: 22,
            ),
          ),

          const SizedBox(width: 13),

          // Keterangan dan tanggal
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.keterangan?.trim().isNotEmpty == true
                      ? transaction.keterangan!
                      : transaction.jenis,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF263238),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  dateFormat.format(transaction.tanggal),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Nominal
          Text(
            '${isPemasukan ? '+' : '-'}${currencyFormat.format(transaction.nominal)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isPemasukan ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
