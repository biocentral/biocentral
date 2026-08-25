// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_learning_engineering_iteration_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ActiveLearningEngineeringIterationRequest
    extends ActiveLearningEngineeringIterationRequest {
  @override
  final ActiveLearningEngineeringCampaignConfig campaignConfig;
  @override
  final ActiveLearningEngineeringIterationConfig iterationConfig;

  factory _$ActiveLearningEngineeringIterationRequest(
          [void Function(ActiveLearningEngineeringIterationRequestBuilder)?
              updates]) =>
      (ActiveLearningEngineeringIterationRequestBuilder()..update(updates))
          ._build();

  _$ActiveLearningEngineeringIterationRequest._(
      {required this.campaignConfig, required this.iterationConfig})
      : super._();
  @override
  ActiveLearningEngineeringIterationRequest rebuild(
          void Function(ActiveLearningEngineeringIterationRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ActiveLearningEngineeringIterationRequestBuilder toBuilder() =>
      ActiveLearningEngineeringIterationRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ActiveLearningEngineeringIterationRequest &&
        campaignConfig == other.campaignConfig &&
        iterationConfig == other.iterationConfig;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, campaignConfig.hashCode);
    _$hash = $jc(_$hash, iterationConfig.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'ActiveLearningEngineeringIterationRequest')
          ..add('campaignConfig', campaignConfig)
          ..add('iterationConfig', iterationConfig))
        .toString();
  }
}

class ActiveLearningEngineeringIterationRequestBuilder
    implements
        Builder<ActiveLearningEngineeringIterationRequest,
            ActiveLearningEngineeringIterationRequestBuilder> {
  _$ActiveLearningEngineeringIterationRequest? _$v;

  ActiveLearningEngineeringCampaignConfigBuilder? _campaignConfig;
  ActiveLearningEngineeringCampaignConfigBuilder get campaignConfig =>
      _$this._campaignConfig ??=
          ActiveLearningEngineeringCampaignConfigBuilder();
  set campaignConfig(
          ActiveLearningEngineeringCampaignConfigBuilder? campaignConfig) =>
      _$this._campaignConfig = campaignConfig;

  ActiveLearningEngineeringIterationConfigBuilder? _iterationConfig;
  ActiveLearningEngineeringIterationConfigBuilder get iterationConfig =>
      _$this._iterationConfig ??=
          ActiveLearningEngineeringIterationConfigBuilder();
  set iterationConfig(
          ActiveLearningEngineeringIterationConfigBuilder? iterationConfig) =>
      _$this._iterationConfig = iterationConfig;

  ActiveLearningEngineeringIterationRequestBuilder() {
    ActiveLearningEngineeringIterationRequest._defaults(this);
  }

  ActiveLearningEngineeringIterationRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _campaignConfig = $v.campaignConfig.toBuilder();
      _iterationConfig = $v.iterationConfig.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ActiveLearningEngineeringIterationRequest other) {
    _$v = other as _$ActiveLearningEngineeringIterationRequest;
  }

  @override
  void update(
      void Function(ActiveLearningEngineeringIterationRequestBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  ActiveLearningEngineeringIterationRequest build() => _build();

  _$ActiveLearningEngineeringIterationRequest _build() {
    _$ActiveLearningEngineeringIterationRequest _$result;
    try {
      _$result = _$v ??
          _$ActiveLearningEngineeringIterationRequest._(
            campaignConfig: campaignConfig.build(),
            iterationConfig: iterationConfig.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'campaignConfig';
        campaignConfig.build();
        _$failedField = 'iterationConfig';
        iterationConfig.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ActiveLearningEngineeringIterationRequest',
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
