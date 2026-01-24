import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api.dart';

class EditPostPage extends StatefulWidget {
  final int postId;
  final String currentCaption;
  final String? imageUrl;

  const EditPostPage({
    super.key,
    required this.postId,
    required this.currentCaption,
    this.imageUrl,
  });

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  late TextEditingController _captionController;
  Uint8List? _newImageBytes;
  String? _newImageName;
  bool _saving = false;
  bool _imageChanged = false;

  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController(text: widget.currentCaption);
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
        _newImageBytes = bytes;
        _newImageName = picked.name;
        _imageChanged = true;
      });
    }
  }

  Future<void> _submit() async {
    final caption = _captionController.text.trim();

    if (caption.isEmpty) {
      _showSnackBar('Caption tidak boleh kosong', isError: true);
      return;
    }

    if (caption.length > 2000) {
      _showSnackBar('Caption maksimal 2000 karakter', isError: true);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    try {
      print('DEBUG: Updating post ${widget.postId}');

      Map<String, dynamic> res;
      if (_imageChanged && _newImageBytes != null && _newImageName != null) {
        print('DEBUG: Updating post with new image');
        res = await Api.updatePostMultipart(
          widget.postId,
          {'text': caption},
          imageBytes: _newImageBytes,
          filename: _newImageName,
        );
      } else {
        print('DEBUG: Updating post with caption only');
        res = await Api.updatePost(widget.postId, {'text': caption});
      }

      if (!mounted) return;

      print('DEBUG: Update post response: ${res['statusCode']}');

      if (res['statusCode'] == 200 || res['statusCode'] == 201) {
        setState(() => _saving = false);
        _showSnackBar('Post berhasil diperbarui!', isError: false);

        if (!mounted) return;
        Navigator.pop(context, true);
      } else {
        setState(() => _saving = false);
        final message = res['body']?['message'] ?? 'Gagal memperbarui post';
        _showSnackBar(message, isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      print('DEBUG: Update post error: $e');
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
          'Edit Post',
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
                    'Simpan',
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
          border: Border.all(color: const Color(0xFF43A047), width: 2),
        ),
        child: _newImageBytes != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.memory(
                      _newImageBytes!,
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
                ],
              )
            : widget.imageUrl != null
            ? Stack(
                children: [
                  Image.network(
                    widget.imageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
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
                ],
              )
            : Column(
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
                    'Tap untuk mengganti foto',
                    style: TextStyle(
                      color: Color(0xFF757575),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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
                'Edit caption...',
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
        ],
      ),
    );
  }
}
