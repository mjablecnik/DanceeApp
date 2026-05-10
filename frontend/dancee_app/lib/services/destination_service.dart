class DestinationService {
  String? _intendedDestination;

  void setDestination(String route) {
    _intendedDestination = route;
  }

  /// Returns and clears the stored destination. Returns null if none stored.
  String? consumeDestination() {
    final dest = _intendedDestination;
    _intendedDestination = null;
    return dest;
  }

  bool get hasDestination => _intendedDestination != null;
}
