import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:regres/model/todo.dart';
import 'package:regres/repository/offlineservices.dart';
import 'package:uuid/uuid.dart';

class Todoprovider extends ChangeNotifier {
  final Box<Todo> box = Hive.box<Todo>('todos');
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Todo> get todos => box.values.where((todo) => !todo.isDeleted).toList();
  bool isloading = true;

  Future<void> fetchFromFirebase() async {
    isloading = true;
    final hasConnection = await SyncService.networkHelper();
    if (hasConnection) {
      try {
        final snapshot = await firestore.collection('todos').get();
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final todo = Todo(
            id: data['id'],
            title: data['title'] ?? '',
            isDone: data['isDone'] ?? false,
            isDeleted: data['isDeleted'] ?? false,
            isSynced: true,
          );
          await box.put(todo.id, todo);
        }
        debugPrint('Fetched...');
      } catch (e) {
        debugPrint('Error todos : $e');
      } finally {
        isloading = false;
      }
    } else {
      debugPrint('No internet');
      isloading = false;
    }

    notifyListeners();
  }

  void addTodo(String title) async {
    final todo = Todo(id: const Uuid().v4(), title: title, isSynced: false);
    await box.put(todo.id, todo);

    final hasConnection = await SyncService.networkHelper();
    if (hasConnection) {
      try {
        await FirebaseFirestore.instance.collection('todos').doc(todo.id).set({
          'id': todo.id,
          'title': todo.title,
          'isDone': todo.isDone,
          'isDeleted': todo.isDeleted,
        });

        todo.isSynced = true;
        await todo.save();
      } catch (e) {
        debugPrint('sync failed: $e');
      }
    }
    notifyListeners();
  }

  void updateTodo(String id, String newTitle) async {
    final todo = box.get(id);
    if (todo != null) {
      todo.title = newTitle;
      todo.isSynced = false;
      await todo.save();

      final hasConnection = await SyncService.networkHelper();
      if (hasConnection) {
        try {
          await FirebaseFirestore.instance
              .collection('todos')
              .doc(todo.id)
              .set({
                'id': todo.id,
                'title': todo.title,
                'isDone': todo.isDone,
                'isDeleted': todo.isDeleted,
              });

          todo.isSynced = true;
          await todo.save();
        } catch (e) {
          debugPrint('update failed: $e');
        }
      }

      notifyListeners();
    }
  }

  void toggleDone(String id) async {
    final todo = box.get(id);
    if (todo != null) {
      todo.isDone = !todo.isDone;
      todo.isSynced = false;
      todo.save();

      final hasConnection = await SyncService.networkHelper();
      if (hasConnection) {
        try {
          await FirebaseFirestore.instance
              .collection('todos')
              .doc(todo.id)
              .set({
                'id': todo.id,
                'title': todo.title,
                'isDone': todo.isDone,
                'isDeleted': todo.isDeleted,
              });

          todo.isSynced = true;
          await todo.save();
        } catch (e) {
          debugPrint('sync failed: $e');
        }
      }

      notifyListeners();
    }
  }

  void deleteTodo(String id) async {
    final todo = box.get(id);
    if (todo != null) {
      todo.isDeleted = true;
      todo.isSynced = false;
      await todo.save();

      final hasConnection = await SyncService.networkHelper();
      if (hasConnection) {
        try {
          await FirebaseFirestore.instance
              .collection('todos')
              .doc(todo.id)
              .delete();

          await box.delete(todo.id);
        } catch (e) {
          debugPrint('Failed delete : $e');
        }
      }

      notifyListeners();
    }
  }

  Future<void> syncToFirebase() async {
    final unsyncedTodos = box.values.where((todo) => !todo.isSynced).toList();

    for (var todo in unsyncedTodos) {
      try {
        if (todo.isDeleted) {
          await firestore.collection('todos').doc(todo.id).delete();
          await box.delete(todo.id);
        } else {
          await firestore.collection('todos').doc(todo.id).set({
            'id': todo.id,
            'title': todo.title,
            'isDone': todo.isDone,
          });
          todo.isSynced = true;
          await todo.save();
        }
      } catch (e) {
        debugPrint('Sync failed for ${todo.id}: $e');
      }
    }

    notifyListeners();
  }
}
