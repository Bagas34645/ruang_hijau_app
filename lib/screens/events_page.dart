import 'package:flutter/material.dart';
import '../services/api.dart';
import 'add_event_page.dart';
import 'detail_event_page.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  List<Map<String, dynamic>> events = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _loading = true);
    try {
      final res = await Api.fetchEvents();
      if (!mounted) return;
      print('DEBUG EventsPage: API response statusCode=${res['statusCode']}');
      if (res['statusCode'] == 200 && res['body'] != null) {
        final data = res['body'] as List<dynamic>;
        events = data.map((e) {
          return {
            'id': e['id'],
            'title': e['title'] ?? 'No title',
            'description': e['description'] ?? '',
            'date': e['date'] ?? '',
            'location': e['location'] ?? '',
            'image': e['image'],
          };
        }).toList();
        print('DEBUG EventsPage: Loaded ${events.length} events');
      } else {
        print(
          'DEBUG EventsPage: API call failed. Status=${res['statusCode']}, Error=${res['error'] ?? 'Unknown'}',
        );
        events = [];
      }
    } catch (e) {
      print('DEBUG EventsPage: Exception in _loadEvents: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading events: $e'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
      events = [];
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (events.isEmpty) {
      return Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green,
          onPressed: () async {
            final res = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddEventPage()),
            );
            if (res == true) _loadEvents();
          },
          child: const Icon(Icons.add),
        ),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Belum ada event.'),
        ),
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEventPage()),
          );
          if (res == true) _loadEvents();
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final ev = events[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: ev['image'] != null
                  ? SizedBox(
                      width: 64,
                      height: 64,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          ev['image'].toString().startsWith('http')
                              ? ev['image']
                              : '${Api.baseUrl}/uploads/${ev['image']}',
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) =>
                              const Icon(Icons.broken_image),
                        ),
                      ),
                    )
                  : const SizedBox(
                      width: 64,
                      height: 64,
                      child: Icon(Icons.image),
                    ),
              title: Text(ev['title']),
              subtitle: Text('${ev['date']} • ${ev['location']}'),
              onTap: () async {
                final res = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DetailEventPage(event: ev)),
                );
                if (res == true) _loadEvents();
              },
            ),
          );
        },
      ),
    );
  }
}
