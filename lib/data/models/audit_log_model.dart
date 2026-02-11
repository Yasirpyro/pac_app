import 'dart:convert';

class AuditLogModel {
  final int? id;
  final DateTime? timestamp;
  final String actionType;
  final String? referenceId;
  final Map<String, dynamic>? details;
  final String? userNote;

  AuditLogModel({
    this.id,
    this.timestamp,
    required this.actionType,
    this.referenceId,
    this.details,
    this.userNote,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'action_type': actionType,
      'reference_id': referenceId,
      'details': details != null ? jsonEncode(details) : null,
      'user_note': userNote,
    };
  }

  factory AuditLogModel.fromMap(Map<String, dynamic> map) {
    return AuditLogModel(
      id: map['id'] as int?,
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'] as String)
          : null,
      actionType: map['action_type'] as String,
      referenceId: map['reference_id'] as String?,
      details: map['details'] != null
          ? jsonDecode(map['details'] as String) as Map<String, dynamic>
          : null,
      userNote: map['user_note'] as String?,
    );
  }
}
