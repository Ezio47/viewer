// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class RialtoArgumentError extends ArgumentError {
    RialtoArgumentError(String message) : super(message);
}

class RialtoStateError extends StateError {
    RialtoStateError(String message) : super(message);
}

class RialtoUnimplementedError extends UnimplementedError {
    RialtoUnimplementedError(String message) : super(message);
}
