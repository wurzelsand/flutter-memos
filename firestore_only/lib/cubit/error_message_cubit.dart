import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'error_message_state.dart';

class ErrorMessageCubit extends Cubit<List<ErrorMessage>> {
  ErrorMessageCubit() : super(const []);

  void addErrorMessge(ErrorMessage errorMessage) {
    final errorMessages = state.toList();
    errorMessages.add(errorMessage);
    emit(errorMessages);
  }

  void removeErrorMessage(ErrorMessage errorMessage) {
    final errorMessages = state.toList();
    errorMessages.remove(errorMessage);
    emit(errorMessages);
  }
}
