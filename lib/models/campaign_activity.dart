/// Something a member can turn up to: a medical mission, a relief run, a tree
/// planting.
///
/// These come from the same `campaign_activities` table the field teams plan
/// against, so the member app shows what is actually scheduled rather than a
/// separately maintained list that would drift from it.
class CampaignActivity {
  final int id;

  /// 'medical' | 'relief' | 'tree_planting' | … — free text on the server, so
  /// [typeLabel] falls back to the raw value rather than dropping an unknown
  /// kind on the floor.
  final String type;
  final String title;
  final String scheduledAt;
  final String endsAt;

  final String barangay;
  final String cityMunicipality;
  final String province;

  /// Whether this falls in the member's own province.
  ///
  /// Province, not city: the activities are few and spread thin, so a tighter
  /// match would mark almost nothing and read as though it were broken. False
  /// also covers the member whose address the server could not place, which is
  /// why nothing is hidden on the strength of it.
  final bool nearYou;

  final String contactPerson;
  final String contactNumber;

  const CampaignActivity({
    required this.id,
    required this.type,
    required this.title,
    required this.scheduledAt,
    required this.endsAt,
    required this.barangay,
    required this.cityMunicipality,
    required this.province,
    required this.nearYou,
    required this.contactPerson,
    required this.contactNumber,
  });

  /// 'Tree planting' from 'tree_planting'. An unrecognised kind is shown as
  /// itself, tidied, rather than blanked.
  String get typeLabel {
    if (type.isEmpty) return '';
    final words = type.replaceAll('_', ' ').trim();
    return words[0].toUpperCase() + words.substring(1);
  }

  /// 'Santa Anastacia, City of Sto. Tomas, Batangas', skipping whichever parts
  /// the address row is missing.
  String get where => [
        barangay,
        cityMunicipality,
        province,
      ].where((p) => p.isNotEmpty).join(', ');

  bool get hasEndDate => endsAt.isNotEmpty;

  static String _str(dynamic v) => v?.toString() ?? '';

  factory CampaignActivity.fromJson(Map<String, dynamic> json) {
    return CampaignActivity(
      id: int.tryParse(_str(json['id'])) ?? 0,
      type: _str(json['type']),
      title: _str(json['title']),
      scheduledAt: _str(json['scheduled_at']),
      endsAt: _str(json['ends_at']),
      barangay: _str(json['barangay']),
      cityMunicipality: _str(json['city_municipality']),
      province: _str(json['province']),
      // MySQL hands booleans back as 1/0 through this API.
      nearYou: json['near_you'] == true || _str(json['near_you']) == '1',
      contactPerson: _str(json['contact_person']),
      contactNumber: _str(json['contact_number']),
    );
  }
}
