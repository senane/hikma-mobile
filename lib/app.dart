import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hikma_health/colors.dart';
import 'package:hikma_health/user_repository/user_repository.dart';
import 'package:hikma_health/widgets/home/home.dart';
import 'package:hikma_health/widgets/login/login.dart';

import 'authentication/authentication.dart';

void main() {
//  BlocSupervisor().delegate = SimpleBlocDelegate();
  runApp(App(userRepository: UserRepository()));
}

class App extends StatefulWidget {

  final UserRepository userRepository;

  App({Key key, @required this.userRepository}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  AuthenticationBloc _authenticationBloc;
  UserRepository get _userRepository => widget.userRepository;

  @override
  void initState() {
    _authenticationBloc = AuthenticationBloc(userRepository: _userRepository);
    _authenticationBloc.dispatch(AppStarted());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthenticationBloc>(
      builder: (context) {
        return _authenticationBloc;
      },
      child: MaterialApp(
        theme: buildTheme(),
        home: BlocBuilder<AuthenticationEvent, AuthenticationState>(
          bloc: _authenticationBloc,
          builder: (BuildContext context, AuthenticationState state) {
            if (state is AuthenticationAuthenticated) {
              if (state.auto) {
                return HomeScreen(userRepository: _userRepository);
              } else {
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            HomeScreen(userRepository: _userRepository)
                    ),
                  );
                });
                return LoginPage(userRepository: _userRepository);
              }
            } else {
              return LoginPage(userRepository: _userRepository);
            }
            // TODO tweak here and make a splash screen
//            if (state is AuthenticationUninitialized) {
//              return SplashPage();
//            }
//            if (state is AuthenticationAuthenticated) {
//              return HomePage();
//            }
//            if (state is AuthenticationUnauthenticated) {
//              return LoginPage(userRepository: _userRepository);
//            }
//            if (state is AuthenticationLoading) {
//              return LoadingIndicator();
//            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _authenticationBloc.dispose();
    super.dispose();
  }

  ThemeData buildTheme() {
    final ThemeData base = ThemeData.light();
    return base.copyWith(
      primaryColor: hikmaPrimary,
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.elliptical(10, 10)),
          gapPadding: 10,
        ),
      ),

      textTheme: _buildTextTheme(base.textTheme),
      primaryTextTheme: _buildTextTheme(base.primaryTextTheme),
      accentTextTheme: _buildTextTheme(base.accentTextTheme),
    );
  }

  TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      headline: base.headline.copyWith(
          fontWeight: FontWeight.w900
      ),
      title: base.title.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w500
      ),
      caption: base.caption.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w400
      ),
    );
  }
}


class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    print(event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    print(error);
  }
}
