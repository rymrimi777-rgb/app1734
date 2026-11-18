import 'package:flutter/material.dart';
import '../repository.dart';
import '../theme.dart';
import '../widgets/cloud_sync.dart';
import '../widgets/audio_player_helper.dart';
import '../widgets/companion_system.dart';
import '../widgets/rabbit_system.dart';
import '../widgets/journal_security.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final repository = DataRepository();

    return AnimatedBuilder(
      animation: repository,
      builder: (context, child) {
        final currentThemeMode = repository.currentThemeMode;
        final isBiometric = repository.isBiometricLockEnabled;
        final paperStyle = repository.paperStyle;
        final theme = Theme.of(context);

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Settings & Preferences',
              style: TextStyle(
                fontFamily: 'Essays1743',
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            elevation: 0.5,
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // --- 1. PERSONAL SECTION ---
              _buildSectionHeader('Personal', Icons.person_outline, theme),
              const SizedBox(height: 8),
              Card(
                color: theme.cardColor,
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Icon(Icons.badge_outlined, color: theme.primaryColor),
                  title: const Text('User Name', style: TextStyle(fontFamily: 'Essays1743', fontWeight: FontWeight.bold)),
                  subtitle: Text(repository.userName, style: const TextStyle(fontFamily: 'Essays1743', fontSize: 13)),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: () => _showEditUserNameDialog(context, repository),
                ),
              ),

              const SizedBox(height: 24),

              // --- 2. VIRTUAL COMPANION SECTION (PHASE 4) ---
              _buildSectionHeader('Virtual Companion', Icons.pets_outlined, theme),
              const SizedBox(height: 8),
              AnimatedBuilder(
                animation: CompanionManager.instance,
                builder: (context, _) {
                  final selected = CompanionManager.instance.selected;
                  return Card(
                    color: theme.cardColor,
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select your virtual companion for a peaceful writing space:',
                            style: TextStyle(
                              fontFamily: 'Essays1743',
                              fontSize: 12,
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              // Rabbit Companion Option
                              Expanded(
                                child: _buildCompanionOption(
                                  context: context,
                                  title: 'Rabbit',
                                  subtitle: 'Calm & resting',
                                  isSelected: selected == CompanionType.rabbit,
                                  theme: theme,
                                  preview: const IsolatedRabbitSprite(
                                    animation: RabbitAnimation.rest04,
                                    scale: 2.2,
                                  ),
                                  onTap: () => CompanionManager.instance.setCompanion(CompanionType.rabbit),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Deer Companion Option
                              Expanded(
                                child: _buildCompanionOption(
                                  context: context,
                                  title: 'Pixel Deer',
                                  subtitle: 'Woodland gentle',
                                  isSelected: selected == CompanionType.deer,
                                  theme: theme,
                                  preview: const DeerSprite(
                                    animState: CompanionAnimState.idle,
                                    scale: 2.4,
                                  ),
                                  onTap: () => CompanionManager.instance.setCompanion(CompanionType.deer),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // --- 3. NOTIFICATIONS SECTION ---
              _buildSectionHeader('Notifications', Icons.notifications_outlined, theme),
              const SizedBox(height: 8),
              Card(
                color: theme.cardColor,
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Morning Rabbit', style: TextStyle(fontFamily: 'Essays1743', fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text('Animated morning greeting banner', style: TextStyle(fontFamily: 'Essays1743', fontSize: 12, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6))),
                      value: repository.notifyMorningRabbit,
                      activeColor: theme.primaryColor,
                      onChanged: (val) => repository.setNotificationToggle('morning_rabbit', val),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Evening Rabbit', style: TextStyle(fontFamily: 'Essays1743', fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text('Animated evening peaceful banner', style: TextStyle(fontFamily: 'Essays1743', fontSize: 12, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6))),
                      value: repository.notifyEveningRabbit,
                      activeColor: theme.primaryColor,
                      onChanged: (val) => repository.setNotificationToggle('evening_rabbit', val),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Pomodoro Rabbit', style: TextStyle(fontFamily: 'Essays1743', fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text('Focus session completion banner', style: TextStyle(fontFamily: 'Essays1743', fontSize: 12, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6))),
                      value: repository.notifyPomodoroRabbit,
                      activeColor: theme.primaryColor,
                      onChanged: (val) => repository.setNotificationToggle('pomodoro_rabbit', val),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('New Note', style: TextStyle(fontFamily: 'Essays1743', fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text('Simple text alerts on note creation', style: TextStyle(fontFamily: 'Essays1743', fontSize: 12, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6))),
                      value: repository.notifyNewNote,
                      activeColor: theme.primaryColor,
                      onChanged: (val) => repository.setNotificationToggle('new_note', val),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Reminder', style: TextStyle(fontFamily: 'Essays1743', fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text('Agenda & task reminder text alerts', style: TextStyle(fontFamily: 'Essays1743', fontSize: 12, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6))),
                      value: repository.notifyReminder,
                      activeColor: theme.primaryColor,
                      onChanged: (val) => repository.setNotificationToggle('reminder', val),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- 4. SOUNDS SECTION (PHASE 2) ---
              _buildSectionHeader('Sounds & Alarms', Icons.volume_up_outlined, theme),
              const SizedBox(height: 8),
              Card(
                color: theme.cardColor,
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                        child: Text(
                          'Pomodoro & Alarm Sounds',
                          style: TextStyle(fontFamily: 'Essays1743', fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Select and preview sounds played on session completion:',
                          style: TextStyle(fontFamily: 'Essays1743', fontSize: 11, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._buildPomodoroSoundOptions(context, repository, theme),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // --- 5. APPEARANCE SECTION (PHASE 3) ---
              _buildSectionHeader('Appearance', Icons.palette_outlined, theme),
              const SizedBox(height: 12),
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildThemeCard(
                          context: context,
                          title: 'Light Mode',
                          subtitle: 'Clean cream paper',
                          mode: AppThemeMode.light,
                          currentMode: currentThemeMode,
                          bgColor: const Color(0xFFFAF9F6),
                          accentColor: const Color(0xFF2D2319),
                          onTap: () => repository.setThemeMode(AppThemeMode.light),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildThemeCard(
                          context: context,
                          title: 'Warm Coffee',
                          subtitle: 'Espresso & beige',
                          mode: AppThemeMode.warmCoffee,
                          currentMode: currentThemeMode,
                          bgColor: const Color(0xFF1E1815),
                          accentColor: const Color(0xFFE8DCC4),
                          onTap: () => repository.setThemeMode(AppThemeMode.warmCoffee),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildThemeCard(
                          context: context,
                          title: 'Pitch Black',
                          subtitle: 'OLED contrast',
                          mode: AppThemeMode.pitchBlack,
                          currentMode: currentThemeMode,
                          bgColor: const Color(0xFF121212),
                          accentColor: Colors.white,
                          onTap: () => repository.setThemeMode(AppThemeMode.pitchBlack),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildThemeCard(
                          context: context,
                          title: 'Vintage Sepia',
                          subtitle: 'Warm parchment',
                          mode: AppThemeMode.vintageSepia,
                          currentMode: currentThemeMode,
                          bgColor: const Color(0xFFF4ECD8),
                          accentColor: const Color(0xFF433422),
                          onTap: () => repository.setThemeMode(AppThemeMode.vintageSepia),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionHeader('Paper Style & Grid', Icons.grid_on_outlined, theme),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: ['Plain', 'Lined', 'Dotted', 'Grid'].map((style) {
                  final isSelected = paperStyle == style;
                  return ChoiceChip(
                    label: Text(
                      style,
                      style: TextStyle(
                        fontFamily: 'Essays1743',
                        color: isSelected
                            ? (theme.brightness == Brightness.dark ? Colors.black : Colors.white)
                            : theme.textTheme.bodyLarge?.color,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: theme.primaryColor,
                    backgroundColor: theme.cardColor,
                    onSelected: (val) {
                      if (val) repository.setPaperStyle(style);
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // --- 6. VOICE SECTION ---
              _buildSectionHeader('Voice', Icons.mic_none_outlined, theme),
              const SizedBox(height: 8),
              Card(
                color: theme.cardColor,
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.mic_outlined),
                  title: const Text('Voice Recording Settings', style: TextStyle(fontFamily: 'Essays1743', fontWeight: FontWeight.bold)),
                  subtitle: Text('Mic permissions & voice memo attachment defaults', style: TextStyle(fontFamily: 'Essays1743', fontSize: 12, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6))),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Microphone permissions active & voice memo storage ready.')),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // --- 7. PRIVACY & SECURITY SECTION (PHASE 5) ---
              _buildSectionHeader('Privacy & Security', Icons.security_outlined, theme),
              const SizedBox(height: 8),
              Card(
                color: theme.cardColor,
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: JournalSecurityService.instance,
                      builder: (context, _) {
                        final isLocked = JournalSecurityService.instance.isLockEnabled;
                        final isUnlocked = JournalSecurityService.instance.isUnlocked;

                        return ListTile(
                          leading: Icon(
                            isLocked
                                ? (isUnlocked ? Icons.lock_open_outlined : Icons.lock_outlined)
                                : Icons.lock_outline,
                            color: isLocked
                                ? (isUnlocked ? Colors.green : Colors.amber.shade700)
                                : theme.primaryColor,
                          ),
                          title: const Text(
                            'Journal Password Lock',
                            style: TextStyle(fontFamily: 'Essays1743', fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            !isLocked
                                ? 'Disabled • Encrypt & password-protect private writings'
                                : (isUnlocked
                                    ? 'Active • Unlocked for this session (Tap to manage/lock)'
                                    : 'Active • Locked (Tap to unlock)'),
                            style: TextStyle(
                              fontFamily: 'Essays1743',
                              fontSize: 12,
                              color: isLocked
                                  ? (isUnlocked ? Colors.green : Colors.amber.shade800)
                                  : theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isLocked)
                                IconButton(
                                  icon: Icon(
                                    isUnlocked ? Icons.lock_outline : Icons.lock_open_outlined,
                                    size: 20,
                                    color: theme.primaryColor,
                                  ),
                                  tooltip: isUnlocked ? 'Lock Now' : 'Unlock Now',
                                  onPressed: () {
                                    if (isUnlocked) {
                                      JournalSecurityService.instance.lock();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Journal locked.')),
                                      );
                                    } else {
                                      showDialog(
                                        context: context,
                                        builder: (_) => const JournalUnlockDialog(),
                                      );
                                    }
                                  },
                                ),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                          onTap: () {
                            if (!isLocked) {
                              showDialog(
                                context: context,
                                builder: (_) => const JournalPasswordSetupDialog(),
                              );
                            } else {
                              _showJournalLockSettingsModal(context, theme);
                            }
                          },
                        );
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('App Lock & Biometrics', style: TextStyle(fontFamily: 'Essays1743', fontWeight: FontWeight.bold)),
                      subtitle: Text('Require Face ID / Fingerprint / Passcode on app launch', style: TextStyle(fontFamily: 'Essays1743', fontSize: 12, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6))),
                      value: isBiometric,
                      activeColor: theme.primaryColor,
                      onChanged: (val) => repository.setBiometricLock(val),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.cloud_sync_outlined),
                      title: const Text('Cloud Backup & Restore', style: TextStyle(fontFamily: 'Essays1743', fontWeight: FontWeight.bold)),
                      subtitle: Text('Sync notes with cloud JSON storage', style: TextStyle(fontFamily: 'Essays1743', fontSize: 12, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6))),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const CloudSyncSheet(),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              Center(
                child: Text(
                  '1734 Notebook App v2.0 • Vintage Essays Edition',
                  style: TextStyle(
                    fontFamily: 'Essays1743',
                    fontSize: 12,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Essays1743',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildCompanionOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool isSelected,
    required ThemeData theme,
    required Widget preview,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor.withOpacity(0.08) : theme.cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? theme.primaryColor : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 48,
              child: Center(child: preview),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Essays1743',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'Essays1743',
                fontSize: 11,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isSelected ? theme.primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? theme.primaryColor : theme.dividerColor,
                ),
              ),
              child: Text(
                isSelected ? 'SELECTED' : 'SELECT',
                style: TextStyle(
                  fontFamily: 'Essays1743',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? (theme.brightness == Brightness.dark ? Colors.black : Colors.white)
                      : theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required AppThemeMode mode,
    required AppThemeMode currentMode,
    required Color bgColor,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    final isSelected = mode == currentMode;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? accentColor : Colors.black12,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: accentColor,
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          size: 14,
                          color: bgColor == Colors.white || bgColor == const Color(0xFFFAF9F6) || bgColor == const Color(0xFFF4ECD8)
                              ? Colors.white
                              : Colors.black,
                        )
                      : null,
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'ACTIVE',
                      style: TextStyle(
                        fontFamily: 'Essays1743',
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: bgColor == Colors.white || bgColor == const Color(0xFFFAF9F6) || bgColor == const Color(0xFFF4ECD8)
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Essays1743',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'Essays1743',
                fontSize: 11,
                color: accentColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditUserNameDialog(BuildContext context, DataRepository repository) {
    final nameCtrl = TextEditingController(text: repository.userName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          'Edit User Name',
          style: TextStyle(
            fontFamily: 'Essays1743',
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        content: TextField(
          controller: nameCtrl,
          decoration: InputDecoration(
            hintText: 'Enter your preferred name',
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),
          ),
          style: TextStyle(
            fontFamily: 'Essays1743',
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(fontFamily: 'Essays1743', color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
            onPressed: () {
              repository.setUserName(nameCtrl.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'User Name updated to "${repository.userName}"',
                    style: const TextStyle(fontFamily: 'Essays1743'),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Text(
              'Save',
              style: TextStyle(
                fontFamily: 'Essays1743',
                color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showJournalLockSettingsModal(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        final isUnlocked = JournalSecurityService.instance.isUnlocked;

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lock_outline, color: theme.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Journal Lock Settings',
                    style: TextStyle(
                      fontFamily: 'Essays1743',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(isUnlocked ? Icons.lock_outline : Icons.lock_open_outlined, color: theme.iconTheme.color),
                title: Text(isUnlocked ? 'Lock Journal Now' : 'Unlock Journal', style: const TextStyle(fontFamily: 'Essays1743', fontWeight: FontWeight.bold)),
                subtitle: Text(isUnlocked ? 'Immediately hide and lock protected notes' : 'Enter password to unlock private notes', style: const TextStyle(fontFamily: 'Essays1743', fontSize: 12)),
                onTap: () {
                  Navigator.pop(context);
                  if (isUnlocked) {
                    JournalSecurityService.instance.lock();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Journal locked.')));
                  } else {
                    showDialog(context: context, builder: (_) => const JournalUnlockDialog());
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.password_outlined, color: theme.iconTheme.color),
                title: const Text('Change Password', style: TextStyle(fontFamily: 'Essays1743', fontWeight: FontWeight.bold)),
                subtitle: const Text('Update your encryption passphrase', style: TextStyle(fontFamily: 'Essays1743', fontSize: 12)),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(context: context, builder: (_) => const JournalPasswordSetupDialog());
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock_reset, color: Colors.redAccent),
                title: const Text('Disable Journal Protection', style: TextStyle(fontFamily: 'Essays1743', fontWeight: FontWeight.bold, color: Colors.redAccent)),
                subtitle: const Text('Remove password requirement', style: TextStyle(fontFamily: 'Essays1743', fontSize: 12)),
                onTap: () {
                  Navigator.pop(context);
                  _showDisableLockDialog(context, theme);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDisableLockDialog(BuildContext context, ThemeData theme) {
    final pwdCtrl = TextEditingController();
    String? error;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: theme.cardColor,
          title: const Text('Disable Journal Protection', style: TextStyle(fontFamily: 'Essays1743', fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your current password to confirm disabling journal encryption:'),
              const SizedBox(height: 12),
              TextField(
                controller: pwdCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  errorText: error,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () async {
                final nav = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                final ok = await JournalSecurityService.instance.disableLock(pwdCtrl.text);
                if (ok) {
                  nav.pop();
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Journal protection disabled.')),
                  );
                } else {
                  setState(() => error = 'Incorrect password.');
                }
              },
              child: const Text('Disable', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPomodoroSoundOptions(BuildContext context, DataRepository repository, ThemeData theme) {
    final sounds = [
      {'title': 'Alarme 1 (Tone 1)', 'path': 'assets/sounds/alarme1.mp3'},
      {'title': 'Alarme 2 (Wave Tone)', 'path': 'assets/sounds/alarme 2.wav'},
      {'title': 'Community Alarm (Short)', 'path': 'assets/sounds/freesound_community-alarm-clock-short-6402.mp3'},
      {'title': 'Classic Sophia Alarm', 'path': 'assets/sounds/sophiahalmen-alarm-clock-207274.mp3'},
    ];

    return sounds.map((sound) {
      final isSelected = repository.selectedPomodoroSound == sound['path'];

      return Column(
        children: [
          ListTile(
            dense: true,
            title: Text(
              sound['title']!,
              style: TextStyle(
                fontFamily: 'Essays1743',
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? theme.primaryColor : theme.textTheme.bodyLarge?.color,
              ),
            ),
            subtitle: Text(
              sound['path']!,
              style: TextStyle(
                fontFamily: 'Essays1743',
                fontSize: 10,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
              ),
            ),
            leading: Radio<String>(
              value: sound['path']!,
              groupValue: repository.selectedPomodoroSound,
              activeColor: theme.primaryColor,
              onChanged: (val) {
                if (val != null) repository.setSelectedPomodoroSound(val);
              },
            ),
            trailing: IconButton(
              icon: const Icon(Icons.play_circle_outline, size: 22),
              color: theme.primaryColor,
              onPressed: () {
                AudioPlayerHelper.playSound(sound['path']!);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Previewing: ${sound['title']}'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              tooltip: 'Preview Sound',
            ),
            onTap: () => repository.setSelectedPomodoroSound(sound['path']!),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
        ],
      );
    }).toList();
  }
}
