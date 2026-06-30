import 'package:flgreet/src/domain/clock/bloc/clock_bloc.dart' show ClockBloc;
import 'package:flgreet/src/domain/clock/clock.dart' show ClockBlocState;
import 'package:flutter/material.dart'
    show
        BuildContext,
        Center,
        LayoutBuilder,
        StatelessWidget,
        Text,
        TextStyle,
        Widget;
import 'package:flutter_bloc/flutter_bloc.dart' show BlocProvider, BlocSelector;

class ClockWidget extends StatelessWidget {
  const ClockWidget({super.key, this.pattern = 'HH:mm', this.style});
  final String pattern;
  final TextStyle? style;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ClockBloc(pattern: pattern),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return BlocSelector<ClockBloc, ClockBlocState, String>(
            selector: (state) {
              return state.date;
            },
            builder: (context, date) {
              return Center(child: Text(date, style: style));
            },
          );
        },
      ),
    );
  }
}
