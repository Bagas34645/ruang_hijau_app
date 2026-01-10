import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final _captionController = TextEditingController();
  Uint8List? _imageBytes;
  String? _imageName;
  bool _saving = false;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    setState(() => _userId = userId);
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageName = picked.name;
      });
    }
  }

  Future<void> _submit() async {
    // Validate inputs
    if (_userId == null) {
      _showSnackBar(
        'User tidak ditemukan. Silakan login kembali.',
        isError: true,
      );
      return;
    }

    final caption = _captionController.text.trim();

    // Check that either caption or image exists
    if (caption.isEmpty && _imageBytes == null) {
      _showSnackBar(
        'Tambahkan gambar atau caption untuk membuat post',
        isError: true,
      );
      return;
    }

    // Validate caption length if provided
    if (caption.isNotEmpty && caption.length > 2000) {
      _showSnackBar('Caption maksimal 2000 karakter', isError: true);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    try {
      print('DEBUG: Creating post with user_id: $_userId');

      Map<String, dynamic> res;
      if (_imageBytes != null && _imageName != null) {
        print('DEBUG: Uploading post with image');
        print('DEBUG: Image name: $_imageName');
        print('DEBUG: Image size: ${_imageBytes?.length} bytes');
        res = await Api.createPostMultipart(
          {
            'user_id': _userId.toString(),
            'text': caption.isEmpty ? '[Post tanpa caption]' : caption,
          },
          imageBytes: _imageBytes,
          filename: _imageName,
        );
      } else {
        print('DEBUG: Creating post with caption only');
        res = await Api.createPost({
          'user_id': _userId.toString(),
          'text': caption.isEmpty ? '[Post tanpa gambar]' : caption,
        });
      }

      if (!mounted) return;

      print('DEBUG: Create post response statusCode: ${res['statusCode']}');
      print('DEBUG: Create post response body: ${res['body']}');

      final body = res['body'];
      final message = body?['message'] ?? 'Terjadi kesalahan saat membuat post';

      // Status 201 = Created
      if (res['statusCode'] == 201) {
        setState(() => _saving = false);
        _showSnackBar('Post berhasil dibuat!', isError: false);

        // Clear form
        _captionController.clear();
        _imageBytes = null;
        _imageName = null;

        // Navigate back with success indicator
        if (!mounted) return;
        Navigator.pop(context, true);
      }
      // Status 400 = Bad request (validation error)
      else if (res['statusCode'] == 400) {
        setState(() => _saving = false);
        _showSnackBar(message, isError: true);
      }
      // Status 401 = Unauthorized
      else if (res['statusCode'] == 401) {
        setState(() => _saving = false);
        _showSnackBar(
          'Anda belum login. Silakan login terlebih dahulu.',
          isError: true,
        );
      }
      // Status 500 = Server error
      else if (res['statusCode'] == 500) {
        setState(() => _saving = false);
        _showSnackBar(message, isError: true);
      }
      // Other status codes
      else {
        setState(() => _saving = false);
        _showSnackBar(
          'Error: $message (Status ${res['statusCode']})',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      print('DEBUG: Create post error: $e');
      _showSnackBar('Terjadi kesalahan: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, maxLines: 3, overflow: TextOverflow.ellipsis),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF2E7D32)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Buat Post Baru',
          style: TextStyle(
            color: Color(0xFF2E7D32),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _submit,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF43A047),
                      ),
                    ),
                  )
                : const Text(
                    'Posting',
                    style: TextStyle(
                      color: Color(0xFF43A047),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildImageSection(), _buildCaptionSection()],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 400,
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _imageBytes != null
                ? const Color(0xFF43A047)
                : const Color(0xFFE0E0E0),
            width: 2,
          ),
        ),
        child: _imageBytes == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 64,
                      color: Color(0xFF43A047),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tap untuk menambahkan foto',
                    style: TextStyle(
                      color: Color(0xFF757575),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Upload gambar dari galeri',
                    style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                  ),
                ],
              )
            : Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.memory(
                      _imageBytes!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF43A047),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF000000).withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 22,
                        ),
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xE6000000),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 22,
                        ),
                        onPressed: () {
                          setState(() {
                            _imageBytes = null;
                            _imageName = null;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCaptionSection() {
    final captionLength = _captionController.text.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.eco, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              const Text(
                'Tulis caption...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _captionController,
            maxLines: 5,
            maxLength: 2000,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 15, height: 1.5),
            decoration: const InputDecoration(
              hintText: 'Ceritakan sesuatu tentang foto ini...',
              hintStyle: TextStyle(color: Color(0xFF9E9E9E)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              counterText: '',
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              '$captionLength/2000',
              style: TextStyle(
                color: captionLength > 1800
                    ? Colors.orange
                    : captionLength > 1900
                    ? Colors.red
                    : Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildActionChip(Icons.tag, 'Tag Teman'),
              const SizedBox(width: 8),
              _buildActionChip(Icons.location_on_outlined, 'Lokasi'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(IconData icon, String label) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 18, color: const Color(0xFF43A047)),
      label: Text(
        label,
        style: const TextStyle(fontSize: 13, color: Color(0xFF43A047)),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFF43A047)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
