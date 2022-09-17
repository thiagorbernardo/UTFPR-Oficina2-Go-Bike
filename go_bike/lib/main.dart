import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

import 'package:go_bike/cubit/bottom_nav_cubit.dart';
import 'package:go_bike/cubit/theme_cubit.dart';
import 'package:go_bike/utils/routes/routes.dart';
import 'package:go_bike/data/bloc/user/user_bloc.dart';
import 'package:go_bike/models/push_notification.dart';

void requestAndRegisterNotification() async {
  NotificationSettings settings = await FirebaseMessaging.instance
      .requestPermission(
          alert: true, badge: true, provisional: false, sound: true);

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    print("\n\n\n\n TOKEN $fcmToken \n\n\n\n");
    //TODO: send to server

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }

      PushNotification _notification = PushNotification(
          title: message.notification!.title, body: message.notification!.body);
    });
  }
}

void main() async {
  /// Initialize packages
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  requestAndRegisterNotification();
  // Storage
  Hive.initFlutter();

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

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({Key? key, required this.initialRoute}) : super(key: key);

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
          return MaterialApp(
            title: 'Go Bike',
            theme: state.themeData,
            initialRoute: initialRoute,
            routes: Routes.routes,
            debugShowCheckedModeBanner: false,
            locale: const Locale('pt', 'BR'),
          );
        },
      ),
    );
  }
}
