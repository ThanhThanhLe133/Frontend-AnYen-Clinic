import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

const Color secondaryColor = Colors.grey;
const double defaultPadding = 16.0;

class RadialBarChart extends ConsumerStatefulWidget {
  const RadialBarChart({
    super.key,
    required this.screenWidth,
    required this.happyDiaries,
    required this.relaxDiaries,
    required this.sadDiaries,
    required this.stressDiaries,
    required this.month,
    required this.year,
  });
  final double screenWidth;
  final int happyDiaries;
  final int relaxDiaries;
  final int sadDiaries;
  final int stressDiaries;
  final int month;
  final int year;

  @override
  ConsumerState<RadialBarChart> createState() => _RadialBarChartState();
}

class _RadialBarChartState extends ConsumerState<RadialBarChart> {
  final Map<String, Color> labels = {
    'Vui vẻ': const Color.fromARGB(255, 60, 23, 181),
    'Thoải mái': const Color.fromARGB(255, 23, 181, 63),
    'Buồn': const Color(0xFFB5179E),
    'Căng thẳng': const Color(0xFFFFC300),
  };

  final today = DateTime.now();
  late double stressAngle;
  late double sadAngle;
  late double relaxAngle;
  late double happyAngle;

  late double sadPercent;
  late double relaxPercent;
  late double happyPercent;
  late double stressPercent;

  late int percentDaysPassed;
  @override
  void initState() {
    super.initState();
    updateData();
  }

  @override
  void didUpdateWidget(covariant RadialBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.month != widget.month ||
        oldWidget.year != widget.year ||
        oldWidget.happyDiaries != widget.happyDiaries ||
        oldWidget.relaxDiaries != widget.relaxDiaries ||
        oldWidget.sadDiaries != widget.sadDiaries ||
        oldWidget.stressDiaries != widget.stressDiaries) {
      updateData();
    }
  }

  void updateData() {
    final today = DateTime.now();
    final totalDaysInMonth = DateTime(widget.year, widget.month + 1, 0).day;

    int daysPassed;
    if (widget.year > today.year ||
        (widget.year == today.year && widget.month > today.month)) {
      daysPassed = 0;
    } else if (widget.year == today.year && widget.month == today.month) {
      daysPassed = today.day;
    } else {
      daysPassed = totalDaysInMonth;
    }

    percentDaysPassed = ((daysPassed / totalDaysInMonth) * 100).round();

    final total = (widget.happyDiaries +
        widget.relaxDiaries +
        widget.sadDiaries +
        widget.stressDiaries);

    happyPercent = total > 0 ? widget.happyDiaries / total : 0;
    relaxPercent = total > 0 ? widget.relaxDiaries / total : 0;
    sadPercent = total > 0 ? widget.sadDiaries / total : 0;
    stressPercent = total > 0 ? widget.stressDiaries / total : 0;
    happyAngle = happyPercent * 360;
    relaxAngle = relaxPercent * 360;
    sadAngle = sadPercent * 360;
    stressAngle = stressPercent * 360;
  }

  @override
  Widget build(BuildContext context) {
    double start = 0;

    return Padding(
      padding: EdgeInsets.all(widget.screenWidth * 0.05),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: SizedBox(
              height: widget.screenWidth * 0.5,
              child: SfRadialGauge(
                axes: <RadialAxis>[
                  RadialAxis(
                    minimum: 0,
                    maximum: 100,
                    labelOffset: 0,
                    pointers: [
                      RangePointer(
                        value: percentDaysPassed.toDouble(),
                        cornerStyle: CornerStyle.bothCurve,
                        width: widget.screenWidth * 0.08,
                        color: Colors.transparent,
                      ),
                    ],
                    axisLineStyle: AxisLineStyle(
                      thickness: widget.screenWidth * 0.08,
                      color: Colors.grey.withOpacity(0.2),
                    ),
                    startAngle: 0,
                    endAngle: 360,
                    showTicks: false,
                    showLabels: false,
                    annotations: [
                      GaugeAnnotation(
                        widget: Text(
                          '${percentDaysPassed.round()}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: widget.screenWidth * 0.04,
                            color: Colors.grey,
                          ),
                        ),
                        positionFactor: 0,
                      ),
                    ],
                  ),

// Happy
                  if (happyPercent > 0)
                    RadialAxis(
                      startAngle: 0,
                      endAngle: happyAngle,
                      showAxisLine: false,
                      showTicks: false,
                      showLabels: false,
                      pointers: [
                        RangePointer(
                          value: 100,
                          color: const Color(0xFF3C17B5),
                          width: widget.screenWidth * 0.08,
                        )
                      ],
                    ),

// Relax
                  if (relaxPercent > 0)
                    RadialAxis(
                      startAngle: happyAngle,
                      endAngle: happyAngle + relaxAngle,
                      showAxisLine: false,
                      showTicks: false,
                      showLabels: false,
                      pointers: [
                        RangePointer(
                          value: 100,
                          color: const Color(0xFF17B53F),
                          width: widget.screenWidth * 0.08,
                        )
                      ],
                    ),

// Sad
                  if (sadPercent > 0)
                    RadialAxis(
                      startAngle: happyAngle + relaxAngle,
                      endAngle: happyAngle + relaxAngle + sadAngle,
                      showAxisLine: false,
                      showTicks: false,
                      showLabels: false,
                      pointers: [
                        RangePointer(
                          value: 100,
                          color: const Color(0xFFFFC300),
                          width: widget.screenWidth * 0.08,
                        )
                      ],
                    ),

// Stress
                  if (stressPercent > 0)
                    RadialAxis(
                      startAngle: happyAngle + relaxAngle + sadAngle,
                      endAngle:
                          happyAngle + relaxAngle + sadAngle + stressAngle,
                      showAxisLine: false,
                      showTicks: false,
                      showLabels: false,
                      pointers: [
                        RangePointer(
                          value: 100,
                          color: const Color(0xFFB5179E),
                          width: widget.screenWidth * 0.08,
                        )
                      ],
                    ),
                ],
              ),
            ),
          ),
          SizedBox(width: defaultPadding),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: widget.screenWidth * 0.3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: labels.entries.map((entry) {
                  return Row(
                    children: [
                      Container(
                        width: widget.screenWidth * 0.04,
                        height: widget.screenWidth * 0.04,
                        decoration: BoxDecoration(
                          color: entry.value,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: widget.screenWidth * 0.04,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
