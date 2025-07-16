<?php
include 'connect.php';

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Methods: GET, POST, PATCH, PUT, DELETE, OPTIONS");
header('Content-Type: application/json');

$game = $_POST['game'];

$query = $connect->prepare("SELECT * FROM paket WHERE game = ?");
$query->bind_param("s", $game);
$query->execute();

$result = $query->get_result();
$paketList = [];

while ($row = $result->fetch_assoc()) {
    $paketList[] = $row;
}

echo json_encode($paketList);
