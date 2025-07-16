<?php
include 'connect.php'; // Pastikan file ini terhubung dengan database

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Methods: GET, POST, PATCH, PUT, DELETE, OPTIONS");
header('Content-Type: application/json');

try {
    // Mendapatkan parameter username dan email dari request POST
    $username = $_POST['username'] ?? null;
    $email = $_POST['email'] ?? null;

    if (!$username || !$email) {
        throw new Exception("Parameter 'username' atau 'email' tidak ditemukan.");
    }

    // Query untuk mengambil data transaksi berdasarkan user tertentu
    $query = $connect->prepare("
        SELECT 
            pesanan.id_pesanan,
            paket.nama_paket,
            paket.game,
            agent.nama AS nama_agen,
            pesanan.jumlah_pesanan,
            pesanan.tanggal_dibuat,
            pesanan.status_pengerjaan,
            pesanan.total_biaya
        FROM 
            pesanan
        INNER JOIN 
            user ON pesanan.id_user = user.id_user
        INNER JOIN 
            agent ON pesanan.id_agent = agent.id_agent
        INNER JOIN 
            paket ON pesanan.id_paket = paket.id_paket
        WHERE 
            user.username = ? AND user.email = ?
        ORDER BY 
            pesanan.tanggal_dibuat DESC
    ");
    $query->bind_param("ss", $username, $email);
    $query->execute();

    $result = $query->get_result();
    $transaksiList = [];

    // Menyusun hasil query ke dalam array
    while ($row = $result->fetch_assoc()) {
        $transaksiList[] = $row;
    }

    // Mengembalikan data dalam format JSON
    if (empty($transaksiList)) {
        echo json_encode(['status' => 'empty', 'message' => 'Tidak ada transaksi ditemukan.']);
    } else {
        echo json_encode($transaksiList);
    }
} catch (Exception $e) {
    // Mengembalikan error jika terjadi masalah
    echo json_encode([
        'status' => 'error',
        'message' => $e->getMessage()
    ]);
}

$connect->close();
