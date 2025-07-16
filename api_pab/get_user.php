<?php
include 'connect.php'; // File untuk koneksi database

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Methods: POST");
header('Content-Type: application/json');

try {
	// Mendapatkan data POST
	$username = $_POST['username'];
	$email = $_POST['email'];

	if (!$username || !$email) {
		throw new Exception("Parameter 'username' atau 'email' tidak ditemukan.");
	}

	// Query untuk mendapatkan data user berdasarkan username dan email
	$query = $connect->prepare("SELECT username, email, pass FROM user WHERE username = ? AND email = ?");
	$query->bind_param("ss", $username, $email);
	$query->execute();

	$result = $query->get_result();
	if ($result->num_rows > 0) {
		$data = $result->fetch_assoc();
		echo json_encode([
			'status' => 'success',
			'data' => $data
		]);
	} else {
		echo json_encode([
			'status' => 'error',
			'message' => 'User tidak ditemukan.'
		]);
	}
} catch (Exception $e) {
	echo json_encode([
		'status' => 'error',
		'message' => $e->getMessage()
	]);
}

$connect->close();
