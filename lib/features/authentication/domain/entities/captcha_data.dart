import 'dart:typed_data';
import 'package:equatable/equatable.dart';

/// Captcha data entity
/// Contains captcha image and session information
class CaptchaData extends Equatable {
  final Uint8List imageBytes;
  final String sessionCookie;
  final int timestamp;

  const CaptchaData({
    required this.imageBytes,
    required this.sessionCookie,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [imageBytes, sessionCookie, timestamp];
}
