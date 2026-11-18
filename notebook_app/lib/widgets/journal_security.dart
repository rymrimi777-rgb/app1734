import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pointycastle/export.dart' hide State;

/// Cryptographic Journal Security Manager providing PBKDF2 key derivation
/// and authenticated AES-256 encryption for private journal entries.
class JournalSecurityService extends ChangeNotifier {
  static final JournalSecurityService instance = JournalSecurityService._internal();
  factory JournalSecurityService() => instance;

  JournalSecurityService._internal() {
    _loadState();
  }

  bool _isLockEnabled = false;
  bool _isUnlocked = false;
  Uint8List? _cachedEncKey;
  Uint8List? _cachedMacKey;

  bool get isLockEnabled => _isLockEnabled;
  bool get isUnlocked => _isUnlocked;

  static const String _prefEnabledKey = 'journal_lock_enabled';
  static const String _prefSaltKey = 'journal_lock_salt';
  static const String _prefVerifierKey = 'journal_lock_verifier';

  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLockEnabled = prefs.getBool(_prefEnabledKey) ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('[JournalSecurityService] Error loading lock state: $e');
    }
  }

  /// Derives 64 bytes (32 for AES-256, 32 for HMAC-SHA256) using PBKDF2.
  static Uint8List _deriveKeys(String password, Uint8List salt, {int iterations = 10000}) {
    final derivator = KeyDerivator('SHA-256/HMAC/PBKDF2');
    final params = Pbkdf2Parameters(salt, iterations, 64);
    derivator.init(params);
    return derivator.process(Uint8List.fromList(utf8.encode(password)));
  }

  /// Generate cryptographically secure random bytes.
  static Uint8List _randomBytes(int length) {
    final rnd = Random.secure();
    final bytes = Uint8List(length);
    for (int i = 0; i < length; i++) {
      bytes[i] = rnd.nextInt(256);
    }
    return bytes;
  }

  /// Constant-time comparison to prevent timing attacks.
  static bool _constantTimeEqual(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }

  /// Set up or update password.
  Future<bool> setPassword(String password) async {
    if (password.length < 4) return false;
    try {
      final prefs = await SharedPreferences.getInstance();
      final salt = _randomBytes(16);
      final derived = _deriveKeys(password, salt);

      // Verifier is HMAC of a known token
      final macKey = derived.sublist(32, 64);
      final hmac = HMac(SHA256Digest(), 64)..init(KeyParameter(macKey));
      final verifierBytes = hmac.process(Uint8List.fromList(utf8.encode('1734_VERIFIER_TOKEN')));

      await prefs.setBool(_prefEnabledKey, true);
      await prefs.setString(_prefSaltKey, base64Encode(salt));
      await prefs.setString(_prefVerifierKey, base64Encode(verifierBytes));

      _isLockEnabled = true;
      _isUnlocked = true;
      _cachedEncKey = derived.sublist(0, 32);
      _cachedMacKey = macKey;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[JournalSecurityService] Error setting password: $e');
      return false;
    }
  }

  /// Verify password and unlock the journal for this session.
  Future<bool> unlock(String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saltStr = prefs.getString(_prefSaltKey);
      final verifierStr = prefs.getString(_prefVerifierKey);

      if (saltStr == null || verifierStr == null) return false;

      final salt = base64Decode(saltStr);
      final storedVerifier = base64Decode(verifierStr);

      final derived = _deriveKeys(password, salt);
      final macKey = derived.sublist(32, 64);
      final hmac = HMac(SHA256Digest(), 64)..init(KeyParameter(macKey));
      final computedVerifier = hmac.process(Uint8List.fromList(utf8.encode('1734_VERIFIER_TOKEN')));

      if (_constantTimeEqual(storedVerifier, computedVerifier)) {
        _isUnlocked = true;
        _cachedEncKey = derived.sublist(0, 32);
        _cachedMacKey = macKey;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[JournalSecurityService] Error unlocking: $e');
      return false;
    }
  }

  /// Lock the journal immediately.
  void lock() {
    _isUnlocked = false;
    _cachedEncKey = null;
    _cachedMacKey = null;
    notifyListeners();
  }

  /// Disable lock after confirming current password.
  Future<bool> disableLock(String currentPassword) async {
    final ok = await unlock(currentPassword);
    if (!ok) return false;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefEnabledKey, false);
      await prefs.remove(_prefSaltKey);
      await prefs.remove(_prefVerifierKey);

      _isLockEnabled = false;
      _isUnlocked = false;
      _cachedEncKey = null;
      _cachedMacKey = null;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[JournalSecurityService] Error disabling lock: $e');
      return false;
    }
  }

  /// Encrypt a plaintext string using Authenticated AES-256-CBC.
  String? encryptString(String plaintext) {
    if (_cachedEncKey == null || _cachedMacKey == null) return null;
    try {
      final iv = _randomBytes(16);
      final plainBytes = Uint8List.fromList(utf8.encode(plaintext));

      final cipher = PaddedBlockCipher('AES/CBC/PKCS7');
      final params = PaddedBlockCipherParameters<CipherParameters, CipherParameters>(
        ParametersWithIV<KeyParameter>(KeyParameter(_cachedEncKey!), iv),
        null,
      );
      cipher.init(true, params);
      final cipherBytes = cipher.process(plainBytes);

      // Compute HMAC over IV + Ciphertext
      final toMac = Uint8List(iv.length + cipherBytes.length);
      toMac.setRange(0, iv.length, iv);
      toMac.setRange(iv.length, toMac.length, cipherBytes);

      final hmac = HMac(SHA256Digest(), 64)..init(KeyParameter(_cachedMacKey!));
      final macBytes = hmac.process(toMac);

      return 'ENC:v1:${base64Encode(iv)}:${base64Encode(cipherBytes)}:${base64Encode(macBytes)}';
    } catch (e) {
      debugPrint('[JournalSecurityService] Encryption error: $e');
      return null;
    }
  }

  /// Decrypt an encrypted string.
  String? decryptString(String encryptedStr) {
    if (!encryptedStr.startsWith('ENC:v1:')) {
      // Unencrypted text: return as-is for backward compatibility
      return encryptedStr;
    }
    if (_cachedEncKey == null || _cachedMacKey == null) return null;

    try {
      final parts = encryptedStr.split(':');
      if (parts.length != 5) return null;

      final iv = base64Decode(parts[2]);
      final cipherBytes = base64Decode(parts[3]);
      final macBytes = base64Decode(parts[4]);

      // Verify HMAC first
      final toMac = Uint8List(iv.length + cipherBytes.length);
      toMac.setRange(0, iv.length, iv);
      toMac.setRange(iv.length, toMac.length, cipherBytes);

      final hmac = HMac(SHA256Digest(), 64)..init(KeyParameter(_cachedMacKey!));
      final computedMac = hmac.process(toMac);

      if (!_constantTimeEqual(macBytes, computedMac)) {
        debugPrint('[JournalSecurityService] HMAC mismatch: invalid key or data corrupted');
        return null;
      }

      final cipher = PaddedBlockCipher('AES/CBC/PKCS7');
      final params = PaddedBlockCipherParameters<CipherParameters, CipherParameters>(
        ParametersWithIV<KeyParameter>(KeyParameter(_cachedEncKey!), iv),
        null,
      );
      cipher.init(false, params);
      final decryptedBytes = cipher.process(cipherBytes);

      return utf8.decode(decryptedBytes);
    } catch (e) {
      debugPrint('[JournalSecurityService] Decryption error: $e');
      return null;
    }
  }
}

/// Dialog for setting, confirming, or changing the Journal Password.
class JournalPasswordSetupDialog extends StatefulWidget {
  const JournalPasswordSetupDialog({Key? key}) : super(key: key);

  @override
  State<JournalPasswordSetupDialog> createState() => _JournalPasswordSetupDialogState();
}

class _JournalPasswordSetupDialogState extends State<JournalPasswordSetupDialog> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _errorMessage;
  bool _obscure = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() async {
    final pwd = _passwordController.text;
    final confirm = _confirmController.text;

    if (pwd.length < 4) {
      setState(() => _errorMessage = 'Password must be at least 4 characters long.');
      return;
    }
    if (pwd != confirm) {
      setState(() => _errorMessage = 'Passwords do not match. Please re-enter.');
      return;
    }

    final success = await JournalSecurityService.instance.setPassword(pwd);
    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Journal Lock enabled! Your notes are now securely protected.'),
          backgroundColor: Colors.black,
        ),
      );
    } else {
      setState(() => _errorMessage = 'Failed to enable lock. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: theme.cardColor,
      title: Row(
        children: [
          Icon(Icons.lock_outline, color: theme.primaryColor),
          const SizedBox(width: 8),
          Text(
            'Journal Password Lock',
            style: TextStyle(
              fontFamily: 'Essays1743',
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create a password to encrypt and lock your private writings.',
              style: TextStyle(
                fontFamily: 'Essays1743',
                fontSize: 13,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.amber.shade700.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 20, color: Colors.amber.shade900),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Important: If you forget this password, encrypted entries cannot be recovered.',
                      style: TextStyle(
                        fontFamily: 'Essays1743',
                        fontSize: 11,
                        color: theme.textTheme.bodyMedium?.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: _obscure,
              style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontFamily: 'Essays1743'),
              decoration: InputDecoration(
                labelText: 'New Password',
                labelStyle: TextStyle(color: theme.textTheme.bodyMedium?.color, fontFamily: 'Essays1743'),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: theme.iconTheme.color),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmController,
              obscureText: _obscure,
              style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontFamily: 'Essays1743'),
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                labelStyle: TextStyle(color: theme.textTheme.bodyMedium?.color, fontFamily: 'Essays1743'),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontFamily: 'Essays1743'),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel', style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7))),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor),
          onPressed: _submit,
          child: Text(
            'Enable Protection',
            style: TextStyle(
              fontFamily: 'Essays1743',
              color: theme.brightness == Brightness.dark ? Colors.black : Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

/// Dialog for unlocking the Journal.
class JournalUnlockDialog extends StatefulWidget {
  const JournalUnlockDialog({Key? key}) : super(key: key);

  @override
  State<JournalUnlockDialog> createState() => _JournalUnlockDialogState();
}

class _JournalUnlockDialogState extends State<JournalUnlockDialog> {
  final _passwordController = TextEditingController();
  String? _errorMessage;
  bool _obscure = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    final pwd = _passwordController.text;
    final success = await JournalSecurityService.instance.unlock(pwd);
    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
    } else {
      setState(() => _errorMessage = 'Incorrect password. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: theme.cardColor,
      title: Row(
        children: [
          Icon(Icons.lock_clock_outlined, color: theme.primaryColor),
          const SizedBox(width: 8),
          Text(
            'Journal is Locked',
            style: TextStyle(
              fontFamily: 'Essays1743',
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter your journal password to unlock and access your writings:',
            style: TextStyle(
              fontFamily: 'Essays1743',
              fontSize: 13,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: _obscure,
            autofocus: true,
            style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontFamily: 'Essays1743'),
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(color: theme.textTheme.bodyMedium?.color, fontFamily: 'Essays1743'),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: theme.iconTheme.color),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontFamily: 'Essays1743'),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel', style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7))),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor),
          onPressed: _submit,
          child: Text(
            'Unlock',
            style: TextStyle(
              fontFamily: 'Essays1743',
              color: theme.brightness == Brightness.dark ? Colors.black : Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
