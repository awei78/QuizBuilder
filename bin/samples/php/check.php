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
    /*��ע�������ֻ����[pass=false]�����¼������ʾ��ϢΪ���ڲ�����������Ԥ���[�ʺŻ��������������]
    �����Ƿ���[pass=false&msg=��ʾ��Ϣ]��ʽ�����¼������ʾ��ϢΪmsg=�����[��ʾ��Ϣ]��
    ���������Խ�ϴ����quizId��ѯ���ݿ⣬��ʵ��ͬһ�ʺŶ�ĳ��quizId�̶��Ĳ����⣬����ֻ��һ�εĴ���*/
	 	echo "pass=false";
	} 
?>