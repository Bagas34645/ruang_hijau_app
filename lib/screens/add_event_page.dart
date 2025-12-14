import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import '../services/api.dart';

class AddEventPage extends StatefulWidget {
  const AddEventPage({super.key});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _searchController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool isPublic = true;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _saving = false;

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (pickedDate != null) setState(() => _selectedDate = pickedDate);
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (pickedTime != null) setState(() => _selectedTime = pickedTime);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageName = picked.name;
      });
    }
  }

  Future<void> _simpanAcara() async {
    if (_judulController.text.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null ||
        _deskripsiController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi semua data terlebih dahulu!')),
      );
      return;
    }

    setState(() => _saving = true);

    // capture messenger and navigator before async gap
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // Simple combined datetime string
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    final timeStr = _selectedTime!.format(context);
    final datetime = '$dateStr $timeStr';

    final res = await Api.createEvent(
      {
        'title': _judulController.text,
        'description': _deskripsiController.text,
        'date': datetime,
        'location': isPublic ? 'Public' : 'Private',
      },
      imageBytes: _selectedImageBytes,
      filename: _selectedImageName,
    );

    if (!mounted) return;
    setState(() => _saving = false);

    if (res['statusCode'] == 200) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Acara berhasil disimpan!')),
      );
      navigator.pop(true);
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(res['body']?['message'] ?? 'Gagal menyimpan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFEDE7F6),
        title: const Text(
          'Tambah Acara Baru',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Judul Acara'),
            TextField(
              controller: _judulController,
              decoration: const InputDecoration(hintText: 'Judul Acara'),
            ),
            const SizedBox(height: 15),

            const Text('Jadwal Acara'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text(
                      _selectedDate == null
                          ? 'Pilih Tanggal'
                          : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.access_time_outlined),
                    label: Text(
                      _selectedTime == null
                          ? 'Pilih Waktu'
                          : _selectedTime!.format(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text('Jenis Acara'),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Public'),
                    value: true,
                    groupValue: isPublic,
                    onChanged: (val) => setState(() => isPublic = val!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Private'),
                    value: false,
                    groupValue: isPublic,
                    onChanged: (val) => setState(() => isPublic = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            const Text('Undang Akun'),
            const SizedBox(height: 5),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari nama pengguna...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text('Deskripsi Acara'),
            TextField(
              controller: _deskripsiController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Tuliskan deskripsi acara...',
              ),
            ),
            const SizedBox(height: 20),

            const Text('Upload Gambar'),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 90,
                width: 90,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: _selectedImageBytes == null
                    ? const Icon(Icons.image, size: 40, color: Colors.grey)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          _selectedImageBytes!,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 30),

            Center(
              child: ElevatedButton(
                onPressed: _saving ? null : _simpanAcara,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Simpan',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
