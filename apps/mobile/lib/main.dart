import 'package:blocs/blocs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/demo_data.dart';
import 'data/fake_shopping_list_repository.dart';
import 'map_filter.dart';
import 'router.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await restoreMapFilter();
  runApp(CartMapApp(repository: FakeShoppingListRepository()));
}

class CartMapApp extends StatelessWidget {
  const CartMapApp({super.key, required this.repository});

  final FakeShoppingListRepository repository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<FakeShoppingListRepository>.value(
      value: repository,
      child: BlocProvider(
        create: (context) =>
        ShoppingListsBloc(repository: repository, currentUser: currentUserId)
          ..add(const ListsRequested()),
        child: MaterialApp.router(
          title: 'CartMap',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.system,
          routerConfig: appRouter,
        ),
      ),
    );
  }
}