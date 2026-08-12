import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/eprescription.dart';
import 'format.dart';

/// Renders a consultation's prescription as a PDF the member can save or share.
///
/// What a doctor writes is free text, not an itemised list with dosages in
/// separate fields, so the body is reproduced as written rather than laid out in
/// a table that would imply structure the record does not have.
///
/// This is a copy of a record, not a signed instrument. It says so on the page:
/// nothing here is countersigned, and presenting it as though it were would be a
/// worse failure than the screen showing nothing at all.
Future<List<int>> buildPrescriptionPdf({
  required EPrescription entry,
  required String patientName,
  required String memberId,
}) async {
  final doc = pw.Document();

  final consulted =
      entry.consultedOn.isNotEmpty ? formatDate(entry.consultedOn) : 'Not recorded';

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(40, 40, 40, 40),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('AK MIYEMBRO',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 2),
          pw.Text(
              entry.hasPrescription
                  ? 'Prescription'
                  : "Doctor's Notes",
              style: const pw.TextStyle(fontSize: 13, color: PdfColors.grey700)),
          pw.SizedBox(height: 14),
          pw.Divider(thickness: 0.8),
          pw.SizedBox(height: 14),

          _field('Patient', patientName.isNotEmpty ? patientName : 'Not recorded'),
          _field('Member ID', memberId),
          _field('Consultation date', consulted),
          _field('Doctor',
              entry.doctorName.isNotEmpty ? entry.doctorName : 'Not recorded'),
          if (entry.complaint.isNotEmpty) _field('Complaint', entry.complaint),

          pw.SizedBox(height: 18),

          if (entry.hasPrescription) ...[
            _heading('Prescription'),
            pw.SizedBox(height: 6),
            pw.Text(entry.prescription,
                style: const pw.TextStyle(fontSize: 12, lineSpacing: 3)),
            pw.SizedBox(height: 16),
          ],

          if (entry.notes.isNotEmpty) ...[
            _heading("Doctor's Notes"),
            pw.SizedBox(height: 6),
            pw.Text(entry.notes,
                style: const pw.TextStyle(fontSize: 12, lineSpacing: 3)),
          ],

          pw.Spacer(),
          pw.Divider(thickness: 0.5, color: PdfColors.grey400),
          pw.SizedBox(height: 6),
          pw.Text(
            'Copy of a teleconsultation record from the AK MIYEMBRO app. '
            'Not a signed prescription and not valid as a dispensing document '
            'on its own. Reference: consultation #${entry.id}.',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ],
      ),
    ),
  );

  return doc.save();
}

/// Filename the share sheet offers, e.g. `prescription-AKM-787-2022-08-12.pdf`.
String prescriptionFileName(EPrescription entry, String memberId) {
  final date = entry.consultedOn.isNotEmpty
      ? entry.consultedOn.split(' ').first
      : 'undated';
  final kind = entry.hasPrescription ? 'prescription' : 'doctors-notes';

  return '$kind-$memberId-$date.pdf';
}

pw.Widget _heading(String text) => pw.Text(text,
    style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold));

pw.Widget _field(String label, String value) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(label,
                style:
                    const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          ),
          pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
