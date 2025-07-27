// lib/core/network/api_response.dart

enum Status { loading, completed, error }

class ApiResponse<T> {
  final Status status;
  final T? data;
  final Exception? error;
  final String? errorMessage;

  ApiResponse.loading()
    : status = Status.loading,
      data = null,
      error = null,
      errorMessage = null;

  ApiResponse.completed(this.data)
    : status = Status.completed,
      error = null,
      errorMessage = null;

  ApiResponse.error(this.error, [this.errorMessage])
    : status = Status.error,
      data = null;

  bool get isLoading => status == Status.loading;
  bool get isCompleted => status == Status.completed;
  bool get isError => status == Status.error;

  @override
  String toString() {
    return "Status: $status, Data: $data, Error: $error, Error Message: $errorMessage";
  }
}
