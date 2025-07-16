<?php
include 'connect.php'; // Pastikan file ini terhubung dengan database

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Methods: GET, POST, PATCH, PUT, DELETE, OPTIONS");
header('Content-Type: application/json');

try {
    // Mendapatkan data dari permintaan POST
    $username = $_POST['username'] ?? null;
    $email = $_POST['email'] ?? null;
    $id_paket = isset($_POST['id_paket']) ? intval($_POST['id_paket']) : null;
    $id_agent = isset($_POST['id_agent']) ? intval($_POST['id_agent']) : null;
    $jumlah_pesanan = isset($_POST['jumlah_pesanan']) ? intval($_POST['jumlah_pesanan']) : null;
    $total_biaya = isset($_POST['total_biaya']) ? intval($_POST['total_biaya']) : null;

    // Validasi data yang diterima
    if (!$username || !$email || !$id_paket || !$id_agent || !$jumlah_pesanan || !$total_biaya) {
        throw new Exception("Semua parameter (username, email, id_paket, id_agent, jumlah_pesanan, total_biaya) wajib diisi.");
    }

    // Query untuk mendapatkan id_user berdasarkan username dan email
    $queryUser = $connect->prepare("SELECT id_user FROM user WHERE username = ? AND email = ?");
    $queryUser->bind_param("ss", $username, $email);
    $queryUser->execute();
    $resultUser = $queryUser->get_result();

    if ($resultUser->num_rows === 0) {
        throw new Exception("User tidak ditemukan.");
    }

    $user = $resultUser->fetch_assoc();
    $id_user = intval($user['id_user']);

    // Query untuk memasukkan data pesanan ke tabel pesanan
    $status_pembayaran = "UNPAID";
    $status_pengerjaan = "Menunggu Pembayaran";
    $tanggal_dibuat = date("j F Y");

    $queryInsert = $connect->prepare(
        "INSERT INTO pesanan (id_user, id_agent, id_paket, jumlah_pesanan, total_biaya, status_pembayaran, status_pengerjaan, tanggal_dibuat, tanggal_selesai) 
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, NULL)"
    );
    $queryInsert->bind_param(
        "iiiiisss",
        $id_user,
        $id_agent,
        $id_paket,
        $jumlah_pesanan,
        $total_biaya,
        $status_pembayaran,
        $status_pengerjaan,
        $tanggal_dibuat
    );

    if ($queryInsert->execute()) {
        echo json_encode([
            'status' => 'success',
            'message' => 'Pesanan berhasil dibuat.'
        ]);
    } else {
        throw new Exception("Gagal membuat pesanan. Silakan coba lagi.");
    }
} catch (Exception $e) {
    // Mengembalikan error jika terjadi masalah
    echo json_encode([
        'status' => 'error',
        'message' => $e->getMessage()
    ]);
}

$connect->close();
