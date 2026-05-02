import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../smart_home/data/models/device.dart';
import '../../../smart_home/data/repositories/smart_home_repository.dart';
import '../../data/models/automation_rule.dart';
import '../../data/repositories/automation_repository.dart';
import '../bloc/automation_bloc.dart';

/// Create Rule Page
/// 
/// Form to create new automation rules
class CreateRulePage extends StatefulWidget {
  const CreateRulePage({super.key});

  @override
  State<CreateRulePage> createState() => _CreateRulePageState();
}

class _CreateRulePageState extends State<CreateRulePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  TriggerType _selectedTriggerType = TriggerType.aqiAbove;
  ActionType _selectedActionType = ActionType.turnOn;
  
  int _aqiThreshold = 100;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 7, minute: 0);
  String? _selectedDeviceId;
  String? _selectedMode;
  
  List<SmartDevice> _devices = [];
  bool _isLoadingDevices = true;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    try {
      final repository = SmartHomeRepository();
      final devices = await repository.getDevices();
      setState(() {
        _devices = devices;
        _isLoadingDevices = false;
        if (devices.isNotEmpty) {
          _selectedDeviceId = devices.first.deviceId;
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingDevices = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AutomationBloc(repository: AutomationRepository()),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          elevation: 0,
          title: Text(
            'Create Automation Rule',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
          ),
        ),
        body: _isLoadingDevices
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRuleName(),
                      const SizedBox(height: 24),
                      _buildTriggerSection(),
                      const SizedBox(height: 24),
                      _buildActionSection(),
                      const SizedBox(height: 32),
                      _buildCreateButton(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildRuleName() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rule Name',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'e.g., High AQI Auto-On',
              filled: true,
              fillColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            style: GoogleFonts.poppins(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTriggerSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flash_on, color: Color(0xFF4CAF50), size: 20),
              const SizedBox(width: 8),
              Text(
                'Trigger',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Trigger type dropdown
          DropdownButtonFormField<TriggerType>(
            value: _selectedTriggerType,
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            dropdownColor: Theme.of(context).cardColor,
            style: GoogleFonts.poppins(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            items: TriggerType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type.displayName),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedTriggerType = value!;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          // Trigger parameters
          if (_selectedTriggerType == TriggerType.aqiAbove ||
              _selectedTriggerType == TriggerType.aqiBelow)
            _buildAQIThresholdSlider(),
          
          if (_selectedTriggerType == TriggerType.time)
            _buildTimePicker(),
        ],
      ),
    );
  }

  Widget _buildAQIThresholdSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AQI Threshold: $_aqiThreshold',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        Slider(
          value: _aqiThreshold.toDouble(),
          min: 0,
          max: 300,
          divisions: 30,
          activeColor: const Color(0xFF4CAF50),
          label: _aqiThreshold.toString(),
          onChanged: (value) {
            setState(() {
              _aqiThreshold = value.toInt();
            });
          },
        ),
      ],
    );
  }

  Widget _buildTimePicker() {
    return InkWell(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: _selectedTime,
        );
        if (time != null) {
          setState(() {
            _selectedTime = time;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: Color(0xFF4CAF50)),
            const SizedBox(width: 12),
            Text(
              _selectedTime.format(context),
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.settings, color: Color(0xFF4CAF50), size: 20),
              const SizedBox(width: 8),
              Text(
                'Action',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Device selector
          if (_devices.isNotEmpty) ...[
            Text(
              'Target Device',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedDeviceId,
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              dropdownColor: Theme.of(context).cardColor,
              style: GoogleFonts.poppins(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              items: _devices.map((device) {
                return DropdownMenuItem(
                  value: device.deviceId,
                  child: Text(device.deviceName),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDeviceId = value;
                });
              },
            ),
            const SizedBox(height: 16),
          ],
          
          // Action type
          Text(
            'Action Type',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<ActionType>(
            value: _selectedActionType,
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            dropdownColor: Theme.of(context).cardColor,
            style: GoogleFonts.poppins(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            items: ActionType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type.displayName),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedActionType = value!;
              });
            },
          ),
          
          // Mode selector for changeMode action
          if (_selectedActionType == ActionType.changeMode) ...[
            const SizedBox(height: 16),
            Text(
              'Device Mode',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedMode ?? 'auto',
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              dropdownColor: Theme.of(context).cardColor,
              style: GoogleFonts.poppins(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              items: ['auto', 'turbo', 'sleep', 'manual'].map((mode) {
                return DropdownMenuItem(
                  value: mode,
                  child: Text(mode.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMode = value;
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: BlocConsumer<AutomationBloc, AutomationState>(
        listener: (context, state) {
          if (state is RuleCreated) {
            Navigator.of(context).pop(true);
          } else if (state is AutomationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message, style: GoogleFonts.poppins()),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return ElevatedButton(
            onPressed: _createRule,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Create Rule',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        },
      ),
    );
  }

  void _createRule() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDeviceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a device',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Build trigger
    final trigger = RuleTrigger(
      type: _selectedTriggerType,
      aqiThreshold: (_selectedTriggerType == TriggerType.aqiAbove ||
              _selectedTriggerType == TriggerType.aqiBelow)
          ? _aqiThreshold
          : null,
      timeOfDay: _selectedTriggerType == TriggerType.time
          ? _selectedTime
          : null,
    );

    // Build action
    final action = RuleAction(
      type: _selectedActionType,
      deviceId: _selectedDeviceId!,
      powerState: _selectedActionType == ActionType.turnOn
          ? true
          : (_selectedActionType == ActionType.turnOff ? false : null),
      mode: _selectedActionType == ActionType.changeMode
          ? _selectedMode ?? 'auto'
          : null,
    );

    // Create rule
    final rule = AutomationRule(
      id: '',
      name: _nameController.text,
      isEnabled: true,
      trigger: trigger,
      action: action,
      createdAt: DateTime.now(),
    );

    context.read<AutomationBloc>().add(CreateRule(rule));
  }
}
