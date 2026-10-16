/// [day] (default: today) as a zero-padded DDMM integer, used as the default random seed:
/// 15 Oct -> 1510, 5 Mar -> 503.
int dateSeed([DateTime? day]) {
  final DateTime date = day ?? DateTime.now();
  return int.parse('${date.day.toString().padLeft(2, '0')}${date.month.toString().padLeft(2, '0')}');
}
