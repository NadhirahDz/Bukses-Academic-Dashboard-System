import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeMenuPage extends StatelessWidget {
  final String name;
  final String role;
  final String password;

  static const Color kEmerald = Color(0xFF059669);
  static const Color kEmeraldDark = Color(0xFF047857);
  static const Color kEmeraldDeep = Color(0xFF064E3B);
  static const Color kEmeraldLight = Color(0xFF6EE7B7);

  const HomeMenuPage(
      {super.key,
      required this.name,
      required this.role,
      this.password = ''});

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
              Color(0xFF059669),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Custom AppBar area ──────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            kEmeraldLight.withOpacity(0.5),
                            kEmerald.withOpacity(0.5),
                          ],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withOpacity(0.5), width: 2),
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang,',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            name,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 3),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              color: kEmeraldLight.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: kEmeraldLight.withOpacity(0.4)),
                            ),
                            child: Text(
                              _getRoleLabel(role),
                              style: GoogleFonts.poppins(
                                color: kEmeraldLight,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Logout button
                    Tooltip(
                      message: 'Log Keluar',
                      child: InkWell(
                        onTap: () =>
                            Navigator.pushReplacementNamed(context, '/'),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.25)),
                          ),
                          child: const Icon(Icons.logout_rounded,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Divider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Section title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 16,
                      decoration: BoxDecoration(
                        color: kEmeraldLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'PILIH TINDAKAN',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.65),
                        fontSize: 11,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Menu cards
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      // View Dashboard
                      Expanded(
                        child: _buildMenuCard(
                          context,
                          icon: Icons.bar_chart_rounded,
                          gradientColors: [
                            const Color(0xFF059669),
                            const Color(0xFF047857),
                          ],
                          title: 'Lihat\nDashboard',
                          subtitle: 'Papar prestasi pelajar',
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
                          gradientColors: [
                            const Color(0xFF065f46),
                            const Color(0xFF064E3B),
                          ],
                          title: 'Kemaskini\nData',
                          subtitle: 'Muat naik fail / data',
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/update',
                              arguments: {
                                'name': name,
                                'role': role,
                                'password': password,
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Footer
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  '© Sistem Prestasi Pelajar SMKBBKH',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required List<Color> gradientColors,
    required String title,
    required String subtitle,
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
              color: Colors.black.withOpacity(0.18),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            children: [
              // Top gradient banner
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(icon, size: 48, color: Colors.white),
                ),
              ),
              // Bottom text area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: kEmeraldDeep,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 7),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: gradientColors,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Buka',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 13,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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