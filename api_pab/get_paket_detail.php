<?php
include 'connect.php';

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Methods: GET, POST, PATCH, PUT, DELETE, OPTIONS");
header('Content-Type: application/json');

// Periksa apakah ID Paket dikirim
if (isset($_POST['id_paket'])) {
    $id_paket = $_POST['id_paket'];

    // Query untuk mengambil detail paket berdasarkan ID
    $query = $connect->prepare("SELECT * FROM paket WHERE id_paket = ?");
    $query->bind_param("s", $id_paket);
    $query->execute();

    $result = $query->get_result();

    if ($result->num_rows > 0) {
        $paket = $result->fetch_assoc();
        echo json_encode($paket); // Kirim data paket sebagai JSON
    } else {
        echo json_encode(["error" => "Detail paket tidak ditemukan"]);
    }
} else {
    echo json_encode(["error" => "ID Paket tidak diberikan"]);
}
