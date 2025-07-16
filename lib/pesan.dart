import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'home.dart';
import 'store.dart';
import 'transaksi.dart';
import 'akun.dart';

class PesanPage extends StatefulWidget {
  final String username;
  final String email;
  final String idPaket;

  const PesanPage({
    super.key,
    required this.username,
    required this.email,
    required this.idPaket,
  });

  @override
  _PesanPageState createState() => _PesanPageState();
}

class _PesanPageState extends State<PesanPage> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic>? _paketDetail;
  List<dynamic> _agenList = [];
  bool _isLoading = true;
  int _jumlahPesanan = 1;
  int? _selectedAgen;
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _fetchPaketDetail().then((_) {
      if (_paketDetail != null && _paketDetail!.containsKey('game')) {
        _fetchAgenList();
      }
    });
  }

  Future<void> _fetchPaketDetail() async {
    final url = Uri.parse("http://localhost/api_pab/get_paket_detail.php");
    final response = await http.post(url, body: {'id_paket': widget.idPaket});

    if (response.statusCode == 200) {
      setState(() {
        _paketDetail = json.decode(response.body);
        _isLoading = false;
      });
    } else {
      _showErrorDialog("Gagal memuat detail paket.");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchAgenList() async {
    if (_paketDetail == null || !_paketDetail!.containsKey('game')) {
      _showErrorDialog(
          "Detail paket tidak ditemukan atau game tidak tersedia.");
      return;
    }

    final url = Uri.parse("http://localhost/api_pab/select_agen.php");
    final response = await http.post(
      url,
      body: {'game': _paketDetail!['game']},
    );

    if (response.statusCode == 200) {
      setState(() {
        _agenList = json.decode(response.body);
      });
    } else {
      _showErrorDialog("Gagal memuat daftar agen.");
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

  Future<void> _submitOrder() async {
    debugPrint("Submit order triggered.");
    final url = Uri.parse("http://localhost/api_pab/submit_pesanan.php");

    final response = await http.post(url, body: {
      'username': widget.username,
      'email': widget.email,
      'id_paket': widget.idPaket,
      'id_agent': _selectedAgen.toString(),
      'jumlah_pesanan': _jumlahPesanan.toString(),
      'total_biaya': (_jumlahPesanan * _paketDetail!['harga']).toString(),
    });

    debugPrint("Sending data: ${{
      'username': widget.username,
      'email': widget.email,
      'id_paket': widget.idPaket,
      'id_agent': _selectedAgen,
      'jumlah_pesanan': _jumlahPesanan.toString(),
      'total_biaya': (_jumlahPesanan * _paketDetail!['harga']).toString(),
    }}");

    debugPrint("Response status: ${response.statusCode}");
    debugPrint("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'success') {
        debugPrint("Order successful: ${result['message']}");
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Berhasil"),
            content: Text("Pesanan berhasil dibuat!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransaksiPage(
                        username: widget.username,
                        email: widget.email,
                      ),
                    ),
                  );
                },
                child: Text("OK"),
              ),
            ],
          ),
        );
      } else {
        debugPrint("Order failed: ${result['message']}");
        _showErrorDialog(result['message']);
      }
    } else {
      debugPrint("Error: Server responded with status ${response.statusCode}");
      _showErrorDialog("Gagal membuat pesanan.");
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
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Detail Pemesanan',
          style: TextStyle(
            color: Color(0xFF6C4E31),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/pattern.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C4E31)),
                ),
              )
            : Center(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildDetailSection(),
                          Divider(color: Color(0xFF603F26)),
                          _buildUserForm(),
                          SizedBox(height: 20),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  if (_selectedAgen == null) {
                                    _showErrorDialog(
                                        "Pilih agen terlebih dahulu.");
                                    return;
                                  }
                                  _submitOrder();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF6C4E31),
                                foregroundColor: Colors.white,
                              ),
                              child: Text("Pesan Sekarang"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildDetailSection() {
    return _paketDetail == null
        ? Text("Detail paket tidak tersedia.")
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Game: ${_paketDetail!['game']}",
                  style: TextStyle(fontSize: 16, color: Color(0xFF6C4E31))),
              Text("Paket: ${_paketDetail!['nama_paket']}",
                  style: TextStyle(fontSize: 16, color: Color(0xFF6C4E31))),
              Text("Deskripsi: ${_paketDetail!['deskripsi']}",
                  style: TextStyle(fontSize: 16, color: Color(0xFF603F26))),
              Text("Harga: Rp ${_paketDetail!['harga']}",
                  style: TextStyle(fontSize: 16, color: Color(0xFF6C4E31))),
            ],
          );
  }

  Widget _buildUserForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Username: ${widget.username}",
            style: TextStyle(fontSize: 16, color: Color(0xFF6C4E31))),
        Text("Email: ${widget.email}",
            style: TextStyle(fontSize: 16, color: Color(0xFF6C4E31))),
        SizedBox(height: 10),
        TextFormField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "Jumlah Pesanan",
            border: OutlineInputBorder(),
          ),
          initialValue: '$_jumlahPesanan',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Jumlah pesanan wajib diisi.";
            }
            if (int.tryParse(value) == null || int.parse(value) <= 0) {
              return "Jumlah pesanan harus lebih dari 0.";
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              _jumlahPesanan = int.tryParse(value) ?? 1;
            });
          },
        ),
        SizedBox(height: 10),
        DropdownButtonFormField<int>(
          decoration: InputDecoration(
            labelText: "Pilih Agen",
            border: OutlineInputBorder(),
          ),
          value: _selectedAgen,
          items: _agenList.map((agen) {
            return DropdownMenuItem<int>(
              value: agen['id_agent'] as int, // Pastikan ini bertipe int
              child: Text(agen['nama']),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedAgen = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return "Pilih agen terlebih dahulu.";
            }
            return null;
          },
        ),
        SizedBox(height: 10),
        Text(
          "Total Biaya: Rp ${_paketDetail != null ? _jumlahPesanan * _paketDetail!['harga'] : 0}",
          style: TextStyle(fontSize: 16, color: Color(0xFF6C4E31)),
        ),
      ],
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => _navigateToPage(index),
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
    );
  }
}
