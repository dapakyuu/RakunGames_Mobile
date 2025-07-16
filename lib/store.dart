import 'package:flutter/material.dart';
import 'paket.dart';
import 'home.dart';
import 'transaksi.dart';
import 'akun.dart';

class StorePage extends StatefulWidget {
  final String username;
  final String email;

  const StorePage({super.key, required this.username, required this.email});

  @override
  _StorePageState createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  int _currentIndex = 1; // Navbar index untuk Store

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFDBB5),
        title: Row(
          children: [
            Image.asset(
              'assets/rakungames.png',
              height: 40,
            ),
            SizedBox(width: 10),
            Text(
              'Game List',
              style: TextStyle(
                color: Color(0xFF6C4E31),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/pattern.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Text(
                'Game List',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF603F26),
                ),
              ),
              SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildGameCard(context, 'Arknights', 'assets/arknights.png'),
                  _buildGameCard(context, 'Valorant', 'assets/valorant.png'),
                  _buildGameCard(
                      context, 'Genshin Impact', 'assets/genshin.png'),
                  _buildGameCard(
                      context, 'Zenless Zone Zero', 'assets/zenless.png'),
                  _buildGameCard(
                      context, 'Honkai Star Rail', 'assets/starrail.png'),
                  _buildGameCard(
                      context, 'Honkai Impact', 'assets/honkaiimpact.png'),
                  _buildGameCard(
                      context, 'Mobile Legends', 'assets/mobilelegends.png'),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Navigasi antar halaman
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
              // Halaman Store, tidak perlu navigasi ulang
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
        },
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

  Widget _buildGameCard(BuildContext context, String name, String imagePath) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaketPage(
              username: widget.username,
              email: widget.email,
              game: name,
            ),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 80,
            ),
            SizedBox(height: 10),
            Text(
              name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF603F26),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
