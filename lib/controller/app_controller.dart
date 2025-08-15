import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AppController extends GetxController {
  RxString oldVersion = "".obs;
  RxString currentVersion = "".obs;
  RxString newAppUrl = "".obs;

  void onInit() async {
    super.onInit();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    currentVersion.value = packageInfo.version;
    print(currentVersion.value);
    checkLatestVersion();
  }

  Future<void> checkLatestVersion() async {
    const repositoryOwner = 'krishgupta1';
    const repositoryName = 'Todo-App-Updates';
    final response = await http.get(
      Uri.parse(
        'https://api.github.com/repos/$repositoryOwner/$repositoryName/releases/latest',
      ),
    );
    print(currentVersion);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final tagName = data['tag_name'];
      oldVersion.value = tagName;
      final assets = data['assets'] as List<dynamic>;
      for (final asset in assets) {
        // final assetName = asset['name'];
        final assetDownloadUrl = asset['browser_download_url'];
        newAppUrl.value = assetDownloadUrl;
        print(assetDownloadUrl);
      }
      if (oldVersion.value != currentVersion.value) {
        checkUpdate();
      } else {
        Get.rawSnackbar(
          duration: Duration(seconds: 4),
          titleText: Text(
            "✅ You are updated",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          messageText: Text(
            "No new version available.",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          backgroundColor: Colors.green,
          borderRadius: 12,
          margin: EdgeInsets.all(16),
          snackPosition: SnackPosition.TOP,
          mainButton: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Get.back();
              },
              child: Text(
                "OK",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }
    } else {
      print(
        'Failed to fetch GitHub release info. Status code: ${response.statusCode}',
      );
    }
  }

  void checkUpdate() {
    Get.rawSnackbar(
      duration: Duration(days: 1),
      titleText: Text(
        "🚀 New Update Available",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      messageText: Text(
        "A new version of the app is ready to download.",
        style: TextStyle(color: Colors.white70, fontSize: 14),
      ),
      backgroundColor: Colors.blueAccent,
      borderRadius: 12,
      margin: EdgeInsets.all(16),
      snackPosition: SnackPosition.TOP,
      mainButton: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            launchUrl(
              Uri.parse(newAppUrl.value),
              mode: LaunchMode.externalApplication,
            );
            Get.back();
          },
          child: Text(
            "Update Now",
            style: TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );

    print(currentVersion.value);
  }
}
