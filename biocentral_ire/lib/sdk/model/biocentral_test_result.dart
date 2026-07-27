class BiocentralTestResult {
  final Map<String, dynamic>? testMetrics;
  final BiocentralTestStatistic? testStatistic;
  final bool? success;
  final String information;

  BiocentralTestResult(this.information, {this.testMetrics, this.testStatistic, this.success});
}

class BiocentralTestStatistic {
  final double pValue;
  final double statistic;
  final double significance;

  BiocentralTestStatistic(this.statistic, this.pValue, this.significance);

  @override
  String toString() {
    return 'TestStatistic{pValue: $pValue, statistic: $statistic, significance: $significance}';
  }
}
