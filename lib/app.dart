import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'flavors.dart';
import 'routes.dart';
import 'utilities/methods.dart';

class App extends ConsumerStatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: F.title,
          theme: ThemeData(
            fontFamily: GoogleFonts.roboto().fontFamily,
            scaffoldBackgroundColor: const Color(0xffD8EBE9),
            primarySwatch:
                AppMethods.createMaterialColor(const Color(0xFF165A4A)),
          ),
          initialRoute:
              Supabase.instance.client.auth.currentSession?.isExpired ?? true
                  ? AppRoutes.authentication
                  : AppRoutes.dashboard,
          routes: AppRoutes.routes,
        );
      },
    );
  }
}
