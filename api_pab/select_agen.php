<?php
include 'connect.php'; // Pastikan file ini terhubung dengan database

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Methods: GET, POST, PATCH, PUT, DELETE, OPTIONS");
header('Content-Type: application/json');

try {
    // Mendapatkan nilai 'game' dari permintaan POST
    $game = $_POST['game'];

    if (!$game) {
        throw new Exception("Parameter 'game' tidak ditemukan.");
    }

    // Query untuk mengambil semua kolom dari tabel agent jika game yang dicari adalah salah satu dari daftar game yang dimainkan
    $query = $connect->prepare("SELECT * FROM agent WHERE game LIKE ?");
    $searchTerm = "%$game%";
    $query->bind_param("s", $searchTerm);
    $query->execute();

    $result = $query->get_result();
    $agenList = [];

    // Menyusun hasil query ke dalam array
    while ($row = $result->fetch_assoc()) {
        $agenList[] = $row;
    }

    // Mengembalikan data dalam format JSON
    echo json_encode($agenList);
} catch (Exception $e) {
    // Mengembalikan error jika terjadi masalah
    echo json_encode([
        'status' => 'error',
        'message' => $e->getMessage()
    ]);
}

$connect->close();
