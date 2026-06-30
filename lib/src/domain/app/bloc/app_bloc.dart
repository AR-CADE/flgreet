import 'dart:async' show Future, StreamSubscription;
import 'dart:io' show File;

import 'package:bloc/bloc.dart' show Bloc;
import 'package:equatable/equatable.dart' show Equatable;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show
        BuildContext,
        Colors,
        FocusNode,
        ScaffoldMessenger,
        SnackBar,
        Text,
        TextEditingController;
import 'package:flutter_bloc/flutter_bloc.dart' show Emitter;
import 'package:greetd_ipc/greetd_ipc.dart' show GreetdRepository;
import 'package:rxdart/rxdart.dart' show DebounceExtensions;
import 'package:rxdart/subjects.dart';

part 'app_event.dart';
part 'app_state.dart';

List<String> getSessions() {
  final file = File('/etc/greetd/environments');
  if (!file.existsSync()) {
    return [];
  }
  return file.readAsLinesSync();
}

class AppBloc extends Bloc<AppBlocEvent, AppBlocState> {
  AppBloc() : super(const AppBlocState.set(ready: false)) {
    on<_SetReadyRequested>(_onSetReady);
    _sessions = getSessions();
    _errorDebouncerSubscription = _errorDebouncer
        .debounceTime(
          const Duration(milliseconds: 200),
        )
        .listen(
          (context) {
            if (!context.mounted) {
              return;
            }
            const snackBar = SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                'An error has occurred',
                style: TextStyle(color: Colors.white),
              ),
            );

            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          },
        );
    add(const _SetReadyRequested(ready: true));
  }

  late final List<String> _sessions;
  final GreetdRepository _repository = GreetdRepository();
  final _usernameTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _sessionTextController = TextEditingController();
  final _usernameTextFocusNode = FocusNode();
  final _passwordTextFocusNode = FocusNode();
  final _sessionTextFocusNode = FocusNode();
  final PublishSubject<BuildContext> _errorDebouncer =
      PublishSubject<BuildContext>();

  late final StreamSubscription<BuildContext> _errorDebouncerSubscription;

  GreetdRepository get repository => _repository;
  TextEditingController get usernameTextController => _usernameTextController;
  TextEditingController get passwordTextController => _passwordTextController;
  TextEditingController get sessionTextController => _sessionTextController;
  FocusNode get usernameTextFocusNode => _usernameTextFocusNode;
  FocusNode get passwordTextFocusNode => _passwordTextFocusNode;
  FocusNode get sessionTextFocusNode => _sessionTextFocusNode;
  List<String> get sessions => _sessions;

  Future<void> _onSetReady(
    _SetReadyRequested event,
    Emitter<AppBlocState> emit,
  ) async {
    return emit(AppBlocState.set(ready: event.ready));
  }

  void showError(BuildContext context) {
    if (isClosed || _errorDebouncer.isClosed) {
      return;
    }
    _errorDebouncer.add(context);
  }

  @override
  Future<void> close() async {
    if (!isClosed) {
      add(const _SetReadyRequested(ready: false));
    }
    await _errorDebouncerSubscription.cancel();
    await _errorDebouncer.close();
    _sessions.clear();
    await _repository.disconnect();
    _usernameTextFocusNode.dispose();
    _passwordTextFocusNode.dispose();
    _sessionTextFocusNode.dispose();
    _usernameTextController.dispose();
    _passwordTextController.dispose();
    _sessionTextController.dispose();
    return super.close();
  }
}
