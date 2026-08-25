// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_learning_screening_iteration_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ActiveLearningScreeningIterationRequest
    extends ActiveLearningScreeningIterationRequest {
  @override
  final ActiveLearningScreeningCampaignConfig campaignConfig;
  @override
  final ActiveLearningScreeningIterationConfig iterationConfig;

  factory _$ActiveLearningScreeningIterationRequest(
          [void Function(ActiveLearningScreeningIterationRequestBuilder)?
              updates]) =>
      (ActiveLearningScreeningIterationRequestBuilder()..update(updates))
          ._build();

  _$ActiveLearningScreeningIterationRequest._(
      {required this.campaignConfig, required this.iterationConfig})
      : super._();
  @override
  ActiveLearningScreeningIterationRequest rebuild(
          void Function(ActiveLearningScreeningIterationRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ActiveLearningScreeningIterationRequestBuilder toBuilder() =>
      ActiveLearningScreeningIterationRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ActiveLearningScreeningIterationRequest &&
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
            r'ActiveLearningScreeningIterationRequest')
          ..add('campaignConfig', campaignConfig)
          ..add('iterationConfig', iterationConfig))
        .toString();
  }
}

class ActiveLearningScreeningIterationRequestBuilder
    implements
        Builder<ActiveLearningScreeningIterationRequest,
            ActiveLearningScreeningIterationRequestBuilder> {
  _$ActiveLearningScreeningIterationRequest? _$v;

  ActiveLearningScreeningCampaignConfigBuilder? _campaignConfig;
  ActiveLearningScreeningCampaignConfigBuilder get campaignConfig =>
      _$this._campaignConfig ??= ActiveLearningScreeningCampaignConfigBuilder();
  set campaignConfig(
          ActiveLearningScreeningCampaignConfigBuilder? campaignConfig) =>
      _$this._campaignConfig = campaignConfig;

  ActiveLearningScreeningIterationConfigBuilder? _iterationConfig;
  ActiveLearningScreeningIterationConfigBuilder get iterationConfig =>
      _$this._iterationConfig ??=
          ActiveLearningScreeningIterationConfigBuilder();
  set iterationConfig(
          ActiveLearningScreeningIterationConfigBuilder? iterationConfig) =>
      _$this._iterationConfig = iterationConfig;

  ActiveLearningScreeningIterationRequestBuilder() {
    ActiveLearningScreeningIterationRequest._defaults(this);
  }

  ActiveLearningScreeningIterationRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _campaignConfig = $v.campaignConfig.toBuilder();
      _iterationConfig = $v.iterationConfig.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ActiveLearningScreeningIterationRequest other) {
    _$v = other as _$ActiveLearningScreeningIterationRequest;
  }

  @override
  void update(
      void Function(ActiveLearningScreeningIterationRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ActiveLearningScreeningIterationRequest build() => _build();

  _$ActiveLearningScreeningIterationRequest _build() {
    _$ActiveLearningScreeningIterationRequest _$result;
    try {
      _$result = _$v ??
          _$ActiveLearningScreeningIterationRequest._(
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
            r'ActiveLearningScreeningIterationRequest',
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
