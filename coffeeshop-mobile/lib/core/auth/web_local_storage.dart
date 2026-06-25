import 'package:web/web.dart';

String? webStorageRead(String key) => window.localStorage.getItem(key);

void webStorageWrite(String key, String value) {
  window.localStorage.setItem(key, value);
}

void webStorageRemove(String key) {
  window.localStorage.removeItem(key);
}
