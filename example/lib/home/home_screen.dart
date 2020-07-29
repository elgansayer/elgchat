import 'package:elgchat_example/profile/bloc/profile_bloc.dart';
import 'package:elgchat_example/profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/home_bloc.dart';
import 'chat_list_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider<ProfileBloc>(create: (context) => ProfileBloc()),
      BlocProvider<HomeBloc>(create: (context) => HomeBloc())
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
            body: _buildBody(state.pageIndex),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: state.pageIndex,
              onTap: (int index) {
                BlocProvider.of<HomeBloc>(context).add(SwitchTab(index));
              },
              items: [
                BottomNavigationBarItem(
                  icon: new Icon(Icons.mail),
                  title: new Text('Messages'),
                ),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), title: Text('Profile'))
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
