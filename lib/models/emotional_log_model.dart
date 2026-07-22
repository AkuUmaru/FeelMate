import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Domain model for a single emotion classification result.
class EmotionalLogModel extends Equatable {
  final String id;
  final String emotion;
  final double confidence;
  final DateTime timestamp;
  final String? notes;

  const EmotionalLogModel({
    required this.id,
    required this.emotion,
    required this.confidence,
    required this.timestamp,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'emotion': emotion,
        'confidence': confidence,
        'timestamp': Timestamp.fromDate(timestamp),
        'notes': notes,
      };

  factory EmotionalLogModel.fromMap(Map<String, dynamic> map, String id) =>
      EmotionalLogModel(
        id: id,
        emotion: map['emotion'] as String? ?? 'unknown',
        confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
        timestamp:
            (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
        notes: map['notes'] as String?,
      );

  EmotionalLogModel copyWith({
    String? id,
    String? emotion,
    double? confidence,
    DateTime? timestamp,
    String? notes,
  }) =>
      EmotionalLogModel(
        id: id ?? this.id,
        emotion: emotion ?? this.emotion,
        confidence: confidence ?? this.confidence,
        timestamp: timestamp ?? this.timestamp,
        notes: notes ?? this.notes,
      );

  @override
  List<Object?> get props => [id, emotion, confidence, timestamp, notes];
}
