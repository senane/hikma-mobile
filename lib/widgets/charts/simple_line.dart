import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class SimpleLineChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  SimpleLineChart(this.seriesList, {this.animate});

  factory SimpleLineChart.withDummyData() {
    return new SimpleLineChart(_createSampleData());
  }

  @override
  Widget build(BuildContext context) {
    return new charts.LineChart(
      seriesList,
      animate: animate,
      behaviors: [
        charts.ChartTitle(
          'Height Trends Prediction',
          behaviorPosition: charts.BehaviorPosition.top,
          titleOutsideJustification: charts.OutsideJustification.middle,
          innerPadding: 18,
        ),
        charts.ChartTitle(
          'Age (years)',
          behaviorPosition: charts.BehaviorPosition.bottom,
          titleOutsideJustification: charts.OutsideJustification.middle,
          titleStyleSpec: charts.TextStyleSpec(
              fontSize: 16,
              fontFamily: 'sans-serif-condensed'
          ),
        ),
        charts.ChartTitle(
          'Height (centimeters)',
          behaviorPosition: charts.BehaviorPosition.start,
          titleOutsideJustification: charts.OutsideJustification.middle,
          titleStyleSpec: charts.TextStyleSpec(
              fontSize: 16,
              fontFamily: 'sans-serif-condensed'
          ),
        ),
      ],
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<LinearHeight, int>> _createSampleData() {
    final data = [
      new LinearHeight(0, 60),
      new LinearHeight(1, 85),
      new LinearHeight(3, 110),
      new LinearHeight(10, 150),
      new LinearHeight(12, 160),
      new LinearHeight(15, 175),
      new LinearHeight(16, 180),
      new LinearHeight(18, 187),
      new LinearHeight(21, 194),
    ];

    return [
      new charts.Series<LinearHeight, int>(
        id: 'Height',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (LinearHeight heightData, _) => heightData.year,
        measureFn: (LinearHeight heightData, _) => heightData.height,
        data: data,
      )
    ];
  }
}

/// Sample linear data type.
class LinearHeight {
  final int year;
  final int height;
  LinearHeight(this.year, this.height);
}
