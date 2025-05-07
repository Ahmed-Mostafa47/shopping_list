import 'package:flutter/material.dart';
import 'package:flutter_application_1/shopping_item.dart';

class InfoListPage extends StatefulWidget {
  final String title;
  final List<ShoppingItem> items;
  final void Function(ShoppingItem, bool) onItemToggle;

  const InfoListPage({
    super.key,
    required this.title,
    required this.items,
    required this.onItemToggle,
  });

  @override
  State<InfoListPage> createState() => _InfoListPageState();
}

class _InfoListPageState extends State<InfoListPage> {
  late List<ShoppingItem> items;

  @override
  void initState() {
    super.initState();
    items = widget.items;
  }

  @override
  Widget build(BuildContext context) {
    final isScheduledPage = widget.title == 'Scheduled';
    final isCompletedPage = widget.title == 'Completed';
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, i) {
          final item = items[i];
          return ListTile(
            title: Text(item.name),
            subtitle:
                isScheduledPage && item.scheduledDate != null
                    ? Text(
                      item.scheduledDate!.toLocal().toString().split(' ')[0],
                    )
                    : null,
            trailing: Checkbox(
              value: isCompletedPage ? false : item.isCompleted,
              onChanged: (val) {
                widget.onItemToggle(item, val ?? false);
                setState(() {
                  items[i].isCompleted = val ?? false;
                });
              },
            ),
          );
        },
      ),
    );
  }
}
