import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:regres/model/usermodel.dart';
import 'package:regres/repository/userservice.dart';

part 'userbloc_event.dart';
part 'userbloc_state.dart';

class UserblocBloc extends Bloc<UserblocEvent, UserblocState> {
  final userservices = Userservice();
  int page = 1;
  int totalpage = 0;
  int total = 0;
  bool isFetching = false;
  List<UserModel> allUsers = [];

  UserblocBloc() : super(UserblocInitial()) {
    on<UserInitialEvent>(fetchusers);
    on<RefreshEvent>(refreshcall);
  }

  fetchusers(UserInitialEvent event, Emitter<UserblocState> emit) async {
    if (isFetching) return;
    isFetching = true;
    if (page == 1) emit(LoadingState());
    try {
      final resp = await userservices.getusers(page: page);
      final dataval = resp['data'] as List;
      totalpage = resp['total_pages'];
      total = resp['total'];
      if (dataval.isEmpty) {
        emit(SuccessState(userlist: allUsers, hasReachedMax: true));
      } else {
        List<UserModel> userlist =
            dataval.map((e) => UserModel.fromJson(e)).toList();
        allUsers.addAll(userlist);
        page++;
        emit(SuccessState(userlist: allUsers, hasReachedMax: false));
      }
    } catch (e) {
      emit(ErrorState(error: '$e'));
    } finally {
      isFetching = false;
    }
  }

  refreshcall(RefreshEvent event, Emitter<UserblocState> emit) async {
    page = 1;
    allUsers.clear();
    await fetchusers(UserInitialEvent(), emit);
  }
}
