import 'package:ayclinic_doctor_admin/Provider/historyConsultProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

const Color secondaryColor = Colors.grey;
const double defaultPadding = 16.0;

class RadialBarChart extends ConsumerStatefulWidget {
  const RadialBarChart({
    super.key,
    required this.screenWidth,
    required this.onlineAppointment,
    required this.offlineAppointment,
    required this.month,
    required this.year,
  });
  final double screenWidth;
  final int onlineAppointment;
  final int offlineAppointment;
  final int month;
  final int year;

  @override
  ConsumerState<RadialBarChart> createState() => _RadialBarChartState();
}

class _RadialBarChartState extends ConsumerState<RadialBarChart> {
  final Map<String, Color> labels = {
    'Online': Color(0xFF119CF0),
    'Trực tiếp': Color(0xFFDB5B8B),
  };
  final today = DateTime.now();
  late double onlineAngle;
  late double offlineAngle;
  late double onlinePercent;
  late double offlinePercent;
  late int percentDaysPassed;

  @override
  void didUpdateWidget(covariant RadialBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.month != widget.month ||
        oldWidget.year != widget.year ||
        oldWidget.onlineAppointment != widget.onlineAppointment ||
        oldWidget.offlineAppointment != widget.offlineAppointment) {
      updateData();
    }
  }

  void updateData() {
    // Tổng số ngày của tháng được truyền vào
    final totalDaysInMonth = DateTime(widget.year, widget.month + 1, 0).day;

    int daysPassed;
    if (widget.year > today.year ||
        (widget.year == today.year && widget.month > today.month)) {
      // Tháng tương lai
      daysPassed = 0;
    } else if (widget.year == today.year && widget.month == today.month) {
      // Tháng hiện tại
      daysPassed = today.day;
    } else {
      // Tháng quá khứ
      daysPassed = totalDaysInMonth;
    }
    percentDaysPassed = ((daysPassed / totalDaysInMonth) * 100).round();
    final total =
        (widget.offlineAppointment + widget.onlineAppointment).toDouble();
    onlinePercent = total > 0 ? widget.onlineAppointment / total : 0;
    offlinePercent = total > 0 ? widget.offlineAppointment / total : 0;

    onlineAngle = onlinePercent * 360;
    offlineAngle = offlinePercent * 360;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    updateData();
  }

  @override
  Widget build(BuildContext context) {
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
                  // Nền số ngày đã qua
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
                        positionFactor: 0.2,
                      ),
                    ],
                  ),

                  // Online
                  if (onlinePercent > 0)
                    RadialAxis(
                      startAngle: 0,
                      endAngle: onlineAngle,
                      showAxisLine: false,
                      showTicks: false,
                      showLabels: false,
                      pointers: [
                        RangePointer(
                          value: 100,
                          color: Color(0xFF119CF0),
                          width: widget.screenWidth * 0.08,
                        ),
                      ],
                    ),

                  // Offline
                  if (offlinePercent > 0)
                    RadialAxis(
                      startAngle: onlineAngle,
                      endAngle: onlineAngle + offlineAngle,
                      showAxisLine: false,
                      showTicks: false,
                      showLabels: false,
                      pointers: [
                        RangePointer(
                          value: 100,
                          color: Color(0xFFDB5B8B),
                          width: widget.screenWidth * 0.08,
                        ),
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
