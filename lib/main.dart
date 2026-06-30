import 'package:flgreet/src/presentation/app_view.dart' show AppView;
import 'package:flutter/material.dart';

void main() => runApp(const FlGreet());

class FlGreet extends StatelessWidget {
  const FlGreet({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppView();
  }
}
