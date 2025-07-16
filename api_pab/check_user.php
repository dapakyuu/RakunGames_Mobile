<?php
include 'connect.php';

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Methods: GET, POST, PATCH, PUT, DELETE, OPTIONS");

$username = $_POST['username'];
$email = $_POST['email'];

$query = "SELECT * FROM user WHERE username = ? OR email = ?";
$stmt = $connect->prepare($query);
$stmt->bind_param("ss", $username, $email);
$stmt->execute();
$result = $stmt->get_result();

$response = [];
if ($result->num_rows > 0) {
    $response['exists'] = true;
} else {
    $response['exists'] = false;
}
echo json_encode($response);

$stmt->close();
$connect->close();
