<?php
	error_reporting(E_ALL ^E_NOTICE);
	session_start();
	
	//ÿҳ��ʾ��¼��
	define("PAGE_SIZE", 24);
	//�����������ﶨ�������ռ�ϵͳ���õ����ݿ����ƣ�����Ĭ��Ϊdb_quiz
	define("QUIZ_DB_NAME", "db_quiz");
	
	/*
	  �������ݿ������
		$db_hostName: MySQL Server��ip��ַ���������� 
		$db_userName: MySQL���ݿ���û��ʺ� 
		$db_passWord: MySQL���ݿ���û�����
	*/
	$db_hostName = "localhost";
	$db_userName = "root";
	$db_passWord = "123456";
  $conn = mysql_connect($db_hostName, $db_userName, $db_passWord) or die("�������ݿ�ʧ��...");
	
	//�����ָ���������ռ�ϵͳ�����Ƿ���ڡ������Ѵ����ɹ�������ȥ�˴��������ִ��Ч��
	$dbList = mysql_list_dbs($conn);
	$dbCount = mysql_num_rows($dbList);
	$hasQuizDB = false;
	for ($i = 0; $i < $dbCount; $i++) {
	  if (mysql_tablename($dbList, $i) == QUIZ_DB_NAME) {
		  $hasQuizDB = true;
			break;
		}
	}
	mysql_free_result($dbList);
	
	if (!$hasQuizDB) {
	  //ָ�����������������򴴽���ѡ��
		mysql_query("CREATE DATABASE ".QUIZ_DB_NAME) or die("�������ݿ�[".QUIZ_DB_NAME."]ʧ��...");
    mysql_select_db(QUIZ_DB_NAME, $conn) or die("�������ݿ�[".QUIZ_DB_NAME."]ʧ��...");
	}
	else {
    mysql_select_db(QUIZ_DB_NAME, $conn) or die("�������ݿ�[".QUIZ_DB_NAME."]ʧ��...");
	}
	
	//ע�⣺���´��룬�����Ѵ��������������ݱ�������Ƴ��������ִ��Ч��
	//���ָ�������ݱ��Ƿ����
	function has_table($tblName) {
    $rs = mysql_list_tables(QUIZ_DB_NAME);
    while ($row = mysql_fetch_row($rs)) {
      if ($row[0] == $tblName) {
			  return true;
		  }
		}
		
		return false;
	}
		
  //����Quiz���ݱ�
  if (!has_table("quiz")) {
		$sql  = "CREATE TABLE `quiz` (";
		$sql .= "`id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, ";
		$sql .=	"`quizId` VARCHAR(255), ";
		$sql .=	"`quizTitle` VARCHAR(255), ";
		$sql .=	"`userId` VARCHAR(255), ";
		$sql .=	"`userMail` VARCHAR(255), ";
		$sql .=	"`userScore` FLOAT, ";
		$sql .=	"`totalScore` FLOAT, ";
		$sql .=	"`passScore` FLOAT, ";
		$sql .=	"`passState` BOOL, ";
		$sql .=	"`Result` mediumtext, ";
		$sql .=	"`regMail` VARCHAR(255), ";
		$sql .=	"`regCode` VARCHAR(255), ";
		$sql .=	"`addDate` TIMESTAMP";
		$sql .=	");";
		mysql_query($sql, $conn) or die("����Quiz���ݱ�ʧ��...");
	}
		
	//��������Ա��
	if (!has_table("admin")) {
		$sql  = "CREATE TABLE `admin` (";
		$sql .=	"`id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, ";
		$sql .=	"`userId` VARCHAR(255), ";
		$sql .=	"`userPwd` VARCHAR(255), ";
		$sql .=	"`sys` BOOL DEFAULT 0, ";
		$sql .=	"`addDate` TIMESTAMP";
		$sql .=	");";
		mysql_query($sql, $conn) or die("��������Ա��ʧ��...");

    //��ʼ������Ա�ʺ�
    $sql = "INSERT INTO `admin` VALUES(NULL, 'admin', '123456', 1, '2007-01-01 00:00:00')";
		mysql_query($sql, $conn) or die("��ʼ������Ա����ʧ��...");
	}
	
	//�����û���
	if (!has_table("users")) {
		$sql  = "CREATE TABLE `users` (";
		$sql .=	"`id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, ";
		$sql .=	"`userId` VARCHAR(255), ";
		$sql .=	"`userPwd` VARCHAR(255), ";
		$sql .=	"`userMail` VARCHAR(255), ";
		$sql .=	"`admin` VARCHAR(255), ";
    $sql .=	"`inUse` BOOL DEFAULT 1, ";		
		$sql .=	"`addDate` TIMESTAMP";
		$sql .=	");";
		mysql_query($sql, $conn) or die("�����û���ʧ��...");
	}
	
  function goto_url($url) {
    echo '<script language = "javascript">';
    echo '  window.location.href = "'.$url.'"';
    echo '</script>';
  }