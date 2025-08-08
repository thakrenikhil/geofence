import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../models/office.dart';
import '../../../services/admin/office_service.dart';

class AdminOfficesScreen extends StatelessWidget {
  const AdminOfficesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = OfficeService(FirebaseFirestore.instance);
    return Scaffold(
      appBar: AppBar(title: const Text('Offices')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final id = await service.createOffice(Office(id: 'new', name: 'New Office', latitude: 0, longitude: 0, radiusMeters: 100));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Created office: $id')));
          }
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Office>>(
        stream: service.offices(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final items = snapshot.data!;
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final o = items[index];
              return ListTile(
                title: Text(o.name),
                subtitle: Text('(${o.latitude}, ${o.longitude}) • ${o.radiusMeters}m'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => service.deleteOffice(o.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


