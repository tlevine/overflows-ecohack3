<?php

define('WUNDERGROUND_API_KEY', 'e9e74e882dede7ed');

// Get lat and lon.
$lat = isset($_GET['lat']) ? (float) $_GET['lat']:NULL;
$lon = isset($_GET['lon']) ? (float) $_GET['lon']:NULL;

if (isset($lat) && isset($lon)) {
  // Pass-through, deny from alternative IPs.
  $url = "http://api.wunderground.com/weather/api/" . WUNDERGROUND_API_KEY . "/geolookup/conditions/q/" . $lat . "," . $lon . ".json?" . $_SERVER['QUERY_STRING'];

  // These might need to change.
  header('Cache-control:no-cache, must-revalidate, no-cache="Set-Cookie", private');
  header('Connection:close');
  header('Content-Type:application/json; charset=UTF-8');
  header('Expires:Fri, 01 Jan 1990 00:00:00 GMT');
  header('Pragma:no-cache');
  header('Access-Control-Allow-Origin: http://dontflush.me');

  echo file_get_contents($url);
}
