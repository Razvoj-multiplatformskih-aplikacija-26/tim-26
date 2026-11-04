import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/add_item_screen.dart';
import 'screens/home_shell.dart';
import 'screens/list_detail_screen.dart';
import 'screens/lists_screen.dart';
import 'screens/map_screen.dart';
import 'screens/new_list_screen.dart';
import 'screens/profile_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/lists',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          HomeShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const MapScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/lists',
              builder: (context, state) => const ListsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/new',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const NewListScreen(),
    ),
    GoRoute(
      path: '/list/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => ListDetailScreen(
        listId: ShoppingListId(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/list/:id/add',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => AddItemScreen(
        listId: ShoppingListId(state.pathParameters['id']!),
      ),
    ),
  ],
);