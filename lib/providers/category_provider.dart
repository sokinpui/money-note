import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import 'record_provider.dart';

class CategoryNotifier extends AsyncNotifier<List<Category>> {
  @override
  Future<List<Category>> build() async {
    return _fetchCategories();
  }

  Future<List<Category>> _fetchCategories() async {
    return ref.read(databaseHelperProvider).getAllCategories();
  }

  Future<void> addCategory(Category category) async {
    await ref.read(databaseHelperProvider).insertCategory(category);
    state = await AsyncValue.guard(() => _fetchCategories());
  }
}

final categoryProvider = AsyncNotifierProvider<CategoryNotifier, List<Category>>(() {
  return CategoryNotifier();
});
