import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/app_localizations.dart';
import '../providers/record_provider.dart';
import 'package:intl/intl.dart';
import 'add_record_page.dart';
import '../models/record.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  final Set<int> _selectedIds = {};
  bool _isSelectionMode = false;

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
        _isSelectionMode = true;
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectedIds.clear();
      _isSelectionMode = false;
    });
  }

  void _deleteSelected() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteRecord),
        content: Text('${l10n.delete} ${_selectedIds.length} items?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              ref.read(recordProvider.notifier).deleteMultipleRecords(_selectedIds.toList());
              _exitSelectionMode();
              Navigator.pop(context);
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _exportSelected(List<Record> records) async {
    final selectedRecords = records.where((r) => _selectedIds.contains(r.id)).toList();
    final jsonString = jsonEncode(selectedRecords.map((e) => e.toMap()).toList());
    
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/records_export.json');
    await file.writeAsString(jsonString);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: 'Exported Records',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(recordProvider);
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: !_isSelectionMode,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _exitSelectionMode();
      },
      child: Scaffold(
        appBar: _isSelectionMode
            ? AppBar(
                title: Text('${_selectedIds.length} ${l10n.multiSelect}'),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _exitSelectionMode,
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () {
                      recordsAsync.whenData((records) => _exportSelected(records));
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: _deleteSelected,
                  ),
                ],
              )
            : null,
        body: recordsAsync.when(
          data: (records) => ListView.builder(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              final isSelected = _selectedIds.contains(record.id);

              return ListTile(
                selected: isSelected,
                leading: _isSelectionMode
                    ? Checkbox(
                        value: isSelected,
                        onChanged: (_) => _toggleSelection(record.id!),
                      )
                    : CircleAvatar(
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
                onTap: () {
                  if (_isSelectionMode) {
                    _toggleSelection(record.id!);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddRecordPage(initialRecord: record),
                      ),
                    );
                  }
                },
                onLongPress: () {
                  if (!_isSelectionMode) {
                    _toggleSelection(record.id!);
                  }
                },
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('${l10n.error}: $e')),
        ),
      ),
    );
  }
}
