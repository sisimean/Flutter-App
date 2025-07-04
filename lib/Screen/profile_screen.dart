import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? name;
  String? email;
  String? profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? '';
      email = prefs.getString('email') ?? '';
      profile = prefs.getString('profile') ?? '';
    });
  }

  void _showProfilePopup(String imageUrl) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Profile",
      barrierColor: Colors.black.withOpacity(0.8),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    panEnabled: true,
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Hero(
                      tag: 'profile-image-hero',
                      child: Image.network(
                        imageUrl,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 20,
                  right: 20,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim1, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white70 : Colors.black87;
    final subtitleColor = isDark ? Colors.white60 : Colors.black54;
    final dividerColor = isDark ? Colors.white12 : Colors.black12;
    final cardColor =
        isDark
            ? Colors.deepPurple.withOpacity(0.1)
            : Colors.deepPurple.withOpacity(0.05);

    return Scaffold(
      appBar: AppBar(
        backgroundColor:Colors.brown.shade800,
        title: const Text('Profile'),
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onTap: () {
                if (profile != null && profile!.isNotEmpty) {
                  _showProfilePopup(profile!);
                }
              },
              child: Hero(
                tag: 'profile-image-hero',
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      (profile != null && profile!.isNotEmpty)
                          ? NetworkImage(profile!)
                          : const AssetImage('assets/images/default_avatar.png')
                              as ImageProvider,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.deepPurple.withOpacity(isDark ? 0.3 : 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  Icons.person,
                  "Name",
                  name ?? '',
                  textColor,
                  subtitleColor,
                ),
                Divider(color: dividerColor),
                _buildInfoRow(
                  Icons.email,
                  "Email",
                  email ?? '',
                  textColor,
                  subtitleColor,
                ),
                Divider(color: dividerColor),
                _buildInfoRow(
                  Icons.lock,
                  "Password",
                  "••••••••",
                  textColor,
                  subtitleColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String title,
    String value,
    Color valueColor,
    Color titleColor,
  ) {
    return Row(
      children: [
        Icon(icon, color: Colors.brown.shade800, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: titleColor, fontSize: 14)),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
