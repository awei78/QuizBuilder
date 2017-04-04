<?php
  include_once("conn.php");

  //据登录管理员设置查询
  $strType = $_GET["type"];
  if ($strType == "") {
	  $strType = "quiz";
	}
  $strSort= ($strType == "quiz") ? "quizTitle" : "userId";
  
  $strUser = $_GET["user"];
  $strAdmin = $_GET["admin"];
  if ($strUser != "") {
    $strSrh = "userId='".$strUser."'";
    $strUrl = "user=".$strUser."&type=".$strType;
	}
  elseif ($_GET["sort"] != "") {
    $strSrh = $strSort."='".$_GET["sort"]."' AND regMail='".$strAdmin."'";
    $strUrl = "sort=".urlencode($_GET["sort"])."&admin=".$strAdmin."&type=".$strType;
    //细项查询
		if ($_GET["score"] != "") {
		  $strSrh .= " AND userScore=".$_GET["score"];
			$strUrl .= "&score=".$_GET["score"];
  	}
		elseif ($_GET["pass"] == "true") {
		  $strSrh .= " AND userScore >= passScore";
			$strUrl .= "&pass=true";
		}
		elseif ($_GET["fail"] == "true") {
		  $strSrh .= " AND userScore < passScore";
			$strUrl .= "&fail=true";
  	}
	} 
  elseif (strtolower($strAdmin) != "admin") {
    $strSrh = "regMail='".$strAdmin."'";
    $strUrl = "admin=".$strAdmin."&type=".$strType;
	} 
  else {
    $strSrh = TRUE;
    $strUrl = "admin=".$strAdmin."&type=".$strType;
	} 
  $strSql = "SELECT * FROM quiz WHERE ".$strSrh." ORDER BY id DESC";
  $strPage = ($_GET["page"] == 0) ? 1 : $_GET["page"];
  
  //删除操作...
  $delStr = trim($_GET["del"]);
  //删除单条记录 
  if (is_numeric($delStr)) { 
	  mysql_query("DELETE FROM `quiz` WHERE `id`='".$delStr."'", $conn);
	  goto_url("quiz.php?page=".$strPage.$strUrl);
  }
	//删除多条记录
  elseif ($delStr == "true") {
    $delIds = implode(",", $_REQUEST["quiz"]);
		mysql_query("DELETE FROM `quiz` WHERE `id` IN (".$delIds.")", $conn);
    goto_url("ques.php?".$strUrl);
	}
  //清空记录
  elseif ($delStr == "all") {
    mysql_query("DELETE FROM `quiz` WHERE ".$strSrh, $conn);
    goto_url("ques.php?".$strUrl);
  }
?>
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=gb2312">
<link rel="stylesheet" type="text/css" href="style.css">
<meta name="Keywords" content="秋风软件, 秋风试题大师, 秋风人事档案管理系统, E-Learning, SCORM">
<title>秋风试题大师数据管理系统 - 试题信息统计</title>

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
      window.location.href = 'ques.php?del=all&<?php echo($strUrl) ?>';
    }
  }
-->
</script>
</head>

<body>

<center>
<table border="1" width="100%" cellpadding="0" cellspacing="0" bordercolor="#7F9DB9" style="border-collapse: collapse">
  <tr>
    <td colspan="11" align="center" height="20"><b><font size="3" color="#006699">试题信息统计</font></b></td>
  </tr>
  <form name="frmQuiz" method="POST" action="ques.php?del=true&<?php echo($strUrl) ?>">
  <tr>
    <td background="images/tbg.gif" width="4%"><input type="checkbox" id="chkAll" value="1" title="全部选择" onClick="javascript: checkAll(this.form)" style="cursor: hand"></td>
    <td background="images/tbg.gif" width="4%">序号 </td>
    <td background="images/tbg.gif" width="30%">标题 </td>
    <td background="images/tbg.gif" width="8%">测试者 </td>
    <?php
      if ($_SESSION["sys"]) {
    ?>
    <td background="images/tbg.gif" width="12%">管理员　</td>
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
		$rs = mysql_query($strSql, $conn);
		$num = mysql_num_rows($rs);
	  $pageSize = PAGE_SIZE;
		$pageCount = ceil($num / $pageSize);
		if ($strPage > $pageCount) {
		  $strPage = $pageCount;
	  }
			
		$start = ($strPage - 1) * $pageSize;
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
  ?>
  <tr <?php if ($i % 2 != 0) { ?> bgcolor="#E0E0E0"<?php } ?>>
    <td><input type="checkbox" name="quiz[]" value="<?php echo($row['id'])?>"></td>
    <td><?php if ($row['passState']) echo("<span style=\"color:#080\">".$recNo."</span>");else echo("<span style=\"color:#F00\">".$recNo."</span>")?>　</td>
    <td><a href="show.php?id=<?php echo($row['id'])?>" title="点击查看详细信息" target="_blank"><?php echo($row["quizTitle"]) ?></a> </td>
    <td><a href="mailto:<?php echo($row["userMail"]) ?>" title="发个邮件给 <?php echo($row["userId"]) ?>"><?php echo($row["userId"]) ?></a>　</td>
    <?php
      if ($_SESSION["sys"]) {
    ?>
    <td><?php echo($row["regMail"]) ?>　</td>
    <?php
      }
    ?>
    <td><?php echo($row["userScore"]) ?>　</td>
    <td><?php echo($row["totalScore"]) ?>　</td>
    <td><?php echo($row["passScore"]) ?>　</td>
    <td><?php if ($row['passState']) echo("<span style=\"color:#080\">是</span>"); else echo("<span style=\"color:#F00\">否</span>") ?> </td>
    <td><a href="ques.php?page=<?php echo(curPage."&del=".$row["id"]."&".$strUrl) ?>" title="删除此条记录" onClick="javascript: return confirm('您确定删除此记录么？')">删除</a> </td>
    <td><?php echo($row["addDate"]) ?>　</td>
  </tr>
  <?php
    }
  ?>
  </form>
  <tr>
    <td colspan="6" align="left" height="18">
      <a href="#" onClick="javascript: delAll()">[清除所选择的记录]</a>&nbsp;&nbsp;&nbsp;
      <img border="0" src="images/del.gif" align="absbottom"><a href="#" onClick="javascript: clearAll()">[清空所有记录]</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      <font color="#008000">信息数：[<?php echo($num )?>]</font>&nbsp;&nbsp;
      <font color="#008000"><img border="0" src="images/page.gif" align="absbottom">页次：[<?php echo("<font color=\"#FF0000\">".$strPage."</font>/".$pageCount) ?>]
    </td>
    <td colspan="5" align="right" height="18">
      <?php 
			  if ($strPage > 1) {
			?>
      <a href="ques.php?page=1&<?php echo($strUrl)?>">[首 页]</a>&nbsp;&nbsp;
      <a href="ques.php?page=<?php echo(($strPage-1)."&".$strUrl)?>">[上一页]</a>&nbsp;&nbsp;
      <?php
        }
        if ($strPage < $pageCount) {
      ?>
      <a href="ques.php?page=<?php echo(($strPage + 1)."&".$strUrl)?>">[下一页]</a>&nbsp;&nbsp;
      <a href="ques.php?page=<?php echo(($pageCount)."&".$strUrl)?>">[末 页]</a>
      <?php
        }
      ?>
    </td>
  </tr>
</table>
</center>

</body>

</html>