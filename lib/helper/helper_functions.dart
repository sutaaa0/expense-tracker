import 'package:intl/intl.dart';


// conver string to double
double convertStringToDouble(String string) {
  double? amount = double.tryParse(string);

  return amount ?? 0;
}

// fotmat to dollar
String formatAmount(double amount) {
  final format = NumberFormat.currency(locale: "id_ID", symbol: "Rp", decimalDigits: 2);

  return format.format(amount);

}

// calculate the number of month
int calculateMonthCount(int startYear,  startMonth,  currentYear, currentMonth) {
    int monthCount = (currentYear - startYear) * 12 + currentMonth - startMonth + 1;

    return monthCount;
}

// get current month name
String getCurrentMonthName() {
  DateTime now = DateTime.now();
  List<String> month = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];
  return month[now.month - 1];
}