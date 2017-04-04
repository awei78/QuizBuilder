<?php
	error_reporting(E_ALL ^E_NOTICE);
	session_start();
	
	//每页显示记录数
	define("PAGE_SIZE", 24);
	//您可以在这里定义数据收集系统所用的数据库名称，这里默认为db_quiz
	define("QUIZ_DB_NAME", "db_quiz");
	
	/*
	  连接数据库参数：
		$db_hostName: MySQL Server的ip地址或计算机名字 
		$db_userName: MySQL数据库的用户帐号 
		$db_passWord: MySQL数据库的用户密码
	*/
	$db_hostName = "localhost";
	$db_userName = "root";
	$db_passWord = "123456";
  $conn = mysql_connect($db_hostName, $db_userName, $db_passWord) or die("连接数据库失败...");
	
	//检测所指定的数据收集系统数据是否存在。若您已创建成功，可移去此代码以提高执行效率
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
	  //指定的数据若不存在则创建并选择
		mysql_query("CREATE DATABASE ".QUIZ_DB_NAME) or die("创建数据库[".QUIZ_DB_NAME."]失败...");
    mysql_select_db(QUIZ_DB_NAME, $conn) or die("访问数据库[".QUIZ_DB_NAME."]失败...");
	}
	else {
    mysql_select_db(QUIZ_DB_NAME, $conn) or die("访问数据库[".QUIZ_DB_NAME."]失败...");
	}
	
	//注意：以下代码，若您已创建完成所需的数据表，则可以移除其以提高执行效率
	//检测指定的数据表是否存在
	function has_table($tblName) {
    $rs = mysql_list_tables(QUIZ_DB_NAME);
    while ($row = mysql_fetch_row($rs)) {
      if ($row[0] == $tblName) {
			  return true;
		  }
		}
		
		return false;
	}
		
  //创建Quiz数据表
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
		mysql_query($sql, $conn) or die("创建Quiz数据表失败...");
	}
		
	//创建管理员表
	if (!has_table("admin")) {
		$sql  = "CREATE TABLE `admin` (";
		$sql .=	"`id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, ";
		$sql .=	"`userId` VARCHAR(255), ";
		$sql .=	"`userPwd` VARCHAR(255), ";
		$sql .=	"`sys` BOOL DEFAULT 0, ";
		$sql .=	"`addDate` TIMESTAMP";
		$sql .=	");";
		mysql_query($sql, $conn) or die("创建管理员表失败...");

    //初始化管理员帐号
    $sql = "INSERT INTO `admin` VALUES(NULL, 'admin', '123456', 1, '2007-01-01 00:00:00')";
		mysql_query($sql, $conn) or die("初始化管理员数据失败...");
	}
	
	//创建用户表
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
		mysql_query($sql, $conn) or die("创建用户表失败...");
	}
	
  function goto_url($url) {
    echo '<script language = "javascript">';
    echo '  window.location.href = "'.$url.'"';
    echo '</script>';
  }