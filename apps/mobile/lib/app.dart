import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'dependencies.dart';
import 'router.dart';
import 'screens/sign_in_screen.dart';
import 'texts.dart';
import 'theme/app_theme.dart';

class CartMapApp extends StatefulWidget {
  const CartMapApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<CartMapApp> createState() => _CartMapAppState();
}

class _CartMapAppState extends State<CartMapApp> {
  late final SessionBloc _session = SessionBloc(
    sessions: widget.dependencies.sessions,
    admits: AccessPolicy.canUseMobileApp,
  )..add(const SessionRestoreRequested());

  @override
  void dispose() {
    _session.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dependencies = widget.dependencies;
    return RepositoryProvider.value(
      value: dependencies,
      child: BlocProvider.value(
        value: _session,
        child: BlocBuilder<SessionBloc, SessionState>(
          builder: (context, session) => switch (session) {
            SessionUnknown() => _plainApp(
              key: const ValueKey('session-unknown'),
              home: const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            ),
            SignedOut(:final reason) => _plainApp(
              key: ValueKey('signed-out-${reason?.name}'),
              home: SignInScreen(
                reason: reason,
                onSignedIn: (user) => _session.add(SessionStarted(user)),
              ),
            ),
            SignedIn(:final user) => _SignedInApp(
              key: ValueKey(user.id.value),
              user: user,
              dependencies: dependencies,
            ),
          },
        ),
      ),
    );
  }
}

/// Posle prijave: Bloc lista za tog korisnika i ruter sa ekranima iz KT1.
class _SignedInApp extends StatefulWidget {
  const _SignedInApp({
    super.key,
    required this.user,
    required this.dependencies,
  });

  final User user;
  final AppDependencies dependencies;

  @override
  State<_SignedInApp> createState() => _SignedInAppState();
}

class _SignedInAppState extends State<_SignedInApp> {
  final _messenger = GlobalKey<ScaffoldMessengerState>();
  late final GoRouter _router = createRouter();
  late final ShoppingListsBloc _lists = ShoppingListsBloc(
    repository: widget.dependencies.lists,
    currentUser: widget.user.id,
  )..add(const ListsRequested());

  @override
  void dispose() {
    _router.dispose();
    _lists.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<User>.value(
      value: widget.user,
      child: BlocProvider.value(
        value: _lists,
        child: BlocListener<ShoppingListsBloc, ShoppingListsState>(
          listenWhen: (previous, current) => announcement(current) != null,
          listener: (context, state) {
            final message = announcement(state);
            if (message == null) return;
            _messenger.currentState
              ?..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(message)));
          },
          child: MaterialApp.router(
            title: 'CartMap',
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: ThemeMode.system,
            scaffoldMessengerKey: _messenger,
            routerConfig: _router,
          ),
        ),
      ),
    );
  }
}

Widget _plainApp({required Key key, required Widget home}) {
  return MaterialApp(
    key: key,
    title: 'CartMap',
    debugShowCheckedModeBanner: false,
    theme: lightTheme,
    darkTheme: darkTheme,
    themeMode: ThemeMode.system,
    home: home,
  );
}
