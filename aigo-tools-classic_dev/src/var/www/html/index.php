<!DOCTYPE HTML>
<html>
<head>
	<meta http-equiv='Content-Type' content='text/html; charset=utf-8'>
	<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0">
	<title>AiGO Home Page</title>
</head>

<style>
	<!-- BODY, P, TD{font-family: Arial,Verdana,Helvetica, sans-serif; font-size: 12pt;} -->
	<!-- A{font-family: Arial,Verdana,Helvetica, sans-serif;} -->
	<!-- B{font-family: Arial,Helvetica, sans-serif; font-size: 12px; font-weight: bold;} -->
</style>

<script>
<!-- get server time: Ref. https://stackoverflow.com/questions/20269657/right-way-to-get-web-server-time-and-display-it-on-web-pages -->
function get_servertime() {
	try {
		//FF, Opera, Safari, Chrome
		xmlHttp = new XMLHttpRequest();
	}
	catch (err1) {
		//IE
		try {
			xmlHttp = new ActiveXObject('Msxml2.XMLHTTP');
		}
		catch (err2) {
			try {
				xmlHttp = new ActiveXObject('Microsoft.XMLHTTP');
			}
			catch (eerr3) {
				//AJAX not supported, use CPU time.
				alert("AJAX not supported");
			}
			}
	}
	xmlHttp.open('HEAD',window.location.href.toString(),false);
	xmlHttp.setRequestHeader("Content-Type", "text/html");
	xmlHttp.send('');
	return xmlHttp.getResponseHeader("Date");
}

function show_delaysec() {
	var refresh=1000; // Refresh rate in milli seconds
	mytime=setTimeout('show_servertime()',refresh)
}

function show_servertime() {
	var strcount;
	var st = get_servertime();
	var x = new Date(st); //new Date()
	document.getElementById('ct').innerHTML = x;
	tt=show_delaysec();
}
</script>

<?php
function redirectTohttps() {
	if($_SERVER['HTTPS'] != 'on') {
		$redirect= "https://".$_SERVER['HTTP_HOST'].$_SERVER['REQUEST_URI'];
		header("Location: $redirect");
	 }
}

redirectTohttps();

//$fcolor = '#FFDA44';
$fcolor = '#806D22';
$bcolor = '#806D22';

$longitude = "null";
$latitude = "null";
$altitude = "null";
$timestamp = "null";

echo "
<body style='color: $fcolor; background-color: black;' alink='#999999' link='#999999' vlink='#999999' onload='show_servertime()'>
";


if (file_exists("/home/aigo/gps.txt")) {
	$gpsfile = fopen("/home/aigo/gps.txt", "r") or die ("Unable to open file!");
	$longitude = str_replace(array("\r", "\n", "\r\n", "\n\r"), '', explode("=", fgets($gpsfile))[1]);
	$latitude = str_replace(array("\r", "\n", "\r\n", "\n\r"), '', explode("=", fgets($gpsfile))[1]);
	$altitude = str_replace(array("\r", "\n", "\r\n", "\n\r"), '', explode("=", fgets($gpsfile))[1]);
	$timestamp = str_replace(array("\r", "\n", "\r\n", "\n\r"), '', explode("=", fgets($gpsfile))[1]);
	$timezone = str_replace(array("\r", "\n", "\r\n", "\n\r"), '', explode("=", fgets($gpsfile))[1]);
	fclose($gpsfile);
}

// tab = &ensp;
echo "	<table style='background-color: #202020;' align=center>
		<tr>
		<td colspan='2'><div id='ct'></div></td>
		</tr>
		<tr>
		<th colspan='2' style='background-color:$fcolor;'></th>
		</tr>
		<tr>
		<td>Longitude 經度 :</td><td>$longitude</td>
		</tr>
		<tr>
		<td>Latitude 緯度 :</td><td>$latitude</td>
		</tr>
		<tr>
		<td>Altitude 高度 :</td><td>$altitude</td>
		</tr>
		<tr>
		<td>Timestamp 時間 :</td><td>$timestamp<td>
		</tr>
		<tr>
		<td>Timezone 時區 :</td><td>$timezone<td>
		</tr>
	</table>
";

// TODO: sumbmit 'Sync Time' , 'Get GPS' , 'noVNC'

if (isset($_POST['synctime'])) {
	echo "Sync Time";

	echo "
	<script>
		window.location.href = 'synctime.php';
	</script>
	";
} elseif (isset($_POST['getgps'])) {
	echo "Get GPS";

        echo "
	<script>
        	window.location.href = 'getgps.php';
        </script>
	";
} elseif (isset($_POST['novnc'])) {
	echo "noVNC";

	echo "
	<script>
		window.location.href = 'novnc.php';
	</script>
	";
} elseif (isset($_POST['dslrcontrol'])) {
	echo "DSLR Control";

	echo "
	<script>
		window.location.href = '/DSLR_control/index.php';
	</script>
	";
}

echo "	<form method='post' action=''>
		<table border='0' align='center'>
";

echo "			<tr>
			<td colspan='2' align='center'>
			Click button (點擊按鈕)
			</td>
			</tr>
";

echo "			<tr>
			<td>
				<input type='submit' name='synctime' value='Sync Time' style='width:140px; height:40px; font-weight:bold; font-height:bold; color:$fcolor; border:2px $bcolor double; background-color:#202020;' />
			</td>
			<td>
				Sync mobile device or computer time to AiGO.
				<br>
				同步行動裝置或電腦時間到 AiGO
			</td>
			</tr>
";

echo "			<tr>
			<td>
				<input type='submit' name='getgps' value='Get GPS' style='width:140px; height:40px; font-weight:bold; font-height:bold; color:$fcolor; border:2px $bcolor double; background-color:#202020;' />
			</td>
			<td>
				Get mobile device GPS data to AiGO.
				<br>
				取得行動裝置 GPS 資料到 AiGO
			</td>
			</tr>
";

echo "			<tr>
			<td>
				<input type='submit' name='novnc' value='noVNC' style='width:140px; height:40px; font-weight:bold; font-height:bold; color:$fcolor; border:2px $bcolor double; background-color:#202020;' />
			</td>
			<td>
				Operate AiGO Desktop in browser using noVNC.
				<br>
				使用 noVNC 透過瀏覽器來操作 AiGO 桌面
			</td>
			</tr>
";

/* TODO: Coming Soon
echo "			<tr>
			<td>
				<input type='submit' name='dslrcontrol' value='DSLR Control' style='width:140px; height:40px; font-weight:bold; font-height:bold; color:$fcolor; border:2px $bcolor double; background-color:#202020;' />
			</td>
			<td>
				Operate DSLR device in browser.
				<br>
				透過瀏覽器來操作 DSLR 相機
			</td>
			<tr>
";
*/

echo "		</table>
	</form>
";
?>
</body>
</html>
