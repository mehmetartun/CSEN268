import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

import '../../../model/user.dart';

part 'database_state.dart';

class DatabaseCubit extends Cubit<DatabaseState> {
  DatabaseCubit() : super(DatabaseInitial());
  List<User> users = [];
  final db = FirebaseFirestore.instance;

  Future<void> getUsers() async {
    var qs = await db.collection('users').get();
    users = qs.docs.map((doc) {
      print(doc.data());
      return User.fromMap(doc.data());
    }).toList();
  }

  void init() async {
    emit(DatabaseLoading());
    await getUsers();
    emit(DatabaseLoaded(users: users));
  }

  void deleteUser(User user) async {
    await db.doc('users/${user.uid}').delete();
    await getUsers();
    emit(DatabaseLoaded(users: users));
  }

  void showInsertView() {
    emit(DatabaseInsert());
  }

  void insertUser(User user) async {
    emit(DatabaseLoading());
    // await db.collection('users').add(user.toMap());
    await db.doc('users/${user.uid}').set(user.toMap());
    await getUsers();
    emit(DatabaseLoaded(users: users));
  }
}
