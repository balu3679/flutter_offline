import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:regres/bloc/userbloc_bloc.dart';
import 'package:regres/model/usermodel.dart';
import 'package:regres/utils/constants.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  late UserblocBloc userbloc;
  late ScrollController scrollctrller;
  @override
  void initState() {
    userbloc = UserblocBloc();
    userbloc.add(UserInitialEvent());
    super.initState();
    scrollctrller = ScrollController();
    scrollctrller.addListener(listener);
  }

  listener() {
    if (scrollctrller.position.pixels >=
        scrollctrller.position.maxScrollExtent - 300) {
      final currentState = userbloc.state;
      if (currentState is SuccessState && !currentState.hasReachedMax) {
        userbloc.add(UserInitialEvent());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Users')), body: userbody());
  }

  Widget userbody() {
    return BlocBuilder<UserblocBloc, UserblocState>(
      bloc: userbloc,
      builder: (context, state) {
        if (state is LoadingState) {
          return Center(child: CircularProgressIndicator());
        } else if (state is ErrorState) {
          return Center(child: Text(state.error));
        } else if (state is SuccessState) {
          return userlistview(state);
        }
        return Center(child: Text('Something Went Wrong!!!'));
      },
    );
  }

  Widget userlistview(SuccessState state) {
    return RefreshIndicator(
      onRefresh: () async {
        userbloc.add(RefreshEvent());
      },
      child: ListView.builder(
        controller: scrollctrller,
        itemCount: state.userlist.length + (state.hasReachedMax ? 0 : 1),
        itemBuilder: (context, index) {
          if (index >= state.userlist.length && !state.hasReachedMax) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            UserModel user = state.userlist[index];
            return userCard(user);
          }
        },
      ),
    );
  }

  Widget userCard(UserModel user) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  user.avatar != null ? NetworkImage(user.avatar!) : null,
            ),
            title: Text('${user.firstName} ${user.lastName}'),
            subtitle: Text('${user.email}'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(dummytxt, maxLines: 3, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    scrollctrller.dispose();
    super.dispose();
  }
}
