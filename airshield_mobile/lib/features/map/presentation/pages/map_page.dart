import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart' hide Path;

import '../../data/models/station.dart';
import '../../data/repositories/map_repository.dart';
import '../bloc/map_bloc.dart';

/// Map Page
/// 
/// Displays AQI stations on an interactive map
class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MapBloc(repository: MapRepository())..add(const LoadStations()),
      child: const _MapPageContent(),
    );
  }
}

class _MapPageContent extends StatefulWidget {
  const _MapPageContent();

  @override
  State<_MapPageContent> createState() => _MapPageContentState();
}

class _MapPageContentState extends State<_MapPageContent> {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  List<_SearchLocation> _searchResults = [];
  bool _showSearchResults = false;

  // Mock search locations
  final List<_SearchLocation> _mockLocations = [
    _SearchLocation('Hanoi', LatLng(21.0285, 105.8542)),
    _SearchLocation('Ho Chi Minh City', LatLng(10.8231, 106.6297)),
    _SearchLocation('Da Nang', LatLng(16.0544, 108.2022)),
    _SearchLocation('Hai Phong', LatLng(20.8449, 106.6881)),
    _SearchLocation('Can Tho', LatLng(10.0452, 105.7469)),
    _SearchLocation('Nha Trang', LatLng(12.2388, 109.1967)),
    _SearchLocation('Hue', LatLng(16.4637, 107.5909)),
    _SearchLocation('Vung Tau', LatLng(10.3460, 107.0843)),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _searchLocations(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _showSearchResults = false;
      });
      return;
    }

    setState(() {
      _searchResults = _mockLocations
          .where((location) =>
              location.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      _showSearchResults = true;
    });
  }

  void _navigateToLocation(_SearchLocation location) {
    _mapController.move(location.position, 12.0);
    setState(() {
      _searchController.text = location.name;
      _showSearchResults = false;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = [];
      _showSearchResults = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'AQI Map',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          BlocBuilder<MapBloc, MapState>(
            builder: (context, state) {
              if (state is MapLoading || state is MapInitial) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
                );
              }

              if (state is MapError) {
                return Center(
                  child: Text(
                    state.message,
                    style: GoogleFonts.poppins(color: Colors.white70),
                  ),
                );
              }

              if (state is MapLoaded) {
                return _buildMap(context, state.stations);
              }

              return const SizedBox.shrink();
            },
          ),
          // Search bar overlay
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _buildSearchBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF16213E).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _searchLocations,
            style: GoogleFonts.poppins(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search location...',
              hintStyle: GoogleFonts.poppins(color: Colors.white54),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF4CAF50)),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white54),
                      onPressed: _clearSearch,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
        if (_showSearchResults && _searchResults.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: const Color(0xFF16213E).withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final location = _searchResults[index];
                return ListTile(
                  leading: const Icon(
                    Icons.location_on,
                    color: Color(0xFF4CAF50),
                  ),
                  title: Text(
                    location.name,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () => _navigateToLocation(location),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMap(BuildContext context, List<AqiStation> stations) {
    // Center on Vietnam
    const vietnamCenter = LatLng(16.0, 106.0);
    
    return FlutterMap(
      mapController: _mapController,
      options: const MapOptions(
        initialCenter: vietnamCenter,
        initialZoom: 6,
        minZoom: 4,
        maxZoom: 18,
      ),
      children: [
        // OpenStreetMap tiles
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.airshield.mobile',
        ),
        // Station markers
        MarkerLayer(
          markers: stations.map((station) => _buildMarker(context, station)).toList(),
        ),
      ],
    );
  }

  Marker _buildMarker(BuildContext context, AqiStation station) {
    final colorHex = station.aqiColor.replaceAll('#', '');
    final color = Color(int.parse('FF$colorHex', radix: 16));

    return Marker(
      point: LatLng(station.latitude, station.longitude),
      width: 60,
      height: 60,
      child: GestureDetector(
        onTap: () => _showStationInfo(context, station),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '${station.aqi}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: station.aqi <= 100 ? Colors.black87 : Colors.white,
                ),
              ),
            ),
            // Triangle pointer
            CustomPaint(
              size: const Size(10, 6),
              painter: _TrianglePainter(color: color),
            ),
          ],
        ),
      ),
    );
  }

  void _showStationInfo(BuildContext context, AqiStation station) {
    final colorHex = station.aqiColor.replaceAll('#', '');
    final color = Color(int.parse('FF$colorHex', radix: 16));

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16213E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.location_on, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        station.name,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'AQI Station',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'AQI',
                    '${station.aqi}',
                    color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    'Status',
                    station.aqiStatus,
                    color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Triangle painter for marker pointer
class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Search Location Model
class _SearchLocation {
  final String name;
  final LatLng position;

  _SearchLocation(this.name, this.position);
}
