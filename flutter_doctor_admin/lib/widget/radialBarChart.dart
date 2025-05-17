import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

const Color secondaryColor = Colors.grey;
const double defaultPadding = 16.0;

class RadialBarChart extends StatefulWidget {
  const RadialBarChart({
    super.key,
    required this.screenWidth,
    required this.connectingAppointment,
    required this.waitingAppointment,
    required this.month,
    required this.year,
  });
  final double screenWidth;
  final int connectingAppointment;
  final int waitingAppointment;
  final int month;
  final int year;

  @override
  State<RadialBarChart> createState() => _RadialBarChartState();
}

class _RadialBarChartState extends State<RadialBarChart> {
  @override
  Widget build(BuildContext context) {
    final Map<String, Color> labels = {
      'Online': Color(0xFF119CF0),
      'Trực tiếp': Color(0xFFDB5B8B),
    };
    final today = DateTime.now();

    // Tổng số ngày của tháng được truyền vào
    final totalDaysInMonth = DateTime(widget.year, widget.month + 1, 0).day;

    // Nếu là tháng hiện tại => tính theo số ngày thực sự đã qua
    final daysPassed =
        (today.month == widget.month && today.year == widget.year)
            ? today.day
            : totalDaysInMonth;

    final percentDaysPassed = (daysPassed / totalDaysInMonth * 100).round();

    final total =
        (widget.connectingAppointment + widget.waitingAppointment).toDouble();
    final connectingPercent =
        (total > 0 ? (widget.connectingAppointment / total) : 0).toDouble();
    final waitingPercent =
        (total > 0 ? (widget.waitingAppointment / total) : 0).toDouble();

    final connectingAngle = connectingPercent * 360;
    final waitingAngle = waitingPercent * 360;

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
              child: SizedBox(
                child: SfRadialGauge(
                  axes: <RadialAxis>[
                    RadialAxis(
                      labelOffset: 0,
                      pointers: [
                        RangePointer(
                          value: 20,
                          cornerStyle: CornerStyle.bothCurve,
                          width: widget.screenWidth * 0.08,
                        ),
                      ],
                      axisLineStyle: AxisLineStyle(
                        thickness: widget.screenWidth * 0.08,
                      ),
                      startAngle: 0,
                      endAngle: 360,
                      showTicks: false,
                      showLabels: false,
                      annotations: [
                        GaugeAnnotation(
                          widget: Text(
                            '$percentDaysPassed%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: widget.screenWidth * 0.04,
                              color: Colors.grey,
                            ),
                          ),
                          positionFactor: 0.2,
                        ),
                      ],
                    ),
                    RadialAxis(
                      pointers: [
                        RangePointer(
                          value: 20,
                          color: Color(0xFF119CF0),
                          width: widget.screenWidth * 0.08,
                        ),
                      ],
                      startAngle: 0,
                      endAngle: connectingAngle,
                      showAxisLine: false,
                      showTicks: false,
                      showLabels: false,
                    ),
                    RadialAxis(
                      pointers: [
                        RangePointer(
                          value: 30,
                          color: Color(0xFFDB5B8B),
                          width: widget.screenWidth * 0.08,
                        ),
                      ],
                      startAngle: connectingAngle,
                      endAngle: connectingAngle + waitingAngle,
                      showAxisLine: false,
                      showTicks: false,
                      showLabels: false,
                    ),
                  ],
                ),
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
                children:
                    labels.entries.map((entry) {
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
