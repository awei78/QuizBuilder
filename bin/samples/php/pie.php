<?php
  $strType =$_GET["t"];
  $passCount = $_GET["p"];
  $failCount = $_GET["f"];
  
  $total[1][0] = "及格数";
  $total[2][0] = "不及格数";

  $total[1][1] = $passCount; 
  $total[2][1] = $failCount; 
	
  $strTopic = ($strType == "quiz") ? "试题" : "用户";
  $strAdmin = $_GET["a"];
  
	/*
	参数含义(传递的数组，横坐标，纵坐标，图表的宽度，图表的高度,图表的类型)
	纯ASP代码生成图表函数3——饼图
	作者：龚鸣(Passwordgm) QQ:25968152 MSN:passwordgm@sina.com Email:passwordgm@sina.com
	本人非常愿意和ASP,VML,FLASH的爱好者在HTTP://www.ilisten.cn进行交流和探讨
	非常感谢您使用这个函数，请您使用和转载时保留版权信息，这是对作者工作的最好的尊重。
	*/
	function draw_pie($total_data, $table_x, $table_y, $all_width, $all_height) {
		$tb_height = 30;

		$tb_color[1][1] = "#008000";
		$tb_color[2][1] = "#800000";

		$tb_color[1][2] = "#008000";
		$tb_color[2][2] = "#800000";

		$total_no = 2;
		$totalPie = 0;
		for ($i = 1; $i <= $total_no; $i++) {
		  $totalPie = $totalPie + $total_data[$i][1];
		}

		$preAngle = 0;
		for ($i = 1; $i <= $total_no; $i++) {
		  echo "<v:shape id='_x0000_s1025' alt='' style='position:absolute;left:".$table_x."px;top:".$table_y."px;width:".$all_width."px;height:".$all_height."px;z-index:1' coordsize='1500,1400' o:spt='100' adj='0,,0' path='m750,700ae750,700,750,700,".round(23592960*$preAngle).",".round(23592960*$total_data[$i][1]/$totalPie)."xe' fillcolor='".$tb_color[$i][1]."' strokecolor='#FFFFFF'><v:fill color2='".$tb_color[$i][2]."' rotate='t' focus='100%' type='gradient'/><v:stroke joinstyle='round'/><v:formulas/><v:path o:connecttype='segments'/></v:shape>\n";
		  $preAngle = $preAngle + $total_data[$i][1] / $totalPie;
		}

		$pie = 3.14159265358979;
		$tempPie = 0;
		for ($i = 1; $i <= $total_no; $i++) {
		  $tempAngle = $pie * 2 * ($total_data[$i][1] / ($totalPie * 2) + $tempPie);
		  $x1 = $table_x + $all_width / 2 + cos($tempAngle) * $all_width * 3 / 8;
		  $y1 = $table_y + $all_height / 2 - sin($tempAngle) * $all_height * 3 / 8;
		  $x2 = $table_x + $all_width / 2 + cos($tempAngle) * $all_width * 3 / 4;
		  $y2 = $table_y + $all_height / 2 - sin($tempAngle) * $all_height * 3 / 4;
		  if ($x2 > $table_x + $all_width / 2) {
		    $x3 = $x2 + 20;
		    $x4 = $x3;
		  }
			else {
		    $x3 = $x2 - 20;
		    $x4 = $x3 - 100;
		  }
		  echo "<v:oval id='_x0000_s1027' style='position:absolute;left:".($x1-2)."px;top:".($y1-2)."px;width:4px;height:4px; z-index:2' fillcolor='#111111' strokecolor='#111111'/>\r";
		  echo "<v:line id='_x0000_s1025' alt='' style='position:absolute;left:0;text-align:left;top:0;z-index:1' from='".$x1."px,".$y1."px' to='".$x2."px,".$y2."px' coordsize='21600,21600' strokecolor='#111111' strokeweight='1px'></v:line>";
		  echo "<v:line id='_x0000_s1025' alt='' style='position:absolute;left:0;text-align:left;top:0;z-index:1' from='".$x2."px,".$y2."px' to='".$x3."px,".$y2."px' coordsize='21600,21600' strokecolor='#111111' strokeweight='1px'></v:line>";
		  echo "<v:shape id='_x0000_s1025' type='#_x0000_t202' alt='' style='position:absolute;left:".$x4."px;top:".($y2-10)."px;width:130px;height:20px;z-index:1'>";
		  echo "<v:textbox inset='0px,0px,0px,0px'><table cellspacing='3' cellpadding='0' width='100%' height='100%'><tr><td align='left'>".$total_data[$i][0]." ".number_format($total_data[$i][1] * 100 / $totalPie, 2)."%</td></tr></table></v:textbox></v:shape>";
		  $tempPie = $tempPie + $total_data[$i][1] / $totalPie;
		}
	}
?>

<html xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=gb2312">
<link rel="stylesheet" type="text/css" href="style.css">
<title>图表显示</title>
</head>

<body background="images/bg.gif">
<center>
<table border="1" width="100%" bordercolor="#7F9DB9" style="border-collapse: collapse">
  <tr>
    <td align="right" width="15%" height="18"><?php echo($strTopic) ?>：</td>
    <td width="35%" height="18"><?php echo($_GET["u"]) ?></td>
    <td align="right" width="15%" height="18">管理员：</td>
    <td width="35%" height="18"><?php echo($strAdmin) ?></td>
  </tr>
  <tr>
    <td align="right" width="15%" height="18">及格数：</td>
    <td width="35%" height="18"><font color="#008000"><?php echo($passCount) ?></font>　</td>
    <td align="right" width="15%" height="18">不及格数：</td>
    <td width="35%" height="18"><font color="#800000"><?php echo($failCount) ?></font>　</td>
  </tr>
</table>  
</center>  
<br><br>
<?php
  draw_pie($total, 195, 125, 250, 250);
?>
</body>

</html>