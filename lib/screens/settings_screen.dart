import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../user_model.dart';
import 'db_helper.dart';
import 'login_screen.dart';
import 'Health_tracker.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _usernameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _savingUsername = false;
  bool _changingPassword = false;
  bool _generatingReport = false;
  String? _reportText;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserModel>(context, listen: false);
    _usernameController.text = user.username ?? '';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _saveUsername() async {
    final user = Provider.of<UserModel>(context, listen: false);
    final newName = _usernameController.text.trim();
    if (newName.isEmpty) {
      _snack("Username can't be empty");
      return;
    }
    if (user.id == null) {
      _snack("Please log out and back in to edit your profile");
      return;
    }
    setState(() => _savingUsername = true);
    try {
      await DBHelper.updateParent(user.id!, newName, user.email ?? '');
      user.updateUsername(newName);
      _snack('✅ Name updated');
    } catch (e) {
      _snack('Failed to update name');
    } finally {
      if (mounted) setState(() => _savingUsername = false);
    }
  }

  Future<void> _changePassword() async {
    final user = Provider.of<UserModel>(context, listen: false);
    final current = _currentPasswordController.text.trim();
    final next = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (user.id == null) {
      _snack("Please log out and back in, then try again");
      return;
    }
    if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
      _snack("Fill in all three password fields");
      return;
    }
    if (next.length < 6 ||
        !next.contains(RegExp(r'[A-Z]')) ||
        !next.contains(RegExp(r'[a-z]')) ||
        !next.contains(RegExp(r'[0-9]'))) {
      _snack("New password needs 6+ chars, upper, lower & a number");
      return;
    }
    if (next != confirm) {
      _snack("New passwords don't match");
      return;
    }

    setState(() => _changingPassword = true);
    try {
      final ok = await DBHelper.changePassword(user.id!, current, next);
      if (ok) {
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        _snack('🔒 Password changed');
      } else {
        _snack('Current password is incorrect');
      }
    } catch (e) {
      _snack('Something went wrong changing your password');
    } finally {
      if (mounted) setState(() => _changingPassword = false);
    }
  }

  Future<void> _generateBabyReport() async {
    final user = Provider.of<UserModel>(context, listen: false);
    if (user.id == null) {
      _snack("Please log out and back in to generate a report");
      return;
    }
    setState(() {
      _generatingReport = true;
      _reportText = null;
    });

    try {
      final babies = await DBHelper.getBabyProfilesForParent(user.id!);
      final buffer = StringBuffer();
      buffer.writeln('👶 Baby Report for ${user.username ?? 'you'}');
      buffer.writeln(
        'Member since: ${user.createdAt != null ? DateFormat('MMM d, yyyy').format(user.createdAt!) : 'earlier account, date not recorded'}',
      );
      buffer.writeln('Generated: ${DateFormat('MMM d, yyyy · h:mm a').format(DateTime.now())}');
      buffer.writeln('');

      if (babies.isEmpty) {
        buffer.writeln(
          "No babies linked to your account yet. Add one from Baby Profile to start building this report.",
        );
      } else {
        for (final baby in babies) {
          final name = baby['name'] ?? 'Unnamed';
          final babyId = baby['id'] as String;

          final historySnap = await FirebaseFirestore.instance
              .collection('growth_status')
              .doc(babyId)
              .collection('history')
              .orderBy('timestamp')
              .get();

          final reviewsSnap = await FirebaseFirestore.instance
              .collection('weekly_reviews')
              .where('babyName', isEqualTo: name)
              .get();

          buffer.writeln('— $name —');
          buffer.writeln('Age on file: ${baby['age'] ?? '?'} months');
          buffer.writeln('Current weight: ${baby['weight'] ?? '?'} kg, height: ${baby['height'] ?? '?'} cm');
          buffer.writeln('Growth measurements logged: ${historySnap.docs.length}');

          double? latestBmi;
          if (historySnap.docs.isNotEmpty) {
            final first = historySnap.docs.first.data();
            final last = historySnap.docs.last.data();
            buffer.writeln(
              '  First logged: ${first['weight'] ?? '?'} kg / ${first['height'] ?? '?'} cm',
            );
            buffer.writeln(
              '  Most recent: ${last['weight'] ?? '?'} kg / ${last['height'] ?? '?'} cm',
            );
            latestBmi = double.tryParse(last['bmi']?.toString() ?? '');
          }

          // Fall back to computing BMI straight from the profile if there's
          // no logged history yet.
          latestBmi ??= _bmiOf(
            (baby['weight'] as num?)?.toDouble() ?? 0,
            (baby['height'] as num?)?.toDouble() ?? 0,
          );

          if (latestBmi > 0) {
            buffer.writeln('Current BMI: ${latestBmi.toStringAsFixed(1)} (${_bmiLabel(latestBmi)})');
          } else {
            buffer.writeln('Current BMI: not enough data yet');
          }

          buffer.writeln('Weekly meal reviews submitted: ${reviewsSnap.docs.length}');
          buffer.writeln('');
        }
      }

      setState(() => _reportText = buffer.toString());
    } catch (e) {
      _snack('Failed to generate report');
    } finally {
      if (mounted) setState(() => _generatingReport = false);
    }
  }

  double _bmiOf(double weight, double height) {
    if (height <= 0) return 0;
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  // Mirrors the thresholds used on the Growth Status screen, so a baby's
  // BMI reads the same way everywhere in the app.
  String _bmiLabel(double bmi) {
    if (bmi <= 0) return "No data yet";
    if (bmi < 14) return "Underweight";
    if (bmi <= 17) return "On Track";
    return "Gaining Quickly";
  }

  void _copyReport() {
    if (_reportText == null) return;
    Clipboard.setData(ClipboardData(text: _reportText!));
    _snack('📋 Report copied to clipboard');
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Provider.of<UserModel>(context, listen: false).logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserModel>();
    final memberSince = user.createdAt != null
        ? DateFormat('MMM d, yyyy').format(user.createdAt!)
        : 'Not recorded for this account';
    final initial = (user.username ?? '?').isNotEmpty ? user.username![0].toUpperCase() : '?';

    return Scaffold(
      appBar: AppBar(title: const Text('⚙️ Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile header
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.purple, AppColors.pink],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Text(initial,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.purple)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.username ?? 'Unknown',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(user.email ?? '', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text('Member since $memberSince',
                          style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Edit profile
          const FunSectionTitle(emoji: "👤", title: "Your Profile", color: AppColors.pink),
          _SettingsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Display name', prefixIcon: Icon(Icons.badge_outlined)),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _savingUsername ? null : _saveUsername,
                  icon: _savingUsername
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save_outlined),
                  label: const Text('Save name'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.pink),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Change password
          const FunSectionTitle(emoji: "🔒", title: "Change Password", color: AppColors.blue),
          _SettingsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _currentPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Current password', prefixIcon: Icon(Icons.lock_outline)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'New password', prefixIcon: Icon(Icons.lock_reset)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration:
                      const InputDecoration(labelText: 'Confirm new password', prefixIcon: Icon(Icons.check_circle_outline)),
                ),
                const SizedBox(height: 4),
                Text('Needs 6+ characters with an uppercase, lowercase and number.',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _changingPassword ? null : _changePassword,
                  icon: _changingPassword
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.lock_outline),
                  label: const Text('Update password'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Baby report
          const FunSectionTitle(emoji: "📊", title: "Baby History Report", color: AppColors.teal),
          _SettingsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Generate a summary of your baby's growth logs and meal reviews since you started using the app.",
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _generatingReport ? null : _generateBabyReport,
                  icon: _generatingReport
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.summarize_outlined),
                  label: const Text('Generate report'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal),
                ),
                if (_reportText != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.bg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(_reportText!, style: const TextStyle(fontSize: 12, height: 1.5)),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _copyReport,
                    icon: const Icon(Icons.copy_outlined, size: 18),
                    label: const Text('Copy report'),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Quick links
          const FunSectionTitle(emoji: "🔗", title: "Quick Links", color: AppColors.orange),
          _SettingsCard(
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.notifications_active_outlined, color: AppColors.orange),
                  title: const Text('Manage reminders'),
                  subtitle: const Text('Medication, diaper & feeding alerts'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HealthTrackerScreen()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Logout
          OutlinedButton.icon(
            onPressed: _confirmLogout,
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            label: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.redAccent),
              minimumSize: const Size(double.infinity, 46),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text('Nourish Baby App · v1.0.0', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

/// Plain white rounded card used to group settings controls, matching the
/// look of cards elsewhere in the app (baby profile, health tracker, etc).
class _SettingsCard extends StatelessWidget {
  final Widget child;
  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }
}
