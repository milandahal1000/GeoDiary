import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geodiary/bloc/authentication_bloc.dart';
import 'package:geodiary/bloc/authentication_event.dart';
import 'package:geodiary/bloc/authentication_state.dart';
import 'package:geodiary/theme/app_colors.dart';
import 'package:geolocator/geolocator.dart';

/// Settings screen for the signed-in user.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = context.read<FirebaseAuth>().currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildAccountCard(user),
            const SizedBox(height: 28),
            const _SectionHeader('Permissions'),
            Card(
              child: Column(
                children: [
                  if (!kIsWeb)
                    ListTile(
                      leading: const Icon(Icons.location_on_outlined),
                      title: const Text('Location permissions'),
                      subtitle: const Text(
                        'Allow precise location for accurate memories',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Geolocator.openAppSettings(),
                    ),
                  const ListTile(
                    leading: Icon(Icons.photo_camera_outlined),
                    title: Text('Camera and photos'),
                    subtitle: Text(
                      'Asked only when you take or choose a photo',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const _SectionHeader('Data'),
            const Card(
              child: ListTile(
                leading: Icon(Icons.storage_outlined),
                title: Text('Local storage'),
                subtitle: Text('Your memories are stored on this device only.'),
              ),
            ),
            const SizedBox(height: 28),
            const _SectionHeader('About'),
            const Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.map_outlined),
                    title: Text('GeoDiary'),
                    subtitle: Text('Your memories, mapped.'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('Version'),
                    subtitle: Text('1.0.0'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildSignOutButton(context),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCard(User? user) {
    final String displayName = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!
        : 'GeoDiary user';
    final String email = user?.email ?? 'No email available';
    final String? photoUrl = user?.photoURL;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(AppColors.softSage),
              foregroundImage: photoUrl == null ? null : NetworkImage(photoUrl),
              onForegroundImageError: (_, _) {},
              child: Text(
                _initials(displayName),
                style: const TextStyle(
                  color: Color(AppColors.primaryGreen),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(AppColors.mainText),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(AppColors.secondaryText),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Signed in with Google',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(AppColors.primaryGreen),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        final bool isSigningOut = state is AuthenticationSigningOut;
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: isSigningOut ? null : () => _confirmSignOut(context),
            icon: isSigningOut
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout),
            label: Text(isSigningOut ? 'Signing out...' : 'Sign out'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Color(AppColors.error)),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final bool? shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          'You will need to sign in with Google again to use GeoDiary.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );

    if (shouldSignOut != true || !context.mounted) {
      return;
    }

    context.read<AuthenticationBloc>().add(AuthenticationSignOut());
  }

  String _initials(String name) {
    final List<String> parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: Color(AppColors.secondaryText),
        ),
      ),
    );
  }
}
