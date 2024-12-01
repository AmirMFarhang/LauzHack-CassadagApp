import 'dart:async';

import 'package:flutter/cupertino.dart';

class Debounce {
  final VoidCallback _function;
  final Duration? _duration;
  Timer? _timer;
  int? _lastCompletionTime;

  Debounce(this._duration, this._function)
      : assert(_duration != null, "Duration can not be null"),
        assert(_function != null, "Function can not be null");

  void schedule() {
    var now = DateTime.now().millisecondsSinceEpoch;

    if (_timer == null || (_timer != null && !_timer!.isActive)) {
      _lastCompletionTime = now + _duration!.inMilliseconds;
      _timer = Timer(_duration!, _function);
    } else {
      _timer?.cancel(); // doesn't throw exception if _timer is not active
      int wait = _lastCompletionTime! -
          now; // this uses last wait time, so we need to wait only for calculated wait time
      _lastCompletionTime = now + wait;
      _timer = Timer(Duration(milliseconds: wait), _function);
    }
  }
}
