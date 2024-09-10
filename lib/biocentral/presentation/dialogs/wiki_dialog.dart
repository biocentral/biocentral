import 'package:biocentral/biocentral/bloc/wiki_bloc.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:tutorial_system/tutorial_system.dart';

class WikiDialog extends StatefulWidget {
  const WikiDialog({super.key});

  @override
  State<WikiDialog> createState() => _WikiDialogState();
}

class _WikiDialogState extends State<WikiDialog> {
  List<Tutorial> _availableTutorials = [];

  String? _selectedDoc;
  bool _showTutorials = false;

  @override
  void initState() {
    super.initState();
    TutorialRepository tutorialRepository = context.read<TutorialRepository>();
    _availableTutorials = tutorialRepository.getTutorials();
  }

  void startTutorial(Tutorial tutorialContainer) {
    TutorialRepository tutorialRepository = context.read<TutorialRepository>();
    TutorialRunner tutorialRunner = TutorialRunner(tutorialContainer, tutorialRepository);
    TutorialHandler tutorialHandler = TutorialHandler(tutorialRunner, tutorialRepository);
    closeDialog();
    tutorialHandler.startTutorial();
  }

  void closeDialog() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WikiBloc, WikiState>(
      builder: (context, state) {
        return BiocentralDialog(
          small: false, // TODO Small Dialog not working yet
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Biocentral Wiki",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.min,
                  children: [Flexible(child: buildDocSelection(state)), Flexible(flex: 2, child: buildDocStringBox())],
                ),
              ],
            )
          ],
        );
      },
    );
  }

  Widget buildDocSelection(WikiState state) {
    List<ListTile> wikiTiles = state.wikiDocs.entries
        .map((wikiEntry) => ListTile(
              title: Text(wikiEntry.key),
              onTap: () => setState(() {
                _showTutorials = false;
                _selectedDoc = wikiEntry.value;
              }),
            ))
        .toList();

    return ListView(shrinkWrap: true, children: [
      ListTile(
          title: const Text("Tutorials"),
          onTap: () => setState(() {
                _showTutorials = true;
              })),
      ...wikiTiles
    ]);
  }

  Widget buildDocStringBox() {
    if (_showTutorials) {
      return SizedBox(
        height: SizeConfig.screenHeight(context) * 0.15,
        width: SizeConfig.screenWidth(context) * 0.8,
        child: Column(
          children: [
            ..._availableTutorials.map((tutorialContainer) => BiocentralSmallButton(
                onTap: () => startTutorial(tutorialContainer), // Wrap in function to ensure lazy loading
                label: "Start Tutorial: ${tutorialContainer.getName()}"))
          ],
        ),
      );
    }
    return SizedBox(
        height: SizeConfig.screenHeight(context) * 0.15,
        width: SizeConfig.screenWidth(context) * 0.8,
        child: SingleChildScrollView(
            child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Colors.grey,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MarkdownBody(
                    data: _selectedDoc ?? "",
                  ),
                ))));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
