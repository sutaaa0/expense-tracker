import 'package:app/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class ExpenseDatabase extends ChangeNotifier {
  static late Isar isar;
  List<Expense> _allExpenses = [];


  // initialize the database
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([ExpenseSchema], directory: dir.path);
  }

  // GETTERS

  List<Expense> get allExpenses => _allExpenses;


  // OPERATIONS


  // ADD
  Future<void> createExpense(Expense newExpense) async {
    await isar.writeTxn(() => isar.expenses.put(newExpense));

    readExpense();
  }


  // DELETE
  Future<void> deleteExpense(int id) async {

    await isar.writeTxn(() => isar.expenses.delete(id));

    await readExpense();
  }


  // UPDATE
  Future<void> updateExpense(int id,Expense updatedExpense) async {

    updatedExpense.id = id;

    await isar.writeTxn(() => isar.expenses.put(updatedExpense));
 
    await readExpense();
  }


  // READ

  Future<void> readExpense() async {
    List<Expense> fetchedExpenses = await isar.expenses.where().findAll();

    _allExpenses.clear();
    _allExpenses.addAll(fetchedExpenses);

    // update UI
    notifyListeners();
  }


  // HELPER


// calculate
  Future<Map<String, double>> calculateMonthlyTotal() async {
    await readExpense();

    Map<String, double> monthlyTotal = {};

    for (var expense in _allExpenses) {
      String yearMonth = '${expense.date.year}-${expense.date.month}';

      if(!monthlyTotal.containsKey(yearMonth)) {
        monthlyTotal[yearMonth] = 0;
      }

      monthlyTotal[yearMonth] = monthlyTotal[yearMonth]! + expense.amount;
    }

    print("total : $monthlyTotal");
    return monthlyTotal;

  }

  int getStartMonth() {
    if (_allExpenses.isEmpty) {
      return DateTime.now().month;
    }

    _allExpenses.sort(
      (a, b) => a.date.compareTo(b.date),
    );

    return _allExpenses.first.date.month;
  }

  int getStartYear() {
    if (_allExpenses.isEmpty) {
      return DateTime.now().year;
    }

    _allExpenses.sort(
      (a, b) => a.date.compareTo(b.date),
    );

    return _allExpenses.first.date.year;
  }


  // calculate current month total 
Future<double> calculateCurrentMonthTotal() async {
  await readExpense();  

  int currentMonth = DateTime.now().month;
  int currentYear = DateTime.now().year;

  List<Expense> currentMonthExpense = _allExpenses.where((expense) {
    return expense.date.year == currentYear && expense.date.month == currentMonth;
  }).toList();

  double total = currentMonthExpense.fold(0, (sum, expense) => sum + expense.amount);

  return total;
}


}
