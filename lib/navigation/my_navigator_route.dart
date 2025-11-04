// This is an enhanced enum

enum MyNavigatorRoute {
  home("/", "home"),
  images("images", "images"),
  map("map", "map"),
  contacts("contacts", "contacts"),
  signIn("signIn", "signIn"),
  database("database", "database"),
  dialogs("dialogs", "dialogs"),
  messaging("messaging", "messaging");

  const MyNavigatorRoute(this.path, this.name);

  final String path;
  final String name;
}

enum StandardEnum { large, medium, small }
