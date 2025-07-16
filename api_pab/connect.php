<?php
$connect = new mysqli('localhost','root','','rakungames');
if($connect->connect_error){
    die('Connection Failed : '.$connect->connect_error);
}
?>