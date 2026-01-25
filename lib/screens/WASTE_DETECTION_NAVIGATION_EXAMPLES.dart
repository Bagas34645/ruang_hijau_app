// Contoh navigasi ke Waste Detection Page dari halaman lain
// Copy-paste kode ini ke halaman yang ingin menambahkan tombol waste detection

import 'package:flutter/material.dart';

// CONTOH 1: Button di halaman home/dashboard
class WasteDetectionNavigationExample extends StatelessWidget {
  const WasteDetectionNavigationExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.pushNamed(context, '/waste-detection');
      },
      icon: const Icon(Icons.delete_outlined),
      label: const Text('Deteksi Sampah'),
    );
  }
}

// CONTOH 2: FloatingActionButton
class WasteDetectionFAB extends StatelessWidget {
  const WasteDetectionFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.pushNamed(context, '/waste-detection');
      },
      icon: const Icon(Icons.camera_alt),
      label: const Text('Deteksi Sampah'),
      backgroundColor: Colors.green[700],
    );
  }
}

// CONTOH 3: Card di grid atau list
class WasteDetectionCard extends StatelessWidget {
  const WasteDetectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/waste-detection');
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [Colors.green[400]!, Colors.green[700]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delete_outlined, size: 48, color: Colors.white),
              const SizedBox(height: 12),
              const Text(
                'Deteksi Sampah',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Identifikasi jenis sampah',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// CONTOH 4: Bottom Sheet untuk quick access
void showWasteDetectionQuickAccess(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Apa yang ingin Anda lakukan?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Ambil Foto dengan Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/waste-detection');
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/waste-detection');
                },
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('Lihat Panduan Pemilahan'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/waste-detection');
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

// CONTOH 5: Complete integration dalam Home Page
class HomePageWithWasteDetection extends StatelessWidget {
  const HomePageWithWasteDetection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ruang Hijau'), elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section dengan waste detection
            Container(
              color: Colors.green[700],
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selamat datang!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Mari mulai memilah sampah dengan benar',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/waste-detection');
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Mulai Deteksi Sampah'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.green[700],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Rest of home page content...
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fitur Utama',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _buildFeatureCard(
                        context,
                        'Deteksi Sampah',
                        Icons.delete_outlined,
                        Colors.green,
                        () => Navigator.pushNamed(context, '/waste-detection'),
                      ),
                      _buildFeatureCard(
                        context,
                        'Kampanye',
                        Icons.campaign,
                        Colors.blue,
                        () => Navigator.pushNamed(context, '/campaign'),
                      ),
                      _buildFeatureCard(
                        context,
                        'Donasi',
                        Icons.favorite,
                        Colors.red,
                        () => Navigator.pushNamed(context, '/donation'),
                      ),
                      _buildFeatureCard(
                        context,
                        'Volunteer',
                        Icons.people,
                        Colors.orange,
                        () => Navigator.pushNamed(context, '/volunteer'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.6), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
