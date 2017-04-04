<?php
  include_once("conn.php");

  if ($_GET["act"] == "login") {
	  $strUser = $_POST["userId"];
    $strPwd = $_POST["userPwd"];
	  $rs = mysql_query("SELECT * FROM `admin` WHERE `userId`='".$strUser."' AND `userPwd`='".$strPwd."'");
	  $num = mysql_num_rows($rs);
	  if ($num != 0) {
	    $_SESSION["admin"] = $strUser;
			$row = mysql_fetch_array($rs, MYSQL_ASSOC);
			$_SESSION["sys"] = $row["sys"];
	    goto_url("index.php");
    } 
	  else {   	
	    echo "<script language='javascript'>alert('帐号或密码有错误，请重新输入！'); window.history.back()</script>";
    }
  }
	else {
		session_unregister("admin");
		session_unregister("sys");
		goto_url("index.php");
  }
?>