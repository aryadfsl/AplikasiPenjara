class UserProfileScreenController {
  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String calculateRemainingTime(DateTime endDate) {
    final now = DateTime.now();
    final difference = endDate.difference(now);
    
    if (difference.inDays < 0) {
      return 'Sudah selesai';
    }
    
    final years = difference.inDays ~/ 365;
    final months = (difference.inDays % 365) ~/ 30;
    final days = (difference.inDays % 365) % 30;
    
    List<String> parts = [];
    if (years > 0) parts.add('$years tahun');
    if (months > 0) parts.add('$months bulan');
    if (days > 0) parts.add('$days hari');
    
    return parts.isEmpty ? 'Kurang dari 1 hari' : parts.join(' ');
  }

  String calculateProgress(DateTime startDate, DateTime endDate) {
    final total = endDate.difference(startDate).inDays;
    final elapsed = DateTime.now().difference(startDate).inDays;
    
    if (total <= 0) return '0%';
    if (elapsed <= 0) return '0%';
    if (elapsed >= total) return '100%';
    
    final progress = (elapsed / total * 100).toStringAsFixed(1);
    return '$progress%';
  }
}
