<?php
include 'connect.php'; // Pastikan file ini terhubung dengan database

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Methods: GET, POST, PATCH, PUT, DELETE, OPTIONS");
header('Content-Type: application/json');

try {
	// Mendapatkan data dari permintaan POST
	$id_pesanan = intval($_POST['id_pesanan']);
	$rating = $_POST['rating'];
	$ulasan = $_POST['ulasan'];

	// Periksa apakah nilai yang diperlukan ada
	if (!$id_pesanan || !$rating || !$ulasan) {
		throw new Exception("Semua parameter (id_pesanan, rating, ulasan) wajib diisi.");
	}

	// Query untuk menyisipkan ulasan ke dalam tabel
	$query = $connect->prepare("INSERT INTO ulasan (id_pesanan, rating, ulasan) VALUES (?, ?, ?)");
	$query->bind_param("iis", $id_pesanan, $rating, $ulasan);
	$query->execute();

	if ($query->affected_rows > 0) {
		echo json_encode([
			'status' => 'success',
			'message' => 'Ulasan berhasil disimpan.'
		]);
	} else {
		throw new Exception("Gagal menyimpan ulasan.");
	}
} catch (Exception $e) {
	echo json_encode([
		'status' => 'error',
		'message' => $e->getMessage()
	]);
}

$connect->close();
