import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homework/city_provider.dart';
import 'package:homework/fail_screen.dart';
import 'package:homework/initial_screen.dart';
import 'package:homework/loading_screen.dart';
import 'package:homework/success_screen.dart';

class Temperature extends ConsumerStatefulWidget {
  const Temperature({super.key});

  @override
  ConsumerState<Temperature> createState() => _TemperatureState();
}

class _TemperatureState extends ConsumerState<Temperature> {
  final formKey = GlobalKey<FormState>();
  final dio = Dio();
  List<Map<String, dynamic>> minTPeriods = [];
  List<Map<String, dynamic>> maxTPeriods = [];
  CurrentState currentState = CurrentState.initial;
  final confirmedCityNameProvider = StateProvider<String>((ref) => '');

  String? validateInput(String? value) {
    if (value == null || value.isEmpty) {
      return '請輸入文字';
    }

    final regex = RegExp(r'[\u4e00-\u9fa5]');
    if (!regex.hasMatch(value)) {
      return '請輸入中文字';
    }

    return null;
  }

  Future<void> getHttp(String cityName) async {
    minTPeriods.clear();
    maxTPeriods.clear();
    try {
      setState(() {
        currentState = CurrentState.loading;
      });

      final response = await dio.get(
        'https://opendata.cwa.gov.tw/api/v1/rest/datastore/F-C0032-001?Authorization=CWA-A1616A82-2072-4EC4-AA45-2D6BA165D58C&elementName=MinT,MaxT&sort=time',
        queryParameters: {
          'locationName': cityName,
        },
      );

      final location = response.data['records']['location']
          .firstWhere((loc) => loc['locationName'] == cityName);
      final weatherElements = location['weatherElement'];

      for (var element in weatherElements) {
        if (element['elementName'] == 'MinT') {
          for (var time in element['time']) {
            minTPeriods.add({
              'startTime': time['startTime'],
              'endTime': time['endTime'],
              'temperature': time['parameter']['parameterName'],
            });
          }
        } else if (element['elementName'] == 'MaxT') {
          for (var time in element['time']) {
            maxTPeriods.add({
              'startTime': time['startTime'],
              'endTime': time['endTime'],
              'temperature': time['parameter']['parameterName'],
            });
          }
        }
      }
      setState(() {
        currentState = CurrentState.success;
      });
    } catch (e) {
      print('獲取數據時出錯：$e');
      setState(() {
        currentState = CurrentState.fail;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cityName = ref.watch(cityNameProvider);

    return Scaffold(
      backgroundColor: Colors.white70,
      body: SafeArea(
        child: Column(
          children: [
            Form(
              key: formKey,
              child: Row(
                children: [
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        filled: true,
                        hintText: "請輸入城市名稱",
                      ),
                      validator: validateInput,
                      onChanged: (value) => ref
                          .read(cityNameProvider.notifier)
                          .updateCityName(value),
                    ),
                  ),
                  const SizedBox(width: 15),
                  TextButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        ref.read(confirmedCityNameProvider.notifier).state =
                            cityName;

                        getHttp(cityName);
                      }
                    },
                    child: const Text('確認'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  color: Colors.white,
                  width: double.infinity,
                  height: double.infinity,
                  child: switch (currentState) {
                    CurrentState.initial => const InitialScreen(),
                    CurrentState.loading => const LoadingScreen(),
                    CurrentState.success => SuccessScreen(
                        minTPeriods: minTPeriods,
                        maxTPeriods: maxTPeriods,
                                              cityName: ref.watch(confirmedCityNameProvider),

                      ),
                    CurrentState.fail => const FailScreen(),
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum CurrentState {
  initial,
  loading,
  success,
  fail,
}
