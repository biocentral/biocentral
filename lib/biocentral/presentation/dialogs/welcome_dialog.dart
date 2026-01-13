import 'package:biocentral/plugins/proteins/model/analyze_example_dataset_tutorial.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:tutorial_system/tutorial_system.dart';
import 'package:url_launcher/url_launcher_string.dart';

// TODO Hacky solution to determine correct tutorial, could be replaced by proper skipping in tutorial
int __numOpenings = 0;

class WelcomeDialog extends StatefulWidget {
  const WelcomeDialog({super.key});

  @override
  State<WelcomeDialog> createState() => _WelcomeDialogState();
}

class _WelcomeDialogState extends State<WelcomeDialog> with BiocentralDialogCloseMixin {
  @override
  void initState() {
    super.initState();
  }

  void startTutorial(Tutorial tutorial) {
    final TutorialRepository tutorialRepository = context.read<TutorialRepository>();
    final TutorialRunner tutorialRunner = TutorialRunner(tutorial, tutorialRepository);
    final TutorialHandler tutorialHandler = TutorialHandler(tutorialRunner, tutorialRepository);
    closeDialog(callback: tutorialHandler.startTutorial);
  }

  @override
  Widget build(BuildContext context) {
    __numOpenings += 1;
    return BiocentralDialog(
      children: [
        const Text(
          'Welcome to Biocentral!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return Text('Version: ${snapshot.data?.version}', style: const TextStyle(fontWeight: FontWeight.w100));
            }
            return const CircularProgressIndicator();
          },
        ),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                  text: 'Thank you for using biocentral!\n'
                      'The Biocentral IRE is currently under constant development.\n'),
            ],
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          textAlign: TextAlign.center,
        ),
        const Divider(),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(text: 'Getting Started'),
            ],
            style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          textAlign: TextAlign.center,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              onPressed: () {
                launchUrlString('https://biocentral.cloud/docs/biocentral/getting_started');
              },
              icon: const Icon(Icons.book),
              label: const Text('Read Getting Started Guide'),
            ),
            const SizedBox(width: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              onPressed: () {
                startTutorial(
                  __numOpenings <= 1
                      ? AnalyzeExampleDatasetTutorialFromWelcomeScreen()
                      : AnalyzeExampleDatasetTutorial(),
                );
              },
              icon: const Icon(Icons.not_started),
              label: const Text('Start Interactive Tutorial'),
            ),
            const SizedBox(height: 20),
          ],
        ),
        const Divider(),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'If you are experiencing any bugs or issues, '
                    'please get in touch by one of the following methods:',
              ),
            ],
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          textAlign: TextAlign.center,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              onPressed: () {
                launchUrlString('https://github.com/biocentral/biocentral/issues');
              },
              icon: const Icon(SimpleIcons.github),
              label: const Text('Create a GitHub Issue'),
            ),
            const SizedBox(width: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              onPressed: () {
                launchUrlString('mailto:info@biocentral.cloud');
              },
              icon: const Icon(Icons.mail),
              label: const Text('Send us an E-Mail'),
            ),
            const SizedBox(height: 20),
          ],
        ),
        const Divider(),
        BiocentralSmallButton(onTap: closeDialog, label: 'Close'),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
