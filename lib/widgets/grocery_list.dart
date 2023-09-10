import 'package:flutter/material.dart';

import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryItems = [];

  void _addNewItem() async {
    final result = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(builder: (ctx) => const NewItem()),
    );

    if (result != null) {
      setState(() {
        _groceryItems.add(result);
      });
    }
  }

  void _removeGroceryItem(GroceryItem groceryItem) {
    final index = _groceryItems.indexOf(groceryItem);
    setState(() {
      _groceryItems.removeAt(index);
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Removed ${groceryItem.name}"),
            TextButton(
              onPressed: () {
                setState(() {
                  _groceryItems.insert(index, groceryItem);
                });
              },
              child: const Text("Undo"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewItem,
          )
        ],
      ),
      body: _groceryItems.isEmpty
          ? const Center(
              child: Text("No grocery... Add some!"),
            )
          : ListView.builder(
              itemBuilder: (ctx, index) {
                return Dismissible(
                  key: ValueKey(_groceryItems[index].id),
                  onDismissed: (direction) =>
                      _removeGroceryItem(_groceryItems[index]),
                  background: Container(
                    padding: const EdgeInsets.only(right: 8),
                    color: Colors.red,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text("Remove"),
                      ],
                    ),
                  ),
                  child: ListTile(
                    title: Text(_groceryItems[index].name),
                    leading: Container(
                      width: 24,
                      height: 24,
                      color: _groceryItems[index].category.color,
                    ),
                    trailing: Text(_groceryItems[index].quantity.toString()),
                  ),
                );
              },
              itemCount: _groceryItems.length,
            ),
    );
  }
}
