part of 'clock_bloc.dart';

class ClockBlocState extends Equatable {
  const ClockBlocState._({
    required this.date,
  });

  const ClockBlocState.set(
    String date,
  ) : this._(date: date);

  final String date;

  @override
  List<Object> get props => [date];
}
