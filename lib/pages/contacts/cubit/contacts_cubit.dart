import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

part 'contacts_state.dart';

enum PermissionType { readOnly, full, none }

class ContactsCubit extends Cubit<ContactsState> {
  ContactsCubit() : super(ContactsInitial());

  PermissionType permissionType = PermissionType.none;
  List<Contact> contacts = [];

  void init() async {
    if (await FlutterContacts.requestPermission()) {
      permissionType = PermissionType.full;
      contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
        withAccounts: true,
      );
      emit(ContactsPermissionFullAccess(contacts: contacts));
      return;
    } else {
      if (Platform.isAndroid) {
        if (await FlutterContacts.requestPermission(readonly: true)) {
          permissionType = PermissionType.readOnly;
          contacts = await FlutterContacts.getContacts(withAccounts: true);
          emit(ContactsPermissionReadOnly(contacts: contacts));
          return;
        }
      }
    }
    emit(ContactsPermissionDenied());
  }

  void editContact(Contact contact) {
    emit(ContactEdit(contact: contact));
  }

  void saveContact(Contact contact) async {
    emit(WaitingState());
    await contact.update();
    emit(ContactsPermissionFullAccess(contacts: contacts));
  }
}
