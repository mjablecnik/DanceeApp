import 'package:url_launcher/url_launcher.dart';

/// Opens [url] in the platform's default external browser.
/// Does nothing if the URL is null, malformed, or cannot be launched.
Future<void> openUrl(String url) async {
  final uri = Uri.tryParse(url);
  if (uri != null && await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

/// Opens the platform's default map app for the given location.
/// Uses [fullAddress] as the query when non-empty; falls back to [lat]/[lng].
Future<void> openMap(double lat, double lng, String label,
    {String fullAddress = ''}) async {
  final query = fullAddress.isNotEmpty
      ? Uri.encodeComponent(fullAddress)
      : '$lat,$lng';
  final uri = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=$query',
  );
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
