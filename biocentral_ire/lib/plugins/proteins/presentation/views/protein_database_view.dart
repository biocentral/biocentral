import 'package:bio_flutter/bio_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'package:biocentral/plugins/proteins/bloc/protein_database_grid_bloc.dart';

class ProteinDatabaseView extends StatefulWidget {
  final Function(Protein? selectedProtein) onProteinSelected;

  const ProteinDatabaseView({required this.onProteinSelected, super.key});

  @override
  State<ProteinDatabaseView> createState() => ProteinDatabaseViewState();
}

class ProteinDatabaseViewState extends State<ProteinDatabaseView> with AutomaticKeepAliveClientMixin {
  static final List<PlutoColumn> _defaultProteinColumns = <PlutoColumn>[
    PlutoColumn(
      title: 'Protein ID',
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
                text: 'N',
                style: TextStyle(color: Colors.green),
              ),
              const TextSpan(text: ': '),
              TextSpan(text: text),
            ];
          },
        );
      },
    ),
    PlutoColumn(
      title: 'Sequence',
      field: 'sequence',
      type: PlutoColumnType.text(),
      footerRenderer: (rendererContext) {
        return PlutoAggregateColumnFooter(
          rendererContext: rendererContext,
          type: PlutoAggregateColumnType.count,
          filter: (PlutoCell plutoCell) => plutoCell.value == '',
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
    ),
    PlutoColumn(
      title: 'Embeddings',
      field: 'embeddings',
      type: PlutoColumnType.text(),
      footerRenderer: (rendererContext) {
        return PlutoAggregateColumnFooter(
          rendererContext: rendererContext,
          type: PlutoAggregateColumnType.count,
          filter: (PlutoCell plutoCell) => plutoCell.value == '',
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
    ),
    PlutoColumn(
      title: 'Taxonomy ID',
      field: 'taxonomyID',
      type: PlutoColumnType.number(defaultValue: -1),
      footerRenderer: (rendererContext) {
        return PlutoAggregateColumnFooter(
          rendererContext: rendererContext,
          type: PlutoAggregateColumnType.count,
          filter: (PlutoCell plutoCell) => plutoCell.value == -1,
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
    ),
    PlutoColumn(
      title: 'Species Name',
      field: 'taxonomyName',
      type: PlutoColumnType.text(),
      footerRenderer: (rendererContext) {
        return PlutoAggregateColumnFooter(
          rendererContext: rendererContext,
          type: PlutoAggregateColumnType.count,
          filter: (PlutoCell plutoCell) => plutoCell.value == '',
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
    ),
    PlutoColumn(
      title: 'Family Name',
      field: 'taxonomyFamily',
      type: PlutoColumnType.text(),
      footerRenderer: (rendererContext) {
        return PlutoAggregateColumnFooter(
          rendererContext: rendererContext,
          type: PlutoAggregateColumnType.count,
          filter: (PlutoCell plutoCell) => plutoCell.value == '',
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
    ),
    //PlutoColumn(title: 'Target', field: 'target', type: PlutoColumnType.text()),
    //PlutoColumn(title: 'Set', field: 'set', type: PlutoColumnType.text())
  ];

  /// [PlutoGridStateManager] has many methods and properties to dynamically manipulate the grid.
  /// You can manipulate the grid dynamically at runtime by passing this through the [onLoaded] callback.
  PlutoGridStateManager? stateManager;
  final PlutoGridMode plutoGridMode = PlutoGridMode.selectWithOneTap;


  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final ProteinDatabaseGridBloc proteinDatabaseGridBloc = BlocProvider.of<ProteinDatabaseGridBloc>(context);
    Key gridKey = UniqueKey();
    return Scaffold(
      body: BlocConsumer<ProteinDatabaseGridBloc, ProteinDatabaseGridState>(
        listener: (context, state) {
          if (state.status == ProteinDatabaseGridStatus.selected) {
            widget.onProteinSelected(state.selectedProtein);
          }
          if (state.status == ProteinDatabaseGridStatus.loaded) {
            gridKey = UniqueKey(); // Force rebuild
          }
        },
        builder: (context, state) => PlutoGrid(
          key: gridKey,
          mode: plutoGridMode,
          columns: buildColumns(state),
          rows: buildRowsFromProteins(state),
          onLoaded: (PlutoGridOnLoadedEvent event) {
            stateManager ??= event.stateManager;
            stateManager!.setShowColumnFilter(true);
          },
          onChanged: (PlutoGridOnChangedEvent event) {
            // TODO
          },
          onSelected: (PlutoGridOnSelectedEvent event) {
            proteinDatabaseGridBloc.add(ProteinDatabaseGridSelectionEvent(selectedEvent: event));
          },
          onRowSecondaryTap: (PlutoGridOnRowSecondaryTapEvent event) {
            //widget.openProteinViewCallback();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() {
          stateManager!.appendNewRows();
        }),
        child: const Icon(Icons.add),
      ),
    );
  }

  List<PlutoColumn> buildColumns(ProteinDatabaseGridState state) {
    final List<PlutoColumn> result = List.from(_defaultProteinColumns);
    for (String setColumnName in state.additionalColumns ?? {}) {
      result.add(PlutoColumn(
        title: setColumnName,
        field: setColumnName,
        type: PlutoColumnType.text(),
        footerRenderer: (rendererContext) {
          // TODO Change footer to show more meaningful information
          return PlutoAggregateColumnFooter(
            rendererContext: rendererContext,
            type: PlutoAggregateColumnType.count,
            filter: (PlutoCell plutoCell) => plutoCell.value == '',
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
      ),);
    }
    return result;
  }

  List<PlutoRow> buildRowsFromProteins(ProteinDatabaseGridState state) {
    final List<PlutoRow> rows = List.empty(growable: true);
    for (Protein protein in state.proteins) {
      final PlutoRow row = PlutoRow(
        cells: {
          'id': PlutoCell(value: protein.id),
          'sequence': PlutoCell(value: protein.sequence.seq),
          'embeddings': PlutoCell(value: protein.embeddings.information()),
          'taxonomyID': PlutoCell(value: protein.taxonomy.id),
          'taxonomyName': PlutoCell(value: protein.taxonomy.name ?? ''),
          'taxonomyFamily': PlutoCell(value: protein.taxonomy.family ?? ''),
          'target': PlutoCell(value: protein.attributes['TARGET']),
        }..addAll(Map<String, PlutoCell>.fromEntries(state.additionalColumns
                ?.map((columnName) => MapEntry(columnName, PlutoCell(value: protein.attributes[columnName] ?? ''))) ??
            {},),),
      );
      rows.add(row);
    }
    return rows;
  }
}
