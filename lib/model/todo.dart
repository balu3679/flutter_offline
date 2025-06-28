import 'package:hive/hive.dart';

part 'todo.g.dart';

@HiveType(typeId: 0)
class Todo extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  bool isSynced;

  @HiveField(3)
  bool isDone;

  @HiveField(4)
  bool isDeleted;

  Todo({
    required this.id,
    required this.title,
    this.isSynced = false,
    this.isDone = false,
    this.isDeleted = false,
  });
}
