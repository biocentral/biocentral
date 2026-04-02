import 'dart:async';

import 'package:biocentral/sdk/util/constants.dart';

mixin ProjectLoadingContext {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void enterProjectLoadingContext() {
    _isLoading = true;
  }

  void exitProjectLoadingContext() {
    // TODO [Refactoring] A bit of a hacky solution here to decouple auto-saving from the project repository
    Future.delayed(Duration(seconds: Constants.autoSaveDebounceTime.inSeconds + 2))
        .then((_) async => _isLoading = false);
  }
}
