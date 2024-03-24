// ignore_for_file: unnecessary_this

import 'dart:io';
import 'dart:math';

extension FileUtils on File {
  get size {
    int bytes = this.lengthSync();
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return "${((bytes / pow(1024, i)).toStringAsFixed(3))} ${suffixes[i]}";
  }
}
