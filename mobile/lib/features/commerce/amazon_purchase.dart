import 'package:url_launcher/url_launcher.dart';

const String walkaDrawerOrganizerWhiteAsin = 'B0FQN4DCTG';
const String walkaDrawerOrganizerGrayAsin = 'B0FQN4L2ZD';
const String walkaLunchBoxBlueAsin = 'B0FQN4L8MW';
const String walkaLunchBoxPinkAsin = 'B0FQN3W4SF';
const String walkaLunchBoxGreenAsin = 'B0GPZNKF9F';

enum WalkaAmazonLunchVariant { blue, pink, green }

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

String amazonLunchBoxAsin(WalkaAmazonLunchVariant variant) {
  return switch (variant) {
    WalkaAmazonLunchVariant.blue => walkaLunchBoxBlueAsin,
    WalkaAmazonLunchVariant.pink => walkaLunchBoxPinkAsin,
    WalkaAmazonLunchVariant.green => walkaLunchBoxGreenAsin,
  };
}

Uri amazonLunchBoxUri(WalkaAmazonLunchVariant variant) {
  return Uri.https('www.amazon.com', '/dp/${amazonLunchBoxAsin(variant)}');
}

Future<bool> openLunchBoxOnAmazon(WalkaAmazonLunchVariant variant) {
  return launchUrl(
    amazonLunchBoxUri(variant),
    mode: LaunchMode.externalApplication,
  );
}
