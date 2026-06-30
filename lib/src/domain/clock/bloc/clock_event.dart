part of 'clock_bloc.dart';

sealed class ClockBlocEvent extends Equatable {
  const ClockBlocEvent();
}

final class _ClockStatusChanged extends ClockBlocEvent {
  const _ClockStatusChanged(this.now);
  final DateTime now;

  @override
  List<Object?> get props => [now];
}

final class ClockSetPatternRequest extends ClockBlocEvent {
  const ClockSetPatternRequest(this.pattern);
  final String pattern;

  @override
  List<Object?> get props => [pattern];
}
