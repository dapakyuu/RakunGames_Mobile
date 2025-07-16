<?php
include 'connect.php'; // Pastikan file ini terhubung dengan database

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Methods: GET, POST, PATCH, PUT, DELETE, OPTIONS");
header('Content-Type: application/json');

try {
    // Mendapatkan nilai 'id_pesanan' dari permintaan POST
    $id_pesanan = $_POST['id_pesanan'];

    if (!$id_pesanan) {
        throw new Exception("Parameter 'id_pesanan' tidak ditemukan.");
    }

    // Query untuk memeriksa ulasan berdasarkan id_pesanan
    $query = $connect->prepare("SELECT id_ulasan, rating, ulasan FROM ulasan WHERE id_pesanan = ?");
    $query->bind_param("i", $id_pesanan);
    $query->execute();

    $result = $query->get_result();
    $ulasanData = [];

    if ($row = $result->fetch_assoc()) {
        $ulasanData = $row;
        echo json_encode([
            'status' => 'success',
            'exists' => true,
            'data' => $ulasanData
        ]);
    } else {
        echo json_encode([
            'status' => 'success',
            'exists' => false,
            'data' => null
        ]);
    }
} catch (Exception $e) {
    echo json_encode([
        'status' => 'error',
        'message' => $e->getMessage()
    ]);
}

$connect->close();
