import 'package:doro_gear/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../providers/locale_provider.dart';
import '../../services/user_service.dart';
import '../account/signin_page.dart';
import 'profile/addresser/delivery_address_page.dart';
import 'profile/edit_profile_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    void refresh() => (context as Element).markNeedsBuild();

    return UserService.isGuest ? _buildGuestView(context) : _buildUserView(context, refresh);
  }

  Widget _buildGuestView(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            t.translate('guestPrompt'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _navigateToSignIn(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            child: Text(t.translate('loginNow')),
          ),
        ],
      ),
    );
  }

  Widget _buildUserView(BuildContext context, VoidCallback onRefresh) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserProfile(),
          const SizedBox(height: 20),
          _buildAccountSections(context, onRefresh),
          const SizedBox(height: 20),
          _buildSettingsSection(context),
          const SizedBox(height: 30),
          _buildLogoutButton(context),
          const SizedBox(height: 10),
          _buildDeleteAccountButton(context),
        ],
      ),
    );
  }


  Widget _buildUserProfile() {
    final user = UserService.currentUser;
    if (user == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 35,
            backgroundColor: AppColors.primaryColor,
            child: Icon(Icons.person, color: Colors.white, size: 40),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSections(BuildContext context, VoidCallback onRefresh) {
    final t = AppLocalizations.of(context)!;
    return _buildSectionContainer(
      title: t.translate('manageAccount'),
      children: [
        _buildAccountItem(
            Icons.edit,
            t.translate('editProfile'),
                () async {
              await Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfilePage()));
              onRefresh();
            }
        ),
        _buildAccountItem(
            Icons.location_on_outlined,
            t.translate('deliveryAddress'),
                () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DeliveryAddressPage()))
        ),
        _buildAccountItem(Icons.shopping_bag_outlined, t.translate('myOrders'), () {}),
        _buildAccountItem(Icons.favorite_border, t.translate('favoriteProducts'), () {}),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return _buildSectionContainer(
      title: t.translate('settingsAndSupport'),
      children: [
        _buildAccountItem(Icons.language, t.translate('language'), () => _showLanguagePicker(context)),
        _buildAccountItem(Icons.notifications_none, 'Cài đặt thông báo', () {}),
        _buildAccountItem(Icons.security, 'Thay đổi mật khẩu', () {}),
        _buildAccountItem(Icons.help_outline, 'Trung tâm trợ giúp', () {}),
        _buildAccountItem(Icons.info_outline, 'Về ứng dụng', () {}),
      ],
    );
  }

  Widget _buildSectionContainer({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black54),
          ),
        ),
        ...children,
      ],
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(t.translate('chooseLanguage')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Tiếng Việt'),
                onTap: () {
                  Provider.of<LocaleProvider>(context, listen: false).setLocale(const Locale('vi'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('English'),
                onTap: () {
                  Provider.of<LocaleProvider>(context, listen: false).setLocale(const Locale('en'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccountItem(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryColor, size: 24),
            const SizedBox(width: 15),
            Expanded(
              child: Text(title, style: const TextStyle(fontSize: 16, color: Colors.black87)),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton.icon(
          icon: const Icon(Icons.logout, color: Colors.orange),
          label: Text(
            t.translate('logout'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange),
          ),
          onPressed: () {
            UserService.signOut();
            _navigateToSignIn(context);
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.orange, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(t.translate('deleteAccount')),
          content: Text(
            'Bạn có chắc chắn muốn xóa tài khoản này? Thao tác này không thể hoàn tác và sẽ xóa tất cả dữ liệu liên quan. Bạn sẽ được đăng xuất sau khi xóa.',
            style: const TextStyle(fontSize: 14),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(t.translate('cancel'), style: const TextStyle(color: AppColors.primaryColor)),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: Text(t.translate('delete'), style: const TextStyle(color: Colors.red)),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _deleteAccountAndNavigate(context);
    }
  }

  Future<void> _deleteAccountAndNavigate(BuildContext context) async {
    final success = await UserService.deleteUser();
    if (!context.mounted) return;

    if (success) {
      _navigateToSignIn(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tài khoản đã được xóa thành công.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể xóa tài khoản. Vui lòng thử lại.')),
      );
    }
  }

  Widget _buildDeleteAccountButton(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          icon: const Icon(Icons.person_remove_alt_1, color: Colors.red),
          label: Text(
            t.translate('deleteAccount'),
            style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          onPressed: () => _showDeleteConfirmationDialog(context),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: const BorderSide(color: Colors.red, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  void _navigateToSignIn(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SignInPage()),
          (Route<dynamic> route) => false,
    );
  }
}