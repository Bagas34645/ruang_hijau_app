import 'package:flutter/material.dart';
// ...existing imports...
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/beranda_page.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/campaign_page.dart';
import 'screens/donation_page.dart';
import 'screens/volunteer_page.dart';
import 'screens/create_campaign_page.dart';
import 'screens/all_donations_page.dart';
import 'screens/my_volunteer_page.dart';
import 'screens/payment_page.dart';
import 'screens/feedback_page.dart';
import 'screens/profile_page.dart';
import 'screens/waste_detection_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RuangHijau',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (c) => const LoginPage(),
        '/register': (c) => const RegisterPage(),
        '/home': (c) => const BerandaPage(),
        '/campaign': (c) => const CampaignPage(),
        '/donation': (c) => const DonationPage(),
        '/volunteer': (c) => const VolunteerPage(),
        '/create-campaign': (c) => const CreateCampaignPage(),
        '/all-donations': (c) => const AllDonationsPage(),
        '/my-volunteer': (c) => const MyVolunteerPage(),
        '/payment': (c) => const PaymentPage(),
        '/feedback': (c) => const FeedbackPage(),
        '/profile': (c) => const ProfilePage(),
        '/waste-detection': (c) => const WasteDetectionPage(),
      },
    );
  }
}

// SplashCheck removed: splash screen now handles initial navigation.

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AuthHome extends StatelessWidget {
  const AuthHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RuangHijau - Auth')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: const Text('Login'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
