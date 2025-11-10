
# Lecture 15 -  Step 2 - Calling Cloud functions From the App


## Calling functions
The method to call the functions from the app is via:
```dart
  final HttpsCallable helloWorldCall = FirebaseFunctions.instance.httpsCallable(
    'helloWorldCall',
  );
```

## Calling a database function


declaring the callable function in Flutter. Then the call is made by passing a `data` map to the callable function:
```dart
final HttpsCallable helloWorldCall = 
  FirebaseFunctions.instance.httpsCallable(
                  'addDataCall',
                );
HttpsCallableResult result = await addDataCall.call({
                  'collection': 'function_test',
                  'map': {'firstName': 'John', 'lastName': 'Doe'},
                });
```

The result that comes back has a property called `data` which contains the returned value.

On the functions side, we initialize the app to connect to Firestore
```javascript
initializeApp();
```

To connect to Firestore we call:
```javascript
  var collection = request.data['collection'];
  var map = request.data['map'];
  var documentReference = await getFirestore().collection(collection).add(map);
```

To write data (in this case `map`) to the given collection as a new document. Returned documentReference can then be used if necessary.



