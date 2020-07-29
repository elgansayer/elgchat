import 'package:elgchat_example/authentication_bloc/authentication_bloc.dart';
import 'package:elgchat_example/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    UserRepository userRepository =
        RepositoryProvider.of<UserRepository>(context);

    return Container(
      child: FutureBuilder<FirebaseUser>(
          future: userRepository.getUser(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }

            final user = snapshot.data;

            return Scaffold(
              appBar: AppBar(actions: <Widget>[
                FlatButton(
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.exit_to_app),
                        Text("Logout"),
                      ],
                    ),
                    onPressed: () {
                      RepositoryProvider.of<AuthenticationBloc>(context)
                          .add(AuthenticationLoggedOut());
                      userRepository.signOut();
                    })
              ], title: Text(user.displayName ?? 'Nemo')),
              body: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CircleAvatar(
                          radius: 100,
                          backgroundColor: Colors.transparent,
                          backgroundImage: NetworkImage(
                              user.photoUrl ?? 'https://picsum.photos/200/200')),
                    ),
                    Text(user.email),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
