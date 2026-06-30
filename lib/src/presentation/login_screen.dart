import 'dart:async' show unawaited;

import 'package:flgreet/src/domain/app/app.dart' show AppBloc;
import 'package:flgreet/src/presentation/clock.dart' show ClockWidget;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemNavigator;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greetd_ipc/greetd_ipc.dart';
import 'package:yaru/yaru.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({required this.sessions, super.key});

  final List<String> sessions;

  void cancelSession(BuildContext context) {
    if (context.read<GreetdBloc>().state.status == GreetdStatus.cancelled ||
        context.read<GreetdBloc>().state.status == GreetdStatus.connected ||
        context.read<GreetdBloc>().state.status == GreetdStatus.exit ||
        context.read<GreetdBloc>().state.status == GreetdStatus.initial) {
      return;
    }
    context.read<GreetdBloc>().add(const CancelSession());
  }

  @override
  Widget build(BuildContext context) {
    return YaruTheme(
      builder: (context, yaru, child) {
        return Scaffold(
          backgroundColor: yaru.darkTheme.scaffoldBackgroundColor,
          body: BlocListener<GreetdBloc, GreetdState>(
            listener: (context, state) {
              if (state.status == GreetdStatus.exit) {
                unawaited(SystemNavigator.pop());
                return;
              }

              if (state.status == GreetdStatus.authInfo) {
                final snackBar = SnackBar(
                  content: Column(
                    children: [
                      const Text('info: '),
                      Text('promptType: //${state.promptType}'),
                      Text('promptMessage: ${state.promptMessage}'),
                    ],
                  ),
                );

                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                return;
              }

              if (state.status == GreetdStatus.authError ||
                  state.status == GreetdStatus.unknown ||
                  state.status == GreetdStatus.error) {
                context.read<AppBloc>().usernameTextController.clear();
                context.read<AppBloc>().passwordTextController.clear();
                context.read<AppBloc>().showError(context);

                // final snackBar = SnackBar(
                //   content: Column(
                //     children: [
                //       Text('error: ${state.error}'),
                //       if (state.status == GreetdStatus.authError)
                //         Text('promptType: ${state.promptType}'),
                //       if (state.status == GreetdStatus.authError)
                //         Text('promptMessage: ${state.promptMessage}'),
                //     ],
                //   ),
                // );

                // ScaffoldMessenger.of(context).showSnackBar(snackBar);

                cancelSession(context);
                return;
              }

              if (state.status == GreetdStatus.cancelled) {
                context.read<AppBloc>().usernameTextController.clear();
                context.read<AppBloc>().passwordTextController.clear();
                return;
              }
            },
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Card(
                    elevation: 8,
                    color: yaru.darkTheme.cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 56,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClockWidget(
                            style: Theme.of(context).textTheme.displayMedium
                                ?.copyWith(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w300,
                                ),
                          ),
                          const SizedBox(height: 48),

                          // Username
                          TextField(
                            controller: context
                                .read<AppBloc>()
                                .usernameTextController,
                            focusNode: context
                                .read<AppBloc>()
                                .usernameTextFocusNode,
                            decoration: const InputDecoration(
                              labelText: 'Username',
                              prefixIcon: Icon(Icons.person_outline),
                              border: OutlineInputBorder(),
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 24),

                          // Password
                          TextField(
                            controller: context
                                .read<AppBloc>()
                                .passwordTextController,
                            focusNode: context
                                .read<AppBloc>()
                                .passwordTextFocusNode,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock_outline),
                              border: OutlineInputBorder(),
                            ),
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _login(context),
                          ),
                          const SizedBox(height: 24),

                          LayoutBuilder(
                            builder: (context, constraints) {
                              return DropdownMenu(
                                width: constraints.maxWidth,
                                initialSelection: 0,
                                controller: context
                                    .read<AppBloc>()
                                    .sessionTextController,
                                trailingIcon: const Icon(YaruIcons.pan_down),
                                selectedTrailingIcon: const Icon(
                                  YaruIcons.pan_down,
                                ),
                                dropdownMenuEntries: sessions.map((value) {
                                  return DropdownMenuEntry(
                                    value: sessions.indexOf(value),
                                    label: value,
                                  );
                                }).toList(),
                              );
                            },
                          ),
                          const SizedBox(height: 48),

                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                  onPressed: () => _clear(context),
                                  child: const Text('Clear'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                  onPressed: () => _login(context),
                                  child: const Text('Login'),
                                ),
                              ),
                            ],
                          ),
                          if (kDebugMode) ...debugButtons(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> debugButtons() {
    return [
      const SizedBox(height: 24),
      Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                ),
              ),
              onPressed: SystemNavigator.pop,
              child: const Text('Quit'),
            ),
          ),
        ],
      ),
    ];
  }

  void _login(BuildContext context) {
    final bloc = context.read<GreetdBloc>();
    final username = context.read<AppBloc>().usernameTextController.text.trim();
    final password = context.read<AppBloc>().passwordTextController.text;
    final session = context.read<AppBloc>().sessionTextController.text;

    if (username.isNotEmpty && session.isNotEmpty) {
      bloc.add(
        CreateStartableSession(
          username: username,
          password: password,
          cmd: [session],
        ),
      );
    }
  }

  void _clear(BuildContext context) {
    context.read<AppBloc>().usernameTextController.clear();
    context.read<AppBloc>().passwordTextController.clear();
    context.read<AppBloc>().sessionTextController.clear();
    context.read<AppBloc>().sessionTextController.text =
        sessions.firstOrNull ?? '';
    cancelSession(context);
  }
}
