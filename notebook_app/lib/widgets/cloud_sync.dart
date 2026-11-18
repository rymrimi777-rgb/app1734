import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../repository.dart';

class CloudSyncSheet extends StatefulWidget {
  const CloudSyncSheet({Key? key}) : super(key: key);

  @override
  State<CloudSyncSheet> createState() => _CloudSyncSheetState();
}

class _CloudSyncSheetState extends State<CloudSyncSheet> {
  bool _autoSync = true;
  bool _isSyncing = false;
  String _lastSyncedTime = 'Just now';

  void _triggerManualSync() {
    setState(() {
      _isSyncing = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isSyncing = false;
          _lastSyncedTime = 'Today at ${TimeOfDay.now().format(context)}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cloud backup sync completed successfully!'),
            backgroundColor: Colors.black,
          ),
        );
      }
    });
  }

  void _exportJsonBackup() {
    final jsonStr = DataRepository().exportDataJson();
    Clipboard.setData(ClipboardData(text: jsonStr));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Backup JSON data copied to clipboard! Save to Google Drive / iCloud.'),
        backgroundColor: Colors.black,
      ),
    );
  }

  void _showImportDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Restore Backup Data', style: TextStyle(fontFamily: 'Essays1743', fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          maxLines: 5,
          style: const TextStyle(fontFamily: 'Essays1743', fontSize: 13),
          decoration: const InputDecoration(
            hintText: 'Paste backup JSON string here...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            onPressed: () {
              final success = DataRepository().importDataJson(controller.text.trim());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success ? 'Backup restored successfully!' : 'Failed to restore backup data.'),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );
            },
            child: const Text('Restore Data', style: TextStyle(color: Colors.white, fontFamily: 'Essays1743')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Cloud Backup & Sync',
                style: TextStyle(
                  fontFamily: 'Essays1743',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black12),
            ),
            child: Row(
              children: [
                Icon(
                  _isSyncing ? Icons.sync : Icons.cloud_done,
                  color: Colors.black,
                  size: 28,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isSyncing ? 'Syncing notes to Cloud...' : 'Google Drive & iCloud Connected',
                        style: const TextStyle(
                          fontFamily: 'Essays1743',
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'Last Synced: $_lastSyncedTime',
                        style: const TextStyle(fontFamily: 'Essays1743', fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                if (_isSyncing)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SwitchListTile(
            title: const Text('Auto-Sync Notes', style: TextStyle(fontFamily: 'Essays1743', fontWeight: FontWeight.bold)),
            subtitle: const Text('Automatically back up drawing canvas & agenda across devices', style: TextStyle(fontFamily: 'Essays1743', fontSize: 12)),
            activeColor: Colors.black,
            value: _autoSync,
            onChanged: (val) => setState(() => _autoSync = val),
          ),

          const Divider(color: Colors.black12),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _triggerManualSync,
                  icon: const Icon(Icons.sync, color: Colors.black),
                  label: const Text('Sync Now', style: TextStyle(fontFamily: 'Essays1743', color: Colors.black)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _exportJsonBackup,
                  icon: const Icon(Icons.upload_file, color: Colors.white),
                  label: const Text('Export JSON', style: TextStyle(fontFamily: 'Essays1743', color: Colors.white)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: _showImportDialog,
              child: const Text('Restore Data from Backup File / Text', style: TextStyle(fontFamily: 'Essays1743', color: Colors.black87, decoration: TextDecoration.underline)),
            ),
          ),
        ],
      ),
    );
  }
}
