class EPrescription {
  final int id;
  final int userId;
  final String doctorName;
  final String diagnosis;
  final String notes;
  final String status;
  final String createdAt;
  final List<EPrescriptionItem> items;
  final int itemsCount;

  EPrescription({
    required this.id,
    required this.userId,
    required this.doctorName,
    required this.diagnosis,
    required this.notes,
    required this.status,
    required this.createdAt,
    required this.items,
    required this.itemsCount,
  });

  factory EPrescription.fromJson(Map<String, dynamic> json) {
    return EPrescription(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      doctorName: json['doctor_name'] ?? '',
      diagnosis: json['diagnosis'] ?? '',
      notes: json['notes'] ?? '',
      status: json['status'] ?? 'active',
      createdAt: json['created_at'] ?? '',
      items: (json['items'] as List<dynamic>? ?? [])
          .map((i) => EPrescriptionItem.fromJson(i))
          .toList(),
      itemsCount: json['items_count'] ?? 0,
    );
  }
}

class EPrescriptionItem {
  final int id;
  final int prescriptionId;
  final String medicineName;
  final String dosage;
  final String frequency;
  final String duration;
  final String quantity;
  final String notes;

  EPrescriptionItem({
    required this.id,
    required this.prescriptionId,
    required this.medicineName,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.quantity,
    required this.notes,
  });

  factory EPrescriptionItem.fromJson(Map<String, dynamic> json) {
    return EPrescriptionItem(
      id: json['id'] ?? 0,
      prescriptionId: json['prescription_id'] ?? 0,
      medicineName: json['medicine_name'] ?? '',
      dosage: json['dosage'] ?? '',
      frequency: json['frequency'] ?? '',
      duration: json['duration'] ?? '',
      quantity: json['quantity'] ?? '',
      notes: json['notes'] ?? '',
    );
  }
}