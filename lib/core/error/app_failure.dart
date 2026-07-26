/// A typed application failure that preserves its original cause and stack.
sealed class AppFailure implements Exception {
  const AppFailure({required this.message, this.cause, this.stackTrace});

  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() => '$runtimeType: $message';
}

class StorageFailure extends AppFailure {
  const StorageFailure({
    required this.operation,
    required Object cause,
    required StackTrace stackTrace,
  }) : super(
         message: 'Storage operation failed: $operation',
         cause: cause,
         stackTrace: stackTrace,
       );

  final String operation;
}

class NotFoundFailure extends AppFailure {
  const NotFoundFailure({required this.resource, required this.identifier})
    : super(message: '$resource was not found: $identifier');

  final String resource;
  final String identifier;
}

class CorruptDataFailure extends AppFailure {
  const CorruptDataFailure({
    required this.resource,
    required Object cause,
    required StackTrace stackTrace,
  }) : super(
         message: 'Stored $resource data is invalid.',
         cause: cause,
         stackTrace: stackTrace,
       );

  final String resource;
}

class ConstraintFailure extends AppFailure {
  const ConstraintFailure({required this.constraint})
    : super(message: 'Constraint violated: $constraint');

  final String constraint;
}
