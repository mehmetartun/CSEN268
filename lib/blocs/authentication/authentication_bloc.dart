import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:csen268/repositories/authentication/authentication_repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/user.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc(this.authenticationRepository)
    : super(AuthenticationInitial()) {
    on<AuthenticationWithEmailEvent>((event, emit) async {
      await _handleLogin(event, emit);
    });

    on<AuthenticationNewUserEvent>((event, emit) async {
      await _handleNewUser(event, emit);
    });
    on<AuthenticationErrorEvent>((event, emit) {
      _handleError(event, emit);
    });
    on<AuthenticationSignOutEvent>((event, emit) async {
      await _handleSignOut(event, emit);
    });

    on<AuthenticationNewUserRequestEvent>((event, emit) {
      _handleNewUserRequest(event, emit);
    });
  }
  final AuthenticationRepository authenticationRepository;
  User? user;

  void init() async {}

  Future<void> _handleSignOut(event, emit) async {
    emit(AuthenticationWaiting());
    await FirebaseFunctions.instance.httpsCallable('updateUserToken').call({
      'uid': user?.uid,
      'fcmToken': await FirebaseMessaging.instance.getToken() ?? '',
      'action': 'delete',
    });
    user = null;
    await authenticationRepository.signOut();
    emit(AuthenticationInitial());
  }

  void _handleError(event, emit) {
    emit(AuthenticationError(errorText: event.errorText));
  }

  Future<void> _handleLogin(event, emit) async {
    emit(AuthenticationWaiting());
    try {
      user = await authenticationRepository.signIn(
        email: event.email,
        password: event.password,
      );
      await FirebaseFunctions.instance.httpsCallable('updateUserToken').call({
        'uid': user?.uid,
        'fcmToken': await FirebaseMessaging.instance.getToken() ?? '',
        'action': 'add',
      });
      emit(AuthenticationAuthenticated());
      return;
    } catch (e) {
      emit(AuthenticationError(errorText: e.toString()));
      print(e);
    }
  }

  Future<void> _handleNewUser(event, emit) async {
    emit(AuthenticationWaiting());
    try {
      user = await authenticationRepository.newUser(
        email: event.email,
        password: event.password,
      );
      // await FirebaseFirestore.instance.collection("users").doc(user?.uid).set({
      //   'token': await FirebaseMessaging.instance.getToken(),
      // }, SetOptions(merge: true));

      await FirebaseFunctions.instance.httpsCallable('updateUserToken').call({
        'uid': user?.uid,
        'fcmToken': await FirebaseMessaging.instance.getToken() ?? '',
        'action': 'add',
      });

      emit(AuthenticationAuthenticated());
      return;
    } catch (e) {
      emit(AuthenticationError(errorText: e.toString()));
      print(e);
    }
  }

  void _handleNewUserRequest(event, emit) {
    emit(AuthenticationNewUser());
  }
}
