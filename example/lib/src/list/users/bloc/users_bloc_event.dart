part of 'users_bloc.dart';

class UsersEvent extends ListEvent<User> {}

class UsersEventChangeScrollIndex extends UsersEvent {
  final int index;
  UsersEventChangeScrollIndex({required this.index});
}
