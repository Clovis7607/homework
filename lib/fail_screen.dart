import 'package:flutter/material.dart';

class FailScreen extends StatelessWidget {
  const FailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('獲取數據時出錯，請重試'),
    );
  }
}
