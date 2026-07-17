import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/news_model.dart';

class NewsRepository {
  NewsRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<NewsModel>> getVerifiedNews() {
    return _firestore
        .collection('cyber_news')
        .where('status', isEqualTo: 'Published')
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs
              .map(NewsModel.fromFirestore)
              .toList(growable: false);
          items.sort((a, b) {
            final left = a.timestamp;
            final right = b.timestamp;
            if (left == null && right == null) {
              return 0;
            }
            if (left == null) {
              return 1;
            }
            if (right == null) {
              return -1;
            }
            return right.compareTo(left);
          });
          return items;
        })
        .handleError((Object error, StackTrace stackTrace) {
          throw NewsRepositoryException.from(error);
        });
  }

  Future<void> submitUserReport(String headline, String details) async {
    final safeHeadline = headline.trim();
    final safeDetails = details.trim();

    if (safeHeadline.isEmpty || safeDetails.isEmpty) {
      throw const NewsRepositoryException(
        'Please enter both headline and details.',
      );
    }

    try {
      await _firestore.collection('cyber_news').add({
        'headline': safeHeadline,
        'content': safeDetails,
        'details': safeDetails,
        'status': 'Pending',
        'publishedAt': FieldValue.serverTimestamp(),
        'source': 'cyber_uday_dashboard',
      });
    } on FirebaseException catch (error) {
      throw NewsRepositoryException.from(error);
    } catch (_) {
      throw const NewsRepositoryException(
        'Unable to submit the report. Please try again.',
      );
    }
  }
}

class NewsRepositoryException implements Exception {
  const NewsRepositoryException(this.message);

  final String message;

  factory NewsRepositoryException.from(Object error) {
    if (error is NewsRepositoryException) {
      return error;
    }
    if (error is FirebaseException) {
      return NewsRepositoryException(_firebaseMessage(error));
    }
    return const NewsRepositoryException(
      'Unable to load cyber news. Please refresh and try again.',
    );
  }

  static String _firebaseMessage(FirebaseException error) {
    return switch (error.code) {
      'permission-denied' =>
        'You do not have permission to access the news feed.',
      'unavailable' =>
        'Firestore is temporarily unavailable. Please try again shortly.',
      'failed-precondition' =>
        'The news feed requires a Firestore index or updated configuration.',
      _ => 'Unable to reach Firestore. Please try again.',
    };
  }

  @override
  String toString() => message;
}
