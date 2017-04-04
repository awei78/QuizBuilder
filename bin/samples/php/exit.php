<?php
	session_start();
	session_unregister("admin");
	session_unregister("sys");
  echo "<script type='text/javascript'> window.location.href='index.html' </script>";
?>