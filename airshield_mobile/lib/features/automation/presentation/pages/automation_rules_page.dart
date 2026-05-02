import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../data/models/automation_rule.dart';
import '../../data/repositories/automation_repository.dart';
import '../bloc/automation_bloc.dart';
import 'create_rule_page.dart';

/// Automation Rules Page
/// 
/// Shows list of automation rules with create/edit/delete actions
class AutomationRulesPage extends StatelessWidget {
  const AutomationRulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AutomationBloc(
        repository: AutomationRepository(),
      )..add(const LoadRules()),
      child: const _AutomationRulesView(),
    );
  }
}

class _AutomationRulesView extends StatelessWidget {
  const _AutomationRulesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'Automation Rules',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
      ),
      body: BlocConsumer<AutomationBloc, AutomationState>(
        listener: (context, state) {
          if (state is RuleCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Rule created successfully',
                  style: GoogleFonts.poppins(),
                ),
                backgroundColor: const Color(0xFF4CAF50),
              ),
            );
          } else if (state is RuleDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Rule deleted',
                  style: GoogleFonts.poppins(),
                ),
              ),
            );
          } else if (state is AutomationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: GoogleFonts.poppins(),
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AutomationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AutomationLoaded) {
            if (state.rules.isEmpty) {
              return _buildEmptyState(context);
            }
            return _buildRulesList(context, state.rules);
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateRulePage()),
          );
          
          if (result == true) {
            // Reload rules
            if (context.mounted) {
              context.read<AutomationBloc>().add(const LoadRules());
            }
          }
        },
        backgroundColor: const Color(0xFF4CAF50),
        icon: const Icon(Icons.add),
        label: Text(
          'New Rule',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome_outlined,
            size: 80,
            color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'No Automation Rules',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Create automation rules to control your devices based on air quality or time',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRulesList(BuildContext context, List<AutomationRule> rules) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AutomationBloc>().add(const LoadRules());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rules.length,
        itemBuilder: (context, index) {
          return _buildRuleCard(context, rules[index]);
        },
      ),
    );
  }

  Widget _buildRuleCard(BuildContext context, AutomationRule rule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: rule.isEnabled
              ? const Color(0xFF4CAF50).withValues(alpha: 0.3)
              : Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: rule.isEnabled
                        ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                        : Theme.of(context).iconTheme.color?.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: rule.isEnabled
                        ? const Color(0xFF4CAF50)
                        : Theme.of(context).iconTheme.color?.withValues(alpha: 0.5),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Name and description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rule.name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${rule.trigger.getDescription()} → ${rule.action.getDescription()}',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Toggle switch
                Switch(
                  value: rule.isEnabled,
                  onChanged: (value) {
                    context.read<AutomationBloc>().add(ToggleRule(rule.id));
                  },
                  activeColor: const Color(0xFF4CAF50),
                ),
              ],
            ),
          ),
          
          // Footer with last triggered and actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 14,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                const SizedBox(width: 6),
                Text(
                  rule.lastTriggered != null
                      ? 'Last triggered ${_formatDate(rule.lastTriggered!)}'
                      : 'Never triggered',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                const Spacer(),
                
                // Delete button
                InkWell(
                  onTap: () => _confirmDelete(context, rule),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Colors.red.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AutomationRule rule) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          'Delete Rule',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${rule.name}"?',
          style: GoogleFonts.poppins(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AutomationBloc>().add(DeleteRule(rule.id));
            },
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }
}
