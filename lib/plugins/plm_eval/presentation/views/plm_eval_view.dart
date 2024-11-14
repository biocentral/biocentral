import 'package:flutter/material.dart';

class PLMEvalView extends StatefulWidget {
  const PLMEvalView({super.key});

  @override
  State<PLMEvalView> createState() => _PLMEvalViewState();
}

class _PLMEvalViewState extends State<PLMEvalView> with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return const Scaffold(body: Column(),);
  }
}
