import 'package:csen268/pages/generic_page.dart';
import 'package:csen268/repositories/authentication/authentication_repository.dart';
import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/authentication/authentication_bloc.dart';
import 'blocs/notifications/bloc/notifications_bloc.dart';
import 'firebase_options.dart';
import 'navigation/router.dart';
import 'theme/cubit/theme_cubit.dart';
import 'theme/theme.dart';
import 'theme/util.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
  print('Message data: ${message.data}');
  print('Message notification: ${message.notification?.title}');
  print('Message notification: ${message.notification?.body}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print(await FirebaseInstallations.instance.getId());

  final messaging = FirebaseMessaging.instance;
  // final settings = await messaging.requestPermission(
  //   alert: true,
  //   announcement: false,
  //   badge: true,
  //   carPlay: false,
  //   criticalAlert: false,
  //   provisional: false,
  //   sound: true,
  // );

  final vapidKey =
      "BEfe0Y4f84mk24QOgcVfbqCunLyG7Y20p8nPgjURHvMX1o8h1Uceue9H3ptIbQQLHSiB1FLyIYhW3bEGJzQYJ-Q";
  String? token;

  if (DefaultFirebaseOptions.currentPlatform == DefaultFirebaseOptions.web) {
    token = await messaging.getToken(vapidKey: vapidKey);
  } else {
    try {
      token = await messaging.getToken();
    } catch (e) {
      print("Error getting token $e");
    }
  }
  print("Messaging token: $token");
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Handling a foreground message: ${message.messageId}');
    print('Message data: ${message.data}');
    print('Message notification: ${message.notification?.title}');
    print('Message notification: ${message.notification?.body}');
    // Do whatever you need to do with this message
  });
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final authenticationRepository =
        FirebaseAuthenticationRepository() as AuthenticationRepository;
    final authenticationBloc = AuthenticationBloc(authenticationRepository);
    final themeCubit = ThemeCubit()..init();

    MaterialTheme materialTheme = MaterialTheme(
      createTextTheme(context, 'Roboto', 'Roboto Condensed'),
    );

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => authenticationRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => authenticationBloc),
          BlocProvider(create: (context) => themeCubit),
          BlocProvider(create: (context) => NotificationsBloc()..init()),
        ],
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, state) {
            return MaterialApp.router(
              title: 'CSEN 268 Fall 2025',
              theme: materialTheme.light(),
              darkTheme: materialTheme.dark(),
              highContrastDarkTheme: materialTheme.darkHighContrast(),
              highContrastTheme: materialTheme.lightHighContrast(),
              themeMode: state.themeMode,
              debugShowCheckedModeBanner: false,
              routerConfig: router,
              builder: (context, child) {
                // Widget child = child ?? Container();
                return BlocListener<NotificationsBloc, NotificationsState>(
                  listener: (context, state) async {
                    if (state is NotificationsReceivedState) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.message.notification?.title ?? "<title>",
                              ),
                              Text(
                                state.message.notification?.body ?? "<body>",
                              ),
                              Text("Type: ${state.notificationType.name}"),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                  child: child,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class MySimpleApp extends StatelessWidget {
  const MySimpleApp({super.key});

  @override
  build(BuildContext context) {
    return MaterialApp(
      title: 'Simple App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const GenericPage(title: 'Generic Page Test'),
    );
  }
}
