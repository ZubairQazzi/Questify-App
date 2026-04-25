import '../models/app_snapshot.dart';

class BackendException implements Exception {
  BackendException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract class QuestifyRepository {
  Future<bool> isAvailable();

  Future<AppSnapshot?> restoreSession();

  Future<AppSnapshot> signIn({required String email, required String password});

  Future<AppSnapshot> register({
    required String name,
    required String email,
    required String password,
  });

  Future<void> persistSnapshot(AppSnapshot snapshot);

  Future<void> signOut();
}
