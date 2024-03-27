import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/models/models.dart';
import 'core/utils/extensions/target_platform.dart';
import 'core/utils/themes/dark_theme.dart';
import 'core/utils/themes/light_theme.dart';
import 'dummy_data/dummy_data.dart';
import 'features/chat/chat.dart';
import 'features/home_screen/home_screen.dart';
import 'features/settings/settings.dart';
import 'features/status/status.dart';

class WhatsApp extends StatelessWidget {
  const WhatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Disable the app on web version on mobile.
    if (defaultTargetPlatform.isWebMobile) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            fontFamily: 'Helvetica Neue',
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF075E54),
            )),
        title: 'R WhatsApp',
        home: const Scaffold(
          body: Center(
            child: Text('Please open in desktop browser.'),
          ),
        ),
      );
    }

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => UserRepository()),
        RepositoryProvider<User>.value(value: user),
        RepositoryProvider<List<WhatsAppUser>>.value(value: whatsappUsers),
        RepositoryProvider<List<Contact>>.value(value: contacts),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => ChatBloc(messageStore: messages)),
          BlocProvider(create: (context) => ChatRoomBloc()),
          BlocProvider(create: (context) => NewChatBloc()),
          BlocProvider(create: (context) => ChatSearchBloc()),
          BlocProvider(create: (context) => UserProfileBloc()),
          BlocProvider(create: (context) => SettingsBloc()),
          BlocProvider(create: (context) => ChatSettingsBloc()),
          BlocProvider(create: (context) => ProfileSettingsBloc()),
          BlocProvider(
            lazy: false,
            create: (context) => StatusBloc(
              whatsAppUsers: context.read<List<WhatsAppUser>>(),
            ),
          ),
          BlocProvider(create: (context) => StatusListViewCubit()),
        ],
        child: Builder(
          builder: (context) => MaterialApp(
            title: 'WhatsApp',
            theme: lightTheme.copyWith(
              textTheme: lightTheme.textTheme.copyWith(
                // Override fontFamily for all text styles
                headline1: lightTheme.textTheme.headline1!.copyWith(
                  fontFamily: 'Helvetica Neue',
                ),
                headline2: lightTheme.textTheme.headline2!.copyWith(
                  fontFamily: 'Helvetica Neue',
                ),
                headline3: lightTheme.textTheme.headline3!.copyWith(
                  fontFamily: 'Helvetica Neue',
                ),
                headline4: lightTheme.textTheme.headline4!.copyWith(
                  fontFamily: 'Helvetica Neue',
                ),
                headline5: lightTheme.textTheme.headline5!.copyWith(
                  fontFamily: 'Helvetica Neue',
                ),
                headline6: lightTheme.textTheme.headline6!.copyWith(
                  fontFamily: 'Helvetica Neue',
                ),
                subtitle1: lightTheme.textTheme.subtitle1!.copyWith(
                  fontFamily: 'Helvetica Neue',
                ),
                subtitle2: lightTheme.textTheme.subtitle2!.copyWith(
                  fontFamily: 'Helvetica Neue',
                ),
                bodyText1: lightTheme.textTheme.bodyText1!.copyWith(
                  fontFamily: 'Helvetica Neue',
                ),
                bodyText2: lightTheme.textTheme.bodyText2!.copyWith(
                  fontFamily: 'Helvetica Neue',
                ),
                button: lightTheme.textTheme.button!.copyWith(
                  fontFamily: 'Helvetica Neue',
                ),
                caption: lightTheme.textTheme.caption!.copyWith(
                  fontFamily: 'Helvetica Neue',
                ),
                overline: lightTheme.textTheme.overline!.copyWith(
                  fontFamily: 'Helvetica Neue',
                ),
              ),
            ),
            debugShowCheckedModeBanner: false,
            darkTheme: darkTheme,
            themeMode: context.select(
              (ChatSettingsBloc bloc) => bloc.state.themeMode,
            ),
            home: const HomeScreen(),
          ),
        ),
      ),
    );
  }
}
