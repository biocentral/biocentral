// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_learning_screening_simulation_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ActiveLearningScreeningSimulationRequest
    extends ActiveLearningScreeningSimulationRequest {
  @override
  final ActiveLearningScreeningCampaignConfig campaignConfig;
  @override
  final ActiveLearningScreeningSimulationConfig simulationConfig;

  factory _$ActiveLearningScreeningSimulationRequest(
          [void Function(ActiveLearningScreeningSimulationRequestBuilder)?
              updates]) =>
      (ActiveLearningScreeningSimulationRequestBuilder()..update(updates))
          ._build();

  _$ActiveLearningScreeningSimulationRequest._(
      {required this.campaignConfig, required this.simulationConfig})
      : super._();
  @override
  ActiveLearningScreeningSimulationRequest rebuild(
          void Function(ActiveLearningScreeningSimulationRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ActiveLearningScreeningSimulationRequestBuilder toBuilder() =>
      ActiveLearningScreeningSimulationRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ActiveLearningScreeningSimulationRequest &&
        campaignConfig == other.campaignConfig &&
        simulationConfig == other.simulationConfig;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, campaignConfig.hashCode);
    _$hash = $jc(_$hash, simulationConfig.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'ActiveLearningScreeningSimulationRequest')
          ..add('campaignConfig', campaignConfig)
          ..add('simulationConfig', simulationConfig))
        .toString();
  }
}

class ActiveLearningScreeningSimulationRequestBuilder
    implements
        Builder<ActiveLearningScreeningSimulationRequest,
            ActiveLearningScreeningSimulationRequestBuilder> {
  _$ActiveLearningScreeningSimulationRequest? _$v;

  ActiveLearningScreeningCampaignConfigBuilder? _campaignConfig;
  ActiveLearningScreeningCampaignConfigBuilder get campaignConfig =>
      _$this._campaignConfig ??= ActiveLearningScreeningCampaignConfigBuilder();
  set campaignConfig(
          ActiveLearningScreeningCampaignConfigBuilder? campaignConfig) =>
      _$this._campaignConfig = campaignConfig;

  ActiveLearningScreeningSimulationConfigBuilder? _simulationConfig;
  ActiveLearningScreeningSimulationConfigBuilder get simulationConfig =>
      _$this._simulationConfig ??=
          ActiveLearningScreeningSimulationConfigBuilder();
  set simulationConfig(
          ActiveLearningScreeningSimulationConfigBuilder? simulationConfig) =>
      _$this._simulationConfig = simulationConfig;

  ActiveLearningScreeningSimulationRequestBuilder() {
    ActiveLearningScreeningSimulationRequest._defaults(this);
  }

  ActiveLearningScreeningSimulationRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _campaignConfig = $v.campaignConfig.toBuilder();
      _simulationConfig = $v.simulationConfig.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ActiveLearningScreeningSimulationRequest other) {
    _$v = other as _$ActiveLearningScreeningSimulationRequest;
  }

  @override
  void update(
      void Function(ActiveLearningScreeningSimulationRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ActiveLearningScreeningSimulationRequest build() => _build();

  _$ActiveLearningScreeningSimulationRequest _build() {
    _$ActiveLearningScreeningSimulationRequest _$result;
    try {
      _$result = _$v ??
          _$ActiveLearningScreeningSimulationRequest._(
            campaignConfig: campaignConfig.build(),
            simulationConfig: simulationConfig.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'campaignConfig';
        campaignConfig.build();
        _$failedField = 'simulationConfig';
        simulationConfig.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ActiveLearningScreeningSimulationRequest',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
