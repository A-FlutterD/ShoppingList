import 'package:flutter/material.dart';
import 'package:shopping_list/util/dbHelper.dart';
import 'package:shopping_list/models/shopping_list.dart';
import 'package:shopping_list/models/list_items.dart';

class ItemsScreen extends StatefulWidget {
  final ShoppingList shoppingList;
  const ItemsScreen({super.key, required this.shoppingList});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState(shoppingList);
}

class _ItemsScreenState extends State<ItemsScreen> {
  final ShoppingList shoppingList;
  _ItemsScreenState(this.shoppingList);

  DbHelper? helper;
  List<ListItem> items = [];

  @override
  Widget build(BuildContext context) {
    helper = DbHelper();
    showData(shoppingList.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(shoppingList.name),
      ),
      body: ListView.builder(
        itemCount: (items.isEmpty) ? 0 : items.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(items[index].name),
            subtitle: Text("Quantity: ${items[index].quantity} - Note: ${items[index].note}"),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {

              },
            ),
          );
        },
      ),
    );
  }

  Future<void> showData(int idList) async {
    await helper!.openDB();
    items = await helper!.getItems(idList);

    setState(() {
      items = items;
    });
  }
}
