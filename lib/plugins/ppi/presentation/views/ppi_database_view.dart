import 'package:bio_flutter/bio_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../bloc/ppi_database_grid_bloc.dart';

class PPIDatabaseView extends StatefulWidget {
  final Function(ProteinProteinInteraction selectedInteraction) onInteractionSelected;

  const PPIDatabaseView({super.key, required this.onInteractionSelected});

  @override
  State<PPIDatabaseView> createState() => PPIDatabaseViewState();
}

class PPIDatabaseViewState extends State<PPIDatabaseView> with AutomaticKeepAliveClientMixin {
  static final List<PlutoColumn> _defaultInteractionColumns = <PlutoColumn>[
    PlutoColumn(
      title: 'Interaction ID',
      field: 'id',
      type: PlutoColumnType.text(),
      footerRenderer: (rendererContext) {
        return PlutoAggregateColumnFooter(
          rendererContext: rendererContext,
          type: PlutoAggregateColumnType.count,
          format: '#',
          alignment: Alignment.center,
          titleSpanBuilder: (text) {
            return [
              const TextSpan(
                text: 'N: ',
                style: TextStyle(color: Colors.green),
              ),
              TextSpan(text: text),
            ];
          },
        );
      },
    ),
    PlutoColumn(title: 'Interactor1', field: 'interactor1', type: PlutoColumnType.text()),
    PlutoColumn(title: 'Interactor2', field: 'interactor2', type: PlutoColumnType.text()),
    PlutoColumn(
      title: 'Interacting',
      field: 'interacting',
      type: PlutoColumnType.number(),
      footerRenderer: (rendererContext) {
        return PlutoAggregateColumnFooter(
          rendererContext: rendererContext,
          type: PlutoAggregateColumnType.sum,
          format: '#',
          alignment: Alignment.center,
          titleSpanBuilder: (text) {
            return [
              const TextSpan(
                text: 'Positive: ',
                style: TextStyle(color: Colors.green),
              ),
              TextSpan(text: text),
            ];
          },
        );
      },
    ),
  ];

  /// [PlutoGridStateManager] has many methods and properties to dynamically manipulate the grid.
  /// You can manipulate the grid dynamically at runtime by passing this through the [onLoaded] callback.
  PlutoGridStateManager? stateManager;
  final PlutoGridMode plutoGridMode = PlutoGridMode.selectWithOneTap;

  @override
  void initState() {
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    PPIDatabaseGridBloc interactionDatabaseGridBloc = BlocProvider.of<PPIDatabaseGridBloc>(context);
    Key gridKey = UniqueKey();
    return Scaffold(
      body: BlocConsumer<PPIDatabaseGridBloc, PPIDatabaseGridState>(
        listener: (context, state) {
          if (state.status == PPIDatabaseGridStatus.selected) {
            widget.onInteractionSelected(state.selectedPPI!);
          }
          if (state.status == PPIDatabaseGridStatus.loaded) {
            gridKey = GlobalKey(); // Force rebuild
          }
        },
        builder: (context, state) => PlutoGrid(
          key: gridKey,
          mode: plutoGridMode,
          columns: buildColumns(state),
          rows: getRowsFromInteractions(state),
          onLoaded: (PlutoGridOnLoadedEvent event) {
            stateManager ??= event.stateManager;
            stateManager!.setShowColumnFilter(true);
          },
          onChanged: (PlutoGridOnChangedEvent event) {},
          onSelected: (PlutoGridOnSelectedEvent event) {
            interactionDatabaseGridBloc.add(PPIDatabaseGridSelectionEvent(selectedEvent: event));
          },
          onRowSecondaryTap: (PlutoGridOnRowSecondaryTapEvent event) {},
          configuration: const PlutoGridConfiguration(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() {
          stateManager!.appendNewRows(count: 1);
        }),
        child: const Icon(Icons.add),
      ),
    );
  }

  List<PlutoColumn> buildColumns(PPIDatabaseGridState state) {
    List<PlutoColumn> result = List.from(_defaultInteractionColumns);
    for (String setColumnName in state.additionalColumns ?? {}) {
      result.add(PlutoColumn(
        title: setColumnName,
        field: setColumnName,
        type: PlutoColumnType.text(),
        footerRenderer: (rendererContext) {
          // TODO Change footer to show more meaningful information like train-val-test distribution
          return PlutoAggregateColumnFooter(
            rendererContext: rendererContext,
            type: PlutoAggregateColumnType.count,
            filter: (PlutoCell plutoCell) => plutoCell.value == "",
            format: '#',
            alignment: Alignment.center,
            titleSpanBuilder: (text) {
              return [
                const TextSpan(
                  text: 'Missing',
                  style: TextStyle(color: Colors.red),
                ),
                const TextSpan(text: ': '),
                TextSpan(text: text),
              ];
            },
          );
        },
      ));
    }
    return result;
  }

  List<PlutoRow> getRowsFromInteractions(PPIDatabaseGridState state) {
    List<PlutoRow> rows = List.empty(growable: true);
    for (ProteinProteinInteraction interaction in state.ppis) {
      PlutoRow row = PlutoRow(
        cells: {
          'id': PlutoCell(value: interaction.getID()),
          'interactor1': PlutoCell(value: interaction.interactor1.id),
          'interactor2': PlutoCell(value: interaction.interactor2.id),
          'interacting': PlutoCell(value: interaction.interacting ? 1 : 0),
        }..addAll(Map<String, PlutoCell>.fromEntries(state.additionalColumns?.map(
                (columnName) => MapEntry(columnName, PlutoCell(value: interaction.attributes[columnName] ?? ""))) ??
            {})),
      );
      rows.add(row);
    }
    return rows;
  }
}
