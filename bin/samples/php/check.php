<?php
  include_once("conn.php");

  $strQId = $_POST["quizId"];
	$strUser = $_POST["userId"];
	$strPwd = $_POST["userPwd"];
	$strSql = "SELECT id FROM `users` WHERE `userId`='".$strUser."' and `userPwd`='".$strPwd."' AND `inUse`=1";
	$rs = mysql_query($strSql, $conn) or die("Select users error.");
	$num = mysql_num_rows($rs);
	
	if ($num != 0) {
		echo "pass=true";
	} 
	else {  
    /*请注意这里：若只返回[pass=false]，则登录错误提示信息为您在播放器设置中预设的[帐号或密码错误，请重试]
    但若是返回[pass=false&msg=提示信息]格式，则登录错误提示信息为msg=后面的[提示信息]。
    这里您可以结合传入的quizId查询数据库，可实现同一帐号对某个quizId固定的测试题，进行只做一次的处理。*/
	 	echo "pass=false";
	} 
?>