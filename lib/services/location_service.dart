import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class IntervalRecord {
  final DateTime timestamp;
  final double displacement;
  final double totalDistance;

  IntervalRecord({
    required this.timestamp,
    required this.displacement,
    required this.totalDistance,
  });
}

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  StreamSubscription<Position>? _positionSubscription;
  final StreamController<Position> _positionController = StreamController<Position>.broadcast();
  Stream<Position> get positionStream => _positionController.stream;

  final List<LatLng> _path = [];
  List<LatLng> get path => List.unmodifiable(_path);

  double _totalDistance = 0.0;
  double get totalDistance => _totalDistance;

  Position? _startPosition;
  Position? _currentPosition;

  bool _isTracking = false;
  bool get isTracking => _isTracking;

  // Interval Recording
  Timer? _intervalTimer;
  final List<IntervalRecord> _intervalHistory = [];
  List<IntervalRecord> get intervalHistory => List.unmodifiable(_intervalHistory);
  int _intervalSeconds = 30; // Default
  Position? _intervalStartPoint;

  void setInterval(int seconds) {
    _intervalSeconds = seconds;
    if (_isTracking) {
      _resetIntervalTimer();
    }
  }

  // Reference Point for stats (Defaults to start position)
  LatLng? _referencePoint;
  LatLng? get referencePoint => _referencePoint;
  void setReferencePoint(LatLng point) {
    _referencePoint = point;
  }

  Future<bool> handlePermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    return permission != LocationPermission.deniedForever;
  }

  void startTracking() async {
    if (_isTracking) return;
    
    bool hasPermission = await handlePermission();
    if (!hasPermission) return;

    _path.clear();
    _totalDistance = 0.0;
    _startPosition = null;
    _currentPosition = null;
    _intervalHistory.clear();
    _referencePoint = null;
    _isTracking = true;

    _resetIntervalTimer();

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 3, 
      ),
    ).listen((Position position) {
      _startPosition ??= position;
      _intervalStartPoint ??= position;
      
      if (_currentPosition != null) {
        double distance = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          position.latitude,
          position.longitude,
        );
        _totalDistance += distance;
      }

      _currentPosition = position;
      _path.add(LatLng(position.latitude, position.longitude));
      _positionController.add(position);
    });
  }

  void _resetIntervalTimer() {
    _intervalTimer?.cancel();
    _intervalTimer = Timer.periodic(Duration(seconds: _intervalSeconds), (timer) {
      if (!_isTracking || _currentPosition == null || _intervalStartPoint == null) return;

      double disp = Geolocator.distanceBetween(
        _intervalStartPoint!.latitude,
        _intervalStartPoint!.longitude,
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      _intervalHistory.add(IntervalRecord(
        timestamp: DateTime.now(),
        displacement: disp,
        totalDistance: _totalDistance,
      ));

      _intervalStartPoint = _currentPosition;
    });
  }

  void stopTracking() {
    _positionSubscription?.cancel();
    _intervalTimer?.cancel();
    _isTracking = false;
  }

  void resetTracking() {
    stopTracking();
    _path.clear();
    _totalDistance = 0.0;
    _startPosition = null;
    _currentPosition = null;
    _intervalHistory.clear();
    _referencePoint = null;
  }

  double calculateDisplacementFromRef() {
    if (_currentPosition == null) return 0.0;
    
    // If no reference point set, use start position
    double refLat = _referencePoint?.latitude ?? _startPosition?.latitude ?? _currentPosition!.latitude;
    double refLng = _referencePoint?.longitude ?? _startPosition?.longitude ?? _currentPosition!.longitude;

    return Geolocator.distanceBetween(
      refLat,
      refLng,
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );
  }

  double calculateCalories() {
    // Basic MET formula: 3.5 METs for walking
    // kcal = MET * weight_kg * time_hours
    // Assuming 70kg weight for now
    // Since we don't have accurate time from start, we can estimate based on distance or actual elapsed time
    // Let's use distance: ~0.05 kcal per meter for average walking
    return _totalDistance * 0.05;
  }

  void dispose() {
    stopTracking();
    _positionController.close();
  }
}
