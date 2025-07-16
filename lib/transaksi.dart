import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'home.dart';
import 'store.dart';
import 'akun.dart';
import 'ulasan.dart';

class TransaksiPage extends StatefulWidget {
  final String username;
  final String email;

  const TransaksiPage({super.key, required this.username, required this.email});

  @override
  _TransaksiPageState createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  List<dynamic> _transaksiList = [];
  bool _isLoading = true;
  int _currentIndex = 2; // Index untuk halaman Transaksi

  @override
  void initState() {
    super.initState();
    _fetchTransaksiList();
  }

  Future<void> _fetchTransaksiList() async {
    final url = Uri.parse("http://localhost/api_pab/get_transaksi.php");
    try {
      final response = await http.post(url, body: {
        'username': widget.username,
        'email': widget.email,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          setState(() {
            _transaksiList = data;
            _isLoading = false;
          });
        } else if (data['status'] == 'empty') {
          setState(() {
            _transaksiList = [];
            _isLoading = false;
          });
          _showErrorDialog("Tidak ada transaksi ditemukan.");
        } else {
          throw Exception(data['message'] ?? "Kesalahan tidak diketahui.");
        }
      } else {
        throw Exception(
            "Gagal memuat data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      _showErrorDialog("Terjadi kesalahan: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _hapusPesanan(int idPesanan) async {
    final url = Uri.parse("http://localhost/api_pab/delete_pesanan.php");
    final response = await http.post(url, body: {
      'id_pesanan': idPesanan.toString(),
    });

    if (response.statusCode == 200) {
      _fetchTransaksiList();
    } else {
      _showErrorDialog("Gagal menghapus pesanan.");
    }
  }

  Future<bool> _cekUlasan(int idPesanan) async {
    final url = Uri.parse("http://localhost/api_pab/check_ulasan.php");
    final response = await http.post(url, body: {
      'id_pesanan': idPesanan.toString(),
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Pastikan atribut 'exists' tersedia dalam JSON
      if (data['status'] == 'success') {
        return data['exists'] ?? false;
      }
    }
    return false;
  }

  // Ubah fungsi pembayaran agar menerima dua parameter
  Future<void> _bayarPesanan(dynamic idPesanan, dynamic totalBiaya) async {
    try {
      final url = Uri.parse("http://localhost/api_pab/get_midtrans_token.php");
      final response = await http.post(
        url,
        body: json.encode({
          'id_pesanan': idPesanan.toString(),
          'total_biaya': totalBiaya.toString(),
          'username': widget.username,
          'email': widget.email,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'];
        if (token == null) throw Exception("Token tidak ditemukan");

        final snapUrl = Uri.parse(
            "https://app.sandbox.midtrans.com/snap/v2/vtweb/" + token);

        // Buka tab baru di browser
        if (await canLaunchUrl(snapUrl)) {
          await launchUrl(snapUrl, mode: LaunchMode.externalApplication);
        } else {
          _showErrorDialog("Tidak dapat membuka pembayaran Midtrans.");
        }
      } else {
        throw Exception("Gagal mendapatkan token Midtrans");
      }
    } catch (e) {
      _showErrorDialog("Gagal memproses pembayaran: $e");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _navigateToPage(int index) {
    setState(() {
      _currentIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              username: widget.username,
              email: widget.email,
            ),
          ),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => StorePage(
              username: widget.username,
              email: widget.email,
            ),
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TransaksiPage(
              username: widget.username,
              email: widget.email,
            ),
          ),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AkunPage(
              username: widget.username,
              email: widget.email,
            ),
          ),
        );
        break;
    }
  }

  void _redirectToInstagram() async {
    final url = Uri.parse("https://www.instagram.com/rakun_games.id/");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _showErrorDialog("Tidak dapat membuka Instagram.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFDBB5),
        title: Text(
          'Riwayat Transaksi',
          style: TextStyle(
            color: Color(0xFF6C4E31),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/pattern.png'), // Tambahkan background pattern
            fit: BoxFit.cover,
          ),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _transaksiList.isEmpty
                ? Center(
                    child: Text(
                      "Tidak ada transaksi yang tersedia.",
                      style: TextStyle(fontSize: 16, color: Color(0xFF6C4E31)),
                    ),
                  )
                : ListView.builder(
                    itemCount: _transaksiList.length,
                    itemBuilder: (context, index) {
                      final transaksi = _transaksiList[index];
                      return Card(
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                _getStatusColor(transaksi['status_pengerjaan']),
                            child: Icon(
                              _getStatusIcon(transaksi['status_pengerjaan']),
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            transaksi['nama_paket'] +
                                " (" +
                                transaksi['status_pengerjaan'] +
                                ")",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Game: ${transaksi['game']}",
                                  style: TextStyle(
                                      fontSize: 14, color: Color(0xFF6C4E31))),
                              Text("Agen: ${transaksi['nama_agen']}",
                                  style: TextStyle(
                                      fontSize: 14, color: Color(0xFF603F26))),
                              Text("Jumlah: ${transaksi['jumlah_pesanan']}",
                                  style: TextStyle(
                                      fontSize: 14, color: Color(0xFF6C4E31))),
                              Text("Tanggal: ${transaksi['tanggal_dibuat']}",
                                  style: TextStyle(
                                      fontSize: 14, color: Color(0xFF6C4E31))),
                              Text("Total: Rp ${transaksi['total_biaya']}",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF6C4E31),
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'Ulasan') {
                                bool hasUlasan =
                                    await _cekUlasan(transaksi['id_pesanan']);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UlasanPage(
                                      idPesanan: transaksi['id_pesanan'],
                                      namaAgen: transaksi['nama_agen'],
                                      idUlasan: hasUlasan
                                          ? transaksi['id_ulasan']
                                          : null,
                                    ),
                                  ),
                                );
                              } else {
                                _handleMenuSelection(value, transaksi);
                              }
                            },
                            itemBuilder: (context) =>
                                _buildPopupMenuItems(transaksi),
                          ),
                        ),
                      );
                    },
                  ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _navigateToPage,
        selectedItemColor: Color(0xFF6C4E31),
        unselectedItemColor: Color(0xFF603F26),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Store',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Akun',
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Menunggu Pembayaran':
        return Colors.orange;
      case 'On-Progress':
        return Colors.blue;
      case 'Dibatalkan':
        return Colors.red;
      case 'Selesai':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Menunggu Pembayaran':
        return Icons.hourglass_empty;
      case 'On-Progress':
        return Icons.work;
      case 'Dibatalkan':
        return Icons.cancel;
      case 'Selesai':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  List<PopupMenuEntry<String>> _buildPopupMenuItems(
      Map<String, dynamic> transaksi) {
    String status = transaksi['status_pengerjaan'];
    if (status == 'Menunggu Pembayaran') {
      return [
        PopupMenuItem(
          value: 'Bayar',
          child: Row(
            children: [
              Icon(Icons.payment, color: Colors.green),
              SizedBox(width: 8),
              Text('Bayar Sekarang'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'Hapus',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 8),
              Text('Hapus Pesanan'),
            ],
          ),
        ),
      ];
    } else if (status == 'On-Progress') {
      return [
        PopupMenuItem(
          value: 'Hubungi',
          child: Row(
            children: [
              Icon(Icons.message, color: Colors.blue),
              SizedBox(width: 8),
              Text('Hubungi Agen'),
            ],
          ),
        ),
      ];
    } else if (status == 'Selesai') {
      return [
        PopupMenuItem(
          value: 'Ulasan',
          child: Row(
            children: [
              Icon(Icons.rate_review, color: Colors.orange),
              SizedBox(width: 8),
              Text('Beri Ulasan'),
            ],
          ),
        ),
      ];
    }
    return [];
  }

  void _handleMenuSelection(String value, Map<String, dynamic> transaksi) {
    switch (value) {
      case 'Bayar':
        _bayarPesanan(transaksi['id_pesanan'], transaksi['total_biaya']);
        break;
      case 'Hubungi':
        _redirectToInstagram();
        break;
      case 'Hapus':
        _hapusPesanan(transaksi['id_pesanan']);
        break;
    }
  }
}
