# Lecture 17 - 5 Testing Scrolling
In this case we shall build a user list and ensure that we have a list that we can scroll and tap.

To do this we start by creating a page with a `ListView` and create 10 mock users. In our [widget_test.dart](/test/widget_test.dart) file we first create a `ListView`:
```dart
  Widget createUserList() {
    return ListView(
        children: List.generate(20, (index) {
      return UserListTile(
          user: User(
              firstName: "First$index",
              lastName: "Last$index",
              imageUrl: "https://placehold.co/400x400",
              email: "first$index@last$index.com",
              uid: "$index"));
    }));
  }
```
which then gets injected into `createWidget` as child. The call to the tester is to expect a `ListView`. 

#### Checking ListView and the first item
```dart
    expect(find.byType(ListView), findsOne);
```
will pass. 

Similary checking if "First0 Last0" exists – corresponding to the first user on the list – will be done:
```dart
    expect(find.text("First0 Last0"), findsOne);
```
We can see that both these will pass.

#### Checking the Scroll Behaviour
To check the scroll behaviour we use  `tester.fling()` method. 
```dart
    ...
    await tester.fling(find.byType(ListView), Offset(0, -200), 400);
    await tester.pumpAndSettle();
    expect(find.text("First0 Last0"), findsNothing);
    ...
```
This means that we would scroll past the first item in the list and we would not find any text that matches this. Note that the origin on the screen is the upper left hand corner and an offset of (0,-200) means scroll down by 200 pixels. This passes as well.

Using `flutter run` instead of `flutter test` we can see this playing out on the simulator as seen in this video:

![Scroll Test](/assets/gifs/Testing%20Scroll%20Behaviour.gif)
