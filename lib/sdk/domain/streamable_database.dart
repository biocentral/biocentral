import 'dart:async';

mixin StreamableDatabase<S> {
  final _databaseController = StreamController<S>.broadcast();

  Stream<S> get databaseStream => _databaseController.stream;

  S toStreamable();

  void updateStream() {
    _databaseController.add(toStreamable());
  }
}