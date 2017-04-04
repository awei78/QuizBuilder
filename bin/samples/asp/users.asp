<!-- #include file="conn.asp" -->

<%
  If Session("Admin") = "" Then Response.Redirect "index.html"  

  Dim i, delStr, strInfo, strPage, strUrl, strSrh
  '据登录管理员设置查询
  If Session("Sys") = True Then
    strSrh = "True"
  ElseIf Session("Admin") <> "" Then
    strSrh = "admin='"& Session("Admin") &"'"
  Else
    strSrh = "admin=''"
  End If
  
  strPage = Request.QueryString("page")
  If Not IsNumeric(strPage) Then strPage = "0"
  
  strInfo = Trim(Request("sinfo"))
  If strInfo = "" Then
    strUrl = ""
  Else
    strUrl = "&sinfo=" & Server.UrlEncode(strInfo)
  End If
  
  '网络检测启用与否...
  '启用
  If Request.QueryString("u") <> "" Then
    conn.Execute("UPDATE [users] SET inUse=True WHERE id="& Request.QueryString("u"))
  End If
  '禁用
  If Request.QueryString("r") <> "" Then
    conn.Execute("UPDATE [users] SET inUse=False WHERE id="& Request.QueryString("r"))
  End If
  
  Dim strId, strUid, strPwd, strMail, inUse
  '取编辑数据
  strId = Request.QueryString("id") & ""
  If IsNumeric(strId) Then
    Set rs = conn.Execute("SELECT * FROM [users] WHERE "& strSrh &" AND id="& strId)
    If Not rs.EOF Then
      strUid = rs("userId")
      strPwd = rs("userPwd")
      strMail = rs("userMail")
      inUse = rs("inUse")
    End If
    Set rs = Nothing
  End If
    
  Dim strAct
  strAct = Request.QueryString("act")
  '添加
  If strAct = "add" Then
    strUid = Request.Form("userId")
    set rs = conn.Execute("SELECT id FROM [users] WHERE "& strSrh &" AND userId='"& strUid &"'")
    
    If Not rs.EOF Then
      Response.Write("<script language='javascript'>alert('您要添加的帐号 ["&strUid&"] 已存在！'); window.location.href='users.asp'</script>")
    Else
      strPwd = Request.Form("userPwd")
      strMail = Request.Form("userMail")
      inUse = Request.Form("cbUse")
      If inUse = "" Then inUse = False
      conn.Execute("INSERT INTO [users](userId, userPwd, userMail, admin, inUse) VALUES('"& strUid &"', '"& strPwd &"', '"& strMail &"', '"& Session("Admin") &"', "& inUse &")")
      
      Response.Redirect "users.asp?page="& strPage & strUrl
    End If
    
    Set rs = Nothing
  End If
  
  '编辑
  If strAct = "edit" Then
    strUid = Replace(Request.Form("userId"), "'", "''")
    strId = Request.Form("id")
    set rs = conn.Execute("SELECT id FROM [users] WHERE "& strSrh &" AND userId='"& strUid &"' AND id <> "& strId)
    
    If Not rs.EOF Then
      Response.Write("<script language='javascript'>alert('您要更新的帐号 ["&strUid&"] 已存在！'); window.history.back()</script>")
    Else
      strPwd = Request.Form("userPwd")
      strMail = Request.Form("userMail")
      inUse = Request.Form("cbUse")
      If inUse = "" Then inUse = False
      conn.Execute("UPDATE [users] SET userId='"& strUid &"', userPwd='"& strPwd &"', userMail='"& strMail &"', inUse="& inUse &" WHERE id="& strId)
      
      Response.Redirect "users.asp?page=" & strPage & strUrl
    End If
    
    Set rs = Nothing
  End If

  '删除.
  delStr = Trim(Request.QueryString("del"))
  '删除单条记录
  If IsNumeric(delStr) Then
    conn.Execute ("DELETE FROM [users] WHERE id="& delStr)
    Response.Redirect "users.asp?page="& strPage & strUrl
  '删除所选择记录      
  ElseIf delStr = "true" Then
    Dim delIds
    delIds = Request("id")
    conn.Execute("DELETE FROM [users] WHERE id IN ("& delIds &")")
    Response.Redirect "users.asp?page="& strPage & strUrl
  '清空记录  
  ElseIf delStr = "all" Then
    If strInfo = "" Then
      conn.Execute ("DELETE FROM [users] WHERE "& strSrh)
    Else
      conn.Execute("DELETE FROM [users] WHERE "& strSrh &" AND userId LIKE '%"& strInfo &"%'")
    End If
    Response.Redirect "users.asp"
  End If
%>

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
  
  function selAll(state) {
    if (document.frmUser.id == undefined) {
      return;
    }
  
    document.all('sel').title = state ? '取消选择' : '全部选择';
    document.frmUser.id.checked = state;
    for (var i = 0; i <= document.frmUser.id.length - 1; i++) {
      document.frmUser.id[i].checked = state;
    }
  }
  
  function delAll() {
    var hasChecked = false;
    for (var i = 0; i <= document.frmUser.id.length - 1; i++) {
      if (document.frmUser.id[i].checked) {
        hasChecked = true;
        break;
      }
    }
    if (!hasChecked) {
      hasChecked = document.frmUser.id.checked;
    }
    
    if (!hasChecked) {
      alert('请选择要删除的账号信息！');
    }
    else if (confirm('您确定要删除所选择的信息吗？')) {
      document.frmUser.submit();
    }
  }
  
  function clearAll() {
    if (confirm('您确定要清空所有记录吗？')) {
      window.location.href = 'users.asp?del=all&sinfo=<%=Server.URLEncode(strInfo)%>';
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
  <tr>
    <td background="images/tbg.gif" width="4%"><input type="checkbox" id="sel" value="sel" title="全部选择" onClick="javascript: selAll(this.checked)" style="cursor: hand"></td>
    <td background="images/tbg.gif" width="4%">序号</td>
    <td background="images/tbg.gif" width="15%">用户账号</td>
    <td background="images/tbg.gif" width="10%">密码</td>
    <td background="images/tbg.gif" width="14%">邮件</td>
    <%
      If Session("Sys") Then
    %>
    <td background="images/tbg.gif" width="15%">管理员</td>
    <%
      End If
    %>
    <td background="images/tbg.gif" width="8%">启用检测</td>
    <td background="images/tbg.gif" width="6%">删除<img border="0" src="images/del.gif"></td>
    <td background="images/tbg.gif" width="6%">编辑<img border="0" src="images/write.gif"></td>
    <td background="images/tbg.gif" width="18%">加入日期</td>
  </tr>
  <%
    Set rs = Server.CreateObject("ADODB.Recordset")
    If strInfo = "" OR LCase(strInfo) = "admin" Then
      rs.Open "SELECT *, (SELECT Count(id) FROM [quiz] WHERE userId=users.userId) as [recCount] FROM [users] WHERE "& strSrh &" ORDER BY id DESC", conn, 3
    Else
      rs.Open "SELECT *, (SELECT Count(id) FROM [quiz] WHERE userId=users.userId) as [recCount] FROM [users] WHERE "& strSrh &" AND (userId LIKE '%"& strInfo &"%' OR admin LIKE '%"& strInfo &"%') ORDER BY id DESC", conn, 3
    End If
    If rs.RecordCount <> 0 Then
      Dim curPage
      rs.PageSize = 18
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
      
        Dim recNo
        recNo = rs.PageSize * (curPage - 1) + i + 1
        Dim strUser
        strUser = Replace(rs("userId"), strInfo, "<font color=""#FF0000"">"&strInfo&"</font>")
  %>
  <form name="frmUser" method="POST" action="?del=true<%=strUrl%>">
  <tr <%If i Mod 2 <> 0 Then%> bgcolor="#E0E0E0"<%End If%>>
    <td><input type="checkbox" name="id" value="<%=rs("id")%>"></td>
    <td><%=recNo%>　</td>
    <td><a href="ques.asp?user=<%=Server.URLEncode(rs("userId"))%>" title="查看此用户所有试题 [<%=rs("recCount")%>条]" target="_blank"><%=strUser%></a>　</td>
    <td><%=rs("userPwd")%>　</td>
    <td><a href="mailto:<%=rs("userMail")%>" title="发个邮件到<%=rs("userMail")%>"><%=rs("userMail")%></a>　</td>
    <%
        If Session("Sys") Then
    %>
    <td><%=Replace(rs("admin"), strInfo, "<font color=""#FF0000"">"&strInfo&"</font>")%> 　</td>
    <%
        End If
    %>
    <td>
    <%
        If rs("inUse") Then
          Response.Write "<a href=""users.asp?page="& curPage & strUrl &"&r="& rs("id") &""" title=""禁用当前账号的网络检测功能""><font color=""#FF0000"">禁用</font></a>"
        Else
          Response.Write "<a href=""users.asp?page="& curPage & strUrl &"&u="& rs("id") &""" title=""启用当前账号的网络检测功能""><font color=""#008000"">启用</font></a>"
        End If
    %> 　
    </td>
    <td><a href="users.asp?page=<%=curPage%>&del=<%=rs("id")%><%=strUrl%>" title="删除当前记录" onClick="javascript: return confirm('您确定删除此帐号么？')">删除</a> </td>
    <td><a href="users.asp?page=<%=curPage%>&id=<%=rs("id")%><%=strUrl%>" title="编辑当前记录">编辑</a></td>
    <td><%=rs("addDate")%>　</td>
  </tr>
  <%
        rs.MoveNext
      Next
  %>
  <tr>
    <td colspan="6" align="left" height="18" valign="bottom">
      <a href="#" onClick="javascript: delAll()">[清除所选择的记录]</a>&nbsp;&nbsp;&nbsp;
      <img border="0" src="images/del.gif" align="absbottom"><a href="#" onClick="javascript: clearAll()">[清空所有记录]</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      <font color="#008000">信息数：[<%=rs.RecordCount%>]</font>&nbsp;&nbsp;
      <font color="#008000">
      <img border="0" src="images/page.gif" align="absbottom">页次：[<%=curPage &"/"& rs.PageCount%>]</font>
    </td>
    <td colspan="4" align="right" height="18" valign="bottom">
      <%if curPage <> 1 then%>
      <a href="users.asp?page=1<%=strUrl%>">[首 页]</a>&nbsp;&nbsp;&nbsp;
      <a href="users.asp?page=<%=curPage - 1%><%=strUrl%>">[上一页]</a>&nbsp;&nbsp;&nbsp;
      <%
        End If
        If curPage <= rs.PageCount - 1 Then
      %>
      <a href="users.asp?page=<%=curPage + 1%><%=strUrl%>">[下一页]</a>&nbsp;&nbsp;&nbsp;
      <a href="users.asp?page=<%=rs.PageCount%><%=strUrl%>">[末 页]</a>
      <%
        End If
      %>
    </td>
  </tr>
  </form>
  <form name="frmSearch" method="GET" action="users.asp">
  <tr>
    <td colspan="10" align="left">
      <font color="#006699"><b>请输入您要搜索的帐号：</b></font>&nbsp;
      <input type="text" name="sinfo" size="32" value="<%=strInfo%>">&nbsp;
      <input type="submit" value="搜索"></td>
  </tr>
  </form>
  <%
    End If
    Set rs = Nothing
  %>
</table>

<br><br>
<%
  Dim strCap
  If strId <> "" Then
    strAct = "edit"
    strCap = "更新"
  Else
    strAct = "add"
    strCap = "添加"
  End If
%>
<table border="1" width="90%" cellspacing="0" cellpadding="0" style="border-collapse: collapse" bordercolor="#7F9DB9">
  <form name="frmAdd" method="POST" action="?page=<%=curPage%><%=strUrl%>&act=<%=strAct%>" onSubmit="javascript: return checkData()" onReset="javascript: document.all('info').innerHTML = ''; this.userId.focus()">
  <tr>
    <td width="25%" align="right">　</td>
    <td width="75%"><b><font size="2" color="#006699"><%=strCap%>帐号</font></b>　</td>
  </tr>
  <tr>
    <td width="25%" align="right">帐号：&nbsp; </td>
    <td width="75%">
    <input type="input" name="userId" value="<%=strUid%>" style="width: 180; height: 20" size="20">&nbsp; <label id="info"></label></td>
  </tr>
  <tr>
    <td width="25%" align="right">密码：&nbsp; </td>
    <td width="75%">
    <input type="input" name="userPwd" value="<%=strPwd%>" style="width: 180; height: 20" size="20"></td>
  </tr>
  <tr>
    <td width="25%" align="right">邮件：&nbsp; </td>
    <td width="75%">
    <input type="input" name="userMail" value="<%=strMail%>" style="width: 180; height: 20" size="20"></td>
  </tr>
  <tr>
    <td width="25%" align="right">启用检测：&nbsp; </td>
    <td width="75%"><input type="checkbox" name="cbUse" value="True" <%If inUse Or strId = "" Then%>checked<%End If%>>&nbsp; 
    <font color="#0000FF">(此处设置，对应试题大师属性设置之<font color="#FF6600">[试题保护]</font>-><font color="#FF6600">[密码保护]</font>-><font color="#FF6600">[网页验证]</font>之选项)</font></td>
  </tr>
  <tr>
    <td width="25%"></td>
    <td width="75%">
      <input type="submit" value="<%=strCap%>" name="btnTurn">&nbsp;&nbsp;&nbsp;
      <input type="reset" value="重置" name="btnReset">&nbsp;&nbsp;&nbsp;
      <%If strId <> "" Then%>
        <input type="hidden" name="id" value="<%=strId%>">
        <input type="button" value="取消" name="btnCancel" onClick="javascript: window.location.href='users.asp'">
      <%End If%>
    </td>
  </tr>
  </form>
</table>

</body>

</html>