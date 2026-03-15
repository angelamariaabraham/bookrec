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
  List<UserModel>? _filteredUsers;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
      _filteredUsers = users;
      _isLoading = false;
    });
  }

  void _filterUsers(String query) {
    if (_users == null) return;
    setState(() {
      _filteredUsers = _users!
          .where((u) =>
              u.displayName.toLowerCase().contains(query.toLowerCase()) ||
              u.email.toLowerCase().contains(query.toLowerCase()))
          .toList();
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
        actions: [
          if (_users != null)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text(
                  '${_users!.length} Total',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Glassmorphic Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterUsers,
                decoration: InputDecoration(
                  hintText: 'Search by name or email...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            _filterUsers('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.05),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: theme.colorScheme.primary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers == null || _filteredUsers!.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_search_rounded,
                              size: 64,
                              color: theme.colorScheme.outline.withValues(
                                alpha: 0.2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No users found.',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                        itemCount: _filteredUsers!.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final user = _filteredUsers![index];
                          return _buildUserCard(user, theme);
                        },
                      ),
          ),
        ],
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
            user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U',
            style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          user.displayName,
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
            IconButton(
              icon: Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: Colors.red[300],
              ),
              onPressed: () => _showDeleteUserDialog(user),
              tooltip: 'Delete User',
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
        content: Text('What role would you like to assign to ${user.displayName}?'),
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

  void _showDeleteUserDialog(UserModel user) {
    final firestore = FirestoreService();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            const SizedBox(width: 12),
            const Text('Delete Account'),
          ],
        ),
        content: Text(
          'Are you sure you want to permanently delete the account for ${user.displayName}?\n\nThis action cannot be undone and will remove all their data.',
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await firestore.deleteUser(user.uid);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('User ${user.displayName} deleted.'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                _fetchUsers();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }
}
