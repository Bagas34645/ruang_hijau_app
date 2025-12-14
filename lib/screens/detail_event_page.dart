import 'package:flutter/material.dart';
import '../services/api.dart';

class DetailEventPage extends StatefulWidget {
  final Map<String, dynamic> event;
  const DetailEventPage({super.key, required this.event});

  @override
  State<DetailEventPage> createState() => _DetailEventPageState();
}

class _DetailEventPageState extends State<DetailEventPage> {
  late TextEditingController _title;
  late TextEditingController _desc;
  late TextEditingController _date;
  late TextEditingController _location;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.event['title']);
    _desc = TextEditingController(text: widget.event['description']);
    _date = TextEditingController(text: widget.event['date']);
    _location = TextEditingController(text: widget.event['location']);
  }

  Future<void> _update() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final res = await Api.updateEvent(widget.event['id'], {
      'title': _title.text,
      'description': _desc.text,
      'date': _date.text,
      'location': _location.text,
    });
    if (!mounted) return;
    if (res['statusCode'] == 200) {
      navigator.pop(true);
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(res['body']?['message'] ?? 'Gagal update')),
      );
    }
  }

  Future<void> _delete() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final res = await Api.deleteEvent(widget.event['id']);
    if (!mounted) return;
    if (res['statusCode'] == 200) {
      navigator.pop(true);
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(res['body']?['message'] ?? 'Gagal hapus')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Event'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Event image (if available)
            if (widget.event['image'] != null &&
                widget.event['image'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: Builder(
                    builder: (context) {
                      final img = widget.event['image'].toString();
                      final url = img.startsWith('http')
                          ? img
                          : '${Api.baseUrl}/uploads/$img';
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(url, fit: BoxFit.cover),
                      );
                    },
                  ),
                ),
              ),
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _desc,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _date,
              decoration: const InputDecoration(labelText: 'Date'),
            ),
            TextField(
              controller: _location,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _update,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Simpan'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _delete,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Hapus'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
