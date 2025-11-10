// This is an enhanced enum

enum MyNavigatorRoute {
  home("/", "home"),
  images("images", "images"),
  map("map", "map"),
  contacts("contacts", "contacts"),
  signIn("signIn", "signIn"),
  database("database", "database"),
  dialogs("dialogs", "dialogs"),
  futureBuilder("futureBuilder", "futureBuilder"),
  streamBuilder("streamBuilder", "streamBuilder"),
  shimmer("shimmer", "shimmer"),
  webView("webview", "webview"),
  inAppWebView("inappwebview", "inappwebview"),
  functionsDemo("functionsDemo", "functionsDemo"),
  messaging("messaging", "messaging");

  const MyNavigatorRoute(this.path, this.name);

  final String path;
  final String name;
}

enum StandardEnum { large, medium, small }
