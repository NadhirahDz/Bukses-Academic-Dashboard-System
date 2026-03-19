import 'package:flutter/material.dart';

class HomeMenuPage extends StatelessWidget {
  final String name;
  final String role;

  static const Color kEmerald = Color(0xFF059669);
  static const Color kEmeraldDark = Color(0xFF047857);
  static const Color kEmeraldDeep = Color(0xFF064E3B);
  static const Color kEmeraldLight = Color(0xFF6EE7B7);

  const HomeMenuPage({super.key, required this.name, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              kEmeraldDeep,
              kEmeraldDark,
              kEmerald,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // Avatar circle
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selamat Datang,',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _getRoleLabel(role),
                                style: const TextStyle(
                                  color: kEmeraldLight,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Logout button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/');
                        },
                        icon: const Icon(Icons.logout, color: Colors.white),
                        tooltip: 'Log Keluar',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Divider
                Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.15),
                ),

                const SizedBox(height: 32),

                // Title
                Text(
                  'Pilih Tindakan',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                // Two menu cards
                Expanded(
                  child: Row(
                    children: [
                      // View Dashboard
                      Expanded(
                        child: _buildMenuCard(
                          context,
                          icon: Icons.dashboard_rounded,
                          title: 'Lihat\nDashboard',
                          subtitle: 'Papar prestasi pelajar',
                          iconBgColor: kEmerald,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/dashboard',
                              arguments: {'name': name, 'role': role},
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Update Data
                      Expanded(
                        child: _buildMenuCard(
                          context,
                          icon: Icons.upload_file_rounded,
                          title: 'Kemaskini\nData',
                          subtitle: 'Muat naik fail / data',
                          iconBgColor: kEmeraldDark,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/update',
                              arguments: {'name': name, 'role': role},
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Footer
                Center(
                  child: Text(
                    'Sistem Prestasi Pelajar SMKBBKH',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconBgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon container
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: iconBgColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  size: 36,
                  color: iconBgColor,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: kEmeraldDeep,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 16),
              // Arrow indicator
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: iconBgColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Buka',
                      style: TextStyle(
                        color: iconBgColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: iconBgColor,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'Pentadbir';
      case 'teacher_form4':
        return 'Guru Tingkatan 4';
      case 'teacher_form5':
        return 'Guru Tingkatan 5';
      default:
        return '';
    }
  }
}