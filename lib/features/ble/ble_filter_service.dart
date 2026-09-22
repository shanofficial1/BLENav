class BleFilterService {
  double _filtered = 0;

  bool _first = true;

  double filter(double value) {

    if (_first) {
      _filtered = value;
      _first = false;
      return value;
    }

    const alpha = 0.25;

    _filtered =
        _filtered + alpha * (value - _filtered);

    return _filtered;
  }

  void reset() {
    _filtered = 0;
    _first = true;
  }
}