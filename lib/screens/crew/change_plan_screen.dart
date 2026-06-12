import 'package:flutter/material.dart';

class ChangePlanScreen extends StatelessWidget {
  const ChangePlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Plan'),
      ),
      body: const Center(
        child: Text(
          'Change Plan Coming Soon',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}