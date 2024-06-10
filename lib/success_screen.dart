import 'package:flutter/material.dart';

class SuccessScreen extends StatelessWidget {
  final List<Map<String, dynamic>> minTPeriods;
  final List<Map<String, dynamic>> maxTPeriods;
  final String cityName;

  const SuccessScreen({
    super.key,
    required this.minTPeriods,
    required this.maxTPeriods,
    required this.cityName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('城市: $cityName'),
        SizedBox(height: 15),
        Expanded(
          child: ListView(
            children: [
              const Text('最近三個時間區段的最低溫度和時間：'),
              ...minTPeriods.map((period) => ListTile(
                    title: Text('${period['startTime']} ~ ${period['endTime']}'),
                    subtitle: Text('${period['temperature']}°C'),
                  )),
              const Text('最近三個時間區段的最高溫度和時間：'),
              ...maxTPeriods.map((period) => ListTile(
                    title: Text('${period['startTime']} ~ ${period['endTime']}'),
                    subtitle: Text('${period['temperature']}°C'),
                  )),
            ],
          ),
        ),
      ],
    );
  }
}
