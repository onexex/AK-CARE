/// A member's medical certificate request, and the certificate itself once a
/// doctor has issued one.
///
/// One row covers both because that is what it is: the request becomes the
/// certificate when signed. [stage] is the server's word for where it sits, so
/// the app never has to guess from which fields happen to be filled in.
class MedicalCertificate {
  final int id;
  final String stage; // 'pending' | 'issued' | 'rejected'
  final bool downloadable;

  /// What the member asked for, in their words.
  final String reason;
  final String requestedAt;

  // ── Present once issued ──
  final String certificateNo;
  final String patientName;
  final int? patientAge;
  final String patientSex;
  final String examinedOn;
  final String diagnosis;

  /// 'fit' | 'fit_with_restrictions' | 'unfit'. The part an employer acts on.
  final String fitness;
  final String restrictions;
  final String restFrom;
  final String restTo;
  final String remarks;

  /// The doctor's name and PRC licence number: without them a certificate is
  /// not verifiable, and this app deliberately shows both.
  final String issuedBy;
  final String issuedLicense;
  final String issuedAt;

  // ── Present once rejected ──
  final String rejectionReason;

  const MedicalCertificate({
    required this.id,
    required this.stage,
    required this.downloadable,
    required this.reason,
    required this.requestedAt,
    required this.certificateNo,
    required this.patientName,
    required this.patientAge,
    required this.patientSex,
    required this.examinedOn,
    required this.diagnosis,
    required this.fitness,
    required this.restrictions,
    required this.restFrom,
    required this.restTo,
    required this.remarks,
    required this.issuedBy,
    required this.issuedLicense,
    required this.issuedAt,
    required this.rejectionReason,
  });

  bool get isIssued => stage == 'issued';

  bool get isRejected => stage == 'rejected';

  bool get hasRestPeriod => restFrom.isNotEmpty && restTo.isNotEmpty;

  String get fitnessLabel => switch (fitness) {
        'unfit' => 'Unfit for work',
        'fit_with_restrictions' => 'Fit for work with restrictions',
        'fit' => 'Fit for work',
        _ => '',
      };

  static String _str(dynamic v) => v?.toString() ?? '';

  factory MedicalCertificate.fromJson(Map<String, dynamic> json) {
    return MedicalCertificate(
      id: int.tryParse(_str(json['id'])) ?? 0,
      stage: _str(json['stage']).isEmpty ? 'pending' : _str(json['stage']),
      // MySQL hands booleans back as 1/0 through this API.
      downloadable: json['downloadable'] == true ||
          _str(json['downloadable']) == '1',
      reason: _str(json['reason']),
      requestedAt: _str(json['created_at']),
      certificateNo: _str(json['certificate_no']),
      patientName: _str(json['patient_name']),
      patientAge: int.tryParse(_str(json['patient_age'])),
      patientSex: _str(json['patient_sex']),
      examinedOn: _str(json['examined_on']),
      diagnosis: _str(json['diagnosis']),
      fitness: _str(json['fitness']),
      restrictions: _str(json['restrictions']),
      restFrom: _str(json['rest_from']),
      restTo: _str(json['rest_to']),
      remarks: _str(json['remarks']),
      issuedBy: _str(json['issued_by']),
      issuedLicense: _str(json['issued_license']),
      issuedAt: _str(json['issued_at']),
      rejectionReason: _str(json['rejection_reason']),
    );
  }
}
