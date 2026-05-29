import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../config/firebase_options.dart';
import '../models/app_snapshot.dart';
import '../models/app_user.dart';
import '../models/boss_battle.dart';
import '../models/quest.dart';
import '../models/reward_badge.dart';
import '../models/user_settings.dart';
import '../services/gamification_service.dart';
import 'questify_repository.dart';

class FirebaseRepository implements QuestifyRepository {
  FirebaseRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth,
      _firestore = firestore;

  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;

  bool _initialized = false;

  @override
  Future<bool> isAvailable() async {
    return DefaultFirebaseOptions.currentPlatform != null;
  }

  @override
  Future<AppSnapshot?> restoreSession() async {
    await _ensureInitialized();
    final currentUser = _auth!.currentUser;
    if (currentUser == null) {
      return null;
    }

    return _loadSnapshot(
      currentUser.uid,
      fallbackName: currentUser.displayName ?? 'Student',
      fallbackEmail: currentUser.email ?? '',
    );
  }

  @override
  Future<AppSnapshot> signIn({
    required String email,
    required String password,
  }) async {
    await _ensureInitialized();
    try {
      final credential = await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _loadSnapshot(
        credential.user!.uid,
        fallbackName: credential.user?.displayName ?? 'Student',
        fallbackEmail: credential.user?.email ?? email,
      );
    } on FirebaseAuthException catch (error) {
      throw BackendException(_friendlyAuthError(error));
    }
  }

  @override
  Future<AppSnapshot> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _ensureInitialized();
    try {
      final credential = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(name);

      final snapshot = AppSnapshot(
        user: AppUser.initial(
          id: credential.user!.uid,
          name: name,
          email: email,
        ),
        settings: UserSettings.defaults(),
        quests: const <Quest>[],
        bossBattles: const <BossBattle>[],
        rewards: GamificationService.refreshRewards(
          user: AppUser.initial(
            id: credential.user!.uid,
            name: name,
            email: email,
          ),
          quests: const <Quest>[],
          bossBattles: const <BossBattle>[],
        ),
      );

      await persistSnapshot(snapshot);
      return snapshot;
    } on FirebaseAuthException catch (error) {
      throw BackendException(_friendlyAuthError(error));
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    await _ensureInitialized();
    try {
      await _auth!.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (error) {
      throw BackendException(_friendlyAuthError(error));
    }
  }

  @override
  Future<void> persistSnapshot(AppSnapshot snapshot) async {
    await _ensureInitialized();

    final userRef = _firestore!.collection('users').doc(snapshot.user.id);
    final batch = _firestore!.batch();

    batch.set(userRef, <String, dynamic>{
      ...snapshot.user.toMap(),
      'settings': snapshot.settings.toMap(),
    }, SetOptions(merge: true));

    await _syncCollection(
      batch: batch,
      collection: userRef.collection('quests'),
      documents: {for (final quest in snapshot.quests) quest.id: quest.toMap()},
    );
    await _syncCollection(
      batch: batch,
      collection: userRef.collection('bossBattles'),
      documents: {
        for (final boss in snapshot.bossBattles) boss.id: boss.toMap(),
      },
    );
    await _syncCollection(
      batch: batch,
      collection: userRef.collection('rewards'),
      documents: {
        for (final reward in snapshot.rewards) reward.id: reward.toMap(),
      },
    );

    await batch.commit();
  }

  @override
  Future<void> signOut() async {
    if (!_initialized && !await isAvailable()) {
      return;
    }
    await _ensureInitialized();
    await _auth!.signOut();
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) {
      return;
    }

    final options = DefaultFirebaseOptions.currentPlatform;
    if (options == null) {
      throw BackendException(
        'Firebase is not configured yet. Run flutterfire configure and replace lib/backend/config/firebase_options.dart.',
      );
    }

    await Firebase.initializeApp(options: options);
    _auth ??= FirebaseAuth.instance;
    _firestore ??= FirebaseFirestore.instance;
    _initialized = true;
  }

  Future<AppSnapshot> _loadSnapshot(
    String userId, {
    required String fallbackName,
    required String fallbackEmail,
  }) async {
    final userRef = _firestore!.collection('users').doc(userId);
    final futures = await Future.wait([
      userRef.get(),
      userRef.collection('quests').get(),
      userRef.collection('bossBattles').get(),
      userRef.collection('rewards').get(),
    ]);

    final userDoc = futures[0] as DocumentSnapshot<Map<String, dynamic>>;
    final questDocs =
        futures[1] as QuerySnapshot<Map<String, dynamic>>;
    final bossDocs =
        futures[2] as QuerySnapshot<Map<String, dynamic>>;
    final rewardDocs =
        futures[3] as QuerySnapshot<Map<String, dynamic>>;

    if (!userDoc.exists) {
      final initialUser = AppUser.initial(
        id: userId,
        name: fallbackName,
        email: fallbackEmail,
      );
      final snapshot = AppSnapshot(
        user: initialUser,
        settings: UserSettings.defaults(),
        quests: const <Quest>[],
        bossBattles: const <BossBattle>[],
        rewards: GamificationService.refreshRewards(
          user: initialUser,
          quests: const <Quest>[],
          bossBattles: const <BossBattle>[],
        ),
      );
      await persistSnapshot(snapshot);
      return snapshot;
    }

    final userData = Map<String, dynamic>.from(
      userDoc.data() ?? <String, dynamic>{},
    );
    final settingsMap = Map<String, dynamic>.from(
      userData['settings'] as Map? ?? <String, dynamic>{},
    );
    final quests = questDocs.docs
        .map(
          (doc) =>
              Quest.fromMap(<String, dynamic>{...doc.data(), 'id': doc.id}),
        )
        .toList();
    final bossBattles = bossDocs.docs
        .map(
          (doc) => BossBattle.fromMap(<String, dynamic>{
            ...doc.data(),
            'id': doc.id,
          }),
        )
        .toList();
    final rewards = rewardDocs.docs
        .map(
          (doc) => RewardBadge.fromMap(<String, dynamic>{
            ...doc.data(),
            'id': doc.id,
          }),
        )
        .toList();

    return AppSnapshot(
      user: AppUser.fromMap(<String, dynamic>{
        ...userData,
        'id': userId,
        'name': userData['name'] ?? fallbackName,
        'email': userData['email'] ?? fallbackEmail,
      }),
      settings: UserSettings.fromMap(settingsMap),
      quests: quests,
      bossBattles: bossBattles,
      rewards: rewards,
    );
  }

  Future<void> _syncCollection({
    required WriteBatch batch,
    required CollectionReference<Map<String, dynamic>> collection,
    required Map<String, Map<String, dynamic>> documents,
  }) async {
    final existing = await collection.get();
    final incomingIds = documents.keys.toSet();

    for (final doc in existing.docs) {
      if (!incomingIds.contains(doc.id)) {
        batch.delete(collection.doc(doc.id));
      }
    }

    for (final entry in documents.entries) {
      batch.set(
        collection.doc(entry.key),
        entry.value,
        SetOptions(merge: true),
      );
    }
  }

  String _friendlyAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'The email or password is incorrect.';
      case 'email-already-in-use':
        return 'That email is already registered.';
      case 'weak-password':
        return 'Use a stronger password with at least 6 characters.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      default:
        return error.message ?? 'Firebase authentication failed.';
    }
  }
}
