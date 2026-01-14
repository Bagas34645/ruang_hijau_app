import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({Key? key}) : super(key: key);

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  // Initialize chat with welcome message
  void _initializeChat() {
    Future.delayed(const Duration(milliseconds: 500), () {
      _addMessage(
        ChatMessage(
          text:
              'Halo! Saya EcoBot asisten RuangHijau. Ada yang bisa saya bantu tentang lingkungan dan kelestarian alam?',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  // Add message to list
  void _addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
    _scrollToBottom();
  }

  // Send message
  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    _addMessage(
      ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
    );

    _messageController.clear();
    setState(() => _isTyping = true);

    // Call your chatbot API here
    try {
      final botResponse = await _callChatbotAPI(text);

      setState(() => _isTyping = false);

      _addMessage(
        ChatMessage(
          text: botResponse,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      setState(() => _isTyping = false);

      _addMessage(
        ChatMessage(
          text: 'Maaf, terjadi kesalahan. Silakan coba lagi nanti.',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  // ============================================
  // CHATBOT RAG API INTEGRATION
  // ============================================
  Future<String> _callChatbotAPI(String userMessage) async {
    final url = Uri.parse('${AppConfig.baseUrl}/api/chatbot/chat');
    try {
      print('🚀 [Chatbot] Sending request to: $url');

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'message': userMessage,
              'user_id': 'flutter_user',
            }),
          )
          .timeout(
            const Duration(
              seconds: 300,
            ), // Meningkatkan timeout ke 5 menit untuk LLM lokal
            onTimeout: () {
              throw Exception(
                'Request timeout - server memproses terlalu lama',
              );
            },
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['response'] ?? 'Tidak ada respons dari server.';
        } else {
          return data['error'] ?? 'Terjadi kesalahan pada server.';
        }
      } else if (response.statusCode == 503) {
        // Service unavailable - likely Ollama or dependencies issue
        final data = json.decode(response.body);
        final message =
            data['message'] ?? 'Layanan chatbot sedang tidak tersedia';
        return 'Layanan chatbot sedang loading atau error:\n\n$message\n\nMohon:\n1. Tunggu sebentar dan coba lagi\n2. Jika masih error, cek:\n   - Ollama service running (ollama serve)\n   - Flask backend running (python app.py)\n   - Semua dependencies terinstall';
      } else if (response.statusCode == 500) {
        // Server error - check logs
        final data = json.decode(response.body);
        final message = data['message'] ?? 'Internal server error';
        return '❌ Server error (500):\n\n$message\n\nCek Flask terminal untuk detail error.';
      } else if (response.statusCode == 502) {
        // Bad gateway - backend crashed
        return '❌ HTTP 502 - Bad Gateway\n\nBackend service tidak merespons. Kemungkinan penyebab:\n\n1. Flask backend crashed\n   → Restart: python app.py\n\n2. Ollama service tidak running\n   → Start: ollama serve\n\n3. Model embedding sedang download\n   → Tunggu 5-10 menit\n\n4. Dependencies missing\n   → Run: pip install -r requirements.txt\n\nCek terminal untuk error details.';
      } else {
        return 'Server error (${response.statusCode}).\n\nCek konfigurasi:\n- BaseURL di app_config.dart\n- Backend running di http://localhost:5000\n- Firewall tidak memblok port 5000';
      }
    } catch (e) {
      print('Chatbot API Error: $e');
      if (e.toString().contains('timeout')) {
        return 'Waktu habis (300 detik). Proses AI memakan waktu lama.\n\nKemungkinan penyebab:\n- Model embedding terlalu besar\n- PC spec kurang\n- Ollama sedang loading model\n\nSolusi:\n1. Tunggu dan coba lagi\n2. Atau gunakan model lebih kecil (edit OLLAMA_MODEL di .env)\n3. Cek folder ~/.ollama untuk model cache';
      } else if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('XMLHttpRequest')) {
        return 'Gagal terhubung ke server.\n\nPastikan:\n1. ✅ Server Flask berjalan:\n   - Terminal: cd Ruang-Hijau-Backend && python app.py\n\n2. ✅ Konfigurasi URL benar di app_config.dart:\n   - Android Emulator: http://10.0.2.2:5000\n   - HP Fisik: gunakan IP lokal PC (bukan localhost)\n\n3. ✅ Firewall izinkan port 5000\n\n4. ✅ Backend URL: ${AppConfig.baseUrl}/api/chatbot/chat';
      } else if (e.toString().contains('FormatException')) {
        return 'Respons dari server tidak valid (bukan JSON).\n\nMungkin server error atau port salah. Cek:\n- BaseURL di app_config.dart\n- Flask running di port 5000\n- Error di Flask terminal';
      }
      return 'Error koneksi: ${e.toString()}\n\nSolusi:\n1. Cek Flask terminal untuk error\n2. Jalankan: python test_chatbot_components.py\n3. Verifikasi BaseURL di app_config.dart';
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF43A047),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Color(0xFF43A047),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EcoBot Assistant',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Online • Siap membantu',
                    style: TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showOptionsMenu();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageBubble(_messages[index]);
                    },
                  ),
          ),

          // Typing Indicator
          if (_isTyping) _buildTypingIndicator(),

          // Input Area
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.green[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: Colors.green[300],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Mulai Percakapan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tanyakan apa saja tentang RuangHijau',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser ? const Color(0xFF43A047) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(message.isUser ? 20 : 4),
            bottomRight: Radius.circular(message.isUser ? 4 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isUser ? Colors.white : Colors.black87,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                color: message.isUser ? Colors.white70 : Colors.grey[500],
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 100)),
      builder: (context, double value, child) {
        return Opacity(
          opacity: 0.3 + (value * 0.7),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              shape: BoxShape.circle,
            ),
          ),
        );
      },
      onEnd: () {
        if (mounted && _isTyping) setState(() {});
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.add_circle_outline, color: Colors.grey[600]),
              onPressed: () {
                _showAttachmentOptions();
              },
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Ketik pesan...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (text) => _sendMessage(text),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
                ),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white),
                onPressed: () => _sendMessage(_messageController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Hapus Riwayat Chat'),
              onTap: () {
                Navigator.pop(context);
                _clearChat();
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.blue),
              title: const Text('Tentang EcoBot'),
              onTap: () {
                Navigator.pop(context);
                _showAboutDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Lampirkan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  Icons.image,
                  'Gambar',
                  Colors.purple,
                  () {
                    Navigator.pop(context);
                    // TODO: Implement image upload
                  },
                ),
                _buildAttachmentOption(
                  Icons.insert_drive_file,
                  'File',
                  Colors.blue,
                  () {
                    Navigator.pop(context);
                    // TODO: Implement file upload
                  },
                ),
                _buildAttachmentOption(
                  Icons.location_on,
                  'Lokasi',
                  Colors.red,
                  () {
                    Navigator.pop(context);
                    // TODO: Implement location sharing
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Riwayat Chat'),
        content: const Text('Yakin ingin menghapus semua riwayat percakapan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _messages.clear();
              });
              _initializeChat();
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tentang EcoBot'),
        content: const Text(
          'EcoBot adalah asisten virtual RuangHijau yang siap membantu Anda dengan informasi tentang kampanye, donasi, dan menjadi relawan.\n\n'
          'Powered by AI Technology.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// Message Model
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
