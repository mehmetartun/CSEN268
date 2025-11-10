# Lecture 15 -  Step 3 - Event Triggers

In this section we implemented the event trigger due to Firestore database document creation. We need to import:
```javascript
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
```
in order to use this function.

Setting up the trigger is done first by creating this function and then deploying it.
```javascript
exports.onUserCreated = onDocumentCreated("/function_test/{userId}" , async (event)=>{
  await getFirestore().collection('log_test').add(
    {
      'userId':event.params.userId,
      'createTime':event.data.createTime,
    }
  )
});
```
This matches any document with a path `/function_test/{userId}` and whenever a document with this pattern is created, it triggers this function. In turn we can act on this data. The `userId` in the **pattern** `"/function_test/{userId}"` is  a property of the `event.params` object.

# Deploying
When first time deploying triggered function you may get this error:
```zsh
⚠  functions: Since this is your first time using 2nd gen functions, we need a little bit longer to finish setting everything up. Retry the deployment in a few minutes.
⚠  functions:  failed to create function projects/csen268-f25/locations/us-central1/functions/onUserCreated
Failed to create function projects/csen268-f25/locations/us-central1/functions/onUserCreated
```
Just follow the instructions and wait for a few minutes before deploying again.