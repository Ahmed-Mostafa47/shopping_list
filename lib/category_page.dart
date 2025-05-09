import 'package:flutter/material.dart';
import 'package:flutter_application_1/shoppingList.dart';
import 'package:flutter_application_1/shopping_item.dart';
import 'package:hive/hive.dart';

class CategoryPage extends StatefulWidget {
  int index;
  CategoryPage({super.key, required this.index});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  var allLists;

  @override
  void initState() {
    super.initState();
    allLists = Hive.box<ShoppingList>('shopping_lists').values.toList();
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

  void _addItem() {
    var box = Hive.box<ShoppingList>('shopping_lists');
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        bool isScheduled = false;
        DateTime? selectedDate;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Add Item'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(labelText: 'Item Name'),
                  ),
                  // CheckboxListTile(
                  //   title: const Text('Scheduled'),
                  //   value: isScheduled,
                  //   onChanged:
                  //       (v) => setStateDialog(() => isScheduled = v ?? false),
                  // ),
                  SizedBox(height: 10),
                  if (true)
                    TextButton(
                      onPressed: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (d != null) {
                          setStateDialog(() => selectedDate = d);
                        }
                      },
                      child: Text(
                        selectedDate == null
                            ? 'Pick Date'
                            : selectedDate!.toLocal().toString().split(' ')[0],
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (controller.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Item name cannot be empty"),
                        ),
                      );
                    } else if (true && selectedDate != null) {
                      final newItem = ShoppingItem(
                        name: controller.text,
                        isScheduled: isScheduled,
                        scheduledDate: selectedDate,
                      );
                      setState(() {
                        ShoppingList updated = box.getAt(widget.index)!;
                        updated.items.add(newItem);
                        box.putAt(widget.index, updated);
                        loadAndUpdateLists();
                      });
                      Navigator.pop(context);
                    } else {
                      // If scheduled is selected but no date is picked, show a warning
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please select a scheduled date"),
                        ),
                      );
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _updateItem(int i) {
    var box = Hive.box<ShoppingList>('shopping_lists');
    final controller = TextEditingController(
      text: box.getAt(widget.index)!.items[i].name,
    );
    bool isScheduled = box.getAt(widget.index)!.items[i].isScheduled;
    DateTime? selectedDate = box.getAt(widget.index)!.items[i].scheduledDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Update Item'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(labelText: 'Item Name'),
                  ),
                  CheckboxListTile(
                    title: const Text('Scheduled'),
                    value: isScheduled,
                    onChanged:
                        (v) => setStateDialog(() => isScheduled = v ?? false),
                  ),
                  if (true)
                    TextButton(
                      onPressed: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (d != null) {
                          setStateDialog(() => selectedDate = d);
                        }
                      },
                      child: Text(
                        selectedDate == null
                            ? 'Pick Date'
                            : selectedDate!.toLocal().toString().split(' ')[0],
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (controller.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Item name cannot be empty"),
                        ),
                      );
                    } else if (isScheduled && selectedDate != null) {
                      setState(() {
                        ShoppingList updated = box.getAt(widget.index)!;
                        updated.items[i] = ShoppingItem(
                          name: controller.text,
                          isScheduled: isScheduled,
                          scheduledDate: selectedDate,
                        );
                        box.putAt(widget.index, updated);
                        loadAndUpdateLists();

                        // items[index] = ShoppingItem(
                        //   name: controller.text,
                        //   isScheduled: isScheduled,
                        //   scheduledDate: selectedDate,
                        // );
                      });
                      Navigator.pop(context);
                    } else {
                      // If scheduled is selected but no date is picked, show a warning
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please select a scheduled date"),
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
      },
    );
  }

  void _deleteItem(int i) {
    var box = Hive.box<ShoppingList>('shopping_lists');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Item'),
          content: Text(
            'Are you sure you want to delete "${box.getAt(widget.index)!.items[i].name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  ShoppingList updated = box.getAt(widget.index)!;
                  updated.items.removeAt(i);
                  box.putAt(widget.index, updated);
                  loadAndUpdateLists();
                });
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var box = Hive.box<ShoppingList>('shopping_lists');
    final currentList = box.getAt(widget.index)!;
    final nonCompletedItems =
        currentList.items.where((item) => !item.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(title: Text(currentList.name)),
      body: ListView.builder(
        itemCount: nonCompletedItems.length,
        itemBuilder: (context, i) {
          final item = nonCompletedItems[i];
          return ListTile(
            title: Text(item.name),
            subtitle:
                item.scheduledDate != null
                    ? Text(
                      item.scheduledDate!.toLocal().toString().split(' ')[0],
                    )
                    : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _updateItem(i),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteItem(i),
                ),
                Checkbox(
                  value: item.isCompleted,
                  onChanged: (bool? value) {
                    setState(() {
                      item.isCompleted = value ?? false;
                      currentList.save(); // Persist changes
                      loadAndUpdateLists(); // Refresh UI
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        child: Icon(Icons.add),
      ),
    );
  }
}
