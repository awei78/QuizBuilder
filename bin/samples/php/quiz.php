<?php
  include_once("conn.php");

  //据登录管理员设置查询
	if ($_SESSION["sys"]) {
	  $strSrh = TRUE;
	}
	elseif ($_SESSION["admin"] != "") {
	  $strSrh = "regMail='".$_SESSION["admin"]."'";
	}
	else {
	  $strSrh = "regMail=''";
	}
	
	$strPage = ($_GET["page"] == 0) ? 1 : $_GET["page"];
  $strInfo = trim($_REQUEST["info"]);
  $strUrl = ($strInfo == "") ? "" : "&info=".urlencode($strInfo);

  //删除操作...
  $delStr = trim($_REQUEST["del"]);
	//删除单条记录
  if (is_numeric($delStr)) { 
	  mysql_query("DELETE FROM `quiz` WHERE `id`='".$delStr."'", $conn);
	  goto_url("quiz.php?page=".$strPage.$strUrl);
  }
	//删除多条记录
  elseif ($delStr == "true") {
	  $delIds = implode(",", $_REQUEST["quiz"]);
	  mysql_query("DELETE FROM `quiz` WHERE `id` IN (".$delIds.")", $conn);
		goto_url("quiz.php");
  }
	//清空记录
  elseif ($delStr == "all") {
	  if ($strInfo == "") {
      mysql_query("DELETE FROM `quiz` WHERE ".$strSrh, $conn);
	  } 
	  else {
	    mysql_query("DELETE FROM `quiz` WHERE ".$strSrh." AND `quizTitle` LIKE '%".$strInfo."%' or `userId` LIKE '".$strInfo."'", $conn);
	  }
    goto_url("quiz.php");
  }
?>
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=gb2312">
<link rel="stylesheet" type="text/css" href="style.css">
<meta name="Keywords" content="秋风软件, 秋风试题大师, 秋风人事档案管理系统, E-Learning, SCORM">
<title>秋风试题大师数据管理系统 - 试题信息管理</title>

<script type="text/javascript">
<!--
	function checkAll(form) {
		form.elements("chkAll").title =form.elements("chkAll").checked ? '取消选择' : '全部选择';
		for(var i = 0; i < form.elements.length; i++) {
			var e = form.elements[i];
			if(e.type=="checkbox" && e.name == "quiz[]") {
				e.checked = form.elements("chkAll").checked;;
			}
		}
	}
 
  function delAll() {
    var hasChecked = false;
    for (var i = 0; i <= document.getElementsByName('quiz[]').length - 1; i++) {
      if (document.getElementsByName('quiz[]')[i].checked) {
        hasChecked = true;
        break;
      }
    }
		
	  if (!hasChecked) {
      alert('请选择要删除的信息！');
    }  
    else if (confirm('您确定要删除所选择的信息吗？')) {
      document.frmQuiz.submit(); 
    } 
  }
  
  function clearAll() {
    if (confirm('您确定要清空所有记录吗？')) {
      window.location.href = "quiz.php?del=all&info=<?php echo(urlencode($strInfo)) ?>";
    }  
  }
-->
</script>
</head>

<body>

<center>
<table border="1" width="100%" cellpadding="0" cellspacing="0" bordercolor="#7F9DB9" style="border-collapse: collapse">
  <tr>
    <td colspan="11" align="center" height="20"><b><font size="3" color="#006699">试题信息管理</font></b></td>
  </tr>
  <form name="frmQuiz" method="POST" action="quiz.php?del=true">
  <tr>
    <td background="images/tbg.gif" width="4%"><input type="checkbox" name="chkAll" value="1" title="全部选择" onClick="javascript: checkAll(this.form)" style="cursor: hand"></td>
    <td background="images/tbg.gif" width="4%">序号 </td>
    <td background="images/tbg.gif" width="28%">标题 </td>
    <td background="images/tbg.gif" width="8%">测试者 </td>
    <?php
      if ($_SESSION["sys"]) {
    ?>
    <td background="images/tbg.gif" width="14%">管理员　</td>
    <?php
      }
    ?>
    <td background="images/tbg.gif" width="4%">得分 </td>
    <td background="images/tbg.gif" width="4%">总分 </td>
    <td background="images/tbg.gif" width="5%">及格分 </td>
    <td background="images/tbg.gif" width="7%">是否通过 </td>
    <td background="images/tbg.gif" width="4%">删除 </td>
    <td background="images/tbg.gif" width="18%">提交日期 </td>
  </tr>
  <?php
		if ($strInfo == "") { 
			$sql = "SELECT * FROM `quiz` WHERE ".$strSrh;
		}
		else {
			$sql = "SELECT * FROM `quiz` WHERE ".$strSrh." AND (`quizTitle` LIKE '%".$strInfo."%' OR `userId` LIKE '%".$strInfo."%')";
		}
		$rs = mysql_query($sql, $conn);
		$num = mysql_num_rows($rs);
		mysql_free_result($rs);
	  $pageSize = PAGE_SIZE;
		$pageCount = ceil($num / $pageSize);
		if ($strPage > $pageCount) {
		  $strPage = $pageCount;
	  }
			
		$start = ($strPage - 1) * $pageSize;
 		$sql .= " ORDER BY `id` DESC LIMIT $start, $pageSize";
		$rs = mysql_query($sql, $conn);
		if (!$rs) {
		  $pageSize = 0;
		}

		for ($i = 0; $i < $pageSize; $i++) {
			$row = mysql_fetch_array($rs, MYSQL_ASSOC);
			if (!$row) {
			  break;
		  }
			
			$recNo = $pageSize * ($strPage - 1) + $i + 1;
  ?>
  <tr <?php if ($i % 2 != 0) { ?> bgcolor="#E0E0E0"<?php } ?>>
    <td><input type="checkbox" name="quiz[]" value="<?php echo($row['id'])?>"> </td>
    <td><?php if($row['passState']) echo("<span style=\"color:#080\">".$recNo."</span>");else echo("<span style=\"color:#F00\">".$recNo."</span>")?> </td>
		<td><a href="show.php?id=<?php echo($row['id'])?>"  title="点击查看详细信息" target="_blank"><?php echo(str_replace($strInfo, "<span style=\"color:#F00\">$strInfo</span>", $row['quizTitle']))?></a> </td>
    <td><a href="mailto:<?php echo($row['userMail'])?>" title="发个邮件给 <?php echo($row['userId'])?>"><?php echo(str_replace($strInfo, "<span style=\"color:#F00\">$strInfo</span>", $row['userId']))?></a> </td>
    <?php
      if ($_SESSION["sys"]) {
    ?>
    <td><?php echo($row['regMail'])?> </td>
    <?php
      }
    ?>
    <td><?php echo($row['userScore'])?> </td>
    <td><?php echo($row['totalScore'])?> </td>
    <td><?php echo($row['passScore'])?> </td>
    <td><?php if ($row['passState']) echo("<span style=\"color:#080\">是</span>"); else echo("<span style=\"color:#F00\">否</span>")?> </td>
    <td><a href="quiz.php?del=<?php echo($row['id'])?>&page=<?php echo($strPage )?><?php echo($strUrl)?>" title="删除此条记录" onClick="javascript: return confirm('您确定删除此记录么？')">删除</a> </td>
    <td><?php echo($row['addDate'])?> </td>
  </tr>
  <?php
	  }
  ?>
  </form>
  <tr>
    <td colspan="7" align="left" height="18">
      <a href="#" onClick="javascript: delAll()">[清除所选择的记录]</a>&nbsp;&nbsp;&nbsp;
      <img border="0" src="images/del.gif" align="absbottom"><a href="#" onClick="javascript: clearAll()">[清空所有记录]</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      <font color="#008000">信息数：[<?php echo($num )?>]</font>&nbsp;&nbsp;
      <font color="#008000"><img border="0" src="images/page.gif" align="absbottom">页次：[<?php echo("<font color=\"#FF0000\">".$strPage."</font>/".$pageCount) ?>]
    </td>
    <td colspan="4" align="right" height="18">
      <?php 
			  if ($strPage > 1) {
			?>
      <a href="quiz.php?page=1<?php echo($strUrl)?>">[首 页]</a>&nbsp;&nbsp;
      <a href="quiz.php?page=<?php echo(($strPage-1).$strUrl)?>">[上一页]</a>&nbsp;&nbsp;
      <?php
        }
        if ($strPage < $pageCount) {
      ?>
      <a href="quiz.php?page=<?php echo(($strPage + 1).$strUrl)?>">[下一页]</a>&nbsp;&nbsp;
      <a href="quiz.php?page=<?php echo(($pageCount).$strUrl)?>">[末 页]</a>
      <?php
        }
      ?>
    </td>
  </tr>
  <form name="frmSearch" method="GET" action="quiz.php">
  <tr>
    <td colspan="11">
      <font color="#006699"><b>请输入主题或测试者帐号搜索：</b></font>&nbsp;
      <input type="text" name="info" size="35" value="<?php echo($strInfo)?>">&nbsp;
      <input type="submit" value="搜索" name="btnSrh"></td>
  </tr>
  </form>
</table>
</center>

</body>

</html>