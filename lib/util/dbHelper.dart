import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shopping_list/models/shopping_list.dart';
import 'package:shopping_list/models/list_items.dart';

class DbHelper {
  final int version = 1;
  Database? db;

  static final DbHelper dbHelper = DbHelper.internal();
  DbHelper.internal();
  factory DbHelper() {
    return dbHelper;
  }

  Future<Database> openDB() async {
    db ??= await openDatabase(join(await getDatabasesPath(), "shopping.db"), onCreate: (database, version) {
        database.execute("CREATE TABLE lists (id INTEGER PRIMARY KEY, name TEXT, priority INTEGER)");
        database.execute("CREATE TABLE items (id INTEGER PRIMARY KEY, idList INTEGER, name TEXT, quantity INTEGER, note TEXT, FOREIGN KEY(idList) REFERENCES lists(id))");
      }, version: version);
    return db!;
  }

  Future<void> testDB() async {
    db = await openDB();
    await db!.execute('INSERT INTO lists VALUES(0, "Frutas", 1)');
    await db!.execute('INSERT INTO items VALUES(0, 0, "Manzana", "20 uds", "De preferencia roja")');

    List lists = await db!.rawQuery(("SELECT * FROM lists"));
    List items = await db!.rawQuery(("SELECT * FROM items"));
  }

  Future<int> insertList(ShoppingList list) async {
    int id = await db!.insert("lists", list.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  Future<int> insertItem(ListItem item) async {
    int id = await db!.insert("items", item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }
  
  Future<List<ShoppingList>> getLists() async {
    final List<Map<String, dynamic>> maps = await db!.query("lists");
    return List.generate(maps.length, (index) {
      return ShoppingList(
        maps[index]["id"],
        maps[index]["name"],
        maps[index]["priority"]
      );
    });
  }

  Future<List<ListItem>> getItems(int idList) async {
    final List<Map<String, dynamic>> maps = await db!.query("items", where: "idList = ?", whereArgs: [idList]);
    return List.generate(maps.length, (index) {
      return ListItem(
          maps[index]["id"],
          maps[index]["idList"],
          maps[index]["name"],
          maps[index]["quantity"],
          maps[index]["note"]
      );
    });
  }

  Future<int> deleteList(ShoppingList list) async {
    int result = await db!.delete("items", where: "idList = ?", whereArgs: [list.id]);
    result = await db!.delete("lists", where: "id = ?", whereArgs: [list.id]);
    return result;
  }
}