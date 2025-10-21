import 'package:doro_gear/localization/app_localizations.dart';
import 'package:doro_gear/models/user.dart';
import 'package:flutter/material.dart';

import '../../../helpers/enums/user_role.dart';
import '../../../services/user_service.dart';
import 'customer_detail_page.dart';

class CustomerManagementPage extends StatefulWidget {
  const CustomerManagementPage({super.key});

  @override
  State<CustomerManagementPage> createState() => _CustomerManagementPageState();
}

class _CustomerManagementPageState extends State<CustomerManagementPage> {
  List<User> _customerList = [];
  List<User> _filteredCustomerList = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _searchController.addListener(_filterCustomers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadCustomers() {
    setState(() {
      _customerList = UserService.allUsers.where((user) => user.role == UserRole.customer).toList();
      _filteredCustomerList = _customerList;
    });
  }

  void _filterCustomers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCustomerList = _customerList.where((customer) {
        final nameMatches = customer.name.toLowerCase().contains(query);
        final emailMatches = customer.email.toLowerCase().contains(query);
        return nameMatches || emailMatches;
      }).toList();
    });
  }

  Future<void> _navigateToDetail(User customer) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CustomerDetailPage(customer: customer)),
    );
    _loadCustomers();
    _filterCustomers();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('customerManagement')),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: t.translate('searchCustomerHint'),
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
              itemCount: _filteredCustomerList.length,
              itemBuilder: (context, index) {
                final customer = _filteredCustomerList[index];
                final isBanned = customer.isBanned;
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: isBanned ? Colors.grey.shade300 : null,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isBanned ? Colors.grey : Colors.green.shade100,
                      child: Icon(
                        isBanned ? Icons.block : Icons.person_outline,
                        color: isBanned ? Colors.white : Colors.green,
                      ),
                    ),
                    title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(customer.email),
                    trailing: isBanned
                        ? Text(
                      t.translate('bannedStatus'),
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    )
                        : const Icon(Icons.chevron_right),
                    onTap: () => _navigateToDetail(customer),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}