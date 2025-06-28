part of 'userbloc_bloc.dart';

@immutable
sealed class UserblocEvent {}

class UserInitialEvent extends UserblocEvent {}

class RefreshEvent extends UserblocEvent {}
