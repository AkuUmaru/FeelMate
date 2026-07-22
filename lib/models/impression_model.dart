import 'package:equatable/equatable.dart';

/// Domain model for a local SQLite mood diary entry.
class ImpressionModel extends Equatable {
  final int id;
  final int emoticon; // 1–5 rating
  final String text;
  final String date;

  const ImpressionModel({
    required this.id,
    required this.emoticon,
    required this.text,
    required this.date,
  });

  factory ImpressionModel.fromMap(Map<String, dynamic> map) => ImpressionModel(
        id: map['id'] as int,
        emoticon: map['emoticon'] as int,
        text: map['text'] as String,
        date: map['date'] as String,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'emoticon': emoticon,
        'text': text,
        'date': date,
      };

  @override
  List<Object?> get props => [id, emoticon, text, date];
}
