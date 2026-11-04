import 'package:blocs/blocs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/fake_price_repository.dart';
import 'screens/prices_screen.dart';
import 'theme.dart';

void main() {
  runApp(BackofficeApp(repository: FakePriceRepository()));
}

class BackofficeApp extends StatelessWidget {
  const BackofficeApp({super.key, required this.repository});

  final FakePriceRepository repository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<FakePriceRepository>.value(
      value: repository,
      child: BlocProvider(
        create: (context) =>
        PriceReviewBloc(repository: repository)..add(const PricesRequested()),
        child: MaterialApp(
          title: 'CartMap Backoffice',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.system,
          home: const PricesScreen(),
        ),
      ),
    );
  }
}