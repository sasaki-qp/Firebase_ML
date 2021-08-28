import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ml_demo/provider/text_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends HookWidget {
  late double screenWidth;
  late double screenHeight;

  late ImageSource image;
  late FirebaseAuth auth;
  late ImagePicker picker;
  @override
  Widget build(BuildContext context) {
    TextStateNotifier notifier = useProvider(textProvider.notifier);
    String state = useProvider(textProvider);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    picker = ImagePicker();
    image = ImageSource.camera;

    auth = FirebaseAuth.instance;

    print("== rebuild == $state");

    return Scaffold(
        body: Container(
          height: screenHeight,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [],
          ),
        ),
        floatingActionButton: Row(
          children: [
            Gap(screenWidth * 0.65,),
            FloatingActionButton(
              child: Icon(
                Icons.login_sharp,
              ),
              onPressed: () async {
                var res = await auth.signInAnonymously();
                print("== auth response == $res");
              },
            ),
            Gap(15),
            FloatingActionButton(
              child: Icon(Icons.camera_alt_sharp),
              onPressed: () async {
                try {
                  var file = await picker.pickImage(source: image);
                  if (file == null) {
                    throw "キャンセルしました";
                  } else {
                    notifier.analyze(filePath: file.path);
                  }
                } catch (err) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        err == "キャンセルしました" ? err.toString() : "読み取りに失敗しました",
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ));
  }
}
