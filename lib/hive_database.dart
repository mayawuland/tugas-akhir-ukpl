import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'transaction_model.dart';

class HiveDatabase {
  static late Box<User> _userBox;

  static Future<void> init() async {
    // Initialize Hive
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);

    // Register adapter for User and Transaction models
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(TransactionAdapter());

    // Open user box
    _userBox = await Hive.openBox<User>('userBox');
  }

  static Future<void> addUser(User user) async {
    await _userBox.put(user.username, user); // Save user with username as key
  }

  static Future<void> updateUser(User newUser) async {
    await _userBox.put(newUser.username, newUser); // Update user with username as key
  }

  static Future<User?> getUserByUsername(String username) async {
    try {
      return _userBox.get(username);
    } catch (e) {
      print("Error getting user by username: $e");
      return null;
    }
  }

  static User? getUser(String username) {
    return _userBox.get(username); // Get user by username
  }

  static Future<void> deleteUser(String username) async {
    await _userBox.delete(username); // Delete user by username
  }

  static Future<void> close() async {
    await Hive.close();
  }
}
