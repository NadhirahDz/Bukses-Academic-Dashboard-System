// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'myconfig.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  String? _fileName;
  Uint8List? _fileBytes;
  bool _isLoading = false;
  String _statusMessage = '';
  bool _isSuccess = false;
  String _selectedTingkatan = '4';

  static const Color kEmerald = Color(0xFF059669);
  static const Color kEmeraldDark = Color(0xFF047857);
  static const Color kEmeraldDeep = Color(0xFF064E3B);
  static const Color kEmeraldLight = Color(0xFF6EE7B7);

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      withData: true,
    );

    if (result != null) {
      setState(() {
        _fileName = result.files.single.name;
        _fileBytes = result.files.single.bytes;
        _statusMessage = '';
      });
    }
  }

  /// Shows confirmation popup before uploading.
  Future<void> _confirmAndUpload(String correctPassword) async {
    if (_fileBytes == null) {
      setState(() {
        _statusMessage = 'Sila pilih fail Excel terlebih dahulu!';
        _isSuccess = false;
      });
      return;
    }

    // Show warning dialog with password input
    final passwordController = TextEditingController();
    bool obscure = true;
    bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 16,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Red warning header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: const BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                      gradient: LinearGradient(
                        colors: [Color(0xFFdc2626), Color(0xFFb91c1c)],
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: Colors.white, size: 48),
                        const SizedBox(height: 10),
                        Text(
                          'Amaran!',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Warning text
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            'Muat naik fail baru akan MENGGANTIKAN semua data lama yang sedia ada. '
                            'Data lama TIDAK DAPAT dipulihkan selepas proses ini.',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.red.shade800,
                              height: 1.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          'Masukkan Kata Laluan untuk Sahkan',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: kEmeraldDeep,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: passwordController,
                          obscureText: obscure,
                          style: GoogleFonts.poppins(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            hintStyle: TextStyle(
                                color: Colors.grey[400], fontSize: 14),
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: kEmerald, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey,
                                size: 20,
                              ),
                              onPressed: () =>
                                  setDialogState(() => obscure = !obscure),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey[200]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey[200]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: kEmerald, width: 1.5),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Buttons row
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () =>
                                    Navigator.of(ctx).pop(false),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  side: BorderSide(
                                      color: Colors.grey.shade300),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                ),
                                child: Text(
                                  'Batal',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (passwordController.text.trim() ==
                                      correctPassword) {
                                    Navigator.of(ctx).pop(true);
                                  } else {
                                    ScaffoldMessenger.of(ctx).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Kata laluan salah!',
                                          style: GoogleFonts.poppins(),
                                        ),
                                        backgroundColor: Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kEmerald,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                ),
                                child: Text(
                                  'Sahkan',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );

    if (confirmed == true) {
      await _uploadFile();
    }
  }

  Future<void> _uploadFile() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Sedang memuat naik dan memproses data...';
      _isSuccess = false;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${MyConfig.apiUrl}/upload_excel.php'),
      );

      request.fields['tingkatan'] = _selectedTingkatan;
      request.files.add(
        http.MultipartFile.fromBytes(
          'excel_file',
          _fileBytes!,
          filename: _fileName!,
        ),
      );

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var data = jsonDecode(responseBody);

      setState(() {
        _isLoading = false;
        if (data['success'] == true) {
          _isSuccess = true;
          _statusMessage =
              '✅ ${data['message']}\n\nJumlah rekod: ${data['total_records']}\nKelas diproses: ${(data['sheets_processed'] as List).join(', ')}';
        } else {
          _isSuccess = false;
          _statusMessage = '❌ ${data['message']}';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isSuccess = false;
        _statusMessage = '❌ Ralat: ${e.toString()}';
      });
    }
  }

  void _printPage() {
    html.window.print();
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final name = args?['name'] ?? '';
    final password = args?['password'] ?? 'pentadbir123'; // fallback password

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
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Kemaskini Data',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                        Text(
                          'Muat Naik Fail Excel',
                          style: GoogleFonts.poppins(
                            color: kEmeraldLight.withOpacity(0.85),
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // PDF button
                  Tooltip(
                    message: 'Muat Turun / Cetak PDF',
                    child: InkWell(
                      onTap: _printPage,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.3)),
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

                  // Name badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_rounded,
                            color: kEmeraldLight, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          name,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kEmeraldDeep, kEmerald],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: kEmerald.withOpacity(0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.upload_file_rounded,
                        color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Muatnaik Data Pelajar',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pilih fail Excel guru dan sistem akan memproses secara automatik ke Looker Studio',
                    style: GoogleFonts.poppins(
                        color: Colors.white70, fontSize: 12, height: 1.5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Tingkatan selector
            Text(
              'Pilih Tingkatan',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: kEmeraldDeep,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _tingkatanButton('4'),
                const SizedBox(width: 12),
                _tingkatanButton('5'),
              ],
            ),

            const SizedBox(height: 28),

            // File picker
            Text(
              'Pilih Fail Excel',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: kEmeraldDeep,
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickFile,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _fileBytes != null
                        ? kEmerald
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  color: _fileBytes != null
                      ? kEmerald.withOpacity(0.05)
                      : Colors.grey.shade50,
                ),
                child: Column(
                  children: [
                    Icon(
                      _fileBytes != null
                          ? Icons.check_circle_rounded
                          : Icons.cloud_upload_outlined,
                      size: 52,
                      color: _fileBytes != null ? kEmerald : Colors.grey,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _fileBytes != null
                          ? _fileName!
                          : 'Klik untuk pilih fail Excel (.xlsx)',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: _fileBytes != null ? kEmerald : Colors.grey,
                        fontWeight: _fileBytes != null
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                    if (_fileBytes == null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Format: .xlsx atau .xls',
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            if (_fileBytes != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.refresh_rounded, color: kEmerald),
                label: Text(
                  'Tukar Fail',
                  style: GoogleFonts.poppins(color: kEmerald),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kEmerald.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kEmerald.withOpacity(0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: kEmeraldDark, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Panduan Fail Excel',
                        style: GoogleFonts.poppins(
                          color: kEmeraldDeep,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildGuideRow(
                      '• Sheet mesti dinamakan seperti "4 SAB", "4 SO", "4 SU"'),
                  _buildGuideRow(
                      '• Header mesti ada "NAMA PELAJAR", "KELAS"'),
                  _buildGuideRow(
                      '• Kolum subjek: BM, SJ, MATE, BI, PI, SN, ST, SK, GEO, PSV'),
                  _buildGuideRow('• Kolum gred: BM G, SJ G, MATE G, dll.'),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Upload button — now triggers confirmation popup
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed:
                    _isLoading ? null : () => _confirmAndUpload(password),
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.cloud_upload_rounded),
                label: Text(
                  _isLoading
                      ? 'Sedang memproses...'
                      : 'Muat Naik & Proses Data',
                  style: GoogleFonts.poppins(
                      fontSize: 15, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kEmerald,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: kEmerald.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            // Status message
            if (_statusMessage.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isSuccess
                      ? kEmerald.withOpacity(0.08)
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _isSuccess ? kEmerald : Colors.red.shade300,
                  ),
                ),
                child: Text(
                  _statusMessage,
                  style: GoogleFonts.poppins(
                    color: _isSuccess
                        ? kEmeraldDeep
                        : Colors.red.shade700,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        text,
        style:
            GoogleFonts.poppins(fontSize: 12, color: kEmeraldDeep, height: 1.5),
      ),
    );
  }

  Widget _tingkatanButton(String tingkatan) {
    bool isSelected = _selectedTingkatan == tingkatan;
    return GestureDetector(
      onTap: () => setState(() => _selectedTingkatan = tingkatan),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [kEmerald, kEmeraldDark],
                )
              : null,
          color: isSelected ? null : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? kEmerald : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: kEmerald.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Text(
          'Tingkatan $tingkatan',
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}