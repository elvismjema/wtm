String formatShortDateTime(DateTime dt) {
  final minute = dt.minute.toString().padLeft(2, '0');
  final hourRaw = dt.hour;
  final hour = hourRaw % 12 == 0 ? 12 : hourRaw % 12;
  final suffix = hourRaw >= 12 ? 'PM' : 'AM';
  return '${dt.month}/${dt.day} · $hour:$minute $suffix';
}

String formatLongDateTime(DateTime dt) {
  final minute = dt.minute.toString().padLeft(2, '0');
  final hourRaw = dt.hour;
  final hour = hourRaw % 12 == 0 ? 12 : hourRaw % 12;
  final suffix = hourRaw >= 12 ? 'PM' : 'AM';
  return '${dt.month}/${dt.day}/${dt.year} at $hour:$minute $suffix';
}
