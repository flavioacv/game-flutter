abstract interface class LocalStorageService {
  Future<void> setString(String key, String value);
  Future<String?> getString(String key);
  Future<void> setListString(String key, List<String> value);
  Future<List<String>?> getListString(String key);
  Future<void> remove(String key);
}
