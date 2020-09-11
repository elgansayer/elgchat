import 'package:elgchat_example/profile/bloc/profile_bloc.dart';
import 'package:elgchat_example/profile/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../user_repository.dart';
import 'bloc/chat_groups_repository.dart';
import 'bloc/home_bloc.dart';
import 'bloc/chat_group_bloc.dart';
import 'chat_list_page.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeBloc _homeBloc = HomeBloc();
  final ChatGroupsRepository _chatGroupsRepository = ChatGroupsRepository();

  @override
  void dispose() {
    _homeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    UserRepository userRepository =
        RepositoryProvider.of<UserRepository>(context);

    final FirebaseUser user = userRepository.user;

    return MultiBlocProvider(providers: [
      BlocProvider<ChatGroupScreenBloc>(
          create: (context) => ChatGroupScreenBloc(
              _chatGroupsRepository, userRepository, _homeBloc)
            ..add(LoadChatGroups(userId: user.uid))),
      BlocProvider<ProfileBloc>(create: (context) => ProfileBloc()),
      BlocProvider<HomeBloc>(create: (context) => _homeBloc)
    ], child: HomeForm());
  }
}

class HomeForm extends StatelessWidget {
  const HomeForm({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Container(
          child: Scaffold(
            // floatingActionButton: FloatingActionButton(onPressed: () {}),
            body: _buildBody(state.pageIndex),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: state.pageIndex,
              onTap: (int index) {
                BlocProvider.of<HomeBloc>(context).add(SwitchTab(index));
              },
              items: [
                BottomNavigationBarItem(
                  icon: new Icon(Icons.mail),
                  label: ('Messages'),
                ),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: ('Profile'))
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return ChatListPage();
        break;
      case 1:
        return ProfilePage();
        break;
      default:
        return ChatListPage();
    }
  }
}
