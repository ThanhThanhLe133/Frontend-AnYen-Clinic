import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

const Color secondaryColor = Colors.grey;
const double defaultPadding = 16.0;

class RadialBarChart extends StatelessWidget {
  const RadialBarChart({super.key, required this.screenWidth});
  final double screenWidth;
  @override
  Widget build(BuildContext context) {
    final Map<String, Color> labels = {
      'Online': Color(0xFF119CF0),
      'Trực tiếp': Color(0xFFDB5B8B),
    };

    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.05),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: SizedBox(
              height: screenWidth * 0.5,
              child: SizedBox(
                child: SfRadialGauge(
                  axes: <RadialAxis>[
                    RadialAxis(
                      labelOffset: 0,
                      pointers: [
                        RangePointer(
                          value: 20,
                          cornerStyle: CornerStyle.bothCurve,
                          width: screenWidth * 0.08,
                        ),
                      ],
                      axisLineStyle: AxisLineStyle(
                        thickness: screenWidth * 0.08,
                      ),
                      startAngle: 0,
                      endAngle: 360,
                      showTicks: false,
                      showLabels: false,
                      annotations: [
                        GaugeAnnotation(
                          widget: Text(
                            '90%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.04,
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
                          width: screenWidth * 0.08,
                        ),
                      ],
                      startAngle: 0,
                      endAngle: 0,
                      showAxisLine: false,
                      showTicks: false,
                      showLabels: false,
                    ),
                    RadialAxis(
                      pointers: [
                        RangePointer(
                          value: 30,
                          color: Color(0xFFDB5B8B),
                          width: screenWidth * 0.08,
                        ),
                      ],
                      startAngle: 72,
                      endAngle: 72,
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
              height: screenWidth * 0.3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children:
                    labels.entries.map((entry) {
                      return Row(
                        children: [
                          Container(
                            width: screenWidth * 0.04,
                            height: screenWidth * 0.04,
                            decoration: BoxDecoration(
                              color: entry.value,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
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
