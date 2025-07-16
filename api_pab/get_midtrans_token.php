<?php
ini_set('display_errors', 0);
error_reporting(E_ALL);

include 'connect.php';
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Methods: GET, POST, PATCH, PUT, DELETE, OPTIONS");
header('Content-Type: application/json');

// Check if Midtrans library exists
$midtransPath = 'midtrans-php-master/Midtrans.php';
if (!file_exists($midtransPath)) {
    http_response_code(500);
    exit(json_encode(['error' => 'Midtrans library not found']));
}
require_once $midtransPath;

// Terima data dari request
$data = json_decode(file_get_contents('php://input'), true);
if (!$data) {
    $data = $_POST;
}

$id_pesanan = isset($data['id_pesanan']) ? $data['id_pesanan'] : null;
$total_biaya = isset($data['total_biaya']) ? $data['total_biaya'] : null;
$username = isset($data['username']) ? $data['username'] : null;
$email = isset($data['email']) ? $data['email'] : null;

// Validasi parameter
if (!$id_pesanan || !$total_biaya) {
    http_response_code(400);
    exit(json_encode(['error' => 'Parameter id_pesanan dan total_biaya wajib diisi']));
}

// Ambil data pesanan
$sql = "SELECT p.*, u.username, u.email, pk.nama_paket, u.phone, pk.id_paket
        FROM pesanan p
        JOIN user u ON p.id_user = u.id_user
        JOIN paket pk ON p.id_paket = pk.id_paket
        WHERE p.id_pesanan = ? AND u.username = ? AND u.email = ?";
$stmt = $connect->prepare($sql);
$stmt->bind_param("iss", $id_pesanan, $username, $email);
$stmt->execute();
$pesanan = $stmt->get_result()->fetch_assoc();

if (!$pesanan || !isset($pesanan['id_paket'])) {
    http_response_code(404);
    exit(json_encode(['error' => 'Pesanan tidak ditemukan atau data tidak lengkap']));
}

// Set Midtrans config
\Midtrans\Config::$serverKey = 'SB-Mid-server-uhA-_jSC4dfXrlfIs7F9_fTs';
\Midtrans\Config::$isProduction = false;
\Midtrans\Config::$isSanitized = true;
\Midtrans\Config::$is3ds = true;

$params = array(
    'transaction_details' => array(
        'order_id' => 'RG-' . $id_pesanan,
        'gross_amount' => $total_biaya,
    ),
    'customer_details' => array(
        'first_name' => $pesanan['username'],
        'email' => $pesanan['email'],
        'phone' => $pesanan['phone'],
    ),
    'item_details' => array(
        array(
            'id' => $pesanan['id_paket'],
            'price' => $total_biaya,
            'quantity' => 1,
            'name' => $pesanan['nama_paket']
        )
    )
);

try {
    $snapToken = \Midtrans\Snap::getSnapToken($params);
    echo json_encode(['token' => $snapToken]);
    exit;
} catch (Exception $e) {
    http_response_code(500);
    exit(json_encode(['error' => $e->getMessage()]));
}
