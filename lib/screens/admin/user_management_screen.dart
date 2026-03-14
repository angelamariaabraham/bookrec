import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/firestore_service.dart';
import 'user_activity_screen.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<UserModel>? _users;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final firestore = FirestoreService();
    final users = await firestore.getAllUsers();
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Management',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users == null || _users!.isEmpty
              ? const Center(child: Text('No users found.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _users!.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final user = _users![index];
                    return _buildUserCard(user, theme);
                  },
                ),
    );
  }

  Widget _buildUserCard(UserModel user, ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
            style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          user.name,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(user.email),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: user.role == 'admin' ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                user.role.toUpperCase(),
                style: TextStyle(
                  color: user.role == 'admin' ? Colors.red[700] : Colors.green[700],
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.manage_accounts_rounded, size: 20),
              onPressed: () => _showRoleManagementDialog(user),
              tooltip: 'Manage Role',
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UserActivityScreen(user: user),
            ),
          );
        },
      ),
    );
  }

  void _showRoleManagementDialog(UserModel user) {
    final firestore = FirestoreService();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manage User Role'),
        content: Text('What role would you like to assign to ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          if (user.role == 'admin')
            ElevatedButton(
              onPressed: () async {
                await firestore.updateUserRole(user.uid, 'user');
                if (mounted) {
                  Navigator.pop(context);
                  _fetchUsers();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Move to USER'),
            )
          else
            ElevatedButton(
              onPressed: () async {
                await firestore.updateUserRole(user.uid, 'admin');
                if (mounted) {
                  Navigator.pop(context);
                  _fetchUsers();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('Promote to ADMIN'),
            ),
        ],
      ),
    );
  }
}
