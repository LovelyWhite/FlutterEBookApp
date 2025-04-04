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
      CupertinoRoute(
        page: LicensesRoute.page,
        path: '/licenses-tab',
      ),
    ];
  }
}
