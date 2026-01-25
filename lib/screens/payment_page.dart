import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String selectedPaymentMethod = '';
  bool isProcessing = false;

  final List<Map<String, dynamic>> paymentMethods = [
    {
      'id': 'bank_transfer',
      'name': 'Transfer Bank',
      'icon': Icons.account_balance,
      'color': Colors.blue,
      'description': 'BCA, Mandiri, BNI',
      'options': [
        {
          'name': 'BCA',
          'account': '1310888075',
          'holder': 'RuangHijau Foundation',
          'icon': Icons.account_balance,
          'color': Colors.blue,
          'imagePath': 'assets/images/banks/bca.png',
        },
        {
          'name': 'Mandiri',
          'account': '0987654321',
          'holder': 'RuangHijau Foundation',
          'icon': Icons.account_balance,
          'color': Colors.orange,
          'imagePath': 'assets/images/banks/mandiri.png',
        },
        {
          'name': 'BNI',
          'account': '5432167890',
          'holder': 'RuangHijau Foundation',
          'icon': Icons.account_balance,
          'color': Colors.green,
          'imagePath': 'assets/images/banks/bni.png',
        },
      ],
    },
    {
      'id': 'e_wallet',
      'name': 'E-Wallet',
      'icon': Icons.account_balance_wallet,
      'color': Colors.orange,
      'description': 'GoPay, OVO, DANA, ShopeePay',
      'options': [
        {
          'name': 'GoPay',
          'number': '081228439520',
          'icon': Icons.account_balance_wallet,
          'color': Colors.green,
          'imagePath': 'assets/images/wallets/gopay.png',
        },
        {
          'name': 'OVO',
          'number': '081234567890',
          'icon': Icons.account_balance_wallet,
          'color': Colors.purple,
          'imagePath': 'assets/images/wallets/ovo.png',
        },
        {
          'name': 'DANA',
          'number': '081228439520',
          'icon': Icons.account_balance_wallet,
          'color': Colors.blue,
          'imagePath': 'assets/images/wallets/dana.png',
        },
        {
          'name': 'ShopeePay',
          'number': '085643288791',
          'icon': Icons.account_balance_wallet,
          'color': Colors.orange,
          'imagePath': 'assets/images/wallets/shopeepay.png',
        },
      ],
    },
    // ...existing code...
  ];

  // Format currency to Indonesian Rupiah
  String formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  // Process payment with delay simulation
  void _processPayment(Map<String, dynamic> donationData) {
    setState(() => isProcessing = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      setState(() => isProcessing = false);
      _showSuccessDialog(donationData);
    });
  }

  // Show success dialog after payment
  void _showSuccessDialog(Map<String, dynamic> donationData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green[600],
                size: 64,
              ),
            ),
            const SizedBox(height: 20),

            // Success title
            const Text(
              'Pembayaran Berhasil!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Thank you message
            const Text(
              'Terima kasih atas donasi Anda!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Payment details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    'Jumlah',
                    formatCurrency(donationData['amount']),
                    isAmount: true,
                  ),
                  const Divider(height: 16),
                  _buildDetailRow('Metode', donationData['paymentMethod']),
                  const Divider(height: 16),
                  _buildDetailRow('Kampanye', donationData['campaign']),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Email notification info
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
                  Expanded(
                    child: Text(
                      'Bukti pembayaran telah dikirim ke email Anda',
                      style: TextStyle(fontSize: 11, color: Colors.blue[900]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Close payment detail
                Navigator.of(context).pop(); // Back to home
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Selesai',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build detail row widget
  Widget _buildDetailRow(String label, String value, {bool isAmount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: isAmount ? 16 : 13,
              fontWeight: isAmount ? FontWeight.bold : FontWeight.w500,
              color: isAmount ? Colors.green : Colors.black87,
            ),
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Build payment method card
  Widget _buildPaymentMethodCard(Map<String, dynamic> method) {
    final isSelected = selectedPaymentMethod == method['id'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? const Color(0xFF43A047) : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          setState(() => selectedPaymentMethod = method['id']);
          _showPaymentDetail(
            method,
            args['amount'],
            args['campaign'],
            args['donorName'] ?? 'Anonim',
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Payment method icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (method['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(method['icon'], color: method['color'], size: 28),
              ),
              const SizedBox(width: 16),

              // Payment method info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      method['description'],
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              // Selection indicator
              Icon(
                isSelected ? Icons.check_circle : Icons.arrow_forward_ios,
                color: isSelected ? const Color(0xFF43A047) : Colors.grey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build payment header
  Widget _buildPaymentHeader(int amount, String campaignTitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Pembayaran',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            formatCurrency(amount),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Donasi untuk: $campaignTitle',
              style: const TextStyle(color: Colors.white, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final int amount = args['amount'];
    final String campaignTitle = args['campaign'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Metode Pembayaran'),
        backgroundColor: const Color(0xFF43A047),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Payment header
          _buildPaymentHeader(amount, campaignTitle),

          // Payment methods list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: paymentMethods.length,
              itemBuilder: (context, index) {
                return _buildPaymentMethodCard(paymentMethods[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Show payment detail modal
  void _showPaymentDetail(
    Map<String, dynamic> method,
    int amount,
    String campaign,
    String donorName,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Modal header
            _buildModalHeader(method),

            // Modal content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (method['id'] == 'bank_transfer')
                      _buildBankTransferOptions(method)
                    else if (method['id'] == 'e_wallet')
                      _buildEWalletOptions(method)
                    else if (method['id'] == 'qris')
                      _buildQRISDisplay(amount),

                    const SizedBox(height: 24),
                    _buildPaymentInstructions(),
                  ],
                ),
              ),
            ),

            // Confirm button
            _buildConfirmButton(method, amount, campaign, donorName),
          ],
        ),
      ),
    );
  }

  // Build modal header
  Widget _buildModalHeader(Map<String, dynamic> method) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: method['color'],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Icon(method['icon'], color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              method['name'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // Build bank transfer options
  Widget _buildBankTransferOptions(Map<String, dynamic> method) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Bank Tujuan:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...List.generate(method['options'].length, (index) {
          final bank = method['options'][index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: bank['imagePath'] != null
                    ? Image.asset(
                        bank['imagePath'],
                        width: 32,
                        height: 32,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            bank['icon'],
                            color: bank['color'],
                            size: 24,
                          );
                        },
                      )
                    : Icon(bank['icon'], color: bank['color'], size: 24),
              ),
              title: Text(
                bank['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('No. Rek: ${bank['account']}'),
                  Text(
                    'A/n: ${bank['holder']}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.copy, color: Color(0xFF43A047)),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: bank['account']));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nomor rekening disalin'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  // Build e-wallet options
  Widget _buildEWalletOptions(Map<String, dynamic> method) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih E-Wallet:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...List.generate(method['options'].length, (index) {
          final wallet = method['options'][index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: wallet['imagePath'] != null
                    ? Image.asset(
                        wallet['imagePath'],
                        width: 32,
                        height: 32,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            wallet['icon'],
                            color: wallet['color'],
                            size: 24,
                          );
                        },
                      )
                    : Icon(wallet['icon'], color: wallet['color'], size: 24),
              ),
              title: Text(
                wallet['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Nomor: ${wallet['number']}'),
              trailing: IconButton(
                icon: const Icon(Icons.copy, color: Color(0xFF43A047)),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: wallet['number']));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nomor disalin'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  // Build QRIS display
  Widget _buildQRISDisplay(int amount) {
    return Center(
      child: Column(
        children: [
          // QR Code container
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // QR Code icon (placeholder)
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          Icons.qr_code_2,
                          size: 180,
                          color: Colors.grey[400],
                        ),
                      ),
                      // Transaction ID
                      Positioned(
                        bottom: 8,
                        left: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'QR-$amount-${DateTime.now().millisecondsSinceEpoch}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 9,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Amount display
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Jumlah Pembayaran',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatCurrency(amount),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Scan instruction
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange[700], size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Scan dengan aplikasi e-wallet favorit Anda',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Supported wallets
          Text(
            'GoPay • OVO • DANA • ShopeePay • LinkAja',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // Build payment instructions
  Widget _buildPaymentInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              const Text(
                'Instruksi Pembayaran',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '1. Transfer sesuai nominal yang tertera\n'
            '2. Simpan bukti transfer\n'
            '3. Konfirmasi pembayaran otomatis\n'
            '4. Donasi diproses maksimal 1x24 jam',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[900],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // Build confirm button
  Widget _buildConfirmButton(
    Map<String, dynamic> method,
    int amount,
    String campaign,
    String donorName,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isProcessing
              ? null
              : () {
                  Navigator.pop(context);
                  _processPayment({
                    'amount': amount,
                    'campaign': campaign,
                    'donorName': donorName,
                    'paymentMethod': method['name'],
                  });
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF43A047),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: isProcessing
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Konfirmasi Pembayaran',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }
}
