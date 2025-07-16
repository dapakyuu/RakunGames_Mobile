import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UlasanPage extends StatefulWidget {
  final int idPesanan;
  final String namaAgen;
  int? idUlasan;

  UlasanPage({
    super.key,
    required this.idPesanan,
    required this.namaAgen,
    this.idUlasan,
  });

  @override
  _UlasanPageState createState() => _UlasanPageState();
}

class _UlasanPageState extends State<UlasanPage> {
  int _selectedRating = 0;
  final TextEditingController _ulasanController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUlasanDariPesanan();
  }

  Future<void> _fetchUlasanDariPesanan() async {
    final url = Uri.parse("http://localhost/api_pab/check_ulasan.php");
    final response = await http.post(url, body: {
      'id_pesanan': widget.idPesanan.toString(),
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['exists']) {
        setState(() {
          widget.idUlasan = data['data']['id_ulasan'];
          _selectedRating = data['data']['rating'];
          _ulasanController.text = data['data']['ulasan'];
        });
      }
    } else {
      _showErrorDialog("Gagal memuat ulasan.");
    }
  }

  Future<void> _saveUlasan() async {
    if (_selectedRating == 0 || _ulasanController.text.isEmpty) {
      _showErrorDialog("Harap isi rating dan ulasan.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = widget.idUlasan == null
        ? Uri.parse("http://localhost/api_pab/insert_ulasan.php")
        : Uri.parse("http://localhost/api_pab/update_ulasan.php");

    try {
      final response = await http.post(url, body: {
        'id_ulasan': widget.idUlasan?.toString() ?? "null",
        'id_pesanan': widget.idPesanan.toString(),
        'rating': _selectedRating.toString(),
        'ulasan': _ulasanController.text,
      });

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          _showSuccessDialog("Ulasan berhasil disimpan.");
        } else {
          _showErrorDialog(data['message'] ?? "Gagal menyimpan ulasan.");
        }
      } else {
        _showErrorDialog("Terjadi kesalahan server.");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog(e.toString());
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

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Berhasil"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              Navigator.pop(context); // Kembali ke halaman sebelumnya
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFDBB5),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF6C4E31)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.idUlasan == null ? 'Beri Ulasan' : 'Ubah Ulasan',
          style: TextStyle(
            color: Color(0xFF6C4E31),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Berikan Ulasanmu Kepada',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6C4E31),
                ),
              ),
              SizedBox(height: 8),
              Text(
                widget.namaAgen,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6C4E31),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          Icons.star,
                          color: index < _selectedRating
                              ? Colors.orange
                              : Colors.grey,
                          size: 36,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedRating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  SizedBox(width: 16),
                  Text(
                    '$_selectedRating',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6C4E31),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextField(
                controller: _ulasanController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Tulis ulasanmu di sini...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFF6C4E31)),
                  ),
                ),
              ),
              SizedBox(height: 24),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _saveUlasan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6C4E31),
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Simpan",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
