import '../models/station.dart';

/// Map Repository
/// 
/// Handles fetching station data for map display
class MapRepository {
  /// Get all stations with their current AQI
  Future<List<AqiStation>> getStations() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Return mock data (replace with API call in production)
    return StationsMock.getMockStations();
  }
}
