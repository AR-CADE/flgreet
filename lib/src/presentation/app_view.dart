import 'package:flgreet/src/domain/app/app.dart' show AppBloc, AppBlocState;
import 'package:flgreet/src/presentation/login_screen.dart' show LoginScreen;
import 'package:flutter/material.dart'
    show
        BuildContext,
        MaterialApp,
        SizedBox,
        StatelessWidget,
        ThemeMode,
        Widget;
import 'package:flutter_bloc/flutter_bloc.dart'
    show BlocProvider, BlocSelector, MultiBlocProvider, ReadContext;
import 'package:greetd_ipc/greetd_ipc.dart' show GreetdBloc;
import 'package:yaru/yaru.dart' show YaruTheme;

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return YaruTheme(
      builder: (context, yaru, child) {
        return MaterialApp(
          title: 'flgreet',
          theme: yaru.theme,
          darkTheme: yaru.darkTheme,
          themeMode: ThemeMode.dark,
          home: BlocProvider(
            create: (context) => AppBloc(),
            child: BlocSelector<AppBloc, AppBlocState, bool>(
              selector: (state) {
                return state.ready;
              },
              builder: (context, ready) {
                if (!ready) {
                  return const SizedBox.shrink();
                }
                return MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (context) => GreetdBloc(
                        repository: context.read<AppBloc>().repository,
                      ),
                    ),
                  ],
                  child: LoginScreen(
                    sessions: context.read<AppBloc>().sessions,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
