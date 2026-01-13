// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_learning_simulation_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ActiveLearningSimulationRequest
    extends ActiveLearningSimulationRequest {
  @override
  final ActiveLearningCampaignConfig campaignConfig;
  @override
  final ActiveLearningSimulationConfig simulationConfig;

  factory _$ActiveLearningSimulationRequest(
          [void Function(ActiveLearningSimulationRequestBuilder)? updates]) =>
      (ActiveLearningSimulationRequestBuilder()..update(updates))._build();

  _$ActiveLearningSimulationRequest._(
      {required this.campaignConfig, required this.simulationConfig})
      : super._();
  @override
  ActiveLearningSimulationRequest rebuild(
          void Function(ActiveLearningSimulationRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ActiveLearningSimulationRequestBuilder toBuilder() =>
      ActiveLearningSimulationRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ActiveLearningSimulationRequest &&
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
    return (newBuiltValueToStringHelper(r'ActiveLearningSimulationRequest')
          ..add('campaignConfig', campaignConfig)
          ..add('simulationConfig', simulationConfig))
        .toString();
  }
}

class ActiveLearningSimulationRequestBuilder
    implements
        Builder<ActiveLearningSimulationRequest,
            ActiveLearningSimulationRequestBuilder> {
  _$ActiveLearningSimulationRequest? _$v;

  ActiveLearningCampaignConfigBuilder? _campaignConfig;
  ActiveLearningCampaignConfigBuilder get campaignConfig =>
      _$this._campaignConfig ??= ActiveLearningCampaignConfigBuilder();
  set campaignConfig(ActiveLearningCampaignConfigBuilder? campaignConfig) =>
      _$this._campaignConfig = campaignConfig;

  ActiveLearningSimulationConfigBuilder? _simulationConfig;
  ActiveLearningSimulationConfigBuilder get simulationConfig =>
      _$this._simulationConfig ??= ActiveLearningSimulationConfigBuilder();
  set simulationConfig(
          ActiveLearningSimulationConfigBuilder? simulationConfig) =>
      _$this._simulationConfig = simulationConfig;

  ActiveLearningSimulationRequestBuilder() {
    ActiveLearningSimulationRequest._defaults(this);
  }

  ActiveLearningSimulationRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _campaignConfig = $v.campaignConfig.toBuilder();
      _simulationConfig = $v.simulationConfig.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ActiveLearningSimulationRequest other) {
    _$v = other as _$ActiveLearningSimulationRequest;
  }

  @override
  void update(void Function(ActiveLearningSimulationRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ActiveLearningSimulationRequest build() => _build();

  _$ActiveLearningSimulationRequest _build() {
    _$ActiveLearningSimulationRequest _$result;
    try {
      _$result = _$v ??
          _$ActiveLearningSimulationRequest._(
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
            r'ActiveLearningSimulationRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
