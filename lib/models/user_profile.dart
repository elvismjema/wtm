class UserProfile {
  const UserProfile({
    required this.name,
    required this.username,
    required this.school,
    required this.createdCount,
    required this.attendedCount,
    required this.savedCount,
  });

  final String name;
  final String username;
  final String school;
  final int createdCount;
  final int attendedCount;
  final int savedCount;
}
