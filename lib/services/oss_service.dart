import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class OssService {
  static const String _endpoint = 'https://oss-cn-hangzhou.aliyuncs.com';
  static const String _bucket = 'YOUR_OSS_BUCKET_NAME';
  static const String _accessKeyId = 'YOUR_OSS_ACCESS_KEY_ID';
  static const String _accessKeySecret = 'YOUR_OSS_ACCESS_KEY_SECRET';

  static Future<String?> uploadAvatar(File imageFile, String userId) async {
    if (_accessKeyId == 'YOUR_OSS_ACCESS_KEY_ID') {
      return 'assets/avatars/${userId == '1' ? 'admin_avatar.png' : 'user_avatar.png'}';
    }

    try {
      final bytes = await imageFile.readAsBytes();
      final fileName = 'avatars/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final url = 'https://$_bucket.$_endpoint/$fileName';

      final policy = _buildPolicy(fileName);
      final signature = _calculateSignature(policy);

      final request = http.MultipartRequest('POST', Uri.parse('https://$_bucket.$_endpoint'));
      request.fields['key'] = fileName;
      request.fields['OSSAccessKeyId'] = _accessKeyId;
      request.fields['policy'] = policy;
      request.fields['Signature'] = signature;
      request.fields['success_action_status'] = '200';
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName.split('/').last,
        ),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        return url;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static String _buildPolicy(String fileName) {
    final expiration = DateTime.now().add(const Duration(hours: 1)).toUtc();
    final policyMap = {
      'expiration': expiration.toIso8601String(),
      'conditions': [
        {'bucket': _bucket},
        ['starts-with', '\$key', 'avatars/'],
        ['content-length-range', 0, 10485760],
      ],
    };
    return base64Encode(utf8.encode(jsonEncode(policyMap)));
  }

  static String _calculateSignature(String policy) {
    final hmac = Hmac(sha1, utf8.encode(_accessKeySecret));
    final digest = hmac.convert(utf8.encode(policy));
    return base64Encode(digest.bytes);
  }
}
