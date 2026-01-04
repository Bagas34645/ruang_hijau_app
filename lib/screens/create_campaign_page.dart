import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';

class CreateCampaignPage extends StatefulWidget {
  const CreateCampaignPage({super.key});

  @override
  State<CreateCampaignPage> createState() => _CreateCampaignPageState();
}

class _CreateCampaignPageState extends State<CreateCampaignPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  File? _selectedImage;
  Uint8List? _webImage; // For web support
  String? selectedCategory;
  bool needVolunteers = true;

  final List<String> categories = [
    'Lingkungan',
    'Pendidikan',
    'Kesehatan',
    'Kemanusiaan',
    'Bencana Alam',
    'Sosial',
    'Infrastruktur',
    'Lainnya',
  ];

  final ImagePicker _picker = ImagePicker();

  // Helper method to check if image is selected
  bool get hasImage => _selectedImage != null || _webImage != null;

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image != null) {
        if (kIsWeb) {
          // For web platform
          final bytes = await image.readAsBytes();
          setState(() {
            _webImage = bytes;
          });
        } else {
          // For mobile/desktop platform
          setState(() {
            _selectedImage = File(image.path);
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Gambar berhasil dipilih!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Text('Error memilih gambar: $e'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  String formatCurrency(String value) {
    if (value.isEmpty) return '';
    final number = int.tryParse(value.replaceAll('.', '')) ?? 0;
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  void _submitCampaign() {
    if (_formKey.currentState!.validate()) {
      if (selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.warning_amber_rounded, color: Colors.white),
                SizedBox(width: 12),
                Text('Mohon pilih kategori kampanye'),
              ],
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return;
      }

      // FIXED: Check both _selectedImage and _webImage
      if (!hasImage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.image_not_supported, color: Colors.white),
                SizedBox(width: 12),
                Text('Mohon pilih gambar kampanye'),
              ],
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return;
      }

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green[600],
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Kampanye Dibuat!', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kampanye Anda berhasil dibuat dan akan segera ditinjau oleh tim kami.',
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.campaign,
                          color: Colors.green[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _titleController.text,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    _buildInfoRow(
                      Icons.category,
                      'Kategori',
                      selectedCategory!,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.attach_money,
                      'Target',
                      'Rp ${formatCurrency(_targetController.text)}',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Durasi',
                      '${_durationController.text} hari',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.location_on,
                      'Lokasi',
                      _locationController.text,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Anda akan menerima notifikasi setelah kampanye disetujui',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(true); // Return to campaign list
              },
              style: TextButton.styleFrom(
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
                'OK',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Buat Kampanye Baru'),
        backgroundColor: const Color(0xFF43A047),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
              Card(
                color: Colors.green[50],
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.green[200]!),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.green[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Buat kampanye untuk menggalang dana dan relawan untuk kegiatan sosial Anda.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.green[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Campaign Image
              const Text(
                'Gambar Kampanye *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: hasImage ? Colors.green : Colors.grey[300]!,
                      width: hasImage ? 2 : 1,
                    ),
                  ),
                  child: hasImage
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: kIsWeb
                                  ? Image.memory(
                                      _webImage!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    )
                                  : Image.file(
                                      _selectedImage!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap untuk pilih gambar',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Ukuran maksimal 5MB',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // Basic Information
              const Text(
                'Informasi Dasar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Judul Kampanye *',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.title),
                  helperText: 'Judul yang menarik dan deskriptif',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  if (value.length < 10) {
                    return 'Judul minimal 10 karakter';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Kategori *',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.category),
                ),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Deskripsi Kampanye *',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignLabelWithHint: true,
                  helperText: 'Jelaskan tujuan dan manfaat kampanye Anda',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  if (value.length < 20) {
                    return 'Deskripsi minimal 20 karakter';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Target & Duration
              const Text(
                'Target Dana & Durasi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _targetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Target Dana (Rp) *',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixText: 'Rp ',
                  prefixIcon: const Icon(Icons.attach_money),
                  helperText: 'Masukkan target dana yang dibutuhkan',
                ),
                onChanged: (value) {
                  final formatted = formatCurrency(value.replaceAll('.', ''));
                  if (formatted != value) {
                    _targetController.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(
                        offset: formatted.length,
                      ),
                    );
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Target dana tidak boleh kosong';
                  }
                  final number = int.tryParse(value.replaceAll('.', ''));
                  if (number == null || number < 100000) {
                    return 'Target dana minimal Rp 100.000';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Durasi Kampanye (hari) *',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.calendar_today),
                  helperText: 'Berapa hari kampanye akan berlangsung',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Durasi tidak boleh kosong';
                  }
                  final days = int.tryParse(value);
                  if (days == null || days < 7) {
                    return 'Durasi minimal 7 hari';
                  }
                  if (days > 365) {
                    return 'Durasi maksimal 365 hari';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Location & Contact
              const Text(
                'Lokasi & Kontak',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Lokasi Kegiatan *',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.location_on),
                  helperText: 'Dimana kegiatan ini akan berlangsung',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lokasi tidak boleh kosong';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Nomor Kontak *',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.phone),
                  helperText: 'Nomor yang bisa dihubungi',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor kontak tidak boleh kosong';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Volunteer Option
              const Text(
                'Kebutuhan Relawan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 8),

              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SwitchListTile(
                  title: const Text('Membutuhkan Relawan'),
                  subtitle: const Text(
                    'Aktifkan jika kampanye membutuhkan relawan',
                  ),
                  value: needVolunteers,
                  activeColor: const Color(0xFF43A047),
                  onChanged: (value) {
                    setState(() {
                      needVolunteers = value;
                    });
                  },
                ),
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitCampaign,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF43A047),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Buat Kampanye',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
    _titleController.dispose();
    _descriptionController.dispose();
    _targetController.dispose();
    _durationController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    super.dispose();
  }
}
