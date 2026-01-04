import 'package:flutter/material.dart';
import 'create_campaign_page.dart';

class CampaignPage extends StatefulWidget {
  const CampaignPage({super.key});

  @override
  State<CampaignPage> createState() => _CampaignPageState();
}

class _CampaignPageState extends State<CampaignPage> {
  List<Map<String, dynamic>> campaigns = [];

  @override
  void initState() {
    super.initState();
    _loadDummyCampaigns();
  }

  void _loadDummyCampaigns() {
    campaigns = [
      {
        'title': 'Reboisasi Hutan Mangrove',
        'description':
            'Mari bersama-sama menanam 10.000 pohon mangrove untuk menyelamatkan ekosistem pesisir',
        'target': 50000000,
        'collected': 35000000,
        'daysLeft': 15,
        'volunteers': 45,
        'category': 'Lingkungan',
        'location': 'Pantai Indah, Jakarta',
        'contact': '081234567890',
        'isNew': false,
      },
      {
        'title': 'Bantuan Korban Banjir',
        'description':
            'Pengumpulan dana untuk membantu korban banjir mendapatkan tempat tinggal sementara',
        'target': 30000000,
        'collected': 18000000,
        'daysLeft': 8,
        'volunteers': 78,
        'category': 'Bencana Alam',
        'location': 'Karawang, Jawa Barat',
        'contact': '082345678901',
        'isNew': false,
      },
      {
        'title': 'Beasiswa Anak Prasejahtera',
        'description':
            'Program beasiswa untuk 100 anak prasejahtera agar bisa melanjutkan pendidikan',
        'target': 100000000,
        'collected': 45000000,
        'daysLeft': 30,
        'volunteers': 23,
        'category': 'Pendidikan',
        'location': 'Bandung, Jawa Barat',
        'contact': '083456789012',
        'isNew': false,
      },
    ];
  }

  String formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  double getProgress(int collected, int target) {
    return collected / target;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Kampanye'),
        backgroundColor: const Color(0xFF43A047),
        foregroundColor: Colors.white,
        actions: [
          // Button to view all donations
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Riwayat Donasi',
            onPressed: () {
              Navigator.pushNamed(context, '/all-donations');
            },
          ),
          // Button to view volunteer activities
          IconButton(
            icon: const Icon(Icons.volunteer_activism),
            tooltip: 'Kegiatan Relawan',
            onPressed: () {
              Navigator.pushNamed(context, '/my-volunteer');
            },
          ),
        ],
      ),
      body: campaigns.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: campaigns.length,
              itemBuilder: (context, index) {
                return _buildCampaignCard(campaigns[index]);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateCampaignPage()),
          );

          if (result != null && result is Map<String, dynamic>) {
            setState(() {
              campaigns.insert(0, result);
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: const [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 12),
                    Text('Kampanye berhasil ditambahkan!'),
                  ],
                ),
                backgroundColor: const Color(0xFF43A047),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        backgroundColor: const Color(0xFF43A047),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Buat Kampanye',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F8E9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF43A047).withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.campaign_outlined,
                size: 64,
                color: Color(0xFF43A047),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Belum Ada Kampanye',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Mulai kampanye pertama Anda\ndan buat perubahan!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignCard(Map<String, dynamic> campaign) {
    final progress = getProgress(campaign['collected'], campaign['target']);
    final percentage = (progress * 100).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campaign Image
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: campaign['imageWidget'] != null
                    ? campaign['imageWidget']
                    : Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF66BB6A),
                              const Color(0xFF43A047),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.campaign,
                            size: 64,
                            color: Colors.white70,
                          ),
                        ),
                      ),
              ),
              // New Badge
              if (campaign['isNew'] == true)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'BARU',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              // Category Badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.category, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        campaign['category'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Campaign Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  campaign['title'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  campaign['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),

                // Progress Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rp ${formatCurrency(campaign['collected'])}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF43A047),
                          ),
                        ),
                        Text(
                          '$percentage%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF43A047),
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'dari Rp ${formatCurrency(campaign['target'])}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Stats Row
                Row(
                  children: [
                    _buildStat(
                      Icons.schedule,
                      '${campaign['daysLeft']} hari',
                      'Tersisa',
                    ),
                    const SizedBox(width: 16),
                    _buildStat(
                      Icons.people,
                      '${campaign['volunteers']}',
                      'Relawan',
                    ),
                    const Spacer(),
                    // Donate Button
                    ElevatedButton(
                      onPressed: () {
                        _showCampaignDetail(campaign);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF43A047),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Detail',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  void _showCampaignDetail(Map<String, dynamic> campaign) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle Bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      campaign['title'],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      campaign['description'],
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[800],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildDetailRow(
                      Icons.category,
                      'Kategori',
                      campaign['category'],
                    ),
                    _buildDetailRow(
                      Icons.location_on,
                      'Lokasi',
                      campaign['location'],
                    ),
                    _buildDetailRow(Icons.phone, 'Kontak', campaign['contact']),
                    const SizedBox(height: 32),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              // Navigate to Donation Page
                              Navigator.pushNamed(
                                context,
                                '/donation',
                                arguments: campaign,
                              );
                            },
                            icon: const Icon(Icons.volunteer_activism),
                            label: const Text('Donasi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF43A047),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              // Navigate to Volunteer Page
                              Navigator.pushNamed(
                                context,
                                '/volunteer',
                                arguments: campaign,
                              );
                            },
                            icon: const Icon(Icons.people),
                            label: const Text('Jadi Relawan'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF43A047)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
