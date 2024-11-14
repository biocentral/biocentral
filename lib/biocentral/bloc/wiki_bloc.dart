import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

sealed class WikiEvent {}

final class WikiLoadEvent extends WikiEvent {}

@immutable
final class WikiState extends Equatable {
  final Map<String, String> wikiDocs;
  final WikiStatus status;

  const WikiState(this.wikiDocs, this.status);

  const WikiState.initial()
      : wikiDocs = const {},
        status = WikiStatus.initial;

  const WikiState.loading()
      : wikiDocs = const {},
        status = WikiStatus.loading;

  const WikiState.loaded(this.wikiDocs) : status = WikiStatus.loaded;

  @override
  List<Object?> get props => [status];
}

enum WikiStatus { initial, loading, loaded }

class WikiBloc extends Bloc<WikiEvent, WikiState> {
  WikiBloc() : super(const WikiState.initial()) {
    on<WikiLoadEvent>((event, emit) async {
      emit(const WikiState.loading());

      final manifestContent = await rootBundle.loadString('AssetManifest.json');

      final Map<String, dynamic> manifestMap = jsonDecode(manifestContent);

      final Map<String, String> wikiDocs = {};
      for (String key in manifestMap.keys) {
        if (key.split('/').first == 'doc') {
          final String docContent = await rootBundle.loadString(key);
          wikiDocs[key.split('/').last] = docContent;
        }
      }
      emit(WikiState.loaded(wikiDocs));
    });
  }
}
