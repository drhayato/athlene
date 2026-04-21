import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:athlene/services/location_service.dart';
import 'package:athlene/theme/app_theme.dart';
import 'package:athlene/components/glass_card.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final LocationService _locationService = LocationService();
  final MapController _mapController = MapController();
  Position? _currentPosition;
  int _selectedInterval = 30;
  bool _showHistory = false;
  
  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  void _initLocation() async {
    _locationService.positionStream.listen((Position position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
        _mapController.move(LatLng(position.latitude, position.longitude), _mapController.camera.zoom);
      }
    });

    try {
      Position pos = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() => _currentPosition = pos);
        _mapController.move(LatLng(pos.latitude, pos.longitude), 16);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    bool isTracking = _locationService.isTracking;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: Stack(
        children: [
          _buildMap(isDark),
          _buildOverlay(isDark, isTracking),
          if (_showHistory) _buildHistoryDrawer(isDark),
        ],
      ),
    );
  }

  Widget _buildMap(bool isDark) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentPosition != null 
          ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
          : const LatLng(0, 0),
        initialZoom: 16,
      ),
      children: [
        TileLayer(
          urlTemplate: isDark 
            ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
            : 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.hayato.ka_app',
          tileProvider: NetworkTileProvider(),
        ),
        // Path Dots (Interactive)
        MarkerLayer(
          markers: _locationService.path.asMap().entries.map((entry) {
            final index = entry.key;
            final point = entry.value;
            final isRef = _locationService.referencePoint == point;
            
            return Marker(
              point: point,
              width: 12,
              height: 12,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _locationService.setReferencePoint(point);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Reference point set to Point #${index + 1}"),
                      duration: const Duration(seconds: 1),
                      backgroundColor: AppTheme.neonCyan,
                    )
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isRef ? Colors.white : AppTheme.neonCyan.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: isRef ? 2 : 1),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        // Current Position Marker
        if (_currentPosition != null)
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                width: 24,
                height: 24,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.neonCyan,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(color: AppTheme.neonCyan.withValues(alpha: 0.8), blurRadius: 20)
                    ],
                  ),
                  child: const Center(child: Icon(LucideIcons.navigation, size: 12, color: Colors.black)),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildOverlay(bool isDark, bool isTracking) {
    double totalKm = _locationService.totalDistance / 1000;
    double displacementKm = _locationService.calculateDisplacementFromRef() / 1000;
    double kcal = _locationService.calculateCalories();

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTinyCard(isDark, LucideIcons.mapPin, "LAT", _currentPosition?.latitude.toStringAsFixed(4) ?? "0.0000"),
                _buildTinyCard(isDark, LucideIcons.mapPin, "LONG", _currentPosition?.longitude.toStringAsFixed(4) ?? "0.0000"),
                _buildOfflineIndicator(isDark),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Interval Record Toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildIntervalSelector(isDark),
                const SizedBox(width: 12),
                _buildCircleButton(isDark, LucideIcons.list, () {
                  setState(() => _showHistory = !_showHistory);
                }),
              ],
            ),
          ),
          
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.all(24.0),
            child: GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMainStat("TOTAL KM", totalKm.toStringAsFixed(2), isDark),
                      _buildMainStat("DISP KM", displacementKm.toStringAsFixed(2), isDark),
                      _buildMainStat("KCAL", kcal.toStringAsFixed(1), isDark),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildControlButton(
                        isDark, 
                        isTracking ? LucideIcons.pause : LucideIcons.play, 
                        isTracking ? "STOP" : "START", 
                        isTracking ? Colors.redAccent : AppTheme.neonCyan,
                        () {
                          setState(() {
                            if (isTracking) {
                              _locationService.stopTracking();
                            } else {
                              _locationService.startTracking();
                            }
                          });
                        }
                      ),
                      if (!isTracking && _locationService.path.isNotEmpty) ...[
                        const SizedBox(width: 20),
                        _buildControlButton(
                          isDark, 
                          LucideIcons.rotateCcw, 
                          "RESET", 
                          Colors.white24,
                          () {
                            setState(() {
                              _locationService.resetTracking();
                            });
                          }
                        ),
                      ]
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryDrawer(bool isDark) {
    return Positioned(
      top: 100,
      left: 20,
      right: 20,
      bottom: 250,
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("INTERVAL RECORDS", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 16)),
                IconButton(icon: const Icon(LucideIcons.x, color: Colors.white), onPressed: () => setState(() => _showHistory = false)),
              ],
            ),
            const Divider(color: Colors.white24),
            Expanded(
              child: _locationService.intervalHistory.isEmpty 
              ? const Center(child: Text("No records yet", style: TextStyle(color: Colors.white38)))
              : ListView.builder(
                itemCount: _locationService.intervalHistory.length,
                itemBuilder: (context, index) {
                  final record = _locationService.intervalHistory[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.white10)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("#${index + 1}", style: const TextStyle(color: AppTheme.neonCyan, fontWeight: FontWeight.bold)),
                        Text(DateFormat('mm:ss').format(record.timestamp), style: const TextStyle(color: Colors.white70)),
                        Text("${record.displacement.toStringAsFixed(1)} m disp", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntervalSelector(bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      opacity: 0.1,
      child: DropdownButton<int>(
        value: _selectedInterval,
        dropdownColor: Colors.black.withValues(alpha: 0.9),
        underline: Container(),
        icon: const Icon(LucideIcons.clock, size: 16, color: AppTheme.neonCyan),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        items: [10, 30, 60, 300].map((int value) {
          return DropdownMenuItem<int>(
            value: value,
            child: Text("${value}s", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          );
        }).toList(),
        onChanged: (val) {
          if (val != null) {
            setState(() {
              _selectedInterval = val;
              _locationService.setInterval(val);
            });
          }
        },
      ),
    );
  }

  Widget _buildCircleButton(bool isDark, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildOfflineIndicator(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          const Text("OFFLINE GPS", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTinyCard(bool isDark, IconData icon, String label, String value) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      opacity: 0.1,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: isDark ? AppTheme.neonCyan : Colors.black45),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: isDark ? Colors.white38 : Colors.black26)),
              Text(value, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainStat(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: isDark ? AppTheme.neonCyan : Colors.black38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 24, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildControlButton(bool isDark, IconData icon, String label, Color color, VoidCallback onTap) {
    bool isStart = label == "START";
    bool isStop = label == "STOP";

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isStart 
            ? const Color(0xFF007AFF) // Premium iOS Blue
            : isStop 
              ? const Color(0xFFFF3B30) // Reliable System Red
              : Colors.transparent,
          border: Border.all(
            color: (isStart || isStop) ? Colors.transparent : Colors.white24,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              color: (isStart || isStop) ? Colors.white : (isDark ? Colors.white70 : Colors.black54), 
              size: 18
            ),
            const SizedBox(width: 8),
            Text(
              label, 
              style: TextStyle(
                color: (isStart || isStop) ? Colors.white : (isDark ? Colors.white : Colors.black), 
                fontWeight: FontWeight.w700, 
                fontSize: 14, 
                letterSpacing: 1.2
              )
            ),
          ],
        ),
      ),
    );
  }
}
