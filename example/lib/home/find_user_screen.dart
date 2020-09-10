import 'package:elgchat/models.dart';
import 'package:elgchat/user_search_screen.dart';
import 'package:elgchat_example/home/bloc/finduser_bloc.dart';
import 'package:elgchat_example/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FindUserScreen extends StatelessWidget {
  const FindUserScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    UserRepository userRepository =
        RepositoryProvider.of<UserRepository>(context);

    return BlocProvider<FindUserBloc>(
      create: (context) => FindUserBloc(userRepository),
      child: Container(
        child: FindUserForm(),
      ),
    );
  }
}

class FindUserForm extends StatelessWidget {
  const FindUserForm({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FindUserBloc, FindUserState>(
      builder: (context, FindUserState state) {
        return UserSearchScreen(
          onTap: (Contact contact) {
            onTap(context, contact);
          },
          contacts: state.contacts,
          onUserSearch: (String value) {
            BlocProvider.of<FindUserBloc>(context).add(UserSearch(value));
          },
        );
      },
    );
  }

  onTap(BuildContext context, Contact contact) {
    Navigator.of(context).pop(contact);
  }
}

// class FindUserScreen extends StatefulWidget {
//   FindUserScreen({Key key}) : super(key: key);

//   @override
//   _FindUserScreenState createState() => _FindUserScreenState();
// }

// class _FindUserScreenState extends State<FindUserScreen> {
//   List<Contact> contacts = [];

// }
