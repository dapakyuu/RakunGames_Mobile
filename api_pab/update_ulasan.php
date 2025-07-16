<?php
include 'connect.php'; // Pastikan file ini terhubung dengan database

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Methods: GET, POST, PATCH, PUT, DELETE, OPTIONS");
header('Content-Type: application/json');

try {
	// Mendapatkan data dari permintaan POST
	$id_ulasan = $_POST['id_ulasan'];
	$rating = $_POST['rating'];
	$ulasan = $_POST['ulasan'];

	if (!$id_ulasan || !$rating || !$ulasan) {
		throw new Exception("Semua parameter (id_ulasan, rating, ulasan) wajib diisi.");
	}

	// Query untuk memperbarui ulasan berdasarkan id_ulasan
	$query = $connect->prepare("UPDATE ulasan SET rating = ?, ulasan = ? WHERE id_ulasan = ?");
	$query->bind_param("isi", $rating, $ulasan, $id_ulasan);
	$query->execute();

	if ($query->affected_rows > 0) {
		echo json_encode([
			'status' => 'success',
			'message' => 'Ulasan berhasil diperbarui.'
		]);
	} else {
		throw new Exception("Gagal memperbarui ulasan. Mungkin tidak ada perubahan data.");
	}
} catch (Exception $e) {
	echo json_encode([
		'status' => 'error',
		'message' => $e->getMessage()
	]);
}

$connect->close();
