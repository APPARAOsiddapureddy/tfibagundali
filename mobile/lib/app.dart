import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/providers/auth_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class TfiBagundaliApp extends StatefulWidget {
  const TfiBagundaliApp({super.key});

  @override
  State<TfiBagundaliApp> createState() => _TfiBagundaliAppState();
}

class _TfiBagundaliAppState extends State<TfiBagundaliApp> {
  late final AuthProvider _auth;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _auth = AuthProvider();
    _router = createRouter(_auth);
    Future.delayed(const Duration(milliseconds: 2200), () async {
      await _auth.bootstrap();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _auth,
      child: MaterialApp.router(
        title: 'TFI Bagundali',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        routerConfig: _router,
      ),
    );
  }
}
