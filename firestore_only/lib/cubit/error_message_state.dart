part of 'error_message_cubit.dart';

class ErrorMessage extends Equatable {
  const ErrorMessage({required this.message, required this.type});
  final String message;
  final Type type;

  @override
  List<Object?> get props => [message, type];
}
