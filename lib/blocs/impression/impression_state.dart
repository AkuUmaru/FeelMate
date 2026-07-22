part of 'impression_bloc.dart';

abstract class ImpressionState {
  const ImpressionState();
}

class ImpressionInitial extends ImpressionState {
  const ImpressionInitial();
}

class ImpressionLoading extends ImpressionState {
  const ImpressionLoading();
}

class ImpressionLoaded extends ImpressionState {
  final List<ImpressionModel> entries;
  const ImpressionLoaded(this.entries);
}

class ImpressionOperationSuccess extends ImpressionState {
  final String message;
  final List<ImpressionModel> entries;
  const ImpressionOperationSuccess(this.message, this.entries);
}

class ImpressionFailure extends ImpressionState {
  final String message;
  const ImpressionFailure(this.message);
}
