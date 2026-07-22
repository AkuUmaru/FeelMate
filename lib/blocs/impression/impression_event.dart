part of 'impression_bloc.dart';

abstract class ImpressionEvent {
  const ImpressionEvent();
}

/// Load all diary entries from SQLite.
class ImpressionLoadRequested extends ImpressionEvent {
  const ImpressionLoadRequested();
}

/// Add a new mood diary entry.
class ImpressionAddRequested extends ImpressionEvent {
  final int emoticon;
  final String text;
  final String date;
  const ImpressionAddRequested({
    required this.emoticon,
    required this.text,
    required this.date,
  });
}

/// Delete a diary entry by its SQLite ID.
class ImpressionDeleteRequested extends ImpressionEvent {
  final int id;
  const ImpressionDeleteRequested(this.id);
}
