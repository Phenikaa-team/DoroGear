import 'package:doro_gear/localization/app_localizations.dart';
import 'package:doro_gear/models/user.dart';
import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../helpers/enums/user_role.dart';
import '../../../services/user_service.dart';
import 'add_edit_employee_page.dart';

class StaffManagementPage extends StatefulWidget {
  const StaffManagementPage({super.key});

  @override
  State<StaffManagementPage> createState() => _StaffManagementPageState();
}

class _StaffManagementPageState extends State<StaffManagementPage> {
  List<User> _staffList = [];
  List<User> _filteredStaffList = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStaff();
    _searchController.addListener(_filterStaff);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadStaff() {
    setState(() {
      _staffList = UserService.allUsers
          .where((user) => user.role == UserRole.admin || user.role == UserRole.employee)
          .toList();
      _filteredStaffList = _staffList;
    });
  }

  void _filterStaff() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStaffList = _staffList.where((staff) {
        final nameMatches = staff.name.toLowerCase().contains(query);
        final emailMatches = staff.email.toLowerCase().contains(query);
        return nameMatches || emailMatches;
      }).toList();
    });
  }


  Future<void> _navigateAndRefresh(Widget page) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
    if (result == true && mounted) {
      _loadStaff();
      _filterStaff();
    }
  }

  Future<void> _deleteStaff(User staff) async {
    final t = AppLocalizations.of(context)!;
    if (staff.email == UserService.currentUser?.email) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.translate('cannotDeleteSelf')), backgroundColor: Colors.orange),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.translate('deleteAddressConfirmTitle')),
        content: Text(t.translate('deleteStaffConfirmation').replaceAll('{staffName}', staff.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t.translate('cancel'))),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.translate('delete'), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await UserService.deleteUserByEmail(staff.email);
      _loadStaff();
      _filterStaff();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('staffManagement')),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: t.translate('searchStaffHint'),
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _searchController.clear(),
                )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: _filteredStaffList.length,
              itemBuilder: (context, index) {
                final staff = _filteredStaffList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: staff.role == UserRole.admin ? Colors.red.shade100 : Colors.blue.shade100,
                      child: Icon(
                        staff.role == UserRole.admin ? Icons.admin_panel_settings_outlined : Icons.badge_outlined,
                        color: staff.role == UserRole.admin ? Colors.red : Colors.blue,
                      ),
                    ),
                    title: Text(staff.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      '${staff.email}\n${t.translate('role').replaceAll('{roleName}', staff.role.name)}',
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppColors.primaryColor),
                          onPressed: () => _navigateAndRefresh(AddEditStaffPage(staff: staff)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteStaff(staff),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateAndRefresh(const AddEditStaffPage()),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}