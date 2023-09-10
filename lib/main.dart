import 'package:flutter/material.dart';

import 'package:shopping_list_app/widgets/grocery_list.dart';
import './theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: darkTheme,
      home: const GroceryList(),
    );
  }
}
