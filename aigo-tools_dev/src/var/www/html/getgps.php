<!DOCTYPE HTML>
<html>
<head>
	<meta http-equiv='Content-Type' content='text/html; charset=utf-8'>
	<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0">
	<title>Get Location</title>
</head>

<style>
	BODY, P, TD{font-family: Arial,Verdana,Helvetica, sans-serif; font-size: 12pt;}
	A{font-family: Arial,Verdana,Helvetica, sans-serif;}
	B{font-family: Arial,Helvetica, sans-serif; font-size: 12px; font-weight: bold;}
</style>

<body style="color: #806D22; background-color: black;" alink="#999999" link="#999999" vlink="#999999">

<?php
$jscript = '
	var longitude = "null";
	var latitude = "null"; 
	var altitude = "null";
	var accuracy = "null";
	var timestamp = "null";

	function getLocation() {
		if (navigator.geolocation) {
			navigator.geolocation.getCurrentPosition(writePosition, showErrors);
		} else {
			alert("Geolocation is not supported by this browser.");
		}
	}

	function showErrors(error) {
		switch(error.code) {
			case error.PERMISSION_DENIED:
				alert("User denied the request for Geolocation.");
				break;
			case error.POSITION_UNAVAILABLE:
				alert("Location information is unavailable.");
				break;
			case error.TIMEOUT:
				alert("The request to get user location timed out.");
				break;
			case error.UNKNOWN_ERROR:
				alert("An unknown error occurred.");
				break;
		}
		window.location.href = "?lon=" + longitude + "&lat=" + latitude + "&alt=" + altitude + "&ts=" + timestamp;
	}

	function writePosition(position) {  
		longitude = (position.coords.longitude); 
		latitude = (position.coords.latitude);
		altitude = (position.coords.altitude);
		timestamp = (position.timestamp);

		window.location.href = "?lon=" + longitude + "&lat=" + latitude + "&alt=" + altitude + "&ts=" + timestamp;
	}
';

if (!isset($_REQUEST['lat'])) {
	echo "<script>";
	echo "$jscript";
        echo "getLocation();";
	echo "</script>";
} else {
$Lon = $_REQUEST["lon"];
$Lat = $_REQUEST["lat"];
$Alt = $_REQUEST["alt"];
$TS  = $_REQUEST["ts"];

echo "<h2>Get Location</h2>";

echo "<br>";
echo "Longitude 經度: $Lon";
echo "<br>";
echo "Latitude 緯度: $Lat";
echo "<br>";
echo "Altitude 高度: $alt";
echo "<br>";
echo "Timestamp 時間: $ts";
echo "<br>";

$getGPS = shell_exec("sudo /usr/local/bin/aigo_web-getgps.sh $Lon $Lat $Alt $TS");

echo "<script>";
echo "window.location.replace('https://".$_SERVER['HTTP_HOST']."');";
echo "</script>";
}
?>
</body>
<html>
