import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
    if ((_imageBytes == null && _captionController.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tambahkan gambar atau caption')),
      );
      return;
    }
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // Try multipart first if image present
    Map<String, dynamic> res;
    if (_imageBytes != null && _imageName != null) {
      // reuse createEvent multipart logic by calling a new endpoint; implement createPost multipart in Api
      res = await Api.createPostMultipart(
        {'user_id': 1, 'content': _captionController.text},
        imageBytes: _imageBytes,
        filename: _imageName,
      );
    } else {
      res = await Api.createPost({
        'user_id': 1,
        'content': _captionController.text,
        'image': null,
      });
    }

    if (!mounted) return;
    setState(() => _saving = false);
    if (res['statusCode'] == 200) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Post berhasil ditambahkan')),
      );
      navigator.pop(true);
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(res['body']?['message'] ?? 'Gagal menambahkan post'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Post'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[200],
                child: _imageBytes == null
                    ? const Center(child: Icon(Icons.add_a_photo, size: 48))
                    : Image.memory(_imageBytes!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _captionController,
              decoration: const InputDecoration(hintText: 'Tulis caption...'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const CircularProgressIndicator()
                  : const Text('Posting'),
            ),
          ],
        ),
      ),
    );
  }
}
