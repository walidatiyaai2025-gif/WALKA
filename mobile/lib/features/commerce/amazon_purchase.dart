import 'package:url_launcher/url_launcher.dart';

const String walkaDrawerOrganizerWhiteAsin = 'B0FQN4DCTG';
const String walkaDrawerOrganizerGrayAsin = 'B0FQN4L2ZD';

Uri amazonDrawerOrganizerUri({required bool gray}) {
  final String asin = gray
      ? walkaDrawerOrganizerGrayAsin
      : walkaDrawerOrganizerWhiteAsin;
  return Uri.https('www.amazon.com', '/dp/$asin');
}

Future<bool> openDrawerOrganizerOnAmazon({required bool gray}) {
  return launchUrl(
    amazonDrawerOrganizerUri(gray: gray),
    mode: LaunchMode.externalApplication,
  );
}
