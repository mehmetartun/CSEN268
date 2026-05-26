# Lecture 16 - 5 Firebase Cloud Messaging for Individual Users

## Test Cloud Function for Messaging
Test function for sending a Firebase Cloud Message to users based on their stored FCM Tokens is added to `index.js` in the `functions` directory:
```javascript
exports.sendNotification = onCall(async (request) => {
    const email = request.data.email;
    const message = request.data.message;
    const db = getFirestore();
    const userRef = db.collection('users').where('email', '==', email);
    const qs = await userRef.get();
    if (qs.empty) {
        return { 'error': 'User not found' };
    }
    const user = qs.docs[0].data();
    const fcmTokens = user.fcmTokens;
    if (!fcmTokens || fcmTokens.length === 0) {
        response.status(404).send('No Token Found');
        return;
    }
    var messages = [];
    fcmTokens.forEach(token => {
        messages.push({ 'token': token, 'notification': { 'title': 'Test', 'body': message } });
    });
    await getMessaging().sendEach(messages);
    return { 'success': 'Success' };
});
```

## Testing page
In the app, we modify the `MessagingPage` to expose current logged in user and send a message to the current user.
```dart
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
```