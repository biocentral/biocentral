import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:url_launcher/url_launcher_string.dart';

class InfoDialog extends StatefulWidget {
  const InfoDialog({super.key});

  @override
  State<InfoDialog> createState() => _InfoDialogState();
}

class _InfoDialogState extends State<InfoDialog> {
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
          'Biocentral - Biomedical data, from lab to paper.',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        RichText(
          text: const TextSpan(children: [
            TextSpan(
                text: "Biocentral is an open-source, cutting-edge bioinformatics platform "
                    "designed to bridge the gap between the "
                    "latest developments in bioinformatics and applications "
                    "in molecular biology and diagnostic medicine.\n"),
          ], style: TextStyle(color: Colors.black)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                onPressed: () {
                  launchUrlString('https://github.com/biocentral/biocentral');
                },
                icon: const Icon(SimpleIcons.github),
                label: const Text("GitHub Repository")),
            const SizedBox(height: 20),
            ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                onPressed: () {
                  launchUrlString('https://biocentral.cloud');
                },
                icon: const Icon(Icons.link),
                label: const Text("Biocentral Website")),
            const SizedBox(height: 20),
            ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                onPressed: () {
                  launchUrlString('https://github.com/biocentral/biocentral/blob/main/LICENSE');
                },
                icon: const Icon(Icons.file_present),
                label: const Text("License: GNU GPL v3.0")),
            const SizedBox(height: 20),
            FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                        onPressed: () {
                          showAboutDialog(
                              context: context,
                              applicationName: snapshot.data?.appName,
                              applicationVersion: "Version: ${snapshot.data?.version}");
                        },
                        icon: const Icon(Icons.question_mark),
                        label: const Text("Show application information"));
                  }
                  return const CircularProgressIndicator();
                }),
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
