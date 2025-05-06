import 'package:hive/hive.dart';
import 'shopping_item.dart';

part 'shoppingList.g.dart';

@HiveType(typeId: 1)
class ShoppingList extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  List<ShoppingItem> items;

  ShoppingList({required this.name, required this.items});
}
