<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json");
error_reporting(0);

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once 'vendor/autoload.php';

// =====================
// FUNCTIONS
// =====================
function calculateMataGred($gred) {
    $map = [
        'A+'  => 0, 'A' => 1, 'A-' => 2,
        'B+'  => 3, 'B' => 4,
        'C+'  => 5, 'C' => 6,
        'D'   => 7, 'E' => 8,
        'G'   => 9, 'TH' => 10,
    ];
    return isset($map[strtoupper(trim($gred))]) ? $map[strtoupper(trim($gred))] : '';
}

function detectJantina($nama) {
    $nama_upper = strtoupper(trim($nama));
    if (strpos($nama_upper, 'BINTI') !== false || strpos($nama_upper, 'A/P') !== false) {
        return 'Perempuan';
    } elseif (strpos($nama_upper, 'BIN') !== false || strpos($nama_upper, 'A/L') !== false) {
        return 'Lelaki';
    }
    return 'Tidak Dikenalpasti';
}

// =====================
// GET TINGKATAN
// =====================
$tingkatan = isset($_POST['tingkatan']) ? $_POST['tingkatan'] : '4';

// =====================
// CONFIGURATION
// =====================
$SPREADSHEET_ID = '1J64YnKNoeuB046KvutUwDu_2wIQE8tt1rqo56Z9vErw';
$CREDENTIALS_FILE = __DIR__ . '/credentials.json';
$SHEET_NAME = ($tingkatan == '5') ? 'DataT5' : 'DataT4';

// Subjects mapping
$SUBJECTS = [
    'BM'   => ['code' => 'BM',   'name' => 'BAHASA MELAYU'],
    'SJ'   => ['code' => 'SJ',   'name' => 'SEJARAH'],
    'MATE' => ['code' => 'MATE', 'name' => 'MATEMATIK'],
    'BI'   => ['code' => 'BI',   'name' => 'BAHASA INGGERIS'],
    'PI'   => ['code' => 'PI',   'name' => 'PENDIDIKAN ISLAM'],
    'SN'   => ['code' => 'SN',   'name' => 'SAINS'],
    'ST'   => ['code' => 'ST',   'name' => 'SAINS TAMBAHAN'],
    'SK'   => ['code' => 'SK',   'name' => 'SAINS KOMPUTER'],
    'GEO'  => ['code' => 'GEO',  'name' => 'GEOGRAFI'],
    'PSV'  => ['code' => 'PSV',  'name' => 'PENDIDIKAN SENI VISUAL'],
    'PM'   => ['code' => 'PM',   'name' => 'PENDIDIKAN MORAL'],
    'PJPK' => ['code' => 'PJPK', 'name' => 'PENDIDIKAN JASMANI'],
];

// =====================
// CHECK FILE UPLOADED
// =====================
if (!isset($_FILES['excel_file'])) {
    echo json_encode(['success' => false, 'message' => 'No file uploaded']);
    exit();
}

$file = $_FILES['excel_file'];
$tmp_path = sys_get_temp_dir() . '/' . uniqid() . '.xlsx';
move_uploaded_file($file['tmp_name'], $tmp_path);

// =====================
// READ EXCEL FILE
// =====================
try {
    $spreadsheet = \PhpOffice\PhpSpreadsheet\IOFactory::load($tmp_path);
} catch (Exception $e) {
    echo json_encode(['success' => false, 'message' => 'Cannot read Excel file: ' . $e->getMessage()]);
    exit();
}

// =====================
// TRANSFORM DATA
// =====================
$all_records = [];
$sheets_to_process = [];

foreach ($spreadsheet->getSheetNames() as $sheet_name) {
    if (preg_match('/^\d\s+\w+$/', trim($sheet_name))) {
        $sheets_to_process[] = $sheet_name;
    }
}

if (empty($sheets_to_process)) {
    echo json_encode(['success' => false, 'message' => 'No class sheets found. Make sure sheet names are like "4 SAB", "4 SO", etc.']);
    exit();
}

foreach ($sheets_to_process as $sheet_name) {
    $sheet = $spreadsheet->getSheetByName($sheet_name);
    $rows = $sheet->toArray(null, true, true, false);

    // Find header row
    $header_row_index = -1;
    $headers = [];

    foreach ($rows as $i => $row) {
        foreach ($row as $cell) {
            if (stripos((string)$cell, 'NAMA') !== false && stripos((string)$cell, 'PELAJAR') !== false) {
                $header_row_index = $i;
                $headers = $row;
                break 2;
            }
        }
    }

    if ($header_row_index === -1) continue;

    // Map column indexes
    $col_map = [];
    foreach ($headers as $col_idx => $header) {
        $col_map[strtoupper(trim((string)$header))] = $col_idx;
    }

    // Process data rows
    for ($i = $header_row_index + 1; $i < count($rows); $i++) {
        $row = $rows[$i];

        $nama_key = isset($col_map['NAMA PELAJAR']) ? $col_map['NAMA PELAJAR'] : null;
        if ($nama_key === null) continue;

        $nama = trim((string)$row[$nama_key]);
        if (empty($nama)) continue;

        // Get student info
        $kelas         = isset($col_map['KELAS']) ? trim((string)$row[$col_map['KELAS']]) : $sheet_name;
        $jumlah_markah = isset($col_map['JUM MARKAH']) ? $row[$col_map['JUM MARKAH']] : '';
        $purata        = isset($col_map['PURATA %']) ? $row[$col_map['PURATA %']] : '';
        $gp            = isset($col_map['GP']) ? $row[$col_map['GP']] : '';
        $keputusan     = isset($col_map['KEPUTUSAN']) ? trim((string)$row[$col_map['KEPUTUSAN']]) : '';

        // Detect jantina from name
        $jantina = detectJantina($nama);

        // Status murid from Excel KEPUTUSAN column
        $status_murid = $keputusan;

        // For each subject
        foreach ($SUBJECTS as $subj_col => $subj_info) {
            $grade_col  = $subj_col . ' G';
            $markah_idx = isset($col_map[$subj_col]) ? $col_map[$subj_col] : null;
            $gred_idx   = isset($col_map[$grade_col]) ? $col_map[$grade_col] : null;

            if ($markah_idx === null || $gred_idx === null) continue;

            $markah = $row[$markah_idx];
            $gred   = trim((string)$row[$gred_idx]);

            if (empty($markah) && empty($gred)) continue;

            $mata_gred = calculateMataGred($gred);

            // ✅ Now includes Jumlah_Markah, Purata_Peratus, Gred_Purata_Murid
            $all_records[] = [
                $nama,
                $jantina,
                $tingkatan,
                $kelas,
                $subj_info['code'],
                $markah,
                $gred,
                $mata_gred,
                $status_murid,
                $jumlah_markah,   // col J
                $purata,          // col K
                $gp,              // col L
            ];
        }
    }
}

if (empty($all_records)) {
    echo json_encode(['success' => false, 'message' => 'No data found in Excel file']);
    exit();
}

// =====================
// UPLOAD TO GOOGLE SHEETS
// =====================
try {
    $client = new Google\Client();
    $client->setAuthConfig($CREDENTIALS_FILE);
    $client->addScope(Google\Service\Sheets::SPREADSHEETS);

    $service = new Google\Service\Sheets($client);

    $header = [
        'Nama', 'Jantina', 'Tingkatan', 'Kelas', 'Subjek',
        'Markah', 'Gred', 'Mata_Gred_Num', 'Status_Murid',
        'Jumlah_Markah', 'Purata_Peratus', 'Gred_Purata_Murid'
    ];

    $values = array_merge([$header], $all_records);
    $body   = new Google\Service\Sheets\ValueRange(['values' => $values]);
    $params = ['valueInputOption' => 'RAW'];

    // =====================
    // STEP 1: Update DataT4 or DataT5 with uploaded data
    // =====================
    $service->spreadsheets_values->clear(
        $SPREADSHEET_ID,
        $SHEET_NAME . '!A:Z',
        new Google\Service\Sheets\ClearValuesRequest()
    );

    $service->spreadsheets_values->update(
        $SPREADSHEET_ID,
        $SHEET_NAME . '!A1',
        $body,
        $params
    );

    // =====================
    // STEP 2: Read the OTHER sheet's current data from Google Sheets
    // =====================
    $OTHER_SHEET_NAME = ($SHEET_NAME === 'DataT4') ? 'DataT5' : 'DataT4';

    $otherResponse = $service->spreadsheets_values->get(
        $SPREADSHEET_ID,
        $OTHER_SHEET_NAME . '!A:L'
    );
    $otherValues = $otherResponse->getValues() ?? [];

    // Remove the header row from the other sheet (first row)
    $otherDataRows = [];
    if (!empty($otherValues)) {
        array_shift($otherValues); // Remove header
        $otherDataRows = $otherValues;
    }

    // =====================
    // STEP 3: Merge uploaded data + other sheet data
    // =====================
    // $all_records = new data from uploaded Excel (no header)
    // $otherDataRows = existing data from the other sheet (no header)
    $mergedRecords = array_merge($all_records, $otherDataRows);

    // =====================
    // STEP 4: Write merged data to DataAll (raw values, no formula)
    // =====================
    $mergedValues = array_merge([$header], $mergedRecords);
    $mergedBody   = new Google\Service\Sheets\ValueRange(['values' => $mergedValues]);

    // Clear DataAll
    $service->spreadsheets_values->clear(
        $SPREADSHEET_ID,
        'DataAll!A:Z',
        new Google\Service\Sheets\ClearValuesRequest()
    );

    // Write merged data to DataAll
    $service->spreadsheets_values->update(
        $SPREADSHEET_ID,
        'DataAll!A1',
        $mergedBody,
        ['valueInputOption' => 'RAW']
    );

    unlink($tmp_path);

    echo json_encode([
        'success'          => true,
        'message'          => "Data berjaya dimuatnaik ke $SHEET_NAME dan DataAll dikemaskini!",
        'total_records'    => count($all_records),
        'other_sheet_records' => count($otherDataRows),
        'dataall_total'    => count($mergedRecords),
        'sheets_processed' => $sheets_to_process,
    ]);

} catch (Exception $e) {
    echo json_encode(['success' => false, 'message' => 'Google Sheets error: ' . $e->getMessage()]);
}
?>