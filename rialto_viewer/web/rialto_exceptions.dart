library rialto_exception;

import 'dart:core';

class RialtoArgumentError extends ArgumentError {
    RialtoArgumentError(String message) : super(message);
}

class RialtoStateError extends StateError {
    RialtoStateError(String message) : super(message);
}

class RialtoUnimplementedError extends UnimplementedError {
    RialtoUnimplementedError(String message) : super(message);
}
