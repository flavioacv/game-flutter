

import 'package:pixel_adventure/core/services/local_storage/local_storage_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'local_storage_service.dart';

class LocalStorageServiceImpl implements LocalStorageService {
  @override
  Future<String?> getString(String key) async {
    var sharedPreferences = await SharedPreferences.getInstance();
    try {
      return sharedPreferences.getString(key);
    } catch (e, stackTrace) {
      throw LocalStorageException(
        message: e.toString(),
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> remove(String key) async {
    var sharedPreferences = await SharedPreferences.getInstance();
    try {
      await sharedPreferences.remove(key);
    } catch (e, stackTrace) {
      throw LocalStorageException(
        message: e.toString(),
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> setString(String key, String value) async {
    var sharedPreferences = await SharedPreferences.getInstance();
    try {
      await sharedPreferences.setString(key, value);
    } catch (e, stackTrace) {
      throw LocalStorageException(
        message: e.toString(),
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<String>?> getListString(String key) async {
    var sharedPreferences = await SharedPreferences.getInstance();
    try {
      return sharedPreferences.getStringList(key);
    } catch (e, stackTrace) {
      throw LocalStorageException(
        message: e.toString(),
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> setListString(String key, List<String> value) async {
    var sharedPreferences = await SharedPreferences.getInstance();
    try {
      await sharedPreferences.setStringList(key, value);
    } catch (e, stackTrace) {
      throw LocalStorageException(
        message: e.toString(),
        stackTrace: stackTrace,
      );
    }
  }
}
