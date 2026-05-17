import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../models/record.dart';
import '../providers/record_provider.dart';

class AddRecordPage extends ConsumerStatefulWidget {
  final Record? initialRecord;
  const AddRecordPage({super.key, this.initialRecord});

  @override
  ConsumerState<AddRecordPage> createState() => _AddRecordPageState();
}

class _AddRecordPageState extends ConsumerState<AddRecordPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _valueController;
  late final TextEditingController _categoryController;
  late final TextEditingController _noteController;
  late String _type;
  List<Record> _suggestions = [];
  DateTime? _lastErrorTime;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialRecord?.name ?? '');
    _valueController = TextEditingController(text: widget.initialRecord?.value.toString() ?? '');
    _categoryController = TextEditingController(text: widget.initialRecord?.category ?? '');
    _noteController = TextEditingController(text: widget.initialRecord?.note ?? '');
    _type = widget.initialRecord?.type ?? 'Expense';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    _categoryController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool get _isDirty {
    if (widget.initialRecord == null) {
      return _nameController.text.isNotEmpty ||
          _valueController.text.isNotEmpty ||
          _categoryController.text.isNotEmpty ||
          _noteController.text.isNotEmpty;
    }
    return _nameController.text != widget.initialRecord!.name ||
        _valueController.text != widget.initialRecord!.value.toString() ||
        _categoryController.text != widget.initialRecord!.category ||
        (_noteController.text != (widget.initialRecord!.note ?? '')) ||
        _type != widget.initialRecord!.type;
  }

  void _onNameChanged(String value) async {
    if (value.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    final suggestions = await ref.read(recordProvider.notifier).getSuggestions(value);
    setState(() => _suggestions = suggestions);
  }

  void _applySuggestion(Record record) {
    setState(() {
      _nameController.text = record.name;
      _valueController.text = record.value.toString();
      _type = record.type;
      _categoryController.text = record.category;
      _noteController.text = record.note ?? '';
      _suggestions = [];
    });
  }

  void _save() {
    if (_nameController.text.isEmpty || _valueController.text.isEmpty) {
      final now = DateTime.now();
      if (_lastErrorTime == null || now.difference(_lastErrorTime!) > const Duration(seconds: 5)) {
        _lastErrorTime = now;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.pleaseFillRequiredFields)),
        );
      }
      return;
    }

    final record = Record(
      id: widget.initialRecord?.id,
      name: _nameController.text,
      value: double.tryParse(_valueController.text) ?? 0.0,
      type: _type,
      category: _categoryController.text,
      note: _noteController.text,
      date: widget.initialRecord?.date ?? DateTime.now(),
    );

    if (widget.initialRecord == null) {
      ref.read(recordProvider.notifier).addRecord(record);
    } else {
      ref.read(recordProvider.notifier).updateRecord(record);
    }
    Navigator.pop(context);
  }

  void _delete() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteRecord),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              ref.read(recordProvider.notifier).deleteRecord(widget.initialRecord!.id!);
              Navigator.pop(context); // pop dialog
              Navigator.pop(context); // pop page
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showCalculator() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _Calculator(
        onResult: (result) {
          setState(() => _valueController.text = result);
        },
      ),
    );
  }

  Future<bool?> _showUnsavedChangesDialog() {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.unsavedChanges),
        content: Text(l10n.unsavedChangesMsg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showUnsavedChangesDialog();
        if (shouldPop == true && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.initialRecord == null ? l10n.addRecord : l10n.editRecord),
          actions: [
            if (widget.initialRecord != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: _delete,
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'Expense', label: Text(l10n.expense), icon: const Icon(Icons.remove)),
                  ButtonSegment(value: 'Income', label: Text(l10n.income), icon: const Icon(Icons.add)),
                ],
                selected: {_type},
                onSelectionChanged: (set) => setState(() => _type = set.first),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: l10n.name, border: const OutlineInputBorder()),
                onChanged: _onNameChanged,
              ),
              if (_suggestions.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      final s = _suggestions[index];
                      return ListTile(
                        title: Text(s.name),
                        subtitle: Text('${s.category} - ${s.value}'),
                        onTap: () => _applySuggestion(s),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              TextField(
                controller: _valueController,
                decoration: InputDecoration(
                  labelText: l10n.value,
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(icon: const Icon(Icons.calculate), onPressed: _showCalculator),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: l10n.category, border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(labelText: '${l10n.note} (${l10n.optional})', border: const OutlineInputBorder()),
                maxLines: 5,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(onPressed: _save, child: Text(l10n.save)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Calculator extends StatefulWidget {
  final Function(String) onResult;
  const _Calculator({required this.onResult});

  @override
  State<_Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<_Calculator> {
  String _display = '';

  void _onPressed(String val) {
    setState(() {
      if (val == '=') {
        try {
          _display = _evaluate(_display);
        } catch (e) {
          _display = 'Error';
        }
      } else if (val == 'C') {
        _display = '';
      } else {
        _display += val;
      }
    });
  }

  String _evaluate(String expr) {
    try {
      final tokens = RegExp(r'(\d+\.?\d*)|([\+\-\*\/])').allMatches(expr)
          .map((m) => m.group(0)!)
          .toList();

      if (tokens.isEmpty) return '0';

      List<String> firstPass = [];
      int i = 0;
      while (i < tokens.length) {
        if (tokens[i] == '*' || tokens[i] == '/') {
          String op = tokens[i];
          double left = double.parse(firstPass.removeLast());
          double right = double.parse(tokens[++i]);
          if (op == '*') {
            firstPass.add((left * right).toString());
          } else {
            firstPass.add((left / right).toString());
          }
        } else {
          firstPass.add(tokens[i]);
        }
        i++;
      }

      double result = double.parse(firstPass[0]);
      i = 1;
      while (i < firstPass.length) {
        String op = firstPass[i++];
        double val = double.parse(firstPass[i++]);
        if (op == '+') {
          result += val;
        } else {
          result -= val;
        }
      }
      
      return result % 1 == 0 ? result.toInt().toString() : result.toStringAsFixed(2);
    } catch (e) {
      return 'Error';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_display, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Divider(),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 4,
            children: [
              for (var btn in ['7', '8', '9', '/', '4', '5', '6', '*', '1', '2', '3', '-', '0', 'C', '=', '+'])
                TextButton(
                  onPressed: () {
                    if (btn == '=') {
                      widget.onResult(_display);
                      Navigator.pop(context);
                    } else {
                      _onPressed(btn);
                    }
                  },
                  child: Text(btn, style: const TextStyle(fontSize: 20)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
