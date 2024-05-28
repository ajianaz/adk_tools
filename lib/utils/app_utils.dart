import 'dart:convert';
import 'dart:developer' as d;
import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import '/utils/extensions.dart';

import '/utils/convert_type.dart';
import '/utils/format_date_time.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:crypto/crypto.dart';

class AppUtils {
  static dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  //Enkripsi kebutuhan header api
  static String encryptHMAC(int unixTime, String apiKey) {
    final currentDate = DateTime.now().toIso8601String().substring(0, 10);
    final combinedString = apiKey + currentDate;

    final keyBytes =
        utf8.encode(combinedString); // Buat sebuah kunci dari kombinasi string
    final plainBytes =
        utf8.encode(unixTime.toString()); // Konversi unixtime ke bytes

    final hmacSha256 = Hmac(sha256,
        keyBytes); // Siapkan proses enkripsi HMAC-SHA256 menggunakan kunci yang telah dibuat
    final digest = hmacSha256.convert(plainBytes); // Lakukan enkripsi

    final cipherHexString =
        digest.toString(); // Konversikan hasil enkripsi menjadi string hex

    return cipherHexString;
  }

  static Future<bool> checkTokenValidity(String token) async {
    try {
      final exp = JwtDecoder.getExpirationDate(token);
      final currentTime = DateTime.now();
      final tokenCreated = getIssuedAtToken(token);

      // Log current time and expiration time
      final formattedCurrentTime =
          DateFormat('dd MMM yyyy HH:mm').format(currentTime);
      final formattedExpirationDate =
          DateFormat('dd MMM yyyy HH:mm').format(exp);
      final formattedTokenCreated =
          DateFormat('dd MMM yyyy HH:mm').format(tokenCreated);

      logSys('Current time: $formattedCurrentTime');
      logSys('Token expires at: $formattedExpirationDate');
      logSys('Token created at: $formattedTokenCreated');
      return !JwtDecoder.isExpired(token);
    } catch (e) {
      logSys(e.toString());
      return false;
    }
  }

  static DateTime getIssuedAtToken(String token) {
    final decodedToken = JwtDecoder.decode(token);

    // Get the issued at (iat) claim and convert to DateTime
    final issuedAtDate =
        DateTime.fromMillisecondsSinceEpoch(decodedToken["iat"] * 1000);

    return issuedAtDate;
  }

  static bool checkAvailDateTime({
    required DateTime selectedDate,
    required String showtime,
  }) {
    final dataShowtime = showtime.split(':');

    final dataShowtimeConvert = FormatDateTime.format(
      value: DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        ConvertType.toInt(dataShowtime[0]),
        ConvertType.toInt(dataShowtime[1]),
      ),
      format: DateFormat('yyyy-MM-dd HH:mm'),
    );

    return DateTime.now().isBefore(DateTime.parse(dataShowtimeConvert));
  }

  static bool isJsonString(String s) {
    try {
      json.decode(s) as Map<String, dynamic>;
      return true;
    } on FormatException {
      return false;
    }
  }

  static void generateColorSwatch(Color color) {
    final strengths = <double>[.05];
    final swatch = <int, Color>{};
    final r = color.red;
    final g = color.green;
    final b = color.blue;

    for (var i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }

    for (final strength in strengths) {
      final ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    logSys('cek result : $swatch');
  }

  static convertToFile(XFile? xFile) {
    if (xFile != null) {
      var filePhoto = File(xFile.path);
      return filePhoto;
    }
  }

  static Future<File> compressFile(File file, {int quality = 80}) async {
    final filePath = file.absolute.path;

    // Create output file path
    // eg:- "Volume/VM/abcd_out.jpeg"
    final lastIndex = filePath.lastIndexOf(new RegExp(r'.jp'));
    final splitted = filePath.substring(0, (lastIndex));
    final outPath = "${splitted}_out${filePath.substring(lastIndex)}";
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      outPath,
      quality: quality,
    );

    File resultFile = convertToFile(result);

    logSys("Before Compress : ${file.size}");
    logSys("After Compress : ${resultFile.size}");

    return resultFile;
  }
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static const separator = '.'; // Change this to '.' for other locales

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Short-circuit if the new value is empty
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Handle "deletion" of separator character
    final oldValueText = oldValue.text.replaceAll(separator, '');
    var newValueText = newValue.text.replaceAll(separator, '');

    if (oldValue.text.endsWith(separator) &&
        oldValue.text.length == newValue.text.length + 1) {
      newValueText = newValueText.substring(0, newValueText.length - 1);
    }

    // Only process if the old value and new value are different
    if (oldValueText != newValueText) {
      final selectionIndex =
          newValue.text.length - newValue.selection.extentOffset;
      final chars = newValueText.split('');

      var newString = '';
      for (var i = chars.length - 1; i >= 0; i--) {
        if ((chars.length - 1 - i) % 3 == 0 && i != chars.length - 1) {
          newString = separator + newString;
        }
        newString = chars[i] + newString;
      }

      return TextEditingValue(
        text: newString,
        selection: TextSelection.collapsed(
          offset: newString.length - selectionIndex,
        ),
      );
    }

    // If the new value and old value are the same, just return as-is
    return newValue;
  }
}

logSys(String s) {
  if (kDebugMode) {
    d.log(s);
  }
}
