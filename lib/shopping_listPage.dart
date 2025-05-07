import 'package:flutter/material.dart';
import 'package:flutter_application_1/category_page.dart';
import 'package:flutter_application_1/info_card.dart';
import 'package:flutter_application_1/infolist_page.dart';
import 'package:flutter_application_1/shoppingList.dart';
import 'package:flutter_application_1/shopping_item.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  final Map<String, List<ShoppingItem>> categoryMap =
      {}; //******************************

  List<ShoppingList> lists = [];
  @override
  void initState() {
    super.initState();
    lists = Hive.box<ShoppingList>('shopping_lists').values.toList();
    loadAndUpdateLists();
  }

  List<ShoppingItem> todayItems = [];
  List<ShoppingItem> completedItems = [];
  List<ShoppingItem> scheduledItems = [];
  List<ShoppingItem> allItems = [];

  void updateMainLists(List<ShoppingList> allShoppingLists) {
    todayItems.clear();
    completedItems.clear();
    scheduledItems.clear();
    allItems.clear();

    for (var list in allShoppingLists) {
      for (var item in list.items) {
        allItems.add(item);

        if (item.isCompleted) {
          completedItems.add(item);
        }

        if (item.scheduledDate != null) {
          final now = DateTime.now();
          final scheduledDate = item.scheduledDate!;
          if (scheduledDate.year == now.year &&
              scheduledDate.month == now.month &&
              scheduledDate.day == now.day) {
            todayItems.add(item);
          } else {
            scheduledItems.add(item);
          }
        }
      }
    }
  }

  Future<void> loadAndUpdateLists() async {
    final box = Hive.box<ShoppingList>('shopping_lists');
    final allShoppingLists = box.values.toList();
    updateMainLists(allShoppingLists);
    setState(() {});
  }

  // // Getter methods to organize the data
  // List<ShoppingItem> get allItems =>
  //     categoryMap
  //         .entries //******************************
  //         .where((e) => e.key != 'Completed')
  //         .expand((e) => e.value)
  //         .toList();

  // List<ShoppingItem> get todayItems =>
  //     allItems
  //         .where(
  //           (i) =>
  //               (i.isToday ||
  //                   (i.scheduledDate != null &&
  //                       isSameDate(i.scheduledDate!, DateTime.now()))) &&
  //               !i.isCompleted,
  //         )
  //         .toList();

  // List<ShoppingItem> get scheduledItems =>
  //     allItems
  //         .where(
  //           (i) =>
  //               i.isScheduled &&
  //               !i.isCompleted &&
  //               !(i.scheduledDate != null &&
  //                   isSameDate(i.scheduledDate!, DateTime.now())),
  //         )
  //         .toList();

  // List<ShoppingItem> get completedItems =>
  //     categoryMap['Completed'] ?? []; //******************************

  // Helper function to compare dates
  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<bool> checkIfListNameExists(String listName) async {
    var box = Hive.box<ShoppingList>('shopping_lists');

    return box.values.any((list) => list.name == listName);
  }

  // Function to add a new list
  Future<void> _addCategory() async {
    var box = Hive.box<ShoppingList>('shopping_lists');
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Add List'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: 'List Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String listName = controller.text.trim();
                if (listName.isNotEmpty &&
                    !await checkIfListNameExists(listName)) {
                  final newList = ShoppingList(
                    name: controller.text,
                    items: [],
                  );
                  await box.add(newList);
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Function to update the list name
  Future<void> _updateCategory(String oldListName) async {
    final controller = TextEditingController(text: oldListName);
    final box = await Hive.openBox<ShoppingList>('shopping_lists');
    final listIndex = box.values.toList().indexWhere(
      (item) => item.name == oldListName,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update List'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'List Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  if (!await checkIfListNameExists(controller.text)) {
                    final itemToUpdate = box.getAt(listIndex);
                    itemToUpdate?.name = controller.text;
                    await itemToUpdate?.save();
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("List name exists already")),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("List name cannot be empty")),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  // Function to open a page displaying the items of a category
  Future<void> _openInfoPage(String title, List<ShoppingItem> items) async {
    final box = await Hive.openBox<ShoppingList>('shopping_lists');
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => InfoListPage(
              title: title,
              items: items,
              onItemToggle: (item, value) async {
                if (title == 'Completed') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder:
                        (_) => AlertDialog(
                          title: const Text('Delete Item'),
                          content: Text('Delete "${item.name}" permanently?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('No'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Yes'),
                            ),
                          ],
                        ),
                  );
                  if (confirm == true) {
                    // setState(() {
                    //   categoryMap.forEach((key, list) => list.remove(item));
                    // });
                    for (var list in box.values) {
                      list.items.removeWhere((i) => i.name == item.name);
                      await list.save();
                    }
                  }
                } else {
                  if (value) {
                    // categoryMap.forEach((key, list) => list.remove(item));
                    // item.isCompleted = true;
                    // categoryMap['Completed'] ??= [];
                    // categoryMap['Completed']!.add(item);
                    for (var list in box.values) {}
                  }
                }
              },
            ),
      ),
    );
  }

  // Function to go to the category page
  Future<void> _goToCategoryPage(int index) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CategoryPage(index: index)),
    );
    loadAndUpdateLists();
  }

  int get totalCount => allItems.length;
  int get todayCount => todayItems.length;
  int get scheduledCount => scheduledItems.length;
  int get completedCount => completedItems.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
        actions: [
          IconButton(icon: const Icon(Icons.add_box), onPressed: _addCategory),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  switch (index) {
                    case 0:
                      return InfoCard(
                        title: 'Today',
                        count: todayCount,
                        onTap: () => _openInfoPage('Today', todayItems),
                      );
                    case 1:
                      return InfoCard(
                        title: 'Scheduled',
                        count: scheduledCount,
                        onTap: () => _openInfoPage('Scheduled', scheduledItems),
                      );
                    case 2:
                      return InfoCard(
                        title: 'All',
                        count: totalCount,
                        onTap: () => _openInfoPage('All', allItems),
                      );
                    default:
                      return InfoCard(
                        title: 'Completed',
                        count: completedCount,
                        onTap: () => _openInfoPage('Completed', completedItems),
                      );
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable:
                    Hive.box<ShoppingList>('shopping_lists').listenable(),
                builder: (context, Box<ShoppingList> box, _) {
                  lists = box.values.toList();
                  final keys = box.keys.toList();
                  return ListView.builder(
                    itemCount: lists.length,
                    itemBuilder: (context, idx) {
                      final filteredKeys =
                          categoryMap.keys
                              .where((k) => k != 'Completed')
                              .toList();
                      final listName = lists[idx].name;
                      final items = lists[idx].items;
                      return ListTile(
                        title: Text(listName),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${items.length}'),
                            const SizedBox(width: 10),

                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _updateCategory(listName),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Color.fromARGB(255, 222, 60, 60),
                              ),
                              onPressed: () async {
                                await box.delete(keys[idx]);
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          _goToCategoryPage(idx);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
