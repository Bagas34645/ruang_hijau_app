import 'package:flutter/material.dart';

class AllDonationsPage extends StatelessWidget {
  const AllDonationsPage({super.key});

  String formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    // Sample donation history
    final List<Map<String, dynamic>> donations = [
      {
        'donor': 'Andi Wijaya',
        'amount': 500000,
        'campaign': 'Bantu Korban Bencana Alam',
        'date': '23 Des 2024',
        'isAnonymous': false,
      },
      {
        'donor': 'Anonim',
        'amount': 250000,
        'campaign': 'Renovasi Sekolah Daerah Terpencil',
        'date': '22 Des 2024',
        'isAnonymous': true,
      },
      {
        'donor': 'Budi Santoso',
        'amount': 1000000,
        'campaign': 'Bantuan Makanan untuk Anak Yatim',
        'date': '21 Des 2024',
        'isAnonymous': false,
      },
      {
        'donor': 'Siti Nurhaliza',
        'amount': 300000,
        'campaign': 'Bantu Korban Bencana Alam',
        'date': '20 Des 2024',
        'isAnonymous': false,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Donasi'),
        backgroundColor: const Color(0xFF43A047),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Stats Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text(
                      'Total Donasi',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatCurrency(2050000),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(height: 40, width: 1, color: Colors.white30),
                Column(
                  children: const [
                    Text(
                      'Kampanye Dibantu',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Donations List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: donations.length,
              itemBuilder: (context, index) {
                final donation = donations[index];
                final bool isAnonymous = donation['isAnonymous'] as bool;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: isAnonymous
                          ? Colors.grey[400]
                          : const Color(0xFF43A047),
                      child: Icon(
                        isAnonymous
                            ? Icons.person_off
                            : Icons.volunteer_activism,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      donation['donor'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          donation['campaign'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          donation['date'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    trailing: Text(
                      formatCurrency(donation['amount'] as int),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF43A047),
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/campaign');
        },
        backgroundColor: const Color(0xFF43A047),
        icon: const Icon(Icons.volunteer_activism),
        label: const Text('Donasi Lagi'),
      ),
    );
  }
}
