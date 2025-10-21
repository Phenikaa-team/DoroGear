import 'package:doro_gear/localization/app_localizations.dart';
import 'package:doro_gear/models/user.dart';
import 'package:flutter/material.dart';

import '../../../services/user_service.dart';

class CustomerDetailPage extends StatefulWidget {
  final User customer;
  const CustomerDetailPage({super.key, required this.customer});

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.customer;
  }

  Future<void> _toggleBanStatus() async {
    final t = AppLocalizations.of(context)!;
    final newStatus = !_currentUser.isBanned;
    final actionText = newStatus ? t.translate('ban') : t.translate('unban');

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.translate('confirmation')),
        content: Text(
          t.translate('banConfirmMessage')
              .replaceAll('{action}', actionText)
              .replaceAll('{customerName}', _currentUser.name),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t.translate('cancel'))),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(actionText, style: TextStyle(color: newStatus ? Colors.red : Colors.green)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await UserService.updateUser(
        oldEmail: _currentUser.email,
        isBanned: newStatus,
      );
      setState(() {
        _currentUser = _currentUser.copyWith(isBanned: newStatus);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              t.translate('updateSuccessMessage').replaceAll('{customerName}', _currentUser.name)
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('customerDetails')),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(t, Icons.person, t.translate('staffNameLabel'), _currentUser.name),
            _buildDetailRow(t, Icons.email, t.translate('emailAddress'), _currentUser.email),
            _buildDetailRow(t, Icons.phone, t.translate('phoneNumber'), _currentUser.phoneNumber ?? t.translate('notAvailable')),
            _buildDetailRow(
              t,
              _currentUser.isBanned ? Icons.block : Icons.check_circle,
              t.translate('accountStatus'),
              _currentUser.isBanned ? t.translate('bannedStatus') : t.translate('activeStatus'),
              valueColor: _currentUser.isBanned ? Colors.red : Colors.green,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _toggleBanStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _currentUser.isBanned ? Colors.green : Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text(_currentUser.isBanned ? t.translate('unbanAccount') : t.translate('banAccount')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(AppLocalizations t, IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(
                value,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: valueColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}