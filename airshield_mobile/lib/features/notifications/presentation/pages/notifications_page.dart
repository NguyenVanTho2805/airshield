import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../data/models/notification.dart';
import '../../data/services/notification_service.dart';
import '../bloc/notifications_bloc.dart';

/// Notifications Page
/// 
/// Shows list of notifications with mark as read and delete actions
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotificationsBloc(
        service: NotificationService(),
      )..add(const LoadNotifications()),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        actions: [
          BlocBuilder<NotificationsBloc, NotificationsState>(
            builder: (context, state) {
              if (state is NotificationsLoaded && state.notifications.isNotEmpty) {
                return PopupMenuButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: Theme.of(context).appBarTheme.foregroundColor,
                  ),
                  color: Theme.of(context).cardColor,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: () {
                        context.read<NotificationsBloc>().add(const MarkAllAsRead());
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.done_all, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            'Mark all as read',
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      onTap: () {
                        _confirmClearAll(context);
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                          const SizedBox(width: 12),
                          Text(
                            'Clear all',
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<NotificationsBloc, NotificationsState>(
        listener: (context, state) {
          if (state is NotificationsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message, style: GoogleFonts.poppins()),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is NotificationsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return _buildEmptyState(context);
            }
            return _buildNotificationsList(context, state.notifications);
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSimulateDialog(context),
        backgroundColor: const Color(0xFF4CAF50),
        icon: const Icon(Icons.add_alert),
        label: Text(
          'Simulate',
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
            Icons.notifications_none,
            size: 80,
            color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'No Notifications',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'You\'re all caught up!',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(BuildContext context, List<AppNotification> notifications) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<NotificationsBloc>().add(const LoadNotifications());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return _buildNotificationCard(context, notifications[index]);
        },
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, AppNotification notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        context.read<NotificationsBloc>().add(DeleteNotification(notification.id));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification deleted', style: GoogleFonts.poppins()),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: InkWell(
        onTap: () {
          if (!notification.isRead) {
            context.read<NotificationsBloc>().add(MarkAsRead(notification.id));
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead
                ? Theme.of(context).cardColor
                : notification.getColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notification.isRead
                  ? Theme.of(context).dividerColor
                  : notification.getColor().withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: notification.getColor().withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  notification.getIcon(),
                  color: notification.getColor(),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w600,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: notification.getColor(),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.message,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTimestamp(notification.timestamp),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: notification.getColor().withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            notification.type.displayName,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: notification.getColor(),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmClearAll(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 100), () {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text(
            'Clear All Notifications',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          content: Text(
            'Are you sure you want to clear all notifications?',
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
                context.read<NotificationsBloc>().add(const ClearAll());
              },
              child: Text(
                'Clear',
                style: GoogleFonts.poppins(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _showSimulateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          'Simulate Notification',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: NotificationType.values.map((type) {
            return ListTile(
              leading: Icon(
                _getTypeIcon(type),
                color: _getTypeColor(type),
              ),
              title: Text(
                type.displayName,
                style: GoogleFonts.poppins(),
              ),
              onTap: () {
                Navigator.of(dialogContext).pop();
                context.read<NotificationsBloc>().add(SimulateNotification(type));
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.aqiAlert:
        return Icons.warning_amber;
      case NotificationType.deviceStatus:
        return Icons.devices;
      case NotificationType.automation:
        return Icons.auto_awesome;
      case NotificationType.system:
        return Icons.info_outline;
    }
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.aqiAlert:
        return const Color(0xFFF44336);
      case NotificationType.deviceStatus:
        return const Color(0xFF2196F3);
      case NotificationType.automation:
        return const Color(0xFF4CAF50);
      case NotificationType.system:
        return const Color(0xFF9E9E9E);
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, HH:mm').format(timestamp);
    }
  }
}
