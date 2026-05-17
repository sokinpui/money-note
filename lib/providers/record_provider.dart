import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/record.dart';
import '../services/database_helper.dart';

final databaseHelperProvider = Provider((ref) => DatabaseHelper());

class RecordNotifier extends AsyncNotifier<List<Record>> {
  @override
  Future<List<Record>> build() async {
    return _fetchRecords();
  }

  Future<List<Record>> _fetchRecords() async {
    return ref.read(databaseHelperProvider).getAllRecords();
  }

  Future<void> refreshRecords() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchRecords());
  }

  Future<void> addRecord(Record record) async {
    await ref.read(databaseHelperProvider).insertRecord(record);
    await refreshRecords();
  }

  Future<void> deleteRecord(int id) async {
    await ref.read(databaseHelperProvider).deleteRecord(id);
    await refreshRecords();
  }

  Future<List<Record>> getSuggestions(String query) async {
    if (query.isEmpty) return [];
    return await ref.read(databaseHelperProvider).getRecordsByName(query);
  }

  Future<String> exportRecords() async {
    final records = await _fetchRecords();
    return records.map((e) => e.toMap()).toList().toString();
  }

  Future<void> importRecords(List<dynamic> list) async {
    final db = ref.read(databaseHelperProvider);
    for (var item in list) {
      await db.insertRecord(Record.fromMap(Map<String, dynamic>.from(item)));
    }
    await refreshRecords();
  }
}

final recordProvider = AsyncNotifierProvider<RecordNotifier, List<Record>>(() {
  return RecordNotifier();
});

final weeklySummaryProvider = Provider<AsyncValue<Map<String, double>>>((ref) {
  final recordsAsync = ref.watch(recordProvider);
  return recordsAsync.whenData((records) {
    final now = DateTime.now();
    final lastWeek = now.subtract(const Duration(days: 7));
    final lastMonth = now.subtract(const Duration(days: 30));

    double weekEarn = 0;
    double monthEarn = 0;

    for (var record in records) {
      if (record.date.isAfter(lastWeek)) {
        if (record.type == 'Income') {
          weekEarn += record.value;
        } else {
          weekEarn -= record.value;
        }
      }
      if (record.date.isAfter(lastMonth)) {
        if (record.type == 'Income') {
          monthEarn += record.value;
        } else {
          monthEarn -= record.value;
        }
      }
    }

    return {
      'week': weekEarn,
      'month': monthEarn,
    };
  });
});
