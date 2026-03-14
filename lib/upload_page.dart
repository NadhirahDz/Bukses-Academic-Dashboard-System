import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
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

  Future<void> _uploadFile() async {
    if (_fileBytes == null) {
      setState(() {
        _statusMessage = 'Sila pilih fail Excel terlebih dahulu!';
        _isSuccess = false;
      });
      return;
    }

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

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final name = args?['name'] ?? '';
    final role = args?['role'] ?? '';

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF0e9f6e)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kemaskini Data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Muatnaik Fail Excel',
              style: TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  name,
                  style: const TextStyle(fontSize: 13, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF0e9f6e)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.upload_file, color: Colors.white, size: 40),
                  SizedBox(height: 12),
                  Text(
                    'Muatnaik Data Pelajar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Pilih fail Excel guru dan sistem akan memproses secara automatik ke Looker Studio',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tingkatan selector
            const Text(
              'Pilih Tingkatan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _tingkatanButton('4'),
                const SizedBox(width: 12),
                _tingkatanButton('5'),
              ],
            ),

            const SizedBox(height: 24),

            // File picker area
            const Text(
              'Pilih Fail Excel',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _fileBytes != null
                        ? const Color(0xFF0e9f6e)
                        : Colors.grey.shade300,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: _fileBytes != null
                      ? const Color(0xFF0e9f6e).withOpacity(0.05)
                      : Colors.grey.shade50,
                ),
                child: Column(
                  children: [
                    Icon(
                      _fileBytes != null
                          ? Icons.check_circle
                          : Icons.cloud_upload_outlined,
                      size: 48,
                      color: _fileBytes != null
                          ? const Color(0xFF0e9f6e)
                          : Colors.grey,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _fileBytes != null
                          ? _fileName!
                          : 'Klik untuk pilih fail Excel (.xlsx)',
                      style: TextStyle(
                        fontSize: 14,
                        color: _fileBytes != null
                            ? const Color(0xFF0e9f6e)
                            : Colors.grey,
                        fontWeight: _fileBytes != null
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    if (_fileBytes == null) ...[
                      const SizedBox(height: 4),
                      const Text(
                        'Format: .xlsx atau .xls',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Change file button
            if (_fileBytes != null)
              TextButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.refresh),
                label: const Text('Tukar Fail'),
              ),

            const SizedBox(height: 24),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.blue.shade700, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Panduan Fail Excel',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('• Sheet mesti dinamakan seperti "4 SAB", "4 SO", "4 SU"',
                      style: TextStyle(fontSize: 13)),
                  const Text('• Header mesti ada "NAMA PELAJAR", "KELAS"',
                      style: TextStyle(fontSize: 13)),
                  const Text('• Kolum subjek: BM, SJ, MATE, BI, PI, SN, ST, SK, GEO, PSV',
                      style: TextStyle(fontSize: 13)),
                  const Text('• Kolum gred: BM G, SJ G, MATE G, dll.',
                      style: TextStyle(fontSize: 13)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Upload button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _uploadFile,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.cloud_upload),
                label: Text(
                  _isLoading ? 'Sedang memproses...' : 'Muat Naik & Proses Data',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
                      ? const Color(0xFF0e9f6e).withOpacity(0.1)
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isSuccess
                        ? const Color(0xFF0e9f6e)
                        : Colors.red.shade300,
                  ),
                ),
                child: Text(
                  _statusMessage,
                  style: TextStyle(
                    color: _isSuccess
                        ? const Color(0xFF0e9f6e)
                        : Colors.red.shade700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tingkatanButton(String tingkatan) {
    bool isSelected = _selectedTingkatan == tingkatan;
    return GestureDetector(
      onTap: () => setState(() => _selectedTingkatan = tingkatan),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1565C0) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF1565C0) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          'Tingkatan $tingkatan',
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}