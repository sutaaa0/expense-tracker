// ignore_for_file: prefer_const_constructors

import 'package:app/bar%20graph/bargraph.dart';
import 'package:app/components/my_list_tile.dart';
import 'package:app/database/expense_database.dart';
import 'package:app/helper/helper_functions.dart';
import 'package:app/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  // load graph data
  Future<Map<String, double>>? _monthlyTotalsFuture;
  Future<double>? _calculateCurrentMonthTotal;


  @override
  void initState() {
    // initialized database
    Provider.of<ExpenseDatabase>(context, listen: false).readExpense();

    // load
    refraseData();



    
    super.initState();
  }

  // refrase graphh data
  void refraseData() {
    _monthlyTotalsFuture = Provider.of<ExpenseDatabase>(context, listen: false).calculateMonthlyTotal();
    _calculateCurrentMonthTotal = Provider.of<ExpenseDatabase>(context, listen: false).calculateCurrentMonthTotal();
  }


  void openNewExpenseBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add new expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: "Expense name"),
            ),

            TextField(
              controller: amountController,
              decoration: const InputDecoration(hintText: "Expense amount"),
            )
          ],
        ),
        actions: [
          _cancelButton(),
          _createNewExpenseButton(),
        ],
      )
      );
  }

  void openEditBox(Expense expense) {

    String existingName = expense.name;
    String existingAmount = expense.amount.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(hintText: existingName),
            ),

            TextField(
              controller: amountController,
              decoration: InputDecoration(hintText: existingAmount),
            )
          ],
        ),
        actions: [
          _cancelButton(),
          _editExpenseButton(expense),
        ],
      )
      );
  }

  void openDeleteBox(Expense expense) {
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit expense"),

        actions: [
          _cancelButton(),
          _deleteExpenseButton(expense.id),
        ],
      )
      );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(
      builder: (context, value, child) {

          int startMonth = value.getStartMonth();
          int startYear = value.getStartYear();
          int currentMonth = DateTime.now().month;
          int currentYear = DateTime.now().year;

          int monthCount = calculateMonthCount(startYear, startMonth, currentYear, currentMonth);

        List<Expense> currentMonthExpense = value.allExpenses.where((expense) {
          return expense.date.year == currentYear && expense.date.month == currentMonth;
        }).toList();

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: FutureBuilder(future: _calculateCurrentMonthTotal, builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Text("Rp${snapshot.data!.toStringAsFixed(2)}"),
                    Text(formatAmount(snapshot.data ?? 0.0)),

                    Text(getCurrentMonthName()),
                  ],
                );
              }
              else { 
                return const Text("Loading...");
              }
            }),
            centerTitle: true,
          ),
          backgroundColor: Colors.grey.shade300,
                floatingActionButton: FloatingActionButton(
        onPressed: openNewExpenseBox,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
        
            SizedBox(
              height: 250,
              child: FutureBuilder(
                future: _monthlyTotalsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    Map<String, double> mounthlyTotals = snapshot.data ?? {};
              
                    // create the list monthly summary
                    List<double> monthlySummary = List.generate(monthCount,
                      (index) {
                        int year = startYear + (startMonth + index - 1) ~/ 12;
                        int month = (startMonth + index - 1) % 12 + 1;

                        String yearMonthKey = '$year-$month';

                        return mounthlyTotals[yearMonthKey] ?? 0.0;
                      }
                    );
              
                    return MyBarGraph(
                      
                      monthlySummary: monthlySummary,
                      startMonth: startMonth
                    );
                  }
              
                  else {
                    return const Center(
                      child: Text("Loading..."),
                    );
              
                  }
                } 
              ),
            ),
            
            const SizedBox(height: 25),
          Expanded(
            child: ListView.builder(
            itemCount: currentMonthExpense.length,
            itemBuilder: (context, index) {
              int reversedIndex = currentMonthExpense.length - 1 - index;
            
              Expense individualExpense = currentMonthExpense[index];
            
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: MyListTile(
                  
                  title: individualExpense.name,
                  trailing: formatAmount(individualExpense.amount),
                  onEditPressed: (context) => openEditBox(individualExpense),
                  onDeletePressed: (context) => openDeleteBox(individualExpense),
                ),
              );
            },
                  ),
          ),
          ],
        ),
      )
        );
      },
    );
}

  // calcel button
  Widget _cancelButton() {
    return MaterialButton(
      onPressed: () {
        // pop box
        Navigator.pop(context);
      
      // clear controller
      nameController.clear();
      amountController.clear();

      },
      child: const Text("Cancel"),
    );
  }

  Widget _createNewExpenseButton() {
    return MaterialButton(
      onPressed: () async {

        if(nameController.text.isNotEmpty && amountController.text.isNotEmpty) {

          Navigator.pop(context);

          Expense newExpense = Expense(
            name: nameController.text,
            amount: convertStringToDouble(amountController.text),
            date: DateTime.now(),
          );

          await context.read<ExpenseDatabase>().createExpense(newExpense);

          // refresh graph
          refraseData();

          nameController.clear();
          amountController.clear();

        }
        

      },
      child: const Text("Save"),
    );
  }
  Widget _editExpenseButton(Expense expense) {
    return MaterialButton(
      onPressed: () async {
        if(nameController.text.isNotEmpty && amountController.text.isNotEmpty) {
          Navigator.pop(context);

          Expense updatedExpense = Expense(
            name: nameController.text.isNotEmpty 
            ? nameController.text
            : expense.name,
            amount: amountController.text.isNotEmpty
            ? convertStringToDouble(amountController.text)
            : expense.amount,
            date: DateTime.now(),
          );

          int exsitingId = expense.id;

          await context.read<ExpenseDatabase>()
          .updateExpense(exsitingId, updatedExpense);

          nameController.clear();
          amountController.clear();

            // refresh graph
          refraseData();

        }
      },
      child: const Text("Edit"),
    );
}

Widget _deleteExpenseButton(int id) {
  return MaterialButton(
    onPressed: () async {
      Navigator.pop(context);
      await context.read<ExpenseDatabase>().deleteExpense(id);

        // refresh graph
          refraseData();
    },
    child: const Text("Delete"),
  );
}

}
