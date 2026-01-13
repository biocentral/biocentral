// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_learning_iteration_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ActiveLearningIterationRequest extends ActiveLearningIterationRequest {
  @override
  final ActiveLearningCampaignConfig campaignConfig;
  @override
  final ActiveLearningIterationConfig iterationConfig;

  factory _$ActiveLearningIterationRequest(
          [void Function(ActiveLearningIterationRequestBuilder)? updates]) =>
      (ActiveLearningIterationRequestBuilder()..update(updates))._build();

  _$ActiveLearningIterationRequest._(
      {required this.campaignConfig, required this.iterationConfig})
      : super._();
  @override
  ActiveLearningIterationRequest rebuild(
          void Function(ActiveLearningIterationRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ActiveLearningIterationRequestBuilder toBuilder() =>
      ActiveLearningIterationRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ActiveLearningIterationRequest &&
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
    return (newBuiltValueToStringHelper(r'ActiveLearningIterationRequest')
          ..add('campaignConfig', campaignConfig)
          ..add('iterationConfig', iterationConfig))
        .toString();
  }
}

class ActiveLearningIterationRequestBuilder
    implements
        Builder<ActiveLearningIterationRequest,
            ActiveLearningIterationRequestBuilder> {
  _$ActiveLearningIterationRequest? _$v;

  ActiveLearningCampaignConfigBuilder? _campaignConfig;
  ActiveLearningCampaignConfigBuilder get campaignConfig =>
      _$this._campaignConfig ??= ActiveLearningCampaignConfigBuilder();
  set campaignConfig(ActiveLearningCampaignConfigBuilder? campaignConfig) =>
      _$this._campaignConfig = campaignConfig;

  ActiveLearningIterationConfigBuilder? _iterationConfig;
  ActiveLearningIterationConfigBuilder get iterationConfig =>
      _$this._iterationConfig ??= ActiveLearningIterationConfigBuilder();
  set iterationConfig(ActiveLearningIterationConfigBuilder? iterationConfig) =>
      _$this._iterationConfig = iterationConfig;

  ActiveLearningIterationRequestBuilder() {
    ActiveLearningIterationRequest._defaults(this);
  }

  ActiveLearningIterationRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _campaignConfig = $v.campaignConfig.toBuilder();
      _iterationConfig = $v.iterationConfig.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ActiveLearningIterationRequest other) {
    _$v = other as _$ActiveLearningIterationRequest;
  }

  @override
  void update(void Function(ActiveLearningIterationRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ActiveLearningIterationRequest build() => _build();

  _$ActiveLearningIterationRequest _build() {
    _$ActiveLearningIterationRequest _$result;
    try {
      _$result = _$v ??
          _$ActiveLearningIterationRequest._(
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
            r'ActiveLearningIterationRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
