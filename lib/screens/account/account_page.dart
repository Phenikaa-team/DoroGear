import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../services/user_service.dart';
import '../account/signin_page.dart';
import 'profile/addresser/delivery_address_page.dart';
import 'profile/edit_profile_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (UserService.currentUser == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Vui lòng đăng nhập để xem thông tin tài khoản.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInPage()),
                      (Route<dynamic> route) => false,
                );
              },
              child: const Text('Đăng nhập ngay'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserProfile(),
          const SizedBox(height: 20),
          _buildAccountSections(context),
          const SizedBox(height: 20),
          _buildSettingsSection(),
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
    if (user == null) {
      return const SizedBox.shrink();
    }

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSections(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Quản lý tài khoản',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ),
        _buildAccountItem(
            Icons.edit,
            'Chỉnh sửa hồ sơ',
                () async {
              await Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const EditProfilePage()));
              (context as Element).markNeedsBuild();
            }
        ),
        _buildAccountItem(
            Icons.location_on_outlined,
            'Địa chỉ giao hàng',
                () {
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const DeliveryAddressPage()));
            }
        ),
        _buildAccountItem(
            Icons.shopping_bag_outlined, 'Đơn hàng của tôi', () {}),
        _buildAccountItem(Icons.favorite_border, 'Sản phẩm yêu thích', () {}),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Cài đặt & Hỗ trợ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ),
        _buildAccountItem(Icons.notifications_none, 'Cài đặt thông báo', () {}),
        _buildAccountItem(Icons.security, 'Thay đổi mật khẩu', () {}),
        _buildAccountItem(Icons.help_outline, 'Trung tâm trợ giúp', () {}),
        _buildAccountItem(Icons.info_outline, 'Về ứng dụng', () {}),
      ],
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
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton.icon(
          icon: const Icon(Icons.logout, color: Colors.orange),
          label: const Text(
            'Đăng xuất',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          onPressed: () {
            UserService.signOut();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const SignInPage()),
                  (Route<dynamic> route) => false,
            );
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.orange, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận Xóa Tài Khoản'),
          content: const Text(
            'Bạn có chắc chắn muốn xóa tài khoản này? Thao tác này không thể hoàn tác và sẽ xóa tất cả dữ liệu liên quan. Bạn sẽ được đăng xuất sau khi xóa.',
            style: TextStyle(fontSize: 14),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy', style: TextStyle(color: AppColors.primaryColor)),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
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

    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SignInPage()),
            (Route<dynamic> route) => false,
      );
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          icon: const Icon(Icons.person_remove_alt_1, color: Colors.red),
          label: const Text(
            'Xóa Tài Khoản',
            style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          onPressed: () => _showDeleteConfirmationDialog(context),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: const BorderSide(color: Colors.red, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}