import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/medical_certificate.dart';
import 'format.dart';

/// Renders an issued medical certificate.
///
/// Unlike the prescription PDF, this one does not disclaim itself. A
/// prescription copy can afford to say "not a signed document" because it is a
/// convenience; a medical certificate exists to be relied on by an employer, and
/// a document that undermines itself in the footer is useless for that.
///
/// What it does instead is make itself checkable: the certificate number, the
/// issuing doctor's name and PRC licence number, and the date it was issued are
/// all on the page, with a line telling the reader how to verify it. That is an
/// honest position — the system holds no wet signature and this does not pretend
/// otherwise, but everything needed to confirm the certificate is genuine is
/// printed on it.
///
/// Only call this for an issued certificate; a pending request is not a
/// document. [MedicalCertificate.downloadable] is the server's own word on that.
Future<List<int>> buildCertificatePdf({
  required MedicalCertificate cert,
  required String memberId,
}) async {
  final doc = pw.Document();

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(48, 44, 48, 40),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // ── Letterhead ──
          pw.Center(
            child: pw.Column(children: [
              pw.Text('AK MIYEMBRO',
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 2),
              pw.Text('Teleconsultation Service',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
              pw.SizedBox(height: 16),
              pw.Text('MEDICAL CERTIFICATE',
                  style: pw.TextStyle(
                      fontSize: 15,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 2)),
            ]),
          ),
          pw.SizedBox(height: 6),
          pw.Center(
            child: pw.Text('No. ${cert.certificateNo}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          ),
          pw.SizedBox(height: 18),
          pw.Divider(thickness: 0.8),
          pw.SizedBox(height: 16),

          // ── Who ──
          _row('Patient', cert.patientName.isNotEmpty ? cert.patientName : '—'),
          _row('Member ID', memberId),
          _row(
            'Age / Sex',
            [
              if (cert.patientAge != null) '${cert.patientAge}',
              if (cert.patientSex.isNotEmpty) cert.patientSex,
            ].join(' / ').trim().isEmpty
                ? '—'
                : [
                    if (cert.patientAge != null) '${cert.patientAge}',
                    if (cert.patientSex.isNotEmpty) cert.patientSex,
                  ].join(' / '),
          ),
          _row('Date examined',
              cert.examinedOn.isNotEmpty ? formatDate(cert.examinedOn) : '—'),

          pw.SizedBox(height: 16),

          // ── Findings ──
          _heading('Diagnosis / Findings'),
          pw.SizedBox(height: 4),
          pw.Text(cert.diagnosis.isNotEmpty ? cert.diagnosis : '—',
              style: const pw.TextStyle(fontSize: 11, lineSpacing: 3)),

          pw.SizedBox(height: 16),

          // ── The part an employer acts on, given its own box so it cannot be
          //    skimmed past or confused with the narrative above.
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey600, width: 0.8),
            ),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text('ASSESSMENT',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700, letterSpacing: 1)),
              pw.SizedBox(height: 4),
              pw.Text(cert.fitnessLabel.isNotEmpty ? cert.fitnessLabel : '—',
                  style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
              if (cert.restrictions.isNotEmpty) ...[
                pw.SizedBox(height: 6),
                pw.Text('Restrictions: ${cert.restrictions}',
                    style: const pw.TextStyle(fontSize: 10, lineSpacing: 2)),
              ],
              if (cert.hasRestPeriod) ...[
                pw.SizedBox(height: 6),
                pw.Text(
                    'Advised rest from ${formatDate(cert.restFrom)} to ${formatDate(cert.restTo)}.',
                    style: const pw.TextStyle(fontSize: 10)),
              ],
            ]),
          ),

          if (cert.remarks.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            _heading('Remarks'),
            pw.SizedBox(height: 4),
            pw.Text(cert.remarks,
                style: const pw.TextStyle(fontSize: 11, lineSpacing: 3)),
          ],

          pw.Spacer(),

          // ── Who signed it ──
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Container(
              width: 240,
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Divider(thickness: 0.8),
                pw.Text(cert.issuedBy.isNotEmpty ? cert.issuedBy : 'Attending physician',
                    style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                pw.Text(
                    cert.issuedLicense.isNotEmpty
                        ? 'PRC Licence No. ${cert.issuedLicense}'
                        : 'PRC Licence No. not on file',
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                if (cert.issuedAt.isNotEmpty)
                  pw.Text('Issued ${formatDate(cert.issuedAt)}',
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
              ]),
            ),
          ),

          pw.SizedBox(height: 18),
          pw.Divider(thickness: 0.5, color: PdfColors.grey400),
          pw.SizedBox(height: 6),
          pw.Text(
            'Issued electronically through the AK MIYEMBRO teleconsultation service. '
            'To verify this certificate, quote certificate number ${cert.certificateNo} '
            'and the issuing physician above.',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600, lineSpacing: 2),
          ),
        ],
      ),
    ),
  );

  return doc.save();
}

/// Filename the share sheet offers, e.g. `medical-certificate-MC-2026-000001.pdf`.
String certificateFileName(MedicalCertificate cert) =>
    'medical-certificate-${cert.certificateNo}.pdf';

pw.Widget _heading(String text) => pw.Text(text,
    style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold));

pw.Widget _row(String label, String value) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 110,
            child: pw.Text(label,
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          ),
          pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
