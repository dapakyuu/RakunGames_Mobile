<?php
include 'connect.php';

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header('Content-Type: application/json');

try {
    $idPesanan = $_POST['id_pesanan'];

    if (!$idPesanan) {
        throw new Exception("Parameter 'id_pesanan' tidak ditemukan.");
    }

    $query = $connect->prepare("DELETE FROM pesanan WHERE id_pesanan = ?");
    $query->bind_param("i", $idPesanan);

    if ($query->execute()) {
        echo json_encode(['status' => 'success', 'message' => 'Pesanan berhasil dihapus.']);
    } else {
        throw new Exception("Gagal menghapus pesanan.");
    }
} catch (Exception $e) {
    echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
}

$connect->close();
