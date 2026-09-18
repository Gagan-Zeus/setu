import 'package:supabase_flutter/supabase_flutter.dart';

/// A doctor asking to see her record, or already able to.
class AccessGrant {
  const AccessGrant({
    required this.id,
    required this.doctorName,
    required this.status,
    required this.method,
    this.reason,
    this.expiresAt,
    this.requestedAt,
  });

  final String id;
  final String doctorName;

  /// pending | approved | rejected | expired
  final String status;

  /// request | qr
  final String method;
  final String? reason;
  final DateTime? expiresAt;
  final DateTime? requestedAt;

  bool get isPending => status == 'pending';

  bool get isActive =>
      status == 'approved' &&
      (expiresAt == null || expiresAt!.isAfter(DateTime.now()));

  /// Access she gave by showing her card at the hospital, rather than by
  /// answering a request.
  bool get grantedByQr => method == 'qr';
}

/// Her side of consent: who has asked, who can see her record, and stopping it.
class AccessRequests {
  const AccessRequests(this._client);

  final SupabaseClient? _client;

  Future<List<AccessGrant>> forMe() async {
    final client = _client;
    if (client == null) return const [];
    final rows = await client
        .from('access_grants')
        .select('id, status, method, reason, requested_at, expires_at, '
            'staff:staff!access_grants_staff_id_fkey (name)')
        .order('requested_at', ascending: false);
    return rows.map(_map).toList();
  }

  Future<void> decide(String grantId, {required bool approve}) async {
    final client = _client;
    if (client == null) return;
    await client.rpc('decide_access_request', params: {
      'p_grant_id': grantId,
      'p_approve': approve,
    });
  }

  static AccessGrant _map(Map<String, dynamic> r) {
    final staff = r['staff'] as Map<String, dynamic>?;
    return AccessGrant(
      id: r['id'] as String,
      doctorName: staff?['name'] as String? ?? '',
      status: r['status'] as String? ?? 'pending',
      method: r['method'] as String? ?? 'request',
      reason: r['reason'] as String?,
      expiresAt: r['expires_at'] == null
          ? null
          : DateTime.tryParse(r['expires_at'].toString()),
      requestedAt: r['requested_at'] == null
          ? null
          : DateTime.tryParse(r['requested_at'].toString()),
    );
  }
}
