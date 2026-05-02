import '../models/health_condition.dart';
import '../models/saved_location.dart';
import '../../../auth/data/models/user.dart';

/// Profile Repository
/// 
/// Handles profile data operations including health conditions and saved locations
class ProfileRepository {
  // Mock storage - replace with actual storage later (SharedPreferences/Hive)
  List<HealthCondition> _healthConditions = [];
  List<SavedLocation> _savedLocations = [];

  /// Get current health conditions
  Future<List<HealthCondition>> getHealthConditions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Return mock data if empty
    if (_healthConditions.isEmpty) {
      return _getMockHealthConditions();
    }
    
    return _healthConditions;
  }

  /// Update health conditions
  Future<void> updateHealthConditions(List<HealthCondition> conditions) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _healthConditions = conditions;
  }

  /// Get saved locations
  Future<List<SavedLocation>> getSavedLocations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Return mock data if empty
    if (_savedLocations.isEmpty) {
      return _getMockLocations();
    }
    
    return _savedLocations;
  }

  /// Add new saved location
  Future<SavedLocation> addSavedLocation(SavedLocation location) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _savedLocations.add(location);
    return location;
  }

  /// Update saved location
  Future<SavedLocation> updateSavedLocation(SavedLocation location) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final index = _savedLocations.indexWhere((l) => l.id == location.id);
    if (index != -1) {
      _savedLocations[index] = location;
      return location;
    }
    
    throw Exception('Location not found');
  }

  /// Delete saved location
  Future<void> deleteSavedLocation(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _savedLocations.removeWhere((l) => l.id == id);
  }

  /// Set location as default
  Future<void> setDefaultLocation(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Unset all defaults first
    _savedLocations = _savedLocations
        .map((l) => l.copyWith(isDefault: l.id == id))
        .toList();
  }

  /// Update user profile
  Future<User> updateProfile(User user) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In real app, would call API or update local storage
    return user;
  }

  /// Upload avatar
  Future<String> uploadAvatar(String imagePath) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // In real app, would upload to server and return URL
    return imagePath; // Mock: return the local path
  }

  // Mock data generators
  List<HealthCondition> _getMockHealthConditions() {
    return [
      const HealthCondition(
        type: HealthConditionType.allergies,
        severity: HealthSeverity.mild,
        isActive: true,
      ),
    ];
  }

  List<SavedLocation> _getMockLocations() {
    final now = DateTime.now();
    return [
      SavedLocation(
        id: 'loc_1',
        name: 'Home',
        latitude: 21.0285,
        longitude: 105.8542,
        address: '123 Main St, Hanoi, Vietnam',
        type: LocationType.home,
        isDefault: true,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      SavedLocation(
        id: 'loc_2',
        name: 'Office',
        latitude: 21.0245,
        longitude: 105.8412,
        address: '456 Business Rd, Hanoi, Vietnam',
        type: LocationType.work,
        isDefault: false,
        createdAt: now.subtract(const Duration(days: 20)),
      ),
    ];
  }
}
