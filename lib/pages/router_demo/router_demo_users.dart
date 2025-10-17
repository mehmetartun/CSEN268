import 'package:csen268/widgets/user_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/authentication/authentication_bloc.dart';
import '../../model/user.dart';
import '../../widgets/print_route.dart';

class RouterDemoUsers extends StatelessWidget {
  const RouterDemoUsers({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Users")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              PrintRoute(),
              ...List.generate(3, (index) {
                return UserListTile(user: User.createMockUser());
              }),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  child: Text("Logout"),
                  onPressed: () {
                    BlocProvider.of<AuthenticationBloc>(
                      context,
                    ).add(AuthenticationSignOutEvent());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
