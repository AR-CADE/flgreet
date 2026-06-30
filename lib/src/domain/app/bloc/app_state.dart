part of 'app_bloc.dart';

class AppBlocState extends Equatable {
  const AppBlocState._({
    this.ready = false,
  });

  const AppBlocState.set({
    required bool ready,
  }) : this._(ready: ready);

  final bool ready;

  @override
  List<Object> get props => [ready];
}
