import 'dart:async' show Future, Timer;

import 'package:bloc/bloc.dart' show Bloc, Emitter;
import 'package:equatable/equatable.dart' show Equatable;
import 'package:intl/intl.dart' show DateFormat;

part 'clock_event.dart';
part 'clock_state.dart';

class ClockBloc extends Bloc<ClockBlocEvent, ClockBlocState> {
  ClockBloc({String pattern = 'EEE dd MMM yyyy HH:mm'})
    : _pattern = pattern,
      super(
        ClockBlocState.set(DateFormat(pattern).format(DateTime.now())),
      ) {
    on<_ClockStatusChanged>(_onClockStatusChanged);
    on<ClockSetPatternRequest>(_onClockSetPatternRequest);

    _timer = Timer.periodic(
      _pattern.contains('SSS')
          ? const Duration(milliseconds: 1)
          : const Duration(seconds: 1),
      (_) => add(_ClockStatusChanged(DateTime.now())),
    );
  }

  late final Timer _timer;

  String _pattern;

  @override
  Future<void> close() {
    _timer.cancel();
    return super.close();
  }

  Future<void> _onClockSetPatternRequest(
    ClockSetPatternRequest event,
    Emitter<ClockBlocState> emit,
  ) async {
    _pattern = event.pattern;

    final date = DateFormat(_pattern).format(DateTime.now());
    return emit(ClockBlocState.set(date));
  }

  Future<void> _onClockStatusChanged(
    _ClockStatusChanged event,
    Emitter<ClockBlocState> emit,
  ) async {
    final date = DateFormat(_pattern).format(event.now);
    return emit(ClockBlocState.set(date));
  }
}
