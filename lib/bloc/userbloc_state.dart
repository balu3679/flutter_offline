part of 'userbloc_bloc.dart';

@immutable
sealed class UserblocState {}

final class UserblocInitial extends UserblocState {}

class LoadingState extends UserblocState {}

class ErrorState extends UserblocState {
  final String error;

  ErrorState({required this.error});
}

class SuccessState extends UserblocState {
  final List<UserModel> userlist;
  final bool hasReachedMax;

  SuccessState({required this.userlist, this.hasReachedMax = false});
}
