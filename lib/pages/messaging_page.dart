import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MessagingPage extends StatefulWidget {
  const MessagingPage({super.key});

  @override
  State<MessagingPage> createState() => _MessagingPageState();
}

class _MessagingPageState extends State<MessagingPage> {
  String installationId = "Unknown";
  String? token = "Unknown";
  final _formKey = GlobalKey<FormState>();
  String? fcmMessage;

  @override
  void initState() {
    getInstallationId();
    super.initState();
  }

  void getInstallationId() async {
    installationId = await FirebaseInstallations.instance.getId();
    token = await FirebaseMessaging.instance.getToken() ?? "Unknown";
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Messaging")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Installation Id",
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                Text(
                  installationId,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                FilledButton(
                  child: Text("Copy to Clipboard"),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: installationId));
                  },
                ),
                Divider(),
                Text(
                  "Messaging Token",
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                Text(
                  token!,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                FilledButton(
                  child: Text("Copy to Clipboard"),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: token!));
                  },
                ),
                Divider(height: 40),
                Text("User Email"),
                SizedBox(height: 5),
                Text(
                  FirebaseAuth.instance.currentUser?.email ??
                      "No User Logged In",
                ),
                SizedBox(height: 10),
                TextFormField(
                  initialValue: "",
                  onSaved: (val) {
                    fcmMessage = val;
                  },
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Message cannot be empty";
                    } else {
                      return null;
                    }
                  },
                ),
                SizedBox(height: 10),
                FilledButton(
                  child: Text("Send Message"),
                  onPressed: () async {
                    if (_formKey.currentState!.validate() &&
                        FirebaseAuth.instance.currentUser?.email != null) {
                      _formKey.currentState!.save();
                      var res = await FirebaseFunctions.instance
                          .httpsCallable('sendNotification')
                          .call({
                            'email': FirebaseAuth.instance.currentUser!.email,
                            'message': fcmMessage,
                          });
                      if (res.data['success'] != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Message Sent to ${FirebaseAuth.instance.currentUser!.email} tokens',
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Message could not be ${FirebaseAuth.instance.currentUser!.email} tokens',
                            ),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
