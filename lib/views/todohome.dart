import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:regres/model/todo.dart';
import 'package:regres/provider/todoprovider.dart';

class TodoHome extends StatefulWidget {
  const TodoHome({super.key});

  @override
  State<TodoHome> createState() => _TodoHomeState();
}

class _TodoHomeState extends State<TodoHome> {
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Future.microtask(() {
    Provider.of<Todoprovider>(context, listen: false).fetchFromFirebase();
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todos')),
      body: Consumer<Todoprovider>(
        builder: (context, viewModel, _) => todoListView(viewModel),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final viewModel = context.read<Todoprovider>();
          final resp = await addtodos();
          if (resp) {
            viewModel.addTodo(controller.text);
            controller.clear();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  addtodos({Todo? todo}) async {
    bool isEdit = false;
    if (todo != null) {
      isEdit = true;
      controller.text = todo.title;
    }
    final resp = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'Edit Todo' : 'Add Todo'),
          content: TextFormField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Add Task'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(isEdit ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );

    return resp ?? false;
  }

  Widget todoListView(Todoprovider viewModel) {
    if (viewModel.isloading) {
      return Center(child: CircularProgressIndicator());
    }
    return ValueListenableBuilder(
      valueListenable: Hive.box<Todo>('todos').listenable(),
      builder: (context, Box<Todo> box, _) {
        final todos = box.values.where((t) => !t.isDeleted).toList();
        if (todos.isEmpty) {
          return Center(child: Text('No Todos Found!'));
        }
        return ListView.builder(
          itemCount: todos.length,
          padding: EdgeInsets.all(8),
          itemBuilder: (_, index) {
            final todo = todos[index];
            return Card(
              child: ListTile(
                title: Text(
                  todo.title,
                  style: TextStyle(
                    decoration: todo.isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                leading: Checkbox(
                  value: todo.isDone,
                  onChanged: (_) => viewModel.toggleDone(todo.id),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    todo.isSynced
                        ? const IconButton(
                          onPressed: null,
                          splashRadius: 20,
                          icon: Icon(Icons.cloud_done, color: Colors.green),
                        )
                        : const IconButton(
                          onPressed: null,
                          splashRadius: 20,
                          icon: Icon(Icons.cloud_upload, color: Colors.grey),
                        ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      splashRadius: 20,
                      onPressed: () async {
                        final viewModel = context.read<Todoprovider>();
                        final resp = await addtodos(todo: todo);
                        if (resp) {
                          viewModel.updateTodo(todo.id, controller.text);
                          controller.clear();
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      splashRadius: 20,
                      onPressed: () => viewModel.deleteTodo(todo.id),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
