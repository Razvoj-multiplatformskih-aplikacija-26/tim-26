import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'demo_data.dart';

class FakeShoppingListRepository implements ShoppingListRepository {
  final List<ShoppingList> _lists = buildDemoLists();
  final Catalog _catalog = buildDemoCatalog();

  bool failNextRequest = false;
  bool showEmpty = false;

  Future<void> _simulateNetwork() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (failNextRequest) {
      failNextRequest = false;
      throw Exception('Simulirana greška mreže');
    }
  }

  @override
  Future<List<ShoppingList>> getLists() async {
    await _simulateNetwork();
    if (showEmpty) return [];
    return List.of(_lists);
  }

  @override
  Future<void> saveList(ShoppingList list) async {
    await _simulateNetwork();
    final index = _lists.indexWhere((item) => item.id == list.id);
    if (index == -1) {
      _lists.add(list);
    } else {
      _lists[index] = list;
    }
    showEmpty = false;
  }

  @override
  Future<Catalog> getCatalog() async {
    return _catalog;
  }
}
