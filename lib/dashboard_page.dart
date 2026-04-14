// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardPage extends StatefulWidget {
  final String name;
  final String role;

  const DashboardPage({
    super.key,
    required this.name,
    required this.role,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late String viewId;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  static const Color kEmerald = Color(0xFF059669);
  static const Color kEmeraldDark = Color(0xFF047857);
  static const Color kEmeraldDeep = Color(0xFF064E3B);
  static const Color kEmeraldLight = Color(0xFF6EE7B7);

  final Map<String, String> dashboardUrls = {
    'admin':
        'https://lookerstudio.google.com/embed/reporting/4d52ceca-bdba-4dd5-8896-617036cee9c6/page/KMtjF',
    'teacher_form4':
        'https://lookerstudio.google.com/embed/reporting/ecb73835-335d-4792-92a8-02db246b0b6b/page/p_hgvwo4uj1d',
    'teacher_form5':
        'https://lookerstudio.google.com/embed/reporting/73e1c1f2-fb98-4fa4-bc34-408b3ed243b8/page/p_hgvwo4uj1d',
  };

  @override
  void initState() {
    super.initState();
    viewId = 'looker-${widget.role}-${DateTime.now().millisecondsSinceEpoch}';

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();

    final String url =
        dashboardUrls[widget.role] ?? dashboardUrls['admin']!;

    ui.platformViewRegistry.registerViewFactory(viewId, (int id) {
      final iframe = html.IFrameElement()
        ..src = url
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allow = 'fullscreen'
        ..setAttribute(
            'sandbox',
            'allow-storage-access-by-user-activation allow-scripts allow-same-origin allow-popups allow-popups-to-escape-sandbox');
      return iframe;
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _printDashboard() {
    html.window.print();
  }

  String _getDashboardTitle(String role) {
    switch (role) {
      case 'admin':
        return 'Dashboard Pentadbir';
      case 'teacher_form4':
        return 'Dashboard Tingkatan 4';
      case 'teacher_form5':
        return 'Dashboard Tingkatan 5';
      default:
        return 'Dashboard';
    }
  }

  String _getRoleSubtitle(String role) {
    switch (role) {
      case 'admin':
        return 'Papan Pemuka Pentadbiran';
      case 'teacher_form4':
        return 'Prestasi Pelajar Tingkatan 4';
      case 'teacher_form5':
        return 'Prestasi Pelajar Tingkatan 5';
      default:
        return 'Sistem Prestasi Pelajar';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kEmeraldDeep, kEmeraldDark, kEmerald],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  // Back button
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Kembali',
                  ),

                  // Title block
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getDashboardTitle(widget.role),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                        Text(
                          _getRoleSubtitle(widget.role),
                          style: GoogleFonts.poppins(
                            color: kEmeraldLight.withOpacity(0.85),
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // PDF Download button
                  Tooltip(
                    message: 'Muat Turun / Cetak PDF',
                    child: InkWell(
                      onTap: _printDashboard,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.picture_as_pdf_rounded,
                                color: Colors.white, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'PDF',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // User name badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_rounded,
                            color: kEmeraldLight, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          widget.name,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: HtmlElementView(viewType: viewId),
      ),
    );
  }
}