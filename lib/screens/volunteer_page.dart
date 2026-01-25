import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api.dart';

class VolunteerPage extends StatefulWidget {
  const VolunteerPage({super.key});

  @override
  State<VolunteerPage> createState() => _VolunteerPageState();
}

class _VolunteerPageState extends State<VolunteerPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _motivationController = TextEditingController();

  String? selectedSkill;
  String? selectedAvailability;
  bool _isSubmitting = false;

  final List<String> skills = [
    'Penggalangan Dana',
    'Komunikasi & Media Sosial',
    'Administrasi',
    'Logistik',
    'Kesehatan',
    'Pendidikan',
    'Teknologi',
    'Lainnya',
  ];

  final List<String> availabilities = [
    'Penuh Waktu',
    'Paruh Waktu',
    'Akhir Pekan',
    'Fleksibel',
  ];

  void submitVolunteerForm(Map<String, dynamic> campaign) async {
    if (_formKey.currentState!.validate()) {
      if (selectedSkill == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mohon pilih keahlian Anda')),
        );
        return;
      }

      if (selectedAvailability == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mohon pilih ketersediaan waktu Anda')),
        );
        return;
      }

      setState(() => _isSubmitting = true);

      try {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getInt('user_id');

        print('DEBUG registerVolunteer: userId=$userId');
        print('DEBUG registerVolunteer: campaign=$campaign');

        if (userId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Silakan login terlebih dahulu')),
          );
          setState(() => _isSubmitting = false);
          return;
        }

        // Prepare data for API
        final data = {
          'user_id': userId,
          'campaign_id': campaign['id'] ?? 1,
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
          'skill': selectedSkill,
          'availability': selectedAvailability,
          'experience': _experienceController.text,
          'motivation': _motivationController.text,
        };

        print('DEBUG registerVolunteer: data=$data');

        // Call API
        final res = await Api.registerVolunteer(data);

        print(
          'DEBUG registerVolunteer: response statusCode=${res['statusCode']}',
        );
        print('DEBUG registerVolunteer: response body=${res['body']}');

        if (!mounted) return;

        if (res['statusCode'] == 200 || res['statusCode'] == 201) {
          // Show success dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 28),
                  SizedBox(width: 12),
                  Text('Pendaftaran Berhasil!'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Terima kasih telah mendaftar sebagai relawan!'),
                  const SizedBox(height: 16),
                  Text('Kampanye: ${campaign['title']}'),
                  Text('Nama: ${_nameController.text}'),
                  Text('Keahlian: $selectedSkill'),
                  Text('Ketersediaan: $selectedAvailability'),
                  const SizedBox(height: 16),
                  const Text(
                    'Tim kami akan segera menghubungi Anda melalui email atau telepon.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          final errorMessage =
              res['body']?['message'] ??
              'Gagal mendaftar sebagai relawan. Silakan coba lagi.';
          print('DEBUG registerVolunteer: error=$errorMessage');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $errorMessage'),
              backgroundColor: Colors.red[400],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } catch (e) {
        print('DEBUG registerVolunteer: exception=$e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final campaign =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Relawan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campaign Info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.campaign, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              campaign['title'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bergabunglah dengan ${campaign['volunteers']} relawan lainnya untuk membantu kampanye ini!',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Personal Information
              const Text(
                'Informasi Pribadi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  if (!value.contains('@')) {
                    return 'Email tidak valid';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Nomor Telepon *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor telepon tidak boleh kosong';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Alamat *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Alamat tidak boleh kosong';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Skills and Availability
              const Text(
                'Keahlian & Ketersediaan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: selectedSkill,
                decoration: const InputDecoration(
                  labelText: 'Keahlian *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work),
                ),
                items: skills.map((skill) {
                  return DropdownMenuItem(value: skill, child: Text(skill));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSkill = value;
                  });
                },
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: selectedAvailability,
                decoration: const InputDecoration(
                  labelText: 'Ketersediaan Waktu *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.access_time),
                ),
                items: availabilities.map((availability) {
                  return DropdownMenuItem(
                    value: availability,
                    child: Text(availability),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedAvailability = value;
                  });
                },
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _experienceController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Pengalaman Relawan (Opsional)',
                  border: OutlineInputBorder(),
                  hintText: 'Ceritakan pengalaman Anda sebagai relawan...',
                ),
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _motivationController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Motivasi *',
                  border: OutlineInputBorder(),
                  hintText:
                      'Mengapa Anda ingin menjadi relawan untuk kampanye ini?',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Motivasi tidak boleh kosong';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Info Card
              Card(
                color: Colors.orange[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange[700]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Sebagai relawan, Anda akan:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 36),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '• Membantu dalam kegiatan kampanye',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[900],
                              ),
                            ),
                            Text(
                              '• Mendapat sertifikat relawan',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[900],
                              ),
                            ),
                            Text(
                              '• Berkontribusi untuk kebaikan bersama',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[900],
                              ),
                            ),
                            Text(
                              '• Bertemu dengan relawan lainnya',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[900],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () => submitVolunteerForm(campaign),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    disabledBackgroundColor: Colors.grey[400],
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Daftar Sebagai Relawan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _experienceController.dispose();
    _motivationController.dispose();
    super.dispose();
  }
}
