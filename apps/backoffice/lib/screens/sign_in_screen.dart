import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../dependencies.dart';
import '../texts.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key, required this.onSignedIn, this.reason});

  final void Function(User user) onSignedIn;
  final SignOutReason? reason;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          LoginFormBloc(sessions: context.read<BackofficeDependencies>().sessions),
      child: BlocListener<LoginFormBloc, LoginFormState>(
        listener: (context, state) {
          if (state case LoginSucceeded(:final user)) onSignedIn(user);
        },
        child: Scaffold(body: _SignInForm(reason: reason)),
      ),
    );
  }
}

class _SignInForm extends StatefulWidget {
  const _SignInForm({this.reason});

  final SignOutReason? reason;

  @override
  State<_SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<_SignInForm> {
  final _username = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() => context.read<LoginFormBloc>().add(
    LoginSubmitted(username: _username.text, password: _password.text),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.watch<LoginFormBloc>().state;
    final busy = state is LoginSubmitting;
    final message = switch (state) {
      LoginRejected() => 'Pogrešno korisničko ime ili lozinka.',
      LoginFailed(:final cause) => noticeMessage(noticeOf(cause)),
      _ => signOutMessage(widget.reason),
    };

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.storefront, size: 48, color: theme.colorScheme.primary),
                  const SizedBox(height: 8),
                  Text(
                    'CartMap Backoffice',
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (message.isNotEmpty) ...[
                    Text(
                      message,
                      style: TextStyle(color: theme.colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextField(
                    controller: _username,
                    enabled: !busy,
                    autofillHints: const [AutofillHints.username],
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Korisničko ime',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _password,
                    enabled: !busy,
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    decoration: const InputDecoration(labelText: 'Lozinka'),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: busy ? null : _submit,
                    child: busy
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Prijavi se'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
