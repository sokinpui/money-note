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

final weeklySummaryProvider = Provider<AsyncValue<Map<String, dynamic>>>((ref) {
  final recordsAsync = ref.watch(recordProvider);
  return recordsAsync.whenData((records) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Daily Summary: Last 7 days
    final List<Map<String, dynamic>> dailyData = [];
    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      double expense = 0;
      for (var record in records) {
        if (record.date.year == date.year && record.date.month == date.month && record.date.day == date.day) {
          if (record.type == 'Expense') {
            expense += record.value;
          }
        }
      }
      dailyData.add({'date': date, 'expense': expense});
    }

    // Averages
    double total7Days = 0;
    for (var d in dailyData) {
      total7Days += d['expense'];
    }
    
    double total30Days = 0;
    final last30Days = today.subtract(const Duration(days: 30));
    for (var record in records) {
      if (record.date.isAfter(last30Days) && record.type == 'Expense') {
        total30Days += record.value;
      }
    }

    // Net Earnings: Last 3 months
    final List<Map<String, dynamic>> monthlyData = [];
    for (int i = 2; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      double income = 0;
      double expense = 0;
      for (var record in records) {
        if (record.date.year == monthDate.year && record.date.month == monthDate.month) {
          if (record.type == 'Income') {
            income += record.value;
          } else {
            expense += record.value;
          }
        }
      }
      monthlyData.add({
        'month': monthDate,
        'income': income,
        'expense': expense,
        'net': income - expense,
      });
    }

    return {
      'dailyData': dailyData,
      'avg7Days': total7Days / 7,
      'avg30Days': total30Days / 30,
      'monthlyData': monthlyData,
    };
  });
});
