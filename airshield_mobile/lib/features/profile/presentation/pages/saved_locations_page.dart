import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/saved_location.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../bloc/locations_bloc.dart';

/// Saved Locations Page
/// 
/// Displays and manages user's saved locations
class SavedLocationsPage extends StatefulWidget {
  const SavedLocationsPage({super.key});

  @override
  State<SavedLocationsPage> createState() => _SavedLocationsPageState();
}

class _SavedLocationsPageState extends State<SavedLocationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<LocationsBloc>().add(LoadLocations());
  }

  void _addLocation() {
    // Mock location - in real app would use location picker
    final newLocation = SavedLocation(
      id: 'loc_${DateTime.now().millisecondsSinceEpoch}',
      name: 'New Location',
      latitude: 21.0285,
      longitude: 105.8542,
      address: 'Tap to edit',
      type: LocationType.custom,
      isDefault: false,
      createdAt: DateTime.now(),
    );

    context.read<LocationsBloc>().add(AddLocation(newLocation));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Location added successfully',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteLocation(String id) {
    context.read<LocationsBloc>().add(DeleteLocation(id));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Location removed',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _setDefault(String id) {
    context.read<LocationsBloc>().add(SetDefaultLocation(id));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Default location updated',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          l10n.savedLocations,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
      ),
      body: BlocBuilder<LocationsBloc, LocationsState>(
        builder: (context, state) {
          if (state is LocationsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is LocationsError) {
            return Center(
              child: Text(
                state.message,
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            );
          }
          
          if (state is LocationsLoaded) {
            if (state.locations.isEmpty) {
              return _buildEmptyState();
            }
            
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.locations.length,
              itemBuilder: (context, index) {
                return _buildLocationCard(state.locations[index]);
              },
            );
          }
          
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addLocation,
        backgroundColor: const Color(0xFF4CAF50),
        icon: const Icon(Icons.add_location),
        label: Text(
          'Add Location',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 80,
            color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'No saved locations',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your favorite locations to quickly check AQI',
            style: GoogleFonts.poppins(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(SavedLocation location) {
    return Dismissible(
      key: Key(location.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteLocation(location.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 32),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: location.isDefault
                ? const Color(0xFF4CAF50)
                : Theme.of(context).dividerColor,
            width: location.isDefault ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    location.type.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            location.name,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          if (location.isDefault) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'DEFAULT',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        location.address,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (!location.isDefault)
                  IconButton(
                    icon: const Icon(Icons.star_border),
                    color: Colors.grey,
                    onPressed: () => _setDefault(location.id),
                    tooltip: 'Set as default',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.air, color: Color(0xFF4CAF50), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'AQI: 42', // Mock AQI - in real app would fetch
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4CAF50),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Good',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
