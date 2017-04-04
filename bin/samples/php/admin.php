<?php
  include_once("conn.php");

  if ($_SESSION["admin"] == "") {
	  goto_url("index.html");
  }

  if ($_SESSION["sys"]) {
    $strSrh = TRUE;
	}
  elseif ($_SESSION["admin"] != "") {
    $strSrh = "userId='".$_SESSION["admin"]."'";
	}
	else {
    $strSrh = FALSE;
  }
	
	$strPage = ($_GET["page"] == 0) ? 1 : $_GET["page"];
  $strInfo = trim($_REQUEST["sinfo"]);
  $strUrl = ($strInfo == "") ? "" : "&sinfo=".urlencode($strInfo);
  
  //取编辑数据
  $strId = $_GET["id"];
  if (is_numeric($strId)) {
	  $rs = mysql_query("SELECT * FROM `admin` WHERE ".$strSrh." AND id=".$strId, $conn);
	  $num = mysql_num_rows($rs);
	  if ($num != 0) {
			$row = mysql_fetch_array($rs, MYSQL_ASSOC);
			$strUid = $row["userId"];
			$strPwd = $row["userPwd"];
	  }
    mysql_free_result($rs);
  }
    
  //编辑
  if ($_GET["act"] == "edit") {
    $strPwd = $_POST["userPwd"];
    $strId = $_POST["id"];
		mysql_query("UPDATE `admin` SET `userPwd`='".$strPwd."' WHERE id=".$strId, $conn);
    goto_url("admin.php?page=".$strPage.$strUrl);
  }

  //删除...
  $delStr = Trim($_GET["del"]);
  if (is_numeric($delStr)) {
	  $rs = mysql_query("SELECT `sys` FROM `admin` WHERE id=".$delStr, $conn);
	  $num = mysql_num_rows($rs);
	  if ($num != 0) {
			$row = mysql_fetch_array($rs, MYSQL_ASSOC);
			if ($row["sys"]) {
			  echo "<script language='javascript'>alert('您不能删除系统管理员！'); window.location.href='admin.php'</script>";
			}
	    else {
			  mysql_query("DELETE FROM `admin` WHERE id=".$delStr, $conn);
        goto_url("admin.php?page=".$strPage.$strUrl);
			}
		}
		mysql_free_result($rs);
  }
?>

<html>

<meta http-equiv="Content-Type" content="text/html; charset=gb2312">
<link rel="stylesheet" type="text/css" href="style.css">
<meta name="Keywords" content="秋风软件, 秋风试题大师, 秋风人事档案管理系统, E-Learning, SCORM">
<title>管理员信息</title>
</head>

<body>

<center>
<table border="1" width="100%" cellpadding="0" cellspacing="0" bordercolor="#7F9DB9" style="border-collapse: collapse">
  <tr>
    <td colspan="7" align="center" height="20"><b><font size="3" color="#006699">
    管理员信息</font></b></td>
  </tr>
  <tr>
    <td background="images/tbg.gif" width="5%" height="20">序号</td>
    <td background="images/tbg.gif" width="25%" height="20">管理员账号</td>
    <td background="images/tbg.gif" width="19%" height="20">密码</td>
    <td background="images/tbg.gif" width="10%" height="20">测试者人数　</td>
    <?php
      if ($_SESSION["sys"]) {
    ?>
    <td background="images/tbg.gif" width="10%" height="20">删除<img border="0" src="images/del.gif"></td>
    <?php
      }
    ?>
    <td background="images/tbg.gif" width="10%" height="20">编辑<img border="0" src="images/write.gif"></td>
    <td background="images/tbg.gif" width="20%" height="20">加入日期</td>
  </tr>
  <?php
    if ($strInfo == "") {
      $strSql = "SELECT * FROM `admin` WHERE ".$strSrh." ORDER BY id DESC";
		}
    else {
      $strSql = "SELECT * FROM `admin` WHERE ".$strSrh." AND `userId` LIKE '%".$strInfo."%' ORDER BY id DESC";
    }
		$rs = mysql_query($strSql, $conn);
		if ($rs) {
		  $num = mysql_num_rows($rs);
		  mysql_free_result($rs);
		}
	  $pageSize = 18;
		$pageCount = ceil($num / $pageSize);
		if ($strPage > $pageCount) {
		  $strPage = $pageCount;
	  }
			
		$start = ($strPage - 1) * $pageSize;
		if ($start < 0) {
		  $start = 0;
  	}
		$strSql .= " LIMIT $start, $pageSize";
		$rs = mysql_query($strSql, $conn);
		if (!$rs) {
		  $pageSize = 0;
		}

		for ($i = 0; $i < $pageSize; $i++) {
			$row = mysql_fetch_array($rs, MYSQL_ASSOC);
			if (!$row) {
			  break;
		  }
			
			$recNo = $pageSize * ($strPage - 1) + $i + 1;
		  $strUser = str_replace($strInfo, '<font color="#FF0000">'.$strInfo.'</font>', $row["userId"]);
        
      //求记录条数
      if (strtolower($row["userId"]) != "admin") {
			  $rsc = mysql_query("SELECT Count(id) AS recCount FROM `quiz` WHERE regMail='".$row["userId"]."'", $conn);
      }
			else {
			  $rsc = mysql_query("SELECT Count(id) AS recCount FROM `quiz`", $conn);
      }
			if (mysql_num_rows($rsc) != 0) {
			  $rowc = mysql_fetch_array($rsc, MYSQL_ASSOC);
			  $recCount = $rowc["recCount"];
			}
      mysql_free_result($rsc);  
			
      //测试者人数
      if (strtolower($row["userId"]) != "admin") {
			  $rsc = mysql_query("SELECT Count(id) AS recCount FROM `users` WHERE admin='".$row["userId"]."'", $conn);
			}
			else {
			  $rsc = mysql_query("SELECT Count(id) AS recCount FROM `users`", $conn);
			}
			if (mysql_num_rows($rsc) != 0) {
			  $rowc = mysql_fetch_array($rsc, MYSQL_ASSOC);
			  $userCount = $rowc["recCount"];
			}
      mysql_free_result($rsc);  
  ?>
  <tr <?php if ($i % 2 != 0) { ?> bgcolor="#E0E0E0"<?php } ?>>
    <td height="20"><?php echo($recNo) ?>　</td>
    <td height="20"><a href="ques.php?admin=<?php echo(urlencode($row["userId"])) ?>" title="查看此管理员所有试题 [<?php echo($recCount) ?>条]" target="_blank"><?php echo($strUser) ?></a>　</td>
    <td height="20"><?php echo($row["userPwd"]) ?>　</td>
    <td height="20"><a href="users.php?sinfo=<?php echo($row["userId"]) ?>"><?php echo($userCount) ?></a>　</td>
    <?php
      if ($_SESSION["sys"]) {
    ?>
    <td height="20"><a href="admin.php?page=<?php echo($strPage."&del=".$row["id"].$strUrl) ?>" title="删除当前记录" onClick="javascript: <?php if ($row["sys"]) { ?>alert('您不能删除系统管理员！');return false<?php } else { ?>return confirm('您确定删除此帐号么？')<?php } ?>">删除</a> </td>
    <?php
      }
    ?>
    <td height="20"><a href="admin.php?page=<?php echo($strPage."&id=".$row["id"].$strUrl) ?>" title="编辑当前记录">编辑</a></td>
    <td height="20"><?php echo($row["addDate"]) ?>　</td>
  </tr>
  <?php
    }
      
    if ($_SESSION["sys"]) {
  ?>
  <tr>
    <td colspan="4" align="left" height="18" valign="bottom">
      <font color="#008000">信息数：[<?php echo($num )?>]</font>&nbsp;&nbsp;
      <font color="#008000">
      <img border="0" src="images/page.gif" align="absbottom">页次：[<?php echo("<font color=\"#FF0000\">".$strPage."</font>/".$pageCount) ?>]</font>
    </td>
    <td colspan="3" align="right" height="18" valign="bottom">
      <?php 
			  if ($strPage > 1) {
			?>
      <a href="admin.php?page=1<?php echo($strUrl) ?>">[首 页]</a>&nbsp;&nbsp;
      <a href="admin.php?page=<?php echo(($strPage - 1).$strUrl) ?>">[上一页]</a>&nbsp;&nbsp;
      <?php
        }
        if ($strPage < $pageCount) {
      ?>
      <a href="admin.php?page=<?php echo(($strPage + 1).$strUrl) ?>">[下一页]</a>&nbsp;&nbsp;
      <a href="admin.php?page=<?php echo($pageCount.$strUrl) ?>">[末 页]</a>
      <?php
        }
      ?>
    </td>
  </tr>
  <form name="frmSearch" method="GET" action="admin.php">
  <tr>
    <td colspan="7" align="left">
      <font color="#006699"><b>请输入您要搜索的帐号：</b></font>&nbsp;
      <input type="text" name="sinfo" size="32" value="<?php echo($strInfo) ?>" ID=Text1>&nbsp;
      <input type="submit" value="搜索" ID=Submit1></td>
  </tr>
  <?php
    }
  ?>
  </form>
</table>

<?php
  if ($strId != "") {
?>
<br><br>
<table border="1" width="90%" cellspacing="0" cellpadding="0" style="border-collapse: collapse" bordercolor="#7F9DB9">
  <form name="frmAdd" method="POST" action="?page=<%=strPage%><%=strUrl%>&act=edit" onSubmit="javascript: return checkData()" onReset="javascript: document.all('info').innerHTML = ''; this.userId.focus()">
  <tr>
    <td width="25%" align="right">帐号：&nbsp; </td>
    <td width="75%">
    <input type="input" name="userId" value="<?php echo($strUid) ?>" disabled style="width: 180; height: 20" size="20">&nbsp; <label id="info"></label></td>
  </tr>
  <tr>
    <td width="25%" align="right">密码：&nbsp; </td>
    <td width="75%">
    <input type="input" name="userPwd" value="<?php echo($strPwd) ?>" style="width: 180; height: 20" size="20"></td>
  </tr>
  <tr>
    <td width="25%"></td>
    <td width="75%">
      <input type="submit" value="更新" name="btnTurn">&nbsp;&nbsp;&nbsp;
      <input type="reset" value="重置" name="btnReset">&nbsp;&nbsp;&nbsp;
      <?php
			  if ($strId != "") {
			?>
        <input type="hidden" name="id" value="<?php echo($strId) ?>">
        <input type="button" value="取消" name="btnCancel" onClick="javascript: window.location.href='admin.php'">
      <?php
			  }
			?>
    </td>
  </tr>
  </form>
</table>
<?php
  }
?>

</body>

</html>