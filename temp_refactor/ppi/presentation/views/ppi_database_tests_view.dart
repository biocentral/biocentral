import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:biocentral/plugins/ppi/bloc/ppi_database_tests_bloc.dart';
import 'package:biocentral/plugins/ppi/presentation/displays/ppi_test_display.dart';

class PPIDatabaseTestsView extends StatefulWidget {
  const PPIDatabaseTestsView({super.key});

  @override
  State<PPIDatabaseTestsView> createState() => PPIDatabaseTestsViewState();
}

class PPIDatabaseTestsViewState extends State<PPIDatabaseTestsView> with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<PPIDatabaseTestsBloc, PPIDatabaseTestsState>(builder: (context, state) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: InputDecorator(
          expands: true,
          decoration: InputDecoration(
            labelText: 'Database Tests:',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: Column(
            children: [
              ...buildTestDisplays(state),],
          ),
        ),
      );
    },);
  }

  List<Widget> buildTestDisplays(PPIDatabaseTestsState state) {
    return state.executedTests.map((datasetTest) => PPITestDisplay(test: datasetTest)).toList();
  }
}
