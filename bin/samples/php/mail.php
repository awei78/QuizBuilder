<?php
  if ($_POST["topic"] == "") {
    echo "��Ч���ʼ����ݣ���ҳ��Ϊ�����ʦ�����ɵ����������ã�����ֱ�����������";
    exit();
  }
	
	require_once("class.phpmailer.php");
	$mail = new PHPMailer();

	$mail->IsSMTP();                         
	$mail->Host = "smtp.awindsoft.net";      //�ʼ�ת��������
	$mail->Port = 25;                        //SMTP�˿�
	$mail->SMTPAuth = true;                  
	$mail->Username = "quiz@awindsoft.net";  //SMTP�ʺ�
	$mail->Password = "98765432";              //SMTP����
	
	//��ȡ�ʼ�����
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
	$mail->IsHTML(true);                     //����Ϊhtml��ʽ�ʼ�
	
	$mail->Subject = $subject;
	$mail->Body    = $body;
	$mail->AltBody = "��������ʦ���Խ���ʼ�";
	
	if (!$mail->Send())	{
		echo "feedMsg=�ʼ�����ʧ�ܣ�";
	}
	else {	
	  echo "feedMsg=��ϲ�����ʼ��ѳɹ�����";
	}
?>
