<?php 
  //���Խ�����ݽ����ļ�
	if ($_POST["fromQuiz"] != "true") {
	  $strInfo  = "&nbsp;&nbsp;�������������Ϣ��˵������php�������������С���ҳ�浱һ���������������Ⲣ��ִ���ύ������";
		$strInfo .= "�������ļ��Զ����ã�������Ҫ��������������ҳ����ַ���ʴ�ҳ�档��������ռ����Խ���������������ʦ��";
		$strInfo .= "��[��������]->[�������]ҳ�棬ѡ��[���͵��������ݿ�]������[��ַ]������������ҳ����ַ����http://.../receive.php��";
		$strInfo .= "���ң�������������ļ����µ�crossdomain.xml�ļ������ڷ�������Ŀ¼�����������������в�����������ˣ����Ϳ����ռ����������ύ���������ݡ�";
		
		echo $strInfo;
		exit();
	}

  include_once("conn.php");
	//�����ⲥ������������...
  $quizId     = $_POST["quizId"];
	$quizTitle  = $_POST["quizTitle"];
	$userId     = $_POST["userId"];
	$userMail   = $_POST["userMail"];
	$userScore  = $_POST["userScore"];
	$totalScore = $_POST["totalScore"];
	$passScore  = $_POST["passScore"];
	$passState  = ($_POST["passState"] == "True") ? 1 : 0;
	$strResults = $_POST["quesInfo"];
	$strResults = addslashes($strResults);
	/*��������ɵ������У�ʱ�����ƹ��ܿ��ã��������������ã�����Ϊ��λ��
	timeLength���������ʱ��
	elapsed��   �鿴������ʱ��������ʱ��
	remaining�� �鿴������ʱ��ʣʱ��*/
	//ע����Ϣ
	$regMail    = $_POST["regMail"];
	$regCode    = $_POST["regCode"];
	
	//���뵽���ݿ�...
	//�洢����Ա��Ϣ
	if ($regMail != "") {
	  $rs = mysql_query("SELECT id FROM `admin` WHERE `userId`='".$regMail."'");
	  $num = mysql_num_rows($rs);
	  if ($num == 0) {
		  mysql_query("INSERT INTO `admin` (`userId`, `userPwd`) VALUES('".$regMail."', '".$regCode."')");
	  }
  	mysql_free_result($rs);
	}
	//�洢������Ϣ
	if ($userId != "") {
	  $rs = mysql_query("SELECT id FROM `users` WHERE `userId`='".$userId."'");
	  $num = mysql_num_rows($rs);
	  if ($num == 0) {
	    mysql_query("INSERT INTO `users` (`userId`, `userPwd`, `userMail`, `admin`) VALUES('".$userId ."', '654321', '".$userMail."', '".$regMail."')");
	  }
  	mysql_free_result($rs);
	}

  //���������ݿ�
	$sql  = "INSERT INTO `quiz` (`quizId`, `quizTitle`, `userId`, `userMail`, `userScore`, `totalScore`, `passScore`, `passState`, `Result`, `regMail`, `regCode`) ";
	$sql .= "VALUES ('".$quizId."', '".$quizTitle."', '".$userId."', '".$userMail."', '".$userScore."', '".$totalScore."', '".$passScore."', '".$passState."', '".$strResults."', '".$regMail."', '".$regCode."')";
	$rs = mysql_query($sql);
	
	//������Ϣ��������...
	if ($rs) {
	  $url = $_SERVER["HTTP_HOST"].$_SERVER["PHP_SELF"];  
	  $url = str_replace("receive.php", "index.php", $url);
	  echo "feedMsg=��ϲ�������ݷ��ͳɹ����������".$url ."�鿴���Խ��";	
  }
	else {
	  echo "feedMsg=���ݷ���ʧ�ܣ�";
	}
?> 