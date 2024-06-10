import 'package:flutter_riverpod/flutter_riverpod.dart';

class CityNotifier extends StateNotifier<String> {
  CityNotifier() : super('');

  void updateCityName(String newCityName) {
    state = newCityName;
  }
}

final cityNameProvider = StateNotifierProvider<CityNotifier, String>((ref) {
  return CityNotifier();
});
