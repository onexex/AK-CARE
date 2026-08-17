import 'package:flutter_test/flutter_test.dart';

import 'package:akop_member_app/models/medical_certificate.dart';

/// Fixture shaped like a row from `medical_certs.php`, with only the fields
/// under test varied per case.
Map<String, dynamic> _json({
  String stage = 'issued',
  Object? downloadable = 1,
  bool omitDownloadable = false,
  String certificateNo = 'MC-2026-000001',
}) =>
    {
      'id': '7',
      'stage': stage,
      if (!omitDownloadable) 'downloadable': downloadable,
      'certificate_no': certificateNo,
      'reason': 'Employment',
      'created_at': '2026-08-10 09:12:00',
    };

void main() {
  group('canDownload', () {
    test('an issued certificate the server marks downloadable', () {
      expect(MedicalCertificate.fromJson(_json()).canDownload, isTrue);
    });

    test('MySQL 1/0 arrive as strings and still decide it', () {
      expect(MedicalCertificate.fromJson(_json(downloadable: '1')).canDownload,
          isTrue);
      expect(MedicalCertificate.fromJson(_json(downloadable: '0')).canDownload,
          isFalse);
    });

    test('an explicit refusal is obeyed', () {
      expect(MedicalCertificate.fromJson(_json(downloadable: false)).canDownload,
          isFalse);
    });

    test('an older server that omits the field is not read as a refusal', () {
      final cert = MedicalCertificate.fromJson(_json(omitDownloadable: true));
      expect(cert.downloadable, isNull, reason: 'absent is not false');
      expect(cert.canDownload, isTrue);
    });

    test('a null field is treated the same as an absent one', () {
      expect(MedicalCertificate.fromJson(_json(downloadable: null)).canDownload,
          isTrue);
    });

    test('no certificate number means no verifiable document, so no PDF', () {
      // What the server's own flag encodes; applied here for a server too old
      // to send it, so the two can never disagree.
      expect(
        MedicalCertificate.fromJson(
                _json(omitDownloadable: true, certificateNo: ''))
            .canDownload,
        isFalse,
      );
    });

    test('nothing is downloadable before a doctor has issued it', () {
      for (final stage in ['pending', 'rejected']) {
        expect(
          MedicalCertificate.fromJson(_json(stage: stage)).canDownload,
          isFalse,
          reason: '$stage must not offer a PDF even when flagged downloadable',
        );
      }
    });
  });

  group('fromJson', () {
    test('a missing stage is pending, not blank', () {
      expect(MedicalCertificate.fromJson({}).stage, 'pending');
    });

    test('requestedAt comes off created_at', () {
      expect(MedicalCertificate.fromJson(_json()).requestedAt,
          '2026-08-10 09:12:00');
    });
  });
}
