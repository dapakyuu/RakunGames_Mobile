import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'pesan.dart';
import 'home.dart';
import 'store.dart';
import 'transaksi.dart';
import 'akun.dart';

class PaketPage extends StatefulWidget {
  final String game;
  final String username;
  final String email;

  const PaketPage(
      {super.key,
      required this.game,
      required this.username,
      required this.email});

  @override
  _PaketPageState createState() => _PaketPageState();
}

class _PaketPageState extends State<PaketPage> {
  List<dynamic> _paketList = [];
  bool _isLoading = true;
  int _currentIndex = 1; // Set index ke 1 untuk halaman Store

  @override
  void initState() {
    super.initState();
    _fetchPaket();
  }

  Future<void> _fetchPaket() async {
    final url = Uri.parse(
        "http://localhost/api_pab/select_paket.php"); // Ganti URL dengan server backend Anda
    final response = await http.post(url, body: {'game': widget.game});

    if (response.statusCode == 200) {
      setState(() {
        _paketList = json.decode(response.body);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog("Gagal memuat data paket.");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFDBB5),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF6C4E31)),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => StorePage(
                  username: widget.username,
                  email: widget.email,
                ),
              ),
            );
          },
        ),
        title: Text(
          'Paket Layanan Kami',
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
            image: AssetImage('assets/pattern.png'), // Background pattern
            fit: BoxFit.cover,
          ),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _paketList.isEmpty
                ? Center(
                    child: Text(
                      "Tidak ada paket untuk game ${widget.game}.",
                      style: TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF603F26),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _paketList.length,
                    itemBuilder: (context, index) {
                      final paket = _paketList[index];
                      return _buildPaketCard(paket);
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

  Widget _buildPaketCard(Map<String, dynamic> paket) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PesanPage(
              username: widget.username,
              email: widget.email,
              idPaket: paket['id_paket'].toString(),
            ),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: Color(0xFFFFF2E2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              child: AspectRatio(
                aspectRatio: 16 / 9, // Mengatur proporsi gambar menjadi 16:9
                child: Image.asset(
                  'assets/paket/${paket['gambar']}',
                  width: double.infinity,
                  fit: BoxFit
                      .cover, // Gambar akan memenuhi lebar dan tinggi container
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                paket['nama_paket'],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6C4E31),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                paket['deskripsi'],
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF603F26),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Rp. ${paket['harga']} / ${paket['satuan']}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6C4E31),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
