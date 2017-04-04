<?php 
  //测试结果数据接收文件
	if ($_POST["fromQuiz"] != "true") {
	  $strInfo  = "&nbsp;&nbsp;如果您看到此信息，说明您的php例子正在运行中。此页面当一个测试者做完试题并且执行提交操作后，";
		$strInfo .= "由试题文件自动调用，您不需要在浏览器中输入此页面网址访问此页面。如果您想收集测试结果，请打开秋风试题大师，";
		$strInfo .= "在[试题属性]->[结果设置]页面，选中[发送到网络数据库]，并在[网址]输入框中输入此页面网址，如http://.../receive.php。";
		$strInfo .= "而且，您必须把例子文件夹下的crossdomain.xml文件放置在服务器根目录。当您按照上面所列步骤配置完成了，您就可以收集测试者所提交的试题数据。";
		
		echo $strInfo;
		exit();
	}

  include_once("conn.php");
	//从试题播放器接收数据...
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
	/*如果您生成的试题中，时间限制功能可用，则下面变量亦可用，以秒为单位：
	timeLength：试题的总时长
	elapsed：   查看试题结果时做题所用时间
	remaining： 查看试题结果时所剩时间*/
	//注册信息
	$regMail    = $_POST["regMail"];
	$regCode    = $_POST["regCode"];
	
	//加入到数据库...
	//存储管理员信息
	if ($regMail != "") {
	  $rs = mysql_query("SELECT id FROM `admin` WHERE `userId`='".$regMail."'");
	  $num = mysql_num_rows($rs);
	  if ($num == 0) {
		  mysql_query("INSERT INTO `admin` (`userId`, `userPwd`) VALUES('".$regMail."', '".$regCode."')");
	  }
  	mysql_free_result($rs);
	}
	//存储考生信息
	if ($userId != "") {
	  $rs = mysql_query("SELECT id FROM `users` WHERE `userId`='".$userId."'");
	  $num = mysql_num_rows($rs);
	  if ($num == 0) {
	    mysql_query("INSERT INTO `users` (`userId`, `userPwd`, `userMail`, `admin`) VALUES('".$userId ."', '654321', '".$userMail."', '".$regMail."')");
	  }
  	mysql_free_result($rs);
	}

  //存结果入数据库
	$sql  = "INSERT INTO `quiz` (`quizId`, `quizTitle`, `userId`, `userMail`, `userScore`, `totalScore`, `passScore`, `passState`, `Result`, `regMail`, `regCode`) ";
	$sql .= "VALUES ('".$quizId."', '".$quizTitle."', '".$userId."', '".$userMail."', '".$userScore."', '".$totalScore."', '".$passScore."', '".$passState."', '".$strResults."', '".$regMail."', '".$regCode."')";
	$rs = mysql_query($sql);
	
	//返回信息给做题者...
	if ($rs) {
	  $url = $_SERVER["HTTP_HOST"].$_SERVER["PHP_SELF"];  
	  $url = str_replace("receive.php", "index.php", $url);
	  echo "feedMsg=恭喜您，数据发送成功；您可浏览".$url ."查看测试结果";	
  }
	else {
	  echo "feedMsg=数据发送失败！";
	}
?> 