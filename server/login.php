<?php
// Allow Flutter Web requests
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {

    // Handle both JSON and form POST
    $input = json_decode(file_get_contents('php://input'), true);
    $email = isset($input['email']) ? $input['email'] : (isset($_POST['email']) ? $_POST['email'] : null);
    $password = isset($input['password']) ? $input['password'] : (isset($_POST['password']) ? $_POST['password'] : null);

    if (!$email || !$password) {
        $response = array('success' => false, 'message' => 'Bad Request');
        sendJsonResponse($response);
        exit();
    }

    $password = md5($password);

    $sql = "SELECT * FROM users WHERE email = '$email' AND password = '$password'";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        $userdata = array();
        while ($row = $result->fetch_assoc()) {
            $userdata[] = $row;
        }
        $response = array('success' => true, 'message' => 'Login successful', 'data' => $userdata);
        sendJsonResponse($response);
    } else {
        $response = array('success' => false, 'message' => 'Invalid email or password', 'data' => null);
        sendJsonResponse($response);
    }

} else {
    $response = array('success' => false, 'message' => 'Method Not Allowed');
    sendJsonResponse($response);
    exit();
}

function sendJsonResponse($sentArray) {
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>