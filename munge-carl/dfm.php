<?php

date_default_timezone_set('America/New_York');

/**
 * @todo Build these as a live API.
 */

$local_read_path = 'data/raw';

$local_write_path = 'data/csv';

$outfile = $local_write_path . '/' . 'precip.csv';

// Read in files.
$remote_path = 'http://dl.dropbox.com/u/2199110/dontflushmedata/wundergrounddata/newtowncreek';

$files = array(
  'greenpoint_20110306.txt',
  'greenpoint_20110307.txt',
  'greenpoint_20110416.txt',
  'greenpoint_20110417.txt',
  'greenpoint_20110517.txt',
  'greenpoint_20110518.txt',
  'greenpoint_20110814.txt',
  'greenpoint_20110815.txt',
  'greenpoint_20110827.txt',
  'greenpoint_20110828.txt',
  'greenpoint_20110906.txt',
  'greenpoint_20110907.txt',
  'greenpoint_20110923.txt',
  'greenpoint_20110924.txt',
  'greenpoint_20111029.txt',
  'greenpoint_20111030.txt',
  'greenpoint_20111122.txt',
  'greenpoint_20111123.txt',
  'greenpoint_20111207.txt',
  'greenpoint_20111208.txt'
);

// Our converted data.
$data = array();

/**
 * precipm
 *   Precipitation, metric (mm).
 * precipi
 *   Precipitation, inches.
 */
$keys = array(
  (object) array(
    'name' => 'precipm',
    'type' => 'float',
    'optional' => FALSE,
    'sprintf' => '%0.1f'
  ),
  (object) array(
    'name' => 'precipi',
    'type' => 'float',
    'optional' => FALSE,
    'sprintf' => '%0.2f'
  ),
);

// Formats for output.
$formats['time'] = '%s';
foreach ($keys as $key) {
  $formats[$key->name] = $key->sprintf;
}

foreach ($files as $file) {
  $local = $local_read_path . '/' . $file;
  // Grab files from remote location if they don't currently exist.
  if (!file_exists($local)) {
    $command = "wget " . $remote_path . '/'. $file . " -O " . $local;
    system($command);
  }

  // This should have pulled our local file.
  if (!file_exists($local)) {
    die('File does not exist: ' . $local);
  }

  // For each local file, read-in as JSON.
  $h = fopen($local, 'r');
  $datum = json_decode(fread($h, filesize($local)));
  fclose($h);

  // @todo Replace this with an API call to wunderground.
  $observations = $datum->history->observations;
  foreach ($observations as $observation) {
    // Data point from the observation we'd like to save.
    $datum = new stdClass();
    // Assume valid until proven invalid.
    $valid = TRUE;
    // Date and time of observation.
    $datum->time = date('Y-m-d H:i', mktime(
      (int) $observation->date->hour,
      (int) $observation->date->min,
      0, // Zero seconds.
      (int) $observation->date->mon,
      (int) $observation->date->mday,
      (int) $observation->date->year
    ));
    // Gather keys we'd like to pull.
    foreach ($keys as $key) {
      $value = $observation->{$key->name};
      // This will be parsed as a string, so let's convert.
      settype($value, $key->type);

      // If the value is negative, do not include in CSV. @todo Callback.
      $valid_value = !($key->type == 'float' && $value < 0.0
      || $key->type == 'int' && $value < 0);

      // Save if we are not ignoring.
      if ($valid_value) {
        $datum->{$key->name} = $value;
      }
      elseif (!$key->optional) {
        // If the key is invalid and non-optional, ignore the datum.
        $valid = FALSE;
        // No point is getting the rest of the keys.
        break;
      }
    }

    if ($valid) {
      // Only save if we received all our keys.
      $data[] = $datum;
    }
  }
}

$h = fopen($outfile, 'w');
// Save simple CSV.
foreach ($data as $datum) {
  $datum = (array) $datum;
  if (empty($first)) {
    fwrite($h, join(', ', array_keys($datum)) . "\n");
    $first = TRUE;
  }
  $length = count($datum);
  $i = 0;
  foreach ($datum as $key => $value) {
    fwrite($h, sprintf($formats[$key], $value));
    if (++$i < $length) {
      fwrite($h, ', ');
    }
  }
  fwrite($h, "\n");
}
fclose($h);