import 'package:csen268/navigation/my_navigator_route.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Text(
              'Main Drawer',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          ListTile(
            title: const Text('Images'),
            onTap: () {
              context.pop();
              context.goNamed(MyNavigatorRoute.images.name);
            },
          ),
          ListTile(
            title: const Text('Map'),
            onTap: () {
              context.pop();
              context.goNamed(MyNavigatorRoute.map.name);
            },
          ),
          ListTile(
            title: const Text('Contacts'),
            onTap: () {
              context.pop();
              context.goNamed(MyNavigatorRoute.contacts.name);
            },
          ),
          ListTile(
            title: const Text('Database'),
            onTap: () {
              context.pop();
              context.goNamed(MyNavigatorRoute.database.name);
            },
          ),
        ],
      ),
    );
  }
}
