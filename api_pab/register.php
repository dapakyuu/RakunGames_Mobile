<?php
include 'connect.php';

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Methods: GET, POST, PATCH, PUT, DELETE, OPTIONS");

$username = $_POST['username'];
$email = $_POST['email'];
$password = $_POST['password'];

$query = "INSERT INTO user (username, email, pass) VALUES (?, ?, ?)";
$stmt = $connect->prepare($query);
$stmt->bind_param("sss", $username, $email, $password);

$response = [];
if ($stmt->execute()) {
    $response['success'] = true;
} else {
    $response['success'] = false;
}
echo json_encode($response);

$stmt->close();
$connect->close();
