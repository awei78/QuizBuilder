<?php
  include_once("conn.php");

  if ($_SESSION["admin"] == "") {
	  goto_url("index.html");
  }

  //据登录管理员设置查询
  if ($_SESSION["sys"]) {
    $strSrh = TRUE;
	}
  elseif ($_SESSION["admin"] != "") {
    $strSrh = "admin='".$_SESSION["admin"]."'";
	}
  else {
    $strSrh = "admin=''";
  }
  
  $strPage = ($_GET["page"] == 0) ? 1 : $_GET["page"];
  $strInfo = trim($_REQUEST["sinfo"]);
  $strUrl = ($strInfo == "") ? "" : "&sinfo=".urlencode($strInfo);
  
  //网络检测启用与否...
  //启用
  if ($_GET["u"] != "") {
	  mysql_query("UPDATE `users` SET `inUse`=TRUE WHERE id=".$_GET["u"], $conn);
  }
  //禁用
  if ($_GET["r"] != "") {
    mysql_query("UPDATE `users` SET `inUse`=FALSE WHERE id=".$_GET["r"], $conn);
  }
  
  //取编辑数据
  $strId = $_GET["id"];
  if (is_numeric($strId)) {
    $rs = mysql_query("SELECT * FROM `users` WHERE ".$strSrh." AND id=".$strId, $conn);
	  $num = mysql_num_rows($rs);
	  if ($num != 0) {
			$row = mysql_fetch_array($rs, MYSQL_ASSOC);
			$strUid = $row["userId"];
			$strPwd = $row["userPwd"];
			$strMail = $row["userMail"];
			$inUse = $row["inUse"];
	  }
    mysql_free_result($rs);	
  }
    
  $strAct = $_GET["act"];
  //添加
  if ($strAct == "add") {
    $strUid = $_POST["userId"];
		$rs = mysql_query("SELECT id FROM `users` WHERE ".$strSrh." AND userId='".$strUid."'", $conn);
    
    if (mysql_num_rows($rs) != 0) {
      echo "<script language='javascript'>alert('您要添加的帐号 [".$strUid."] 已存在！'); window.location.href='users.php'</script>";
		}
		else {
      $strPwd = $_POST["userPwd"];
      $strMail = $_POST["userMail"];
      $inUse = $_POST["cbUse"]."";
      if ($inUse == "") {
			  $inUse = "False";
			}
      mysql_query("INSERT INTO `users`(`userId`, `userPwd`, `userMail`, `admin`, `inUse`) VALUES('".$strUid."', '".$strPwd."', '".$strMail."', '".$_SESSION["admin"]."', ".$inUse.")", $conn);
      
      goto_url("users.php?page=".strPage.strUrl);
    }
		mysql_free_result($rs);	
  }
  
  //编辑
  if ($strAct == "edit") {
    $strUid = str_replace("'", "''", $_POST["userId"]);
    $strId = $_POST["id"];
		$rs = mysql_query("SELECT id FROM `users` WHERE ".$strSrh." AND userId='".$strUid."' AND `id`<>".$strId, $conn);
    
    if (mysql_num_rows($rs) != 0) {
      echo "<script language='javascript'>alert('您要更新的帐号 [".$strUid."] 已存在！'); window.history.back()</script>";
		}
		else {
      $strPwd = $_POST["userPwd"];
      $strMail = $_POST["userMail"];
      $inUse = $_POST["cbUse"]."";
      if ($inUse == "") {
			  $inUse = "False";
			}
			mysql_query("UPDATE `users` SET `userId`='".$strUid."', `userPwd`='".$strPwd."', `userMail`='".$strMail."', `inUse`=".$inUse." WHERE `id`=".$strId, $conn);
      
      goto_url("users.php?page=".$strPage.$strUrl);
    }
    mysql_free_result($rs);	
  }

  //删除.
  $delStr = trim($_GET["del"]);
  //删除单条记录
  if (is_numeric($delStr)) {
  	mysql_query("DELETE FROM `users` WHERE `id`=".$delStr, $conn);
    goto_url("users.php?page=".$strPage.$strUrl);
	}
  //删除所选择记录      
  elseif ($delStr == "true") {
	  $delIds = implode(",", $_REQUEST["id"]);
	  mysql_query("DELETE FROM `users` WHERE `id` IN (".$delIds.")", $conn);
		goto_url("users.php");
	}
  //清空记录  
  elseIf ($delStr == "all") {
    if ($strInfo == "") {
		  mysql_query("DELETE FROM `users` WHERE ".$strSrh, $conn);
		}
		else {
		  mysql_query("DELETE FROM `users` WHERE ".$strSrh." AND `userId` LIKE '%".$strInfo."%'", $conn);
    }
    goto_url("users.php");
  }
?>

<html>

<meta http-equiv="Content-Type" content="text/html; charset=gb2312">
<link rel="stylesheet" type="text/css" href="style.css">
<meta name="Keywords" content="秋风软件, 秋风试题大师, 秋风人事档案管理系统, E-Learning, SCORM">
<title>用户信息管理</title>

<script language="javascript">
<!--
  function checkData() {
    if (document.frmAdd.userId.value == "") {
      document.all('info').innerHTML = '<font color="#FF0000">请输入您要添加的帐号！</font>';
      document.frmAdd.userId.focus();
      return false;
    }
    
    return true;
  }
  
	function checkAll(form) {
		form.elements("chkAll").title =form.elements("chkAll").checked ? '取消选择' : '全部选择';
		for(var i = 0; i < form.elements.length; i++) {
			var e = form.elements[i];
			if(e.type=="checkbox" && e.name == "id[]") {
				e.checked = form.elements("chkAll").checked;;
			}
		}
	}
  
  function delAll() {
    var hasChecked = false;
    for (var i = 0; i <= document.getElementsByName('id[]').length - 1; i++) {
      if (document.getElementsByName('id[]')[i].checked) {
        hasChecked = true;
        break;
      }
    }
		
	  if (!hasChecked) {
      alert('请选择要删除的账号！');
    }  
    else if (confirm('您确定要删除所选择的帐号吗？')) {
      document.frmUser.submit(); 
    } 
  }
  
  function clearAll() {
    if (confirm('您确定要清空所有记录吗？')) {
      window.location.href = 'users.php?del=all&sinfo=<?php echo(urlencode($strInfo)) ?>';
    }
  }
-->
</script>
</head>

<body>

<center>
<table border="1" width="100%" cellpadding="0" cellspacing="0" bordercolor="#7F9DB9" style="border-collapse: collapse">
  <tr>
    <td colspan="10" align="center" height="20"><b><font size="3" color="#006699">
    用户信息管理</font></b></td>
  </tr>
  <form name="frmUser" method="POST" action="?del=true<?php echo($strUrl) ?>">
  <tr>
    <td background="images/tbg.gif" width="4%"><input type="checkbox" name="chkAll" value="1" title="全部选择" onClick="javascript: checkAll(this.form)" style="cursor: hand"></td>
    <td background="images/tbg.gif" width="4%">序号</td>
    <td background="images/tbg.gif" width="15%">用户账号</td>
    <td background="images/tbg.gif" width="10%">密码</td>
    <td background="images/tbg.gif" width="14%">邮件</td>
    <?php
      if ($_SESSION["sys"]) {
    ?>
    <td background="images/tbg.gif" width="15%">管理员</td>
    <?php
      }
    ?>
    <td background="images/tbg.gif" width="8%">启用检测</td>
    <td background="images/tbg.gif" width="6%">删除<img border="0" src="images/del.gif"></td>
    <td background="images/tbg.gif" width="6%">编辑<img border="0" src="images/write.gif"></td>
    <td background="images/tbg.gif" width="18%">加入日期</td>
  </tr>
  <?php
	  if ($strInfo == "" || strtolower($strInfo) == "admin") {
		  $strSql = "SELECT *, (SELECT Count(id) FROM `quiz` WHERE userId=users.userId) as `recCount` FROM `users` WHERE ".$strSrh;
		}
		else {
      $strSql = "SELECT *, (SELECT Count(id) FROM `quiz` WHERE userId=users.userId) as `recCount` FROM `users` WHERE ".$strSrh." AND (userId LIKE '%".$strInfo."%' OR admin LIKE '%".$strInfo."%')";		
  	}
		$rs = mysql_query($strSql, $conn);
		$num = mysql_num_rows($rs);
		mysql_free_result($rs);
	  $pageSize = 18;
		$pageCount = ceil($num / $pageSize);
		if ($strPage > $pageCount) {
		  $strPage = $pageCount;
	  }
			
		$start = ($strPage - 1) * $pageSize;
		$strSql .= " ORDER BY `id` DESC LIMIT $start, $pageSize";
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
			$strUser = str_replace($strInfo, "<font color=\"#FF0000\">".$strInfo."</font>", $row["userId"]);
  ?>
  <tr <?php if ($i % 2 != 0) { ?> bgcolor="#E0E0E0"<?php } ?>>
    <td><input type="checkbox" name="id[]" value="<?php echo($row["id"]) ?>"></td>
    <td><?php echo($recNo) ?>　</td>
    <td><a href="ques.php?user=<?php echo(urlencode($row["userId"])) ?>" title="查看此用户所有试题 [<?php echo($row["recCount"]) ?>条]" target="_blank"><?php echo($strUser) ?></a>　</td>
    <td><?php echo($row["userPwd"]) ?>　</td>
    <td><a href="mailto:<?php echo($row["userMail"]) ?>" title="发个邮件到<?php echo($row["userMail"]) ?>"><?php echo($row["userMail"]) ?></a>　</td>
    <?php
      if ($_SESSION["sys"]) {
    ?>
    <td><?php echo(str_replace($strInfo, "<font color=\"#FF0000\">".$strInfo."</font>", $row["admin"])) ?> </td>
    <?php
      }
    ?>
    <td>
    <?php
      if ($row["inUse"]) {
        echo "<a href=\"users.php?page=".$strPage.$strUrl."&r=".$row["id"]."\" title=\"禁用当前账号的网络检测功能\"><font color=\"#FF0000\">禁用</font></a>";
      }
			else {
        echo "<a href=\"users.php?page=".$strPage.$strUrl."&u=".$row["id"]."\" title=\"启用当前账号的网络检测功能\"><font color=\"#008000\">启用</font></a>";
      }
    ?> 　
    </td>
    <td><a href="users.php?page=<?php echo($strPage."&del=".$row["id"].$strUrl) ?>" title="删除当前记录" onClick="javascript: return confirm('您确定删除此帐号么？')">删除</a> </td>
    <td><a href="users.php?page=<?php echo($strPage."&id=".$row["id"].$strUrl) ?>" title="编辑当前记录">编辑</a></td>
    <td><?php echo($row["addDate"]) ?>　</td>
  </tr>
  <?php
    }
  ?>
  <tr>
    <td colspan="6" align="left" height="18" valign="bottom">
      <a href="#" onClick="javascript: delAll()">[清除所选择的记录]</a>&nbsp;&nbsp;&nbsp;
      <img border="0" src="images/del.gif" align="absbottom"><a href="#" onClick="javascript: clearAll()">[清空所有记录]</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      <font color="#008000">信息数：[<?php echo($num )?>]</font>&nbsp;&nbsp;
      <font color="#008000">
      <img border="0" src="images/page.gif" align="absbottom">页次：[<?php echo("<font color=\"#FF0000\">".$strPage."</font>/".$pageCount) ?>]</font>
    </td>
    <td colspan="4" align="right" height="18" valign="bottom">
      <?php 
			  if ($strPage > 1) {
			?>
      <a href="users.php?page=1<?php echo($strUrl) ?>">[首 页]</a>&nbsp;&nbsp;&nbsp;
      <a href="users.php?page=<?php echo(($strPage - 1).$strUrl) ?>">[上一页]</a>&nbsp;&nbsp;&nbsp;
      <?php
        }
        if ($strPage < $pageCount) {
      ?>
      <a href="users.php?page=<?php echo(($strPage + 1).$strUrl) ?>">[下一页]</a>&nbsp;&nbsp;&nbsp;
      <a href="users.php?page=<?php echo($pageCount.$strUrl) ?>">[末 页]</a>
      <?php
        }
      ?>
    </td>
  </tr>
  </form>
  <form name="frmSearch" method="GET" action="users.php">
  <tr>
    <td colspan="10" align="left">
      <font color="#006699"><b>请输入您要搜索的帐号：</b></font>&nbsp;
      <input type="text" name="sinfo" size="32" value="<?php echo($strInfo) ?>">&nbsp;
      <input type="submit" value="搜索"></td>
  </tr>
  </form>
</table>

<br><br>
<?php
  if ($strId != "") {
    $strAct = "edit";
    $strCap = "更新";
	}
	else {
    $strAct = "add";
    $strCap = "添加";
  }
?>
<table border="1" width="90%" cellspacing="0" cellpadding="0" style="border-collapse: collapse" bordercolor="#7F9DB9">
  <form name="frmAdd" method="POST" action="?page=<?php echo($strPage.$strUrl."&act=".$strAct) ?>" onSubmit="javascript: return checkData()" onReset="javascript: document.all('info').innerHTML = ''; this.userId.focus()">
  <tr>
    <td width="25%" align="right">　</td>
    <td width="75%"><b><font size="2" color="#006699"><?php echo($strCap) ?>帐号</font></b>　</td>
  </tr>
  <tr>
    <td width="25%" align="right">帐号：&nbsp; </td>
    <td width="75%">
    <input type="input" name="userId" value="<?php echo($strUid) ?>" style="width: 180; height: 20" size="20">&nbsp; <label id="info"></label></td>
  </tr>
  <tr>
    <td width="25%" align="right">密码：&nbsp; </td>
    <td width="75%">
    <input type="input" name="userPwd" value="<?php echo($strPwd) ?>" style="width: 180; height: 20" size="20"></td>
  </tr>
  <tr>
    <td width="25%" align="right">邮件：&nbsp; </td>
    <td width="75%">
    <input type="input" name="userMail" value="<?php echo($strMail) ?>" style="width: 180; height: 20" size="20"></td>
  </tr>
  <tr>
    <td width="25%" align="right">启用检测：&nbsp; </td>
    <td width="75%"><input type="checkbox" name="cbUse" value="True" <?php if ($inUse || $strId == "") { ?>checked<?php } ?>>&nbsp; 
    <font color="#0000FF">(此处设置，对应试题大师属性设置之<font color="#FF6600">[试题保护]</font>-><font color="#FF6600">[密码保护]</font>-><font color="#FF6600">[网页验证]</font>之选项)</font></td>
  </tr>
  <tr>
    <td width="25%"></td>
    <td width="75%">
      <input type="submit" value="<?php echo($strCap) ?>" name="btnTurn">&nbsp;&nbsp;&nbsp;
      <input type="reset" value="重置" name="btnReset">&nbsp;&nbsp;&nbsp;
      <?php
			  if ($strId != "") {
			?>
        <input type="hidden" name="id" value="<?php echo($strId) ?>">
        <input type="button" value="取消" name="btnCancel" onClick="javascript: window.location.href='users.php'">
      <?php
			  }
			?>
    </td>
  </tr>
  </form>
</table>

</body>

</html>