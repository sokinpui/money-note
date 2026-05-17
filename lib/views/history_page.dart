import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/record_provider.dart';
import 'package:intl/intl.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(recordProvider);

    return Scaffold(
      body: recordsAsync.when(
        data: (records) => ListView.builder(
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: record.type == 'Income' ? Colors.green.shade100 : Colors.red.shade100,
                child: Icon(
                  record.type == 'Income' ? Icons.arrow_upward : Icons.arrow_downward,
                  color: record.type == 'Income' ? Colors.green : Colors.red,
                ),
              ),
              title: Text(record.name),
              subtitle: Text('${record.category} • ${DateFormat('yyyy-MM-dd').format(record.date)}'),
              trailing: Text(
                '${record.type == 'Income' ? "+" : "-"}${record.value.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: record.type == 'Income' ? Colors.green : Colors.red,
                ),
              ),
              onLongPress: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Record?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () {
                          ref.read(recordProvider.notifier).deleteRecord(record.id!);
                          Navigator.pop(context);
                        },
                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implement Export logic
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exporting...')));
        },
        label: const Text('Export'),
        icon: const Icon(Icons.download),
      ),
    );
  }
}
