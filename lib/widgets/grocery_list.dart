import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list_app/data/categories.dart';
import 'dart:convert';

import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  bool _isLoading = true;
  bool? _isError;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final url = Uri.https(
        "shopping-list-10d4a-default-rtdb.europe-west1.firebasedatabase.app",
        "shopping-list.json");

    final response = await http.get(url);

    if (response.body == "null") {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final Map<String, dynamic> listData = json.decode(response.body);
    final List<GroceryItem> loadedItems = [];
    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere(
              (element) => element.value.title == item.value["category"])
          .value;
      loadedItems.add(
        GroceryItem(
          id: item.key,
          name: item.value["name"],
          quantity: item.value["quantity"],
          category: category,
        ),
      );
    }

    setState(() {
      _groceryItems = loadedItems;
      _isLoading = false;
    });
  }

  void _addNewItem() async {
    final response = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(builder: (ctx) => const NewItem()),
    );

    if (response == null) {
      return;
    }

    setState(() {
      _groceryItems.add(response);
    });
  }

  void _removeGroceryItem(GroceryItem groceryItem) async {
    final index = _groceryItems.indexOf(groceryItem);

    final url = Uri.https(
        "shopping-list-10d4a-default-rtdb.europe-west1.firebasedatabase.app",
        "shopping-list/${groceryItem.id}.json");

    final response = await http.delete(url);

    setState(() {
      _groceryItems.removeAt(index);
    });

    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(index, groceryItem);
      });
    }

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).clearSnackBars();
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
    Widget content = const Center(
      child: Text("No grocery... Add some!"),
    );

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

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
          ? content
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
