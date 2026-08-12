import 'package:intl/intl.dart';

/// Display formatting shared across screens.
///
/// This exists because the same two jobs were being redone per screen and
/// drifting: four different date formats were on screen at once — 'Aug 11, 2023',
/// '6/16/2026', '2026-03-23' and '11 Aug 2023' — with three near-identical
/// private _formatDate helpers copy-pasted between the community, prescription
/// and post-detail screens.
///
/// 'M/D/YYYY' was the worst of them: 6/16/2026 reads as the 6th of month 16 to
/// most of the world, and this is a health app used in the Philippines where
/// both conventions are in circulation. The named month removes the ambiguity.

/// The app's one absolute date format, e.g. 'Aug 11, 2023'.
final DateFormat _dayFormat = DateFormat('MMM dd, yyyy');

/// A date, formatted absolutely. Unparseable input is returned untouched rather
/// than blanked, so a malformed row still shows something.
String formatDate(String raw) {
  final when = DateTime.tryParse(raw.trim());
  return when == null ? raw : _dayFormat.format(when);
}

/// A date, relative while it is recent and absolute once it is not.
///
/// Feeds, prescriptions and consultation lists all read better as an age for the
/// last few days ('2d ago') and as a date beyond that — '43d ago' is harder to
/// place than 'Aug 11, 2023'. Future dates always format absolutely: a preferred
/// consultation date is not usefully expressed as 'in 3 days'.
String formatRelativeDate(String raw) {
  final when = DateTime.tryParse(raw.trim());
  if (when == null) return raw;

  final diff = DateTime.now().difference(when);
  if (diff.isNegative) return _dayFormat.format(when);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inHours < 1) return '${diff.inMinutes}m ago';
  if (diff.inDays < 1) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return _dayFormat.format(when);
}

/// Philippine mobile number, for display only.
///
/// members.contact_number is stored in two shapes — 09XXXXXXXXX and the bare
/// 9XXXXXXXXX — and the server hands back whichever one the member's row holds.
/// Showing that raw means half of all members are shown a number that does not
/// look like the one they dial or the one they typed to sign in.
///
/// This does not change what is sent to the API. Lookups still use the value the
/// server gave us; only the label on screen is normalised.
String formatPhMobile(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');

  var core = digits;
  if (core.length == 12 && core.startsWith('639')) {
    core = core.substring(2); // 639171234567 -> 9171234567
  } else if (core.length == 11 && core.startsWith('09')) {
    core = core.substring(1); // 09171234567  -> 9171234567
  }

  // Anything that is not a recognisable PH mobile is shown untouched rather
  // than mangled — a landline or a foreign number should still be readable.
  if (core.length != 10 || !core.startsWith('9')) return raw;

  return '0$core';
}
