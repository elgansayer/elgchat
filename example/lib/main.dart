import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:elgchat_example/authentication_bloc/authentication_bloc.dart';
import 'package:elgchat_example/user_repository.dart';
import 'package:elgchat_example/login/login.dart';
import 'package:elgchat_example/splash_screen.dart';
import 'package:elgchat_example/simple_bloc_observer.dart';

import 'home/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = SimpleBlocObserver();
  final UserRepository userRepository = UserRepository();
  runApp(RepositoryProvider<UserRepository>(
    create: (context) => userRepository,
    child: BlocProvider(
      create: (context) => AuthenticationBloc(
        userRepository: userRepository,
      )..add(AuthenticationStarted()),
      child: App(userRepository: userRepository),
    ),
  ));
}

class App extends StatelessWidget {
  final UserRepository _userRepository;

  App({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is AuthenticationFailure) {
            return LoginScreen(userRepository: _userRepository);
          }
          if (state is AuthenticationSuccess) {
            return HomeScreen();
          }
          return SplashScreen();
        },
      ),
    );
  }
}
