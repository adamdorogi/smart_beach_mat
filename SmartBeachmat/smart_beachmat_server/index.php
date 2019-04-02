<?php
const FILE_NAME = __DIR__.'/credentials.php';
if (file_exists(FILE_NAME)) {
  require_once FILE_NAME;
  echo "Found file! Password is ".PASSWORD.", username is ".USERNAME.".";
} else {
  echo "Couldn't find file.";
  exit(1);
}

phpinfo();
?>
