// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_learning_engineering_simulation_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ActiveLearningEngineeringSimulationRequest
    extends ActiveLearningEngineeringSimulationRequest {
  @override
  final ActiveLearningEngineeringCampaignConfig campaignConfig;
  @override
  final ActiveLearningEngineeringSimulationConfig simulationConfig;

  factory _$ActiveLearningEngineeringSimulationRequest(
          [void Function(ActiveLearningEngineeringSimulationRequestBuilder)?
              updates]) =>
      (ActiveLearningEngineeringSimulationRequestBuilder()..update(updates))
          ._build();

  _$ActiveLearningEngineeringSimulationRequest._(
      {required this.campaignConfig, required this.simulationConfig})
      : super._();
  @override
  ActiveLearningEngineeringSimulationRequest rebuild(
          void Function(ActiveLearningEngineeringSimulationRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ActiveLearningEngineeringSimulationRequestBuilder toBuilder() =>
      ActiveLearningEngineeringSimulationRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ActiveLearningEngineeringSimulationRequest &&
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
            r'ActiveLearningEngineeringSimulationRequest')
          ..add('campaignConfig', campaignConfig)
          ..add('simulationConfig', simulationConfig))
        .toString();
  }
}

class ActiveLearningEngineeringSimulationRequestBuilder
    implements
        Builder<ActiveLearningEngineeringSimulationRequest,
            ActiveLearningEngineeringSimulationRequestBuilder> {
  _$ActiveLearningEngineeringSimulationRequest? _$v;

  ActiveLearningEngineeringCampaignConfigBuilder? _campaignConfig;
  ActiveLearningEngineeringCampaignConfigBuilder get campaignConfig =>
      _$this._campaignConfig ??=
          ActiveLearningEngineeringCampaignConfigBuilder();
  set campaignConfig(
          ActiveLearningEngineeringCampaignConfigBuilder? campaignConfig) =>
      _$this._campaignConfig = campaignConfig;

  ActiveLearningEngineeringSimulationConfigBuilder? _simulationConfig;
  ActiveLearningEngineeringSimulationConfigBuilder get simulationConfig =>
      _$this._simulationConfig ??=
          ActiveLearningEngineeringSimulationConfigBuilder();
  set simulationConfig(
          ActiveLearningEngineeringSimulationConfigBuilder? simulationConfig) =>
      _$this._simulationConfig = simulationConfig;

  ActiveLearningEngineeringSimulationRequestBuilder() {
    ActiveLearningEngineeringSimulationRequest._defaults(this);
  }

  ActiveLearningEngineeringSimulationRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _campaignConfig = $v.campaignConfig.toBuilder();
      _simulationConfig = $v.simulationConfig.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ActiveLearningEngineeringSimulationRequest other) {
    _$v = other as _$ActiveLearningEngineeringSimulationRequest;
  }

  @override
  void update(
      void Function(ActiveLearningEngineeringSimulationRequestBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  ActiveLearningEngineeringSimulationRequest build() => _build();

  _$ActiveLearningEngineeringSimulationRequest _build() {
    _$ActiveLearningEngineeringSimulationRequest _$result;
    try {
      _$result = _$v ??
          _$ActiveLearningEngineeringSimulationRequest._(
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
            r'ActiveLearningEngineeringSimulationRequest',
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
