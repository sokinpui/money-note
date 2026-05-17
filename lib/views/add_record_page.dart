import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../models/record.dart';
import '../providers/record_provider.dart';

class AddRecordPage extends ConsumerStatefulWidget {
  const AddRecordPage({super.key});

  @override
  ConsumerState<AddRecordPage> createState() => _AddRecordPageState();
}

class _AddRecordPageState extends ConsumerState<AddRecordPage> {
  final _nameController = TextEditingController();
  final _valueController = TextEditingController();
  final _categoryController = TextEditingController();
  final _noteController = TextEditingController();
  String _type = 'Expense';
  List<Record> _suggestions = [];
  DateTime? _lastErrorTime;

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
      name: _nameController.text,
      value: double.tryParse(_valueController.text) ?? 0.0,
      type: _type,
      category: _categoryController.text,
      note: _noteController.text,
      date: DateTime.now(),
    );

    ref.read(recordProvider.notifier).addRecord(record);
    Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.addRecord)),
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
        // Simple evaluation logic for demo (recommend using a package for real math)
        try {
          // This is a very primitive parser. For production, use 'expressions' package.
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
    // Basic evaluation for +, -, *, /
    try {
      // Use a basic regex to split by operators while keeping them
      final tokens = RegExp(r'(\d+\.?\d*)|([\+\-\*\/])').allMatches(expr)
          .map((m) => m.group(0)!)
          .toList();

      if (tokens.isEmpty) return '0';

      // First pass for * and /
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

      // Second pass for + and -
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
      
      // Return formatted result
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
