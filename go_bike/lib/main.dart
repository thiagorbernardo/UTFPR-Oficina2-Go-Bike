import 'package:flutter/material.dart';
import 'package:go_bike/data/bloc/user/user_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:go_bike/firebase_options.dart';

import 'package:go_bike/cubit/bottom_nav_cubit.dart';
import 'package:go_bike/cubit/theme_cubit.dart';
import 'package:go_bike/utils/routes/routes.dart';
import 'package:go_bike/config/notifications/config.dart';

void main() async {
  // Initialize packages
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await dotenv.load(fileName: ".env");
  // Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Storage
  await Hive.initFlutter();

  final storage = await HydratedStorage.build(
    storageDirectory: await getApplicationSupportDirectory(),
  );
  // Splash Screen
  FlutterNativeSplash.remove();

  HydratedBlocOverrides.runZoned(
    () => runApp(
      const MyApp(initialRoute: Routes.home),
    ),
    storage: storage,
  );
}

class MyApp extends StatefulWidget {
  final String initialRoute;

  const MyApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      requestAndRegisterNotification(context);
      print("REGISTERING NOTIFICATIONS");
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
        BlocProvider<BottomNavCubit>(create: (context) => BottomNavCubit()),
        BlocProvider<UserBloc>(create: (context) => UserBloc()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          context.read<ThemeCubit>().subscribeIfNeeded();
          return MaterialApp(
            title: 'Go Bike',
            theme: state.themeData,
            initialRoute: widget.initialRoute,
            routes: Routes.routes,
            debugShowCheckedModeBanner: false,
            locale: const Locale('pt', 'BR'),
          );
        },
      ),
    );
  }
}
