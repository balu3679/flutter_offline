import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:regres/model/todo.dart';
import 'package:regres/provider/todoprovider.dart';

class SyncService {
  final Box<Todo> box = Hive.box<Todo>('todos');

  List<ConnectivityResult> connectivityResult = [];

  SyncService() {
    Connectivity().checkConnectivity().then((value) {
      connectivityResult = value;
    });
  }

  static Future<bool> networkHelper() async {
    final connectivity = await Connectivity().checkConnectivity();
    return !connectivity.contains(ConnectivityResult.none);
  }

  void monitorConnectivity(context, Todoprovider provider) {
    Connectivity().onConnectivityChanged.listen((status) {
      if (!status.contains(ConnectivityResult.none)) {
        showtoast(context, 'Syncing with firebase. Please Wait...');
        provider.syncToFirebase();
      } else {
        showtoast(context, 'No Internet Connectivity');
      }
    });
  }

  void showtoast(context, msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
