import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/src/common/common.dart';
import 'package:flutter_ebook_app/src/features/features.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes {
    return <AutoRoute>[
      AutoRoute(
        page: SplashRoute.page,
        path: '/',
      ),
      CupertinoRoute(
        page: LocalReaderRoute.page,
        path: '/local-reader',
      ),
      CustomRoute(
        page: TabsRoute.page,
        path: '/tabs-screen',
        transitionsBuilder: (_, animation, ___, child) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        children: <AutoRoute>[
          RedirectRoute(path: '', redirectTo: 'home-tab'),
          CupertinoRoute(
            page: HomeRoute.page,
            path: 'home-tab',
            children: [
              CustomRoute(
                transitionsBuilder: (_, __, ___, child) => child,
                page: BookDetailsRoute.page,
                path: 'book-details-nested-tab',
              ),
              CustomRoute(
                transitionsBuilder: (_, __, ___, child) => child,
                page: GenreRoute.page,
                path: 'genre-nested-tab',
              ),
            ],
          ),
          CupertinoRoute(
            page: ExploreRoute.page,
            path: 'explore-tab',
            children: [
              CustomRoute(
                transitionsBuilder: (_, __, ___, child) => child,
                page: BookDetailsRoute.page,
                path: 'book-details-nested-tab',
              ),
              CustomRoute(
                transitionsBuilder: (_, __, ___, child) => child,
                page: GenreRoute.page,
                path: 'genre-nested-tab',
              ),
            ],
          ),
          CupertinoRoute(
            page: SettingsRoute.page,
            path: 'settings-tab',
            children: [
              CustomRoute(
                transitionsBuilder: (_, __, ___, child) => child,
                page: DownloadsRoute.page,
                path: 'downloads-nested-tab',
              ),
              CustomRoute(
                transitionsBuilder: (_, __, ___, child) => child,
                page: FavoritesRoute.page,
                path: 'favorites-nested-tab',
              ),
              CustomRoute(
                transitionsBuilder: (_, __, ___, child) => child,
                page: LicensesRoute.page,
                path: 'licenses-nested-tab',
              ),
              CustomRoute(
                transitionsBuilder: (_, __, ___, child) => child,
                page: BookDetailsRoute.page,
                path: 'book-details-nested-tab',
              ),
            ],
          ),
        ],
      ),
      CupertinoRoute(
        page: BookDetailsRoute.page,
        path: '/book-details-tab',
      ),
      CupertinoRoute(
        page: ExploreRoute.page,
        path: '/explore-tab',
      ),
      CupertinoRoute(
        page: GenreRoute.page,
        path: '/genre-tab',
      ),
      CupertinoRoute(
        page: DownloadsRoute.page,
        path: '/downloads-tab',
      ),
      CupertinoRoute(
        page: FavoritesRoute.page,
        path: '/favorites-tab',
      ),
      CupertinoRoute(
        page: LicensesRoute.page,
        path: '/licenses-tab',
      ),
    ];
  }
}
