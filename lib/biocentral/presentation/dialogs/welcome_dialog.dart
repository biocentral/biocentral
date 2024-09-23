import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:url_launcher/url_launcher_string.dart';

class WelcomeDialog extends StatefulWidget {
  const WelcomeDialog({super.key});

  @override
  State<WelcomeDialog> createState() => _WelcomeDialogState();
}

class _WelcomeDialogState extends State<WelcomeDialog> {
  @override
  void initState() {
    super.initState();
  }

  void closeDialog() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BiocentralDialog(
      small: false, // TODO Small Dialog not working yet
      children: [
        const Text(
          'Welcome to Biocentral!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return Text("Version: ${snapshot.data?.version}", style: TextStyle(fontWeight: FontWeight.w100));
              }
              return const CircularProgressIndicator();
            }),
        const SizedBox(height: 20),
        RichText(
          text: const TextSpan(children: [
            TextSpan(
                text: "Thank you so much for using biocentral!\n"
                    "Biocentral is currently under constant development. "
                    "The version you are using is an early alpha version.\n"
                    "If you are experiencing any bugs or issues, "
                    "please get in touch by one of the following methods:"),
          ], style: TextStyle(color: Colors.black, fontSize: 18)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                onPressed: () {
                  launchUrlString('https://github.com/biocentral/biocentral/issues');
                },
                icon: const Icon(SimpleIcons.github),
                label: const Text("Create a GitHub issue")),
            const SizedBox(height: 20),
            ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                onPressed: () {
                  launchUrlString('mailto:info@biocentral.cloud');
                },
                icon: const Icon(Icons.mail),
                label: const Text("Send us an email")),
            const SizedBox(height: 20),
            RichText(
              text: const TextSpan(children: [
                TextSpan(
                    text: "Please also make sure to stay up-to-date by signing up for our newsletter:"),
              ], style: TextStyle(color: Colors.black, fontSize: 18)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                onPressed: () {
                  launchUrlString('https://biocentral.cloud#newsletter');
                },
                icon: const Icon(Icons.newspaper),
                label: const Text("Newsletter Registration")),
            const SizedBox(height: 40),
            BiocentralSmallButton(onTap: closeDialog, label: "Close")
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
