import 'package:cloud_firestore/cloud_firestore.dart';

class NewsModel {
  const NewsModel({
    required this.id,
    required this.headline,
    required this.details,
    required this.timestamp,
    this.source,
    this.author,
  });

  final String id;
  final String headline;
  final String details;
  final DateTime? timestamp;
  final String? source;
  final String? author;

  factory NewsModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? <String, dynamic>{};
    return NewsModel(
      id: snapshot.id,
      headline: _readString(data, [
        'headline',
        'title',
      ], fallback: 'Cyber alert'),
      details: _readString(data, [
        'details',
        'summary',
        'content',
        'description',
      ], fallback: 'No details available.'),
      timestamp: _readTimestamp(data, [
        'timestamp',
        'publishedAt',
        'createdAt',
      ]),
      source: _nullableString(data['source']),
      author: _nullableString(data['author']),
    );
  }

  static String _readString(
    Map<String, dynamic> data,
    List<String> keys, {
    required String fallback,
  }) {
    for (final key in keys) {
      final value = _nullableString(data[key]);
      if (value != null && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return fallback;
  }

  static DateTime? _readTimestamp(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = data[key];
      if (value is Timestamp) {
        return value.toDate();
      }
      if (value is DateTime) {
        return value;
      }
      if (value is String) {
        return DateTime.tryParse(value);
      }
    }
    return null;
  }

  static String? _nullableString(Object? value) {
    if (value == null) {
      return null;
    }
    return value.toString();
  }
}
