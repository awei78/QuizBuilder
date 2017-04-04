<!-- #include file="conn.asp" -->
<!-- #include file="fso.asp" -->

<%
  Dim i, delStr, strInfo, strPage, strUrl, strSrh
  '据登录管理员设置查询
  If Session("Sys") Then
    strSrh = "True"
  ElseIf Session("Admin") <> "" Then
    strSrh = "regMail='"& Session("Admin") &"'"
  Else
    strSrh = "regMail=''"
  End If
  
  strPage = Request.QueryString("page")
  '搜索
  strInfo = Trim(Request("info"))
  If strInfo = "" Then
    strUrl = ""
  Else
    strUrl = "&info="& Server.UrlEncode(strInfo)
  End If
  
  '删除
  delStr = Trim(Request.QueryString("del"))
  '删除单条记录 
  If IsNumeric(delStr) Then
    conn.Execute ("DELETE FROM [quiz] WHERE id="& delStr)
    DeleteFile(delStr)
    Response.Redirect "quiz.asp?page="& strPage & strUrl
  '删除所选择记录  
  ElseIf delStr = "true" Then
    Dim delIds, arr
    delIds = Request.Form("quiz")
    '删除对应文件
    arr = Split(delIds, ", ")
    For i = LBound(arr) To UBound(arr)
      DeleteFile(arr(i))
    Next
    conn.Execute("DELETE FROM [quiz] WHERE id IN ("& delIds &")")
    Response.Redirect "quiz.asp"
  '清空记录  
  ElseIf delStr = "all" Then
    If strInfo = "" Then
      '先删除对应文件
      Set rs = Server.CreateObject("ADODB.Recordset")
      rs.Open "SELECT id FROM [quiz] WHERE "& strSrh, conn, 3
      For i = 0 To rs.RecordCount - 1
        DeleteFile(rs("id"))
        rs.MoveNext
      Next
      Set rs = Nothing
      
      conn.Execute("DELETE FROM [quiz] WHERE "& strSrh)
    Else
      '先删除对应文件
      Set rs = Server.CreateObject("ADODB.Recordset")
      rs.Open "SELECT id FROM [quiz] WHERE "& strSrh &" AND quizTitle LIKE '%"& strInfo &"%' OR userId LIKE '%"& strInfo &"%'", conn, 3
      For i = 0 To rs.RecordCount - 1
        DeleteFile(rs("id"))
        rs.MoveNext
      Next
      Set rs = Nothing

      conn.Execute("DELETE FROM [quiz] WHERE "& strSrh &" AND quizTitle LIKE '%"& strInfo &"%' OR userId LIKE '%"& strInfo &"%'")
    End If
    Response.Redirect "quiz.asp"
  End If
%>
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=gb2312">
<link rel="stylesheet" type="text/css" href="style.css">
<meta name="Keywords" content="秋风软件, 秋风试题大师, 秋风人事档案管理系统, E-Learning, SCORM">
<title>秋风试题大师数据管理系统 - 试题信息管理</title>

<script type="text/javascript">
<!--
  function selAll(state) {
    if (document.frmQuiz.quiz == undefined) {
      return;
    }
  
    document.all('sel').title = state ? '取消选择' : '全部选择';
    document.frmQuiz.quiz.checked = state;
    for (var i = 0; i <= document.frmQuiz.quiz.length - 1; i++) {
      document.frmQuiz.quiz[i].checked = state;
    }
  }
  
  function delAll() {
    var hasChecked = false;
    for (var i = 0; i <= document.frmQuiz.quiz.length - 1; i++) {
      if (document.frmQuiz.quiz[i].checked) {
        hasChecked = true;
        break;
      }
    }
    if (!hasChecked) {
      hasChecked = document.frmQuiz.quiz.checked;
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
      window.location.href = 'quiz.asp?del=all&info=<%=Server.URLEncode(strInfo)%>';
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
  <tr>
    <td background="images/tbg.gif" width="4%"><input type="checkbox" id="sel" value="sel" title="全部选择" onClick="javascript: selAll(this.checked)" style="cursor: hand"></td>
    <td background="images/tbg.gif" width="4%">序号 </td>
    <td background="images/tbg.gif" width="28%">标题 </td>
    <td background="images/tbg.gif" width="8%">测试者 </td>
    <%
      If Session("Sys") Then
    %>
    <td background="images/tbg.gif" width="14%">管理员　</td>
    <%
      End If
    %>
    <td background="images/tbg.gif" width="4%">得分 </td>
    <td background="images/tbg.gif" width="4%">总分 </td>
    <td background="images/tbg.gif" width="5%">及格分 </td>
    <td background="images/tbg.gif" width="7%">是否通过 </td>
    <td background="images/tbg.gif" width="4%">删除 </td>
    <td background="images/tbg.gif" width="18%">提交日期 </td>
  </tr>
  <form name="frmQuiz" method="POST" action="quiz.asp?del=true">
  <%
    Set rs = Server.CreateObject("ADODB.Recordset")
    If strInfo = "" Then
      rs.Open "SELECT * FROM [quiz] WHERE "& strSrh &" ORDER BY addDate DESC", conn, 3
    Else
      rs.Open "SELECT * FROM [quiz] WHERE "& strSrh &" AND (quizTitle LIKE '%" &strInfo& "%' OR userId LIKE '%" &strInfo& "%') ORDER BY addDate DESC", conn, 3
    End If
    If rs.RecordCount <> 0 Then
      Dim curPage
      rs.PageSize = g_pageSize
      If strPage <> "" Then
        curPage = CLng(strPage)
      Else
        curPage = 0
      End If
      If curPage < 1 Then curPage = 1
      If curPage > rs.PageCount Then curPage = rs.PageCount
      rs.AbsolutePage = curPage
      
      For i = 0 To rs.PageSize - 1
        If rs.PageSize * (curPage - 1) + i >= rs.RecordCount Then Exit For
      
        Dim passed, recNo, strTitle
        passed = rs("passState") = "True"
        recNo = rs.PageSize * (curPage - 1) + i + 1
        strTitle = Replace(rs("quizTitle"), strInfo, "<font color=""#FF0000"">" & strInfo & "</font>")
  %>
  <tr <%If i Mod 2 <> 0 Then%> bgcolor="#E0E0E0"<%End If%>>
    <td><input type="checkbox" name="quiz" value="<%=rs("id")%>"></td>
    <td><%If passed Then%><font color="#008000"><%=recNo%></font><%Else%><font color="#FF0000"><%=recNo%></font><%End If%>　</td>
    <td>
    <%
        If IsObject(fso) Then 
    %>    
    <a href="data/<%=rs("id")%>.html" title="点击查看详细信息" target="_blank"><%=strTitle%></a>
    <%
        Else
    %>
    <a href="show.asp?id=<%=rs("id")%>" title="点击查看详细信息" target="_blank"><%=strTitle%></a>
    <%
        End If
    %> 　
    </td>
    <td><a href="mailto:<%=rs("userMail")%>" title="发个邮件给 <%=rs("userId")%>"><%=Replace(rs("userId"), strInfo, "<font color=""#FF0000"">"&strInfo&"</font>")%></a>　</td>
    <%
      If Session("Sys") Then
    %>
    <td><%=rs("regMail")%>　</td>
    <%
      End If
    %>
    <td><%=rs("userScore")%>　</td>
    <td><%=rs("totalScore")%>　</td>
    <td><%=rs("passScore")%>　</td>
    <td><%If passed Then%><font color="#008000">是</font><%Else%><font color="#FF000">否</font><%End If%>　</td>
    <td><a href="quiz.asp?page=<%=curPage%>&del=<%=rs("id")%><%=strUrl%>" title="删除此条记录" onClick="javascript: return confirm('您确定删除此记录么？')">删除</a> </td>
    <td><%=rs("addDate")%>　</td>
  </tr>
  <%
        rs.MoveNext
      Next
  %>
  </form>
  <tr>
    <td colspan="7" align="left" height="18">
      <a href="#" onClick="javascript: delAll()">[清除所选择的记录]</a>&nbsp;&nbsp;&nbsp;
      <img border="0" src="images/del.gif" align="absbottom"><a href="#" onClick="javascript: clearAll()">[清空所有记录]</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      <font color="#008000">信息数：[<%=rs.RecordCount%>]</font>&nbsp;&nbsp;
      <font color="#008000"><img border="0" src="images/page.gif" align="absbottom">页次：[<%="<font color=""#FF0000"">"& curPage &"</font>/"& rs.PageCount%>]
    </td>
    <td colspan="4" align="right" height="18">
      <%If curPage <> 1 Then%>
      <a href="quiz.asp?page=1<%=strUrl%>">[首 页]</a>&nbsp;&nbsp;
      <a href="quiz.asp?page=<%=curPage - 1%><%=strUrl%>">[上一页]</a>&nbsp;&nbsp;
      <%
        End If
        If curPage <= rs.PageCount - 1 Then
      %>
      <a href="quiz.asp?page=<%=curPage + 1%><%=strUrl%>">[下一页]</a>&nbsp;&nbsp;
      <a href="quiz.asp?page=<%=rs.PageCount%><%=strUrl%>">[末 页]</a>
      <%
        End If
      %>
    </td>
  </tr>
  <form name="frmSearch" method="GET" action="quiz.asp">
  <tr>
    <td colspan="11">
      <font color="#006699"><b>请输入主题或测试者帐号搜索：</b></font>&nbsp;
      <input type="text" name="info" size="35" value="<%=strInfo%>">&nbsp;
      <input type="submit" value="搜索" name="btnSrh"></td>
  </tr>
  </form>
  <%
    End If
    Set rs = Nothing
  %>
</table>
</center>

</body>

</html>