import 'dart:io';
import 'dart:async';
import 'package:money_manager/functions/functions.dart';
import 'package:money_manager/models/models.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

String _dbName = "Moneymanager.db";

class DatabaseHelper {
  static const int _version = 7;

  static Future<Database> _getDB() async {
    return openDatabase(
      join(await getDatabasesPath(), _dbName),
      onCreate: initDatabase,
      onUpgrade: (db, oldVersion, newVersion) => updateDatabase(db, newVersion),
      version: _version,
    );
  }

  static Future<void> initDatabase(Database db, int version) async {
    await db.execute(
      "CREATE TABLE GROUPS(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, description TEXT, participants TEXT NOT NULL)",
    );
    await db.execute(
      "CREATE TABLE EXPENSES(gid INTEGER, tid INTEGER PRIMARY KEY AUTOINCREMENT, tname TEXT NOT NULL, payername TEXT NOT NULL, amount INTEGER, date TEXT NOT NULL, borrowers TEXT NOT NULL, borrowedamt TEXT NOT NULL)",
    );
    await db.execute("CREATE TABLE ACCOUNTS(name TEXT NOT NULL)");
    await db.execute("CREATE TABLE CATEGORIES(name TEXT NOT NULL)");
    await db.execute(
      "CREATE TABLE TRANSACTIONS(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, date TEXT NOT NULL, account TEXT NOT NULL, category TEXT NOT NULL, amount INTEGER NOT NULL, description TEXT, isExpense TEXT)",
    );
    await db.insert("ACCOUNTS", {"name": "cash"});
    await db.insert("CATEGORIES", {"name": "expense"});
    await db.insert("CATEGORIES", {"name": "income"});
  }

  static Future<void> updateDatabase(Database db, int version) async {
    await db.execute('DROP TABLE IF EXISTS GROUPS');
    await db.execute('DROP TABLE IF EXISTS EXPENSES');
    await db.execute('DROP TABLE IF EXISTS ACCOUNTS');
    await db.execute('DROP TABLE IF EXISTS CATEGORIES');
    await db.execute('DROP TABLE IF EXISTS TRANSACTIONS');
    await db.execute("CREATE TABLE ACCOUNTS(name TEXT NOT NULL)");
    await db.execute("CREATE TABLE CATEGORIES(name TEXT NOT NULL)");
    await db.execute(
      "CREATE TABLE GROUPS(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, description TEXT, participants TEXT NOT NULL)",
    );
    await db.execute(
      "CREATE TABLE EXPENSES(gid INTEGER, tid INTEGER PRIMARY KEY AUTOINCREMENT, tname TEXT NOT NULL, payername TEXT NOT NULL, amount INTEGER, date TEXT NOT NULL, borrowers TEXT NOT NULL, borrowedamt TEXT NOT NULL)",
    );
    await db.execute(
      "CREATE TABLE TRANSACTIONS(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, date TEXT NOT NULL, account TEXT NOT NULL, category TEXT NOT NULL, amount INTEGER NOT NULL, description TEXT, isExpense TEXT)",
    );
    await db.insert("ACCOUNTS", {"name": "cash"});
    await db.insert("CATEGORIES", {"name": "expense"});
    await db.insert("CATEGORIES", {"name": "income"});
  }

  static Future<int> addGroup(Group group) async {
    final db = await _getDB();
    return await db.insert("GROUPS", group.toJson());
  }

  static Future<int> updateGroup(Group group) async {
    final db = await _getDB();
    return await db.update(
      "GROUPS",
      group.toJson(),
      where: 'id = ?',
      whereArgs: [group.id],
    );
  }

  static Future<int> deleteGroup(String id) async {
    final db = await _getDB();
    return await db.delete("GROUPS", where: 'id = ?', whereArgs: [id]);
  }

  static Future<Group?>? getGroupByID(String id) async {
    final db = await _getDB();
    final List<Map<String, dynamic>> maps = await db.query(
      "GROUPS",
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      return null;
    }

    return Group.fromJson(maps[0]);
  }

  static Future<List<Group>?> getAllGroups() async {
    final db = await _getDB();
    final List<Map<String, dynamic>> maps = await db.query("GROUPS");

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(maps.length, (index) => Group.fromJson(maps[index]));
  }

  static Future<int?> getGroupIdFromTitle(String title) async {
    final db = await _getDB();
    final List<Map<String, dynamic>> maps = await db.query(
      "GROUPS",
      where: 'title = ?',
      whereArgs: [title],
    );

    if (maps.isEmpty) {
      return null;
    }

    return Group.fromJson(maps[0]).id;
  }

  static Future<int> addExpense(Expense expense) async {
    final db = await _getDB();
    return await db.insert("Expenses", expense.toJson());
  }

  static Future<int> updateExpense(Expense expense) async {
    final db = await _getDB();
    return await db.update(
      "EXPENSES",
      expense.toJson(),
      where: 'tid = ?',
      whereArgs: [expense.tid],
    );
  }

  static Future<int> deleteExpense(String tid) async {
    final db = await _getDB();
    return await db.delete("EXPENSES", where: 'tid = ?', whereArgs: [tid]);
  }

  static Future<Expense?> getExpenseByID(String tid) async {
    final db = await _getDB();
    final List<Map<String, dynamic>> maps = await db.query(
      "EXPENSES",
      where: 'tid = ?',
      whereArgs: [tid],
    );

    if (maps.isEmpty) {
      return null;
    }

    return Expense.fromJson(maps[0]);
  }

  static Future<List<Expense>?> getAllExpenses() async {
    final db = await _getDB();
    final List<Map<String, dynamic>> maps = await db.query("EXPENSES");

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(maps.length, (index) => Expense.fromJson(maps[index]));
  }

  static Future<List<Expense>?> getExpensesFromGid(String gid) async {
    final db = await _getDB();
    final List<Map<String, dynamic>> maps = await db.query(
      "EXPENSES",
      where: 'gid = ?',
      whereArgs: [gid],
    );

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(maps.length, (index) => Expense.fromJson(maps[index]));
  }

  static Future<int?> getExpenseIdFromTitle(String tname) async {
    final db = await _getDB();
    final List<Map<String, dynamic>> maps = await db.query(
      "EXPENSES",
      where: 'tname = ?',
      whereArgs: [tname],
    );

    if (maps.isEmpty) {
      return null;
    }

    return Group.fromJson(maps[0]).id;
  }

  static Future<int> addAccount(String name) async {
    final db = await _getDB();
    return await db.insert("ACCOUNTS", {"name": name});
  }

  static Future<int> deleteAllAccount() async {
    final db = await _getDB();
    return await db.delete("ACCOUNTS");
  }

  static Future<List<String>?> getAccounts() async {
    final db = await _getDB();
    final List<Map<String, dynamic>> maps = await db.query("ACCOUNTS");

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(maps.length, (index) => maps[index]['name']);
  }

  static Future<int> addCategory(String name) async {
    final db = await _getDB();
    return await db.insert("CATEGORIES", {"name": name});
  }

  static Future<int> deleteAllCategories() async {
    final db = await _getDB();
    return await db.delete("CATEGORIES");
  }

  static Future<List<String>?> getCategories() async {
    final db = await _getDB();
    final List<Map<String, dynamic>> maps = await db.query("CATEGORIES");

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(maps.length, (index) => maps[index]['name']);
  }

  static Future<int> addTransaction(TransactionModel transaction) async {
    final db = await _getDB();
    print(transaction.date);
    print("working");
    return await db.insert("TRANSACTIONS", transaction.toJson());
  }

  static Future<int> deleteTransaction(TransactionModel transaction) async {
    final db = await _getDB();
    return await db.delete(
      "TRANSACTIONS",
      where: 'name = ? AND account = ? AND category = ? AND amount = ?',
      whereArgs: [
        transaction.name,
        transaction.account,
        transaction.category,
        transaction.amount,
      ],
    );
  }

  static Future<List<TransactionModel>?> getAllTransactions() async {
    final db = await _getDB();
    final List<Map<String, dynamic>> maps = await db.query("TRANSACTIONS");

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(
      maps.length,
      (index) => TransactionModel.fromJson(maps[index]),
    );
  }

  static Future<List<TransactionModel>?> getTransactionByMonth(
    int month,
  ) async {
    final db = await _getDB();
    final List<Map<String, dynamic>> maps = await db.query("TRANSACTIONS");
    List<Map<String, dynamic>> sortedMaps = [];

    if (maps.isEmpty) {
      return [];
    }

    print("Raw Database");
    for (Map<String, dynamic> data in maps) {
      if (data['date'].toString().split(":")[0].split("-")[1] == "$month") {
        sortedMaps.add(data);
      }
    }
    print(sortedMaps);
    print("Raw Database");

    return List.generate(
      sortedMaps.length,
      (index) => TransactionModel.fromJson(maps[index]),
    );
  }

  static Future<int> getTotalExpenseAmount(int year, int month) async {
    final db = await _getDB();
    int sum;

    String formattedMonth = month < 10
        ? '0$month'
        : '$month'; // Ensure leading zero for single-digit months

    final List<Map<String, dynamic>> result = await db.rawQuery(
      "SELECT SUM(amount) as total FROM TRANSACTIONS WHERE isExpense='true' AND strftime('%Y-%m', date) = '$year-$formattedMonth'",
    );
    await db.close();

    try {
      sum = result[0]['total'] ?? 0;
    } catch (e) {
      sum = 0;
    }

    return sum;
  }

  static Future<int> getTotalIncomeAmount(int year, int month) async {
    final db = await _getDB();
    int sum;

    String formattedMonth = month < 10
        ? '0$month'
        : '$month'; // Ensure leading zero for single-digit months

    final List<Map<String, dynamic>> result = await db.rawQuery(
      "SELECT SUM(amount) as total FROM TRANSACTIONS WHERE isExpense='false' AND strftime('%Y-%m', date) = '$year-$formattedMonth'",
    );
    await db.close();

    try {
      sum = result[0]['total'] ?? 0;
    } catch (e) {
      sum = 0;
    }

    return sum;
  }

  static Future<List<Map<String, dynamic>>> getStatistics(DateTime date) async {
    final db = await _getDB();
    String formattedMonth = date.month.toString().padLeft(2, '0');
    final List<Map<String, dynamic>> result = await db.rawQuery(
      "SELECT category, SUM(amount) AS total_amount FROM TRANSACTIONS WHERE strftime('%Y-%m', date) = '${date.year}-$formattedMonth' AND isExpense = 'true' GROUP BY category",
    );
    print(result);
    return result;
  }

  static Future<List<TransactionModel>> getExpensesByMonth(DateTime date) async {
    final db = await _getDB();
    String formattedMonth = date.month.toString().padLeft(2, '0');
    final List<Map<String, dynamic>> result = await db.rawQuery(
      "SELECT * FROM TRANSACTIONS WHERE strftime('%Y-%m', date) = '${date.year}-$formattedMonth' AND isExpense = 'true' ORDER BY date DESC",
    );
    return result.map((item) => TransactionModel.fromJson(item)).toList();
  }

  static Future<void> clearData() async {
    final db = await _getDB();

    // Begin a transaction to ensure database consistency
    await db.transaction((txn) async {
      await txn.execute('DROP TABLE IF EXISTS GROUPS');
      await txn.execute('DROP TABLE IF EXISTS EXPENSES');
      await txn.execute('DROP TABLE IF EXISTS ACCOUNTS');
      await txn.execute('DROP TABLE IF EXISTS CATEGORIES');
      await txn.execute('DROP TABLE IF EXISTS TRANSACTIONS');
    });

    await db.transaction((txn) async {
      await txn.execute(
        "CREATE TABLE GROUPS(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, description TEXT, participants TEXT NOT NULL)",
      );
      await txn.execute(
        "CREATE TABLE EXPENSES(gid INTEGER, tid INTEGER PRIMARY KEY AUTOINCREMENT, tname TEXT NOT NULL, payername TEXT NOT NULL, amount INTEGER, date TEXT NOT NULL, borrowers TEXT NOT NULL, borrowedamt TEXT NOT NULL)",
      );
      await txn.execute("CREATE TABLE ACCOUNTS(name TEXT NOT NULL)");
      await txn.execute("CREATE TABLE CATEGORIES(name TEXT NOT NULL)");
      await txn.execute(
        "CREATE TABLE TRANSACTIONS(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, date TEXT NOT NULL, account TEXT NOT NULL, category TEXT NOT NULL, amount INTEGER NOT NULL, description TEXT, isExpense TEXT)",
      );
    });

    await db.insert("ACCOUNTS", {"name": "cash"});
    await db.insert("CATEGORIES", {"name": "expense"});
    await db.insert("CATEGORIES", {"name": "income"});
    await db.close();
  }
}

Future<void> copyBinaryFile(
  String sourceFilePath,
  String destinationFilePath,
) async {
  final File sourceFile = File(sourceFilePath);
  final File destinationFile = File(destinationFilePath);

  if (await sourceFile.exists()) {
    IOSink destinationSink;
    destinationSink = destinationFile.openWrite();

    try {
      final sourceStream = sourceFile.openRead();
      await sourceStream.pipe(destinationSink).whenComplete(() {
        destinationSink.close();
        print('File copied successfully.');
        print(destinationFilePath);
      });
    } catch (e) {
      print('Error copying file: $e');
      destinationSink.close();
    }
  } else {
    print('Source file does not exist.');
  }
}

Future<void> exportDatabase() async {
  try {
    String fileName = getBackupName();
    const downloadsFolderPath =
        "/storage/emulated/0/Documents/money_manager/backups"; //downloadsDirectory?.path;

    await Directory(downloadsFolderPath).create(recursive: true);

    print(downloadsFolderPath);

    final sourceFilePath = join(await getDatabasesPath(), _dbName);
    String destinationFilePath = '$downloadsFolderPath/$fileName';

    copyBinaryFile(sourceFilePath, destinationFilePath);

    print('File created and data written');
  } catch (e) {
    print('Error creating and writing to the file: $e');
  }
}

Future<void> importDatabase(
  String backupFilePath,
  Function onSuccess,
  Function onFailure,
) async {
  final destinationFilePath = join(await getDatabasesPath(), _dbName);
  if (backupFilePath.endsWith("db")) {
    copyBinaryFile(backupFilePath, destinationFilePath);
    onSuccess();
  } else {
    onFailure();
  }
  print(backupFilePath);
  print(destinationFilePath);
  //copyBinaryFile(backupFilePath, destinationFilePath);
}
