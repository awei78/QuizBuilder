<?php
  if ($_POST["topic"] == "") {
    echo "无效的邮件数据！此页面为试题大师所生成的试题所调用，不能直接用浏览器打开";
    exit();
  }
	
	require_once("class.phpmailer.php");
	$mail = new PHPMailer();

	$mail->IsSMTP();                         
	$mail->Host = "smtp.awindsoft.net";      //邮件转发服务器
	$mail->Port = 25;                        //SMTP端口
	$mail->SMTPAuth = true;                  
	$mail->Username = "quiz@awindsoft.net";  //SMTP帐号
	$mail->Password = "98765432";              //SMTP密码
	
	//获取邮件数据
	$to      = trim($_POST["mail"]);
  $subject = trim($_POST["topic"]);
  $body    = trim($_POST["body"]);
	$body    = str_replace("\'", '"', $body);
	$from    = trim($_POST["from"]) == "" ? "quiz@awindsoft.net" : $_POST["from"];
	$user    = trim($_POST["user"]) == "" ? $from : $_POST["user"];
	$sender  = "quiz@awindsoft.net";

	$mail->From = $sender;
	$mail->FromName = $user;
	$maillist = explode(",", $to);
	foreach($maillist as $mailto) {
	  $mail->AddAddress(trim($mailto));
	}
	$mail->AddReplyTo($from);
	
	$mail->WordWrap = 70;                               
	$mail->IsHTML(true);                     //设置为html格式邮件
	
	$mail->Subject = $subject;
	$mail->Body    = $body;
	$mail->AltBody = "秋风试题大师测试结果邮件";
	
	if (!$mail->Send())	{
		echo "feedMsg=邮件发送失败！";
	}
	else {	
	  echo "feedMsg=恭喜您，邮件已成功发送";
	}
?>
