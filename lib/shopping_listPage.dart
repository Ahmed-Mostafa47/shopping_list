import 'package:flutter/material.dart';
import 'package:flutter_application_1/category_page.dart';
import 'package:flutter_application_1/info_card.dart';
import 'package:flutter_application_1/infolist_page.dart';
import 'package:flutter_application_1/shopping_item.dart';

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  final Map<String, List<ShoppingItem>> categoryMap = {};

  // Getter methods to organize the data
  List<ShoppingItem> get allItems =>
      categoryMap.entries
          .where((e) => e.key != 'Completed')
          .expand((e) => e.value)
          .toList();

  List<ShoppingItem> get todayItems =>
      allItems
          .where(
            (i) =>
                (i.isToday ||
                    (i.scheduledDate != null &&
                        isSameDate(i.scheduledDate!, DateTime.now()))) &&
                !i.isCompleted,
          )
          .toList();

  List<ShoppingItem> get scheduledItems =>
      allItems
          .where(
            (i) =>
                i.isScheduled &&
                !i.isCompleted &&
                !(i.scheduledDate != null &&
                    isSameDate(i.scheduledDate!, DateTime.now())),
          )
          .toList();

  List<ShoppingItem> get completedItems => categoryMap['Completed'] ?? [];

  // Helper function to compare dates
  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Function to add a new category
  void _addCategory() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Add List'),
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
              onPressed: () {
                if (controller.text.isNotEmpty &&
                    !categoryMap.containsKey(controller.text)) {
                  setState(() {
                    categoryMap[controller.text] = [];
                  });
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

  // Function to update the category name
  void _updateCategory(String oldCategoryName) {
    final controller = TextEditingController(text: oldCategoryName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Category'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Category Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    // Remove the old category and add the updated category
                    List<ShoppingItem> items = categoryMap[oldCategoryName]!;
                    categoryMap.remove(oldCategoryName);
                    categoryMap[controller.text] = items;
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Category name cannot be empty"),
                    ),
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
                    setState(() {
                      categoryMap.forEach((key, list) => list.remove(item));
                    });
                  }
                } else {
                  setState(() {
                    if (value) {
                      categoryMap.forEach((key, list) => list.remove(item));
                      item.isCompleted = true;
                      categoryMap['Completed'] ??= [];
                      categoryMap['Completed']!.add(item);
                    }
                  });
                }
              },
            ),
      ),
    );
    setState(() {});
  }

  // Function to go to the category page
  Future<void> _goToCategoryPage(String category) async {
    final updated = await Navigator.push<List<ShoppingItem>>(
      context,
      MaterialPageRoute(
        builder:
            (_) =>
                CategoryPage(category: category, items: categoryMap[category]!),
      ),
    );
    if (updated != null) {
      setState(() {
        categoryMap[category] = updated;
      });
    }
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
              child: ListView.builder(
                itemCount:
                    categoryMap.keys.where((k) => k != 'Completed').length,
                itemBuilder: (context, idx) {
                  final filteredKeys =
                      categoryMap.keys.where((k) => k != 'Completed').toList();
                  final category = filteredKeys[idx];
                  final items = categoryMap[category]!;
                  return ListTile(
                    title: Text(category),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${items.length}'),
                        const SizedBox(width: 10),

                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _updateCategory(category),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed:
                              () =>
                                  setState(() => categoryMap.remove(category)),
                        ),
                      ],
                    ),
                    onTap: () => _goToCategoryPage(category),
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
