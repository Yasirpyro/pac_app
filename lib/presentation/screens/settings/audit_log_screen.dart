import 'package:flutter/material.dart';
import 'dart:convert';
import '../../../data/database/dao/audit_log_dao.dart';
import '../../../data/models/audit_log_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../widgets/empty_state.dart';

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  final AuditLogDao _auditDao = AuditLogDao();
  List<AuditLogModel> _logs = [];
  bool _isLoading = true;
  String? _error;
  final Set<int> _expandedLogs = {};

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final logs = await _auditDao.getAllLogs(limit: 100);
      setState(() {
        _logs = logs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLogs,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadLogs,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            AppSpacing.verticalMD,
            Text('Error loading logs: $_error'),
            AppSpacing.verticalMD,
            ElevatedButton(
              onPressed: _loadLogs,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_logs.isEmpty) {
      return EmptyState(
        icon: Icons.history,
        title: 'No Audit Logs Yet',
        message: 'Actions will appear here as you use the app.',
      );
    }

    return ListView.builder(
      padding: AppSpacing.screenPadding,
      itemCount: _logs.length,
      itemBuilder: (context, index) {
        final log = _logs[index];
        final isExpanded = _expandedLogs.contains(log.id);

        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getActionColor(log.actionType).withValues(alpha: 0.2),
                  child: Icon(
                    _getActionIcon(log.actionType),
                    color: _getActionColor(log.actionType),
                    size: 20,
                  ),
                ),
                title: Text(
                  _getActionTitle(log.actionType),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (log.timestamp != null)
                      Text(
                        Formatters.formatDateTime(log.timestamp!),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    if (log.referenceId != null)
                      Text(
                        'Ref: ${log.referenceId}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                  onPressed: () {
                    setState(() {
                      if (isExpanded) {
                        _expandedLogs.remove(log.id);
                      } else {
                        _expandedLogs.add(log.id!);
                      }
                    });
                  },
                ),
                isThreeLine: true,
              ),
              if (isExpanded && log.details != null) ...[
                const Divider(height: 1),
                Container(
                  width: double.infinity,
                  padding: AppSpacing.cardPadding,
                  color: AppColors.surface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Details',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      AppSpacing.verticalSM,
                      Text(
                        _formatJson(log.details!),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  IconData _getActionIcon(String actionType) {
    if (actionType.contains('payment')) return Icons.payments;
    if (actionType.contains('bill')) return Icons.receipt_long;
    if (actionType.contains('recommendation')) return Icons.lightbulb;
    if (actionType.contains('cashflow')) return Icons.account_balance_wallet;
    if (actionType.contains('maintenance')) return Icons.engineering;
    if (actionType.contains('warning')) return Icons.warning;
    return Icons.info;
  }

  Color _getActionColor(String actionType) {
    if (actionType.contains('payment')) return AppColors.success;
    if (actionType.contains('bill')) return AppColors.primary;
    if (actionType.contains('recommendation')) return AppColors.warning;
    if (actionType.contains('cashflow')) return AppColors.info;
    if (actionType.contains('maintenance')) return AppColors.maintenance;
    if (actionType.contains('warning') || actionType.contains('error')) {
      return AppColors.error;
    }
    return AppColors.textSecondary;
  }

  String _getActionTitle(String actionType) {
    // Convert snake_case to Title Case
    return actionType
        .split('_')
        .map((word) => word.isEmpty
            ? ''
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  String _formatJson(Map<String, dynamic> json) {
    try {
      final encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(json);
    } catch (e) {
      return json.toString();
    }
  }
}
