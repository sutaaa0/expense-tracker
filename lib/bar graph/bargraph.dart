import 'package:app/bar%20graph/individual_bargraph.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyBarGraph extends StatefulWidget {
  final List<double> monthlySummary;
  final int startMonth;


  const MyBarGraph({super.key,
    required this.monthlySummary,
    required this.startMonth
  });

  @override
  State<MyBarGraph> createState() => _MyBarGraphState();
}

class _MyBarGraphState extends State<MyBarGraph> {
  List<IndividualBarGraph> barData = [];

  Widget getBottomTitles(double value, TitleMeta meta) {
    const textstyle = TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );

    // Menghitung bulan yang sebenarnya
    int actualMonth = (widget.startMonth + value.toInt() - 1) % 12;
    
    // Daftar nama bulan
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    // Mendapatkan nama bulan
    String text = months[actualMonth];

    // Menambahkan tahun jika lebih dari 12 bulan
    int year = (widget.startMonth + value.toInt() - 1) ~/ 12;
    if (year > 0) {
      text += '\n\'${(year + DateTime.now().year) % 100}';
    }

    return SideTitleWidget(
      child: Text(text, style: textstyle, textAlign: TextAlign.center),
      axisSide: meta.axisSide,
    );
  }

  void initializeBarData() {
    barData = List.generate(widget.monthlySummary.length,
      (index) => IndividualBarGraph(x: index, y: widget.monthlySummary[index]));
  }
    
  // calculate max for upper limit of graph
  double calculateMax() {
    double max = 500000;

    widget.monthlySummary.sort();

    max = widget.monthlySummary.last * 1.05;

    if(max < 500000) {
      return 500000;
    }

    return max;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      scrollToEnd();
    });
  }

  // scroll controller to make sure it scrolls to end latest month
  final ScrollController _scrollController = ScrollController();
  void scrollToEnd() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn
    );
  }



  @override
  Widget build(BuildContext context) {
    // initialize
    initializeBarData();

    // bar dimension
    double barWidth = 20;
    double spaceBetweenBar = 30;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: SizedBox(
          width: barWidth * barData.length + spaceBetweenBar * (barData.length - 1),
          child: BarChart(
            BarChartData(
              minY: 0,
              maxY: calculateMax(),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                show: true,
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: getBottomTitles,
                    reservedSize: 40,
                  )
                )
              ),
              barGroups: barData.map((data) => BarChartGroupData(
                x: data.x,
                barRods: [
                  BarChartRodData(
                    toY: data.y,
                    width: barWidth,
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.grey.shade800,
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: calculateMax(),
                      color: Colors.white
                    )
                  )
                ]
              )).toList(),
              alignment: BarChartAlignment.center,
              groupsSpace: spaceBetweenBar,
            )
          ),
        ),
      ),
    );
  }
// get bottom titles
// Widget getBottomTitles(double value, TitleMeta meta, int startMonth) {
//   const textstyle = TextStyle(
//     color: Colors.grey,
//     fontWeight: FontWeight.bold,
//     fontSize: 14,
//   );

//   // Menghitung bulan yang sebenarnya
//   int actualMonth = (startMonth + value.toInt() - 1) % 12;
  
//   // Daftar nama bulan
//   final months = [
//     'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
//     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
//   ];

//   // Mendapatkan nama bulan
//   String text = months[actualMonth];

//   // Menambahkan tahun jika lebih dari 12 bulan
//   int year = (startMonth + value.toInt() - 1) ~/ 12;
//   if (year > 0) {
//     text += '\n\'${(year + DateTime.now().year) % 100}';
//   }

//   return SideTitleWidget(
//     child: Text(text, style: textstyle, textAlign: TextAlign.center),
//     axisSide: meta.axisSide,
//   );
// }

}
