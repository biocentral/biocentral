import 'package:flutter/material.dart';

class BayesianOptimizationHubView extends StatefulWidget {
  const BayesianOptimizationHubView({super.key});

  @override
  State<BayesianOptimizationHubView> createState() => _BayesianOptimizationHubViewState();
}

class _BayesianOptimizationHubViewState extends State<BayesianOptimizationHubView> with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const Text("Bayesian Optimization Hub View");
  }
}
