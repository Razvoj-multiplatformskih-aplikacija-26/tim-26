import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'dependencies.dart';
import 'screens/prices_screen.dart';
import 'screens/sign_in_screen.dart';
import 'theme.dart';

class BackofficeApp extends StatefulWidget {
  const BackofficeApp({super.key, required this.dependencies});

  final BackofficeDependencies dependencies;

  @override
  State<BackofficeApp> createState() => _BackofficeAppState();
}

class _BackofficeAppState extends State<BackofficeApp> {
  late final SessionBloc _session = SessionBloc(
    sessions: widget.dependencies.sessions,
    admits: AccessPolicy.canUseBackoffice,
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
          builder: (context, session) => MaterialApp(
            key: ValueKey(switch (session) {
              SignedIn(:final user) => 'signed-in-${user.id.value}',
              SignedOut(:final reason) => 'signed-out-${reason?.name}',
              SessionUnknown() => 'session-unknown',
            }),
            title: 'CartMap Backoffice',
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: ThemeMode.system,
            home: switch (session) {
              SessionUnknown() => const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
              SignedOut(:final reason) => SignInScreen(
                reason: reason,
                onSignedIn: (user) => _session.add(SessionStarted(user)),
              ),
              SignedIn(:final user) => RepositoryProvider<User>.value(
                value: user,
                child: BlocProvider(
                  create: (_) =>
                      PriceReviewBloc(repository: dependencies.prices)
                        ..add(const PricesRequested()),
                  child: const PricesScreen(),
                ),
              ),
            },
          ),
        ),
      ),
    );
  }
}
