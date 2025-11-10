# Lecture 15 -  Step 1 - Cloud Functions Installed and Run

Installed Cloud Functions with
```zsh
firebase init
```
and created `google_service_account.json` giving us the keys to access Firebase. This is added to gitignore along with node modules:
```zsh
**/node_modules
**/google_service_account.json
```

## Deploying functions
```zsh
firebase deploy --only functions
```

We can then call the function at the link provided:
```
https://us-central1-csen268-f25.cloudfunctions.net/helloWorld
```


