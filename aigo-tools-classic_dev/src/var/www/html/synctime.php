<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<title>Sync Time</title>
</head>

<body style="color: #806D22; background-color: black;" alink="#999999" link="#999999" vlink="#999999">

<?php
// 504 error: Ref. https://hk.saowen.com/a/ea7c27a5b7ac7d5f047cb175fc9bb31cfae70507938f881eeb067a977161b533
$jscript = '
	var currentTime = new Date();
	var currentTimestamp = Math.floor(currentTime / 1000);
';

if (empty($_REQUEST["client_timestamp"])) {
	echo "<script>";
	echo "$jscript";
	echo "window.location.href = '?client_timestamp=' + currentTimestamp;";
	echo "</script>";
} else {
// Memo: is $_GET or $_REWQUEST

$clientTimestamp = $_REQUEST["client_timestamp"];

// TODO: timezone ?

echo "<h2>Time Synchronization</h2>";

$outTime = shell_exec("sudo /usr/local/bin/aigo_web-synctime.sh $clientTimestamp");

#header("Location: /");
echo "<script>";
echo "window.location.replace('http://".$_SERVER['HTTP_HOST']."');";
echo "</script>";
}
?>

</body>
</html>
