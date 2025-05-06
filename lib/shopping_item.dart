import 'package:hive/hive.dart';

part "shopping_item.g.dart"; 

@HiveType(typeId: 0)
class ShoppingItem extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  bool isCompleted;

  @HiveField(2)
  bool isScheduled;

  @HiveField(3)
  bool isToday;

  @HiveField(4)
  DateTime? scheduledDate;

  ShoppingItem({
    required this.name,
    this.isCompleted = false,
    this.isScheduled = false,
    this.isToday = false,
    this.scheduledDate,
  });
}
