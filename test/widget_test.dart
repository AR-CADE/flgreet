import 'package:flgreet/src/domain/app/app.dart'; // AppBloc
import 'package:flgreet/src/presentation/clock.dart' show ClockWidget;
import 'package:flgreet/src/presentation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greetd_ipc/greetd_ipc.dart';
import 'package:yaru/yaru.dart';

final testSessions = ['wayfire', 'sway', 'niri', 'plasma'];

void main() {
  group('LoginScreen', () {
    late AppBloc appBloc;
    late GreetdBloc greetdBloc;

    setUp(() {
      appBloc = AppBloc();
      greetdBloc = GreetdBloc(repository: GreetdRepository());
    });

    tearDown(() async {
      await appBloc.close();
      await greetdBloc.close();
    });

    testWidgets('Verify all widgets are present', (tester) async {
      await tester.pumpWidget(
        YaruTheme(
          builder: (context, yaru, child) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: appBloc),
              BlocProvider.value(value: greetdBloc),
            ],
            child: MaterialApp(home: LoginScreen(sessions: testSessions)),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Clear'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.byType(ClockWidget), findsOneWidget);

      expect(find.byType(DropdownMenu<int>), findsOneWidget);
      expect(find.text('wayfire'), findsWidgets);
    });

    testWidgets(
      'Login appelle CreateStartableSession avec les bonnes valeurs',
      (tester) async {
        await tester.pumpWidget(
          YaruTheme(
            builder: (context, yaru, child) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: appBloc),
                BlocProvider.value(value: greetdBloc),
              ],
              child: MaterialApp(home: LoginScreen(sessions: testSessions)),
            ),
          ),
        );

        appBloc.usernameTextController.text = 'testuser';
        appBloc.passwordTextController.text = 'password123';
        appBloc.sessionTextController.text = 'wayfire';

        await tester.tap(find.text('Login'));
        await tester.pump();
      },
    );

    testWidgets('Press Clear should reset all fields', (tester) async {
      await tester.pumpWidget(
        YaruTheme(
          builder: (context, yaru, child) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: appBloc),
              BlocProvider.value(value: greetdBloc),
            ],
            child: MaterialApp(home: LoginScreen(sessions: testSessions)),
          ),
        ),
      );

      appBloc.usernameTextController.text = 'user';
      appBloc.passwordTextController.text = 'pass';
      appBloc.sessionTextController.text = 'gnome';

      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      expect(appBloc.usernameTextController.text, isEmpty);
      expect(appBloc.passwordTextController.text, isEmpty);
      expect(
        appBloc.sessionTextController.text,
        testSessions.first,
      );
    });

    testWidgets('Press Clear when session list is empty', (tester) async {
      await tester.pumpWidget(
        YaruTheme(
          builder: (context, yaru, child) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: appBloc),
              BlocProvider.value(value: greetdBloc),
            ],
            child: const MaterialApp(home: LoginScreen(sessions: [])),
          ),
        ),
      );

      appBloc.usernameTextController.text = 'user';
      appBloc.passwordTextController.text = 'pass';
      appBloc.sessionTextController.text = 'gnome';

      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      expect(appBloc.usernameTextController.text, isEmpty);
      expect(appBloc.passwordTextController.text, isEmpty);
      expect(appBloc.sessionTextController.text, isEmpty);
    });

    testWidgets('DropdownMenu should be filled', (tester) async {
      await tester.pumpWidget(
        YaruTheme(
          builder: (context, yaru, child) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: appBloc),
              BlocProvider.value(value: greetdBloc),
            ],
            child: MaterialApp(home: LoginScreen(sessions: testSessions)),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(DropdownMenu<int>), findsOneWidget);

      for (final session in testSessions) {
        expect(find.text(session), findsWidgets);
      }
    });

    testWidgets(
      'Press Enter inside the password textfield should trigger the login',
      (tester) async {
        await tester.pumpWidget(
          YaruTheme(
            builder: (context, yaru, child) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: appBloc),
                BlocProvider.value(value: greetdBloc),
              ],
              child: MaterialApp(home: LoginScreen(sessions: testSessions)),
            ),
          ),
        );

        appBloc.usernameTextController.text = 'testuser';
        appBloc.passwordTextController.text = 'password123';
        appBloc.sessionTextController.text = 'wayfire';

        await tester.enterText(find.byType(TextField).at(1), 'password123');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
      },
    );
  });
}
