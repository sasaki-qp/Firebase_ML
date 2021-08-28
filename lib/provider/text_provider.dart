import 'dart:io';
import 'dart:convert';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';

final textProvider = StateNotifierProvider<TextStateNotifier, String>(
  (ref) => TextStateNotifier(),
);

class TextStateNotifier extends StateNotifier<String> {
  TextStateNotifier() : super("");

  late File file;
  late HttpsCallableResult<dynamic> result;

  late List<int> imageByte;
  late String base64EncodedImage;

  late HttpsCallable callable =
      FirebaseFunctions.instance.httpsCallable("annotateImage");

  analyze({
    required String filePath,
  }) async {
    file = File(filePath);
    imageByte = file.readAsBytesSync();
    base64EncodedImage = base64Encode(imageByte);

    final query = '''{
      "image": {"content": "$base64EncodedImage"},
      "features": [{"type": "TEXT_DETECTION"}],
      "imageContext": {
        "languageHints": ["ja"]
      }
    }''';

    try {
      result = await callable(query);
      add(text: result.data[0]["fullTextAnnotation"]["text"]);
    } catch (err) {
      print("== analyze error ==$err");
    }
  }

  add({required String text}) {
    state = text;
  }
}
