import 'package:flutter/material.dart';
import 'package:shopping_list/util/dbHelper.dart';
import 'package:shopping_list/models/shopping_list.dart';
import 'package:shopping_list/ui/shopping_list_dialog.dart';
import 'package:shopping_list/ui/items_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true
      ),
      home: const ShowList()
    );
  }
}

class ShowList extends StatefulWidget {
  const ShowList({super.key});

  @override
  State<ShowList> createState() => _ShowListState();
}

class _ShowListState extends State<ShowList> {
  DbHelper helper = DbHelper();
  List<ShoppingList> shoppingList = [];
  
  ShoppingListDialog? dialog;
  @override
  void initState() {
    dialog = ShoppingListDialog();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    showData();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shopping List"),
      ),
      body: ListView.builder(
        itemCount: (shoppingList.isEmpty) ? 0 : shoppingList.length,
        itemBuilder: (BuildContext context, int index) {
          return Dismissible(
            key: Key(shoppingList[index].name),
            onDismissed: (direction) {
              String strName = shoppingList[index].name;
              helper.deleteList(shoppingList[index]);

              setState(() {
                shoppingList.removeAt(index);
              });
              //Scaffold.of(context).showSnackBar(SnackBar(content: Text("$strName deleted")));
              Fluttertoast.showToast(
                msg: "$strName deleted",
                toastLength: Toast.LENGTH_SHORT,
              );
            },
            child: ListTile(
              title: Text(shoppingList[index].name),
              leading: CircleAvatar(
                child: Text(shoppingList[index].priority.toString()),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => dialog!.buildDialog(context, shoppingList[index], false)
                  );
                },
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ItemsScreen(shoppingList: shoppingList[index]))
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.cyanAccent,
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) => dialog!.buildDialog(context, ShoppingList(0, "", 0), true)
          );
        },
        child: const Icon(Icons.add_circle),
      ),
    );
  }

  Future<void> showData() async {
    await helper.openDB();
    shoppingList = await helper.getLists();

    setState(() {
      shoppingList = shoppingList;
    });
  }
}

