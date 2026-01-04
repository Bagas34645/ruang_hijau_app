import 'package:flutter/material.dart';

class DonationPage extends StatefulWidget {
  const DonationPage({super.key});

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  int? selectedAmount;
  bool isAnonymous = false;

  final List<int> quickAmounts = [10000, 25000, 50000, 100000, 250000, 500000];

  String formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  void selectAmount(int amount) {
    setState(() {
      selectedAmount = amount;
      _amountController.text = amount.toString();
    });
  }

  void processDonation(Map<String, dynamic> campaign) {
    if (selectedAmount == null || selectedAmount! <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon masukkan jumlah donasi')),
      );
      return;
    }

    // Tidak perlu validasi nama jika anonim
    // if (!isAnonymous && _nameController.text.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Mohon masukkan nama Anda')),
    //   );
    //   return;
    // }

    // Navigate to payment page
    Navigator.pushNamed(
      context,
      '/payment',
      arguments: {
        'amount': selectedAmount!,
        'campaign': campaign['title'],
        'donorName': isAnonymous
            ? 'Anonim'
            : _nameController.text.isEmpty
            ? 'Anonim'
            : _nameController.text,
        'email': _emailController.text,
        'message': _messageController.text,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final campaign =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Donasi')),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
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
                    Text(
                      campaign['title'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      campaign['description'],
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Quick Amount Selection
            const Text(
              'Pilih Nominal Donasi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: quickAmounts.length,
              itemBuilder: (context, index) {
                final amount = quickAmounts[index];
                final isSelected = selectedAmount == amount;

                return OutlinedButton(
                  onPressed: () => selectAmount(amount),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: isSelected ? Colors.green : Colors.white,
                    foregroundColor: isSelected ? Colors.white : Colors.green,
                    side: BorderSide(
                      color: isSelected ? Colors.green : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    formatCurrency(amount),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Custom Amount
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nominal Lainnya',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
                helperText: 'Masukkan nominal donasi Anda',
              ),
              onChanged: (value) {
                setState(() {
                  selectedAmount = int.tryParse(value.replaceAll('.', ''));
                });
              },
            ),

            const SizedBox(height: 24),

            // Anonymous Checkbox
            CheckboxListTile(
              title: const Text('Donasi sebagai Anonim'),
              value: isAnonymous,
              onChanged: (value) {
                setState(() {
                  isAnonymous = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 16),

            // Donor Information
            if (!isAnonymous) ...[
              const Text(
                'Informasi Donatur',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                  helperText: 'Untuk konfirmasi donasi',
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Message
            TextField(
              controller: _messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Pesan (Opsional)',
                border: OutlineInputBorder(),
                hintText: 'Tulis pesan dukungan Anda...',
              ),
            ),

            const SizedBox(height: 24),

            // Donate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => processDonation(campaign),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  selectedAmount != null
                      ? 'Donasi ${formatCurrency(selectedAmount!)}'
                      : 'Donasi Sekarang',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Info Card
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Donasi Anda akan langsung disalurkan untuk membantu kampanye ini.',
                        style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
