/// The doctor's half of a consultation: what they prescribed, and what they
/// wrote back to the member.
///
/// This used to model the `eprescriptions` / `eprescription_items` tables, which
/// have never held a row — nothing writes to them. The real record lives on
/// `consultations`, written by the review screen in the back office, and it is
/// free text rather than a structured medicine list: there are no dosage,
/// frequency or quantity fields behind it to show.
class EPrescription {
  final int id;
  final String consultedOn;
  final String doctorName;

  /// What the member came in with, for context on which consultation this is.
  final String complaint;

  /// The doctor's prescription, as written. Empty on every record so far — the
  /// legacy CRM never captured one and the review screen is new — so the UI has
  /// to read as a doctor's note when this is blank rather than an empty script.
  final String prescription;

  /// The doctor's written answer: advice, follow-up, a referral.
  final String notes;

  /// 'approved', 'reviewed', or null when the record says nothing reliable.
  final String? reviewStatus;

  const EPrescription({
    required this.id,
    required this.consultedOn,
    required this.doctorName,
    required this.complaint,
    required this.prescription,
    required this.notes,
    required this.reviewStatus,
  });

  bool get hasPrescription => prescription.isNotEmpty;

  factory EPrescription.fromJson(Map<String, dynamic> json) {
    return EPrescription(
      id: json['id'] ?? 0,
      consultedOn: json['consulted_on']?.toString() ?? '',
      doctorName: json['doctor_name']?.toString() ?? '',
      complaint: json['complaint']?.toString() ?? '',
      prescription: json['prescription']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      reviewStatus: json['review_status']?.toString(),
    );
  }
}
