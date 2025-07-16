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
	$password = $_POST['password'];

	if (!$username || !$email || !$password) {
		throw new Exception("Parameter 'username', 'email', atau 'password' tidak ditemukan.");
	}

	// Query untuk memperbarui data user
	$query = $connect->prepare("UPDATE user SET username = ?, email = ?, pass = ? WHERE email = ?");
	$query->bind_param("ssss", $username, $email, $password, $email);
	$query->execute();

	if ($query->affected_rows > 0) {
		echo json_encode([
			'status' => 'success',
			'message' => 'Data user berhasil diperbarui.',
			'username' => $username,
			'email' => $email
		]);
	} else {
		echo json_encode([
			'status' => 'error',
			'message' => 'Gagal memperbarui data user atau tidak ada perubahan.'
		]);
	}
} catch (Exception $e) {
	echo json_encode([
		'status' => 'error',
		'message' => $e->getMessage()
	]);
}

$connect->close();
