class Transaction {
  final int? id; // Tipe data integer (untuk SQLite AUTOINCREMENT)
  final DateTime tanggal; // Tipe data tanggal/waktu (DateTime)
  final double nominal; // Tipe data angka desimal (double) untuk jumlah uang
  final String? keterangan; // Tipe data teks untuk catatan
  final String jenis; // Tipe data teks: "Pemasukan" atau "Pengeluaran"
  // Digunakan untuk membuat/menginstansiasi Object dari class
  Transaction({
    this.id,
    required this.tanggal,
    required this.nominal,
    this.keterangan,
    required this.jenis,
  });
  // Mengubah Map (dari SQLite) menjadi objek Transaction
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      tanggal: DateTime.parse(map['tanggal'] as String),
      nominal: (map['nominal'] as num).toDouble(),
      keterangan: map['keterangan'] as String?,
      jenis: map['jenis'] as String,
    );
  }
  // Mengubah objek Transaction menjadi Map (untuk disimpan ke SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tanggal': tanggal.toIso8601String(),
      'nominal': nominal,
      'keterangan': keterangan,
      'jenis': jenis,
    };
  }
}

class DummyData {
  // Menyimpan data di static field agar persisten sementara
  static final List<Transaction> list = [
    Transaction(
      id: 1,
      tanggal: DateTime.now().subtract(const Duration(days: 2)),
      nominal: 2500000.0,
      keterangan: 'Uang Saku Bulanan',
      jenis: 'Pemasukan',
    ),
    Transaction(
      id: 2,
      tanggal: DateTime.now().subtract(const Duration(days: 1)),
      nominal: 150000.0,
      keterangan: 'Beli Buku Pemrograman',
      jenis: 'Pengeluaran',
    ),
  ];
}
