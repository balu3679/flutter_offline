import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:regres/model/todo.dart';
import 'package:regres/provider/todoprovider.dart';
import 'package:regres/repository/offlineservices.dart';
import 'package:regres/views/dynamicform.dart';
import 'package:regres/views/todohome.dart';
import 'package:regres/views/userhome.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SyncService syncService = SyncService();

  @override
  void initState() {
    super.initState();
    syncService.monitorConnectivity(context, Todoprovider());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Page')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserHomePage()),
                );
              },
              child: Text('Users'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TodoHome()),
                );
              },
              child: Text('Todo'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DynamicFormPage()),
                );
              },
              child: Text('Form'),
            ),
            // FilledButton(
            //   onPressed: () async {
            //     final box = Hive.box<Todo>('todos');
            //     await box.clear();
            //   },
            //   child: Text('Clear'),
            // ),
          ],
        ),
      ),
    );
  }
}
