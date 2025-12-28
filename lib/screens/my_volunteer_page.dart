import 'package:flutter/material.dart';

class MyVolunteerPage extends StatelessWidget {
  const MyVolunteerPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample volunteer activities
    final volunteerActivities = [
      {
        'campaign': 'Bantu Korban Bencana Alam',
        'role': 'Logistik',
        'status': 'Aktif',
        'date': '15 Des 2024 - Sekarang',
        'hours': 24,
      },
      {
        'campaign': 'Renovasi Sekolah Daerah Terpencil',
        'role': 'Pendidikan',
        'status': 'Selesai',
        'date': '1 Des 2024 - 10 Des 2024',
        'hours': 40,
      },
      {
        'campaign': 'Bantuan Makanan untuk Anak Yatim',
        'role': 'Penggalangan Dana',
        'status': 'Menunggu',
        'date': 'Belum dimulai',
        'hours': 0,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kegiatan Relawan Saya'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Stats Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[600]!, Colors.blue[800]!],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: const [
                    Text(
                      'Total Jam',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '64 Jam',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.white30,
                ),
                Column(
                  children: const [
                    Text(
                      'Kampanye',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
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
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.white30,
                ),
                Column(
                  children: const [
                    Text(
                      'Status',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Aktif',
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

          // Activities List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: volunteerActivities.length,
              itemBuilder: (context, index) {
                final activity = volunteerActivities[index];
                Color statusColor;
                IconData statusIcon;
                
                switch (activity['status']) {
                  case 'Aktif':
                    statusColor = Colors.green;
                    statusIcon = Icons.check_circle;
                    break;
                  case 'Selesai':
                    statusColor = Colors.blue;
                    statusIcon = Icons.verified;
                    break;
                  default:
                    statusColor = Colors.orange;
                    statusIcon = Icons.pending;
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                activity['campaign'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    statusIcon,
                                    size: 14,
                                    color: statusColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    activity['status'] as String,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.work_outline, 
                                size: 16, 
                                color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Text(
                              'Peran: ${activity['role']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, 
                                size: 16, 
                                color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Text(
                              activity['date'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.access_time, 
                                size: 16, 
                                color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Text(
                              '${activity['hours']} jam kontribusi',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        if (activity['status'] == 'Selesai') ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Sertifikat akan dikirim ke email Anda'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.download),
                              label: const Text('Download Sertifikat'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blue[700],
                              ),
                            ),
                          ),
                        ],
                      ],
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
        backgroundColor: Colors.blue[700],
        icon: const Icon(Icons.add),
        label: const Text('Gabung Kampanye'),
      ),
    );
  }
}