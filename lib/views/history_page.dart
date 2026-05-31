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
import '../providers/category_provider.dart';
import '../models/category.dart' as model;
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

    double totalIncome = 0;
    double totalExpense = 0;
    DateTime? startDate;
    DateTime? endDate;

    if (_isSelectionMode) {
      recordsAsync.whenData((records) {
        final selected = records.where((r) => _selectedIds.contains(r.id)).toList();
        for (final r in selected) {
          if (r.type == 'Income') {
            totalIncome += r.value;
          } else {
            totalExpense += r.value;
          }

          if (startDate == null || r.date.isBefore(startDate!)) {
            startDate = r.date;
          }
          if (endDate == null || r.date.isAfter(endDate!)) {
            endDate = r.date;
          }
        }
      });
    }

    final dateRangeStr = startDate != null && endDate != null
        ? '${DateFormat('yyyy-MM-dd').format(startDate!)} ~ ${DateFormat('yyyy-MM-dd').format(endDate!)}'
        : '';

    return PopScope(
      canPop: !_isSelectionMode,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _exitSelectionMode();
      },
      child: Scaffold(
        appBar: _isSelectionMode
            ? AppBar(
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
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
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 12,
                              children: [
                                Text('+${totalIncome.toStringAsFixed(2)}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.green)),
                                Text('-${totalExpense.toStringAsFixed(2)}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.red)),
                                Text('${l10n.netEarnings}: ${(totalIncome - totalExpense).toStringAsFixed(2)}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            if (dateRangeStr.isNotEmpty)
                              Text(
                                dateRangeStr,
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : null,
        body: recordsAsync.when(
          data: (records) => ListView.builder(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              final isSelected = _selectedIds.contains(record.id);
              
              final categories = ref.watch(categoryProvider).value ?? [];
              final category = categories.firstWhere(
                (c) => c.name == record.category && c.type == record.type,
                orElse: () => model.Category(name: 'Other', iconName: 'category', type: record.type),
              );

              return ListTile(
                selected: isSelected,
                leading: _isSelectionMode
                    ? Checkbox(
                        value: isSelected,
                        onChanged: (_) => record.id != null ? _toggleSelection(record.id!) : null,
                      )
                    : Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: record.type == 'Income' 
                            ? Colors.green.withValues(alpha: 0.1) 
                            : Colors.red.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          model.Category.getIconData(category.iconName),
                          size: 20,
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
