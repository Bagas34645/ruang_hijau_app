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
  bool _isEditing = false;
  bool _updating = false;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.event['title']);
    _desc = TextEditingController(text: widget.event['description']);
    _date = TextEditingController(text: widget.event['date']);
    _location = TextEditingController(text: widget.event['location']);
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _date.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _update() async {
    setState(() => _updating = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    
    final res = await Api.updateEvent(widget.event['id'], {
      'title': _title.text,
      'description': _desc.text,
      'date': _date.text,
      'location': _location.text,
    });

    if (!mounted) return;
    setState(() => _updating = false);

    if (res['statusCode'] == 200) {
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Event berhasil diperbarui!'),
          backgroundColor: const Color(0xFF43A047),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      setState(() => _isEditing = false);
      navigator.pop(true);
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(res['body']?['message'] ?? 'Gagal update'),
          backgroundColor: const Color(0xFFD32F2F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Event'),
        content: const Text('Apakah Anda yakin ingin menghapus event ini?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF757575))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Color(0xFFD32F2F))),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _deleting = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final res = await Api.deleteEvent(widget.event['id']);

    if (!mounted) return;
    setState(() => _deleting = false);

    if (res['statusCode'] == 200) {
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Event berhasil dihapus!'),
          backgroundColor: const Color(0xFF43A047),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      navigator.pop(true);
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(res['body']?['message'] ?? 'Gagal hapus'),
          backgroundColor: const Color(0xFFD32F2F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2E7D32)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Event',
          style: TextStyle(
            color: Color(0xFF2E7D32),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Color(0xFF43A047)),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(),
            const SizedBox(height: 16),
            _buildInfoSection(),
          ],
        ),
      ),
      bottomNavigationBar: _isEditing ? _buildActionButtons() : null,
    );
  }

  Widget _buildImageSection() {
    if (widget.event['image'] == null ||
        widget.event['image'].toString().isEmpty) {
      return Container(
        height: 250,
        width: double.infinity,
        color: const Color(0xFFE8F5E9),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event, size: 64, color: Color(0xFF43A047)),
            SizedBox(height: 8),
            Text(
              'Event Image',
              style: TextStyle(color: Color(0xFF43A047), fontSize: 16),
            ),
          ],
        ),
      );
    }

    final img = widget.event['image'].toString();
    final url = img.startsWith('http') ? img : '${Api.baseUrl}/uploads/$img';

    return Stack(
      children: [
        SizedBox(
          height: 300,
          width: double.infinity,
          child: Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) => Container(
              color: const Color(0xFFE8F5E9),
              child: const Center(
                child: Icon(Icons.broken_image, size: 64, color: Color(0xFF9E9E9E)),
              ),
            ),
            loadingBuilder: (context, child, progress) {
              return progress == null
                  ? child
                  : Container(
                      color: const Color(0xFFF5F5F5),
                      child: const Center(
                        child: CircularProgressIndicator(color: Color(0xFF43A047)),
                      ),
                    );
            },
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  const Color(0xFF000000).withOpacity(0.6),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoField(
            label: 'Judul Event',
            controller: _title,
            icon: Icons.event,
            enabled: _isEditing,
          ),
          const SizedBox(height: 20),
          _buildInfoField(
            label: 'Tanggal & Waktu',
            controller: _date,
            icon: Icons.calendar_today_outlined,
            enabled: _isEditing,
          ),
          const SizedBox(height: 20),
          _buildInfoField(
            label: 'Lokasi',
            controller: _location,
            icon: Icons.location_on_outlined,
            enabled: _isEditing,
          ),
          const SizedBox(height: 20),
          _buildInfoField(
            label: 'Deskripsi',
            controller: _desc,
            icon: Icons.description_outlined,
            enabled: _isEditing,
            maxLines: 5,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF43A047)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF757575),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: 16,
            color: enabled ? const Color(0xFF2E7D32) : const Color(0xFF424242),
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? Colors.white : const Color(0xFFFAFAFA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: enabled ? const Color(0xFF43A047) : const Color(0xFFE0E0E0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF43A047), width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFF5F5F5)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _deleting ? null : _delete,
                icon: _deleting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD32F2F)),
                        ),
                      )
                    : const Icon(Icons.delete_outline, size: 20),
                label: const Text('Hapus'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFD32F2F),
                  side: const BorderSide(color: Color(0xFFD32F2F)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _updating ? null : _update,
                icon: _updating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.check, size: 20),
                label: const Text('Simpan Perubahan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF43A047),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFE0E0E0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}