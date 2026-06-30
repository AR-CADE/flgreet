part of 'app_bloc.dart';

sealed class AppBlocEvent extends Equatable {
  const AppBlocEvent();
}

final class _SetReadyRequested extends AppBlocEvent {
  const _SetReadyRequested({required this.ready});
  final bool ready;

  @override
  List<Object?> get props => [ready];
}
