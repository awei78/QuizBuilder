<!-- #include file="conn.asp" -->
<!-- #include file="fso.asp" -->

<%
  Dim i, delStr, strInfo, strPage, strUrl, strSrh
  '�ݵ�¼����Ա���ò�ѯ
  If Session("Sys") Then
    strSrh = "True"
  ElseIf Session("Admin") <> "" Then
    strSrh = "regMail='"& Session("Admin") &"'"
  Else
    strSrh = "regMail=''"
  End If
  
  strPage = Request.QueryString("page")
  '����
  strInfo = Trim(Request("info"))
  If strInfo = "" Then
    strUrl = ""
  Else
    strUrl = "&info="& Server.UrlEncode(strInfo)
  End If
  
  'ɾ��
  delStr = Trim(Request.QueryString("del"))
  'ɾ��������¼ 
  If IsNumeric(delStr) Then
    conn.Execute ("DELETE FROM [quiz] WHERE id="& delStr)
    DeleteFile(delStr)
    Response.Redirect "quiz.asp?page="& strPage & strUrl
  'ɾ����ѡ���¼  
  ElseIf delStr = "true" Then
    Dim delIds, arr
    delIds = Request.Form("quiz")
    'ɾ����Ӧ�ļ�
    arr = Split(delIds, ", ")
    For i = LBound(arr) To UBound(arr)
      DeleteFile(arr(i))
    Next
    conn.Execute("DELETE FROM [quiz] WHERE id IN ("& delIds &")")
    Response.Redirect "quiz.asp"
  '��ռ�¼  
  ElseIf delStr = "all" Then
    If strInfo = "" Then
      '��ɾ����Ӧ�ļ�
      Set rs = Server.CreateObject("ADODB.Recordset")
      rs.Open "SELECT id FROM [quiz] WHERE "& strSrh, conn, 3
      For i = 0 To rs.RecordCount - 1
        DeleteFile(rs("id"))
        rs.MoveNext
      Next
      Set rs = Nothing
      
      conn.Execute("DELETE FROM [quiz] WHERE "& strSrh)
    Else
      '��ɾ����Ӧ�ļ�
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
<meta name="Keywords" content="������, ��������ʦ, ������µ�������ϵͳ, E-Learning, SCORM">
<title>��������ʦ���ݹ���ϵͳ - ������Ϣ����</title>

<script type="text/javascript">
<!--
  function selAll(state) {
    if (document.frmQuiz.quiz == undefined) {
      return;
    }
  
    document.all('sel').title = state ? 'ȡ��ѡ��' : 'ȫ��ѡ��';
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
      alert('��ѡ��Ҫɾ������Ϣ��');
    }  
    else if (confirm('��ȷ��Ҫɾ����ѡ�����Ϣ��')) {
      document.frmQuiz.submit(); 
    }
  }
  
  function clearAll() {
    if (confirm('��ȷ��Ҫ������м�¼��')) {
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
    <td colspan="11" align="center" height="20"><b><font size="3" color="#006699">������Ϣ����</font></b></td>
  </tr>
  <tr>
    <td background="images/tbg.gif" width="4%"><input type="checkbox" id="sel" value="sel" title="ȫ��ѡ��" onClick="javascript: selAll(this.checked)" style="cursor: hand"></td>
    <td background="images/tbg.gif" width="4%">��� </td>
    <td background="images/tbg.gif" width="28%">���� </td>
    <td background="images/tbg.gif" width="8%">������ </td>
    <%
      If Session("Sys") Then
    %>
    <td background="images/tbg.gif" width="14%">����Ա��</td>
    <%
      End If
    %>
    <td background="images/tbg.gif" width="4%">�÷� </td>
    <td background="images/tbg.gif" width="4%">�ܷ� </td>
    <td background="images/tbg.gif" width="5%">����� </td>
    <td background="images/tbg.gif" width="7%">�Ƿ�ͨ�� </td>
    <td background="images/tbg.gif" width="4%">ɾ�� </td>
    <td background="images/tbg.gif" width="18%">�ύ���� </td>
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
    <td><%If passed Then%><font color="#008000"><%=recNo%></font><%Else%><font color="#FF0000"><%=recNo%></font><%End If%>��</td>
    <td>
    <%
        If IsObject(fso) Then 
    %>    
    <a href="data/<%=rs("id")%>.html" title="����鿴��ϸ��Ϣ" target="_blank"><%=strTitle%></a>
    <%
        Else
    %>
    <a href="show.asp?id=<%=rs("id")%>" title="����鿴��ϸ��Ϣ" target="_blank"><%=strTitle%></a>
    <%
        End If
    %> ��
    </td>
    <td><a href="mailto:<%=rs("userMail")%>" title="�����ʼ��� <%=rs("userId")%>"><%=Replace(rs("userId"), strInfo, "<font color=""#FF0000"">"&strInfo&"</font>")%></a>��</td>
    <%
      If Session("Sys") Then
    %>
    <td><%=rs("regMail")%>��</td>
    <%
      End If
    %>
    <td><%=rs("userScore")%>��</td>
    <td><%=rs("totalScore")%>��</td>
    <td><%=rs("passScore")%>��</td>
    <td><%If passed Then%><font color="#008000">��</font><%Else%><font color="#FF000">��</font><%End If%>��</td>
    <td><a href="quiz.asp?page=<%=curPage%>&del=<%=rs("id")%><%=strUrl%>" title="ɾ��������¼" onClick="javascript: return confirm('��ȷ��ɾ���˼�¼ô��')">ɾ��</a> </td>
    <td><%=rs("addDate")%>��</td>
  </tr>
  <%
        rs.MoveNext
      Next
  %>
  </form>
  <tr>
    <td colspan="7" align="left" height="18">
      <a href="#" onClick="javascript: delAll()">[�����ѡ��ļ�¼]</a>&nbsp;&nbsp;&nbsp;
      <img border="0" src="images/del.gif" align="absbottom"><a href="#" onClick="javascript: clearAll()">[������м�¼]</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      <font color="#008000">��Ϣ����[<%=rs.RecordCount%>]</font>&nbsp;&nbsp;
      <font color="#008000"><img border="0" src="images/page.gif" align="absbottom">ҳ�Σ�[<%="<font color=""#FF0000"">"& curPage &"</font>/"& rs.PageCount%>]
    </td>
    <td colspan="4" align="right" height="18">
      <%If curPage <> 1 Then%>
      <a href="quiz.asp?page=1<%=strUrl%>">[�� ҳ]</a>&nbsp;&nbsp;
      <a href="quiz.asp?page=<%=curPage - 1%><%=strUrl%>">[��һҳ]</a>&nbsp;&nbsp;
      <%
        End If
        If curPage <= rs.PageCount - 1 Then
      %>
      <a href="quiz.asp?page=<%=curPage + 1%><%=strUrl%>">[��һҳ]</a>&nbsp;&nbsp;
      <a href="quiz.asp?page=<%=rs.PageCount%><%=strUrl%>">[ĩ ҳ]</a>
      <%
        End If
      %>
    </td>
  </tr>
  <form name="frmSearch" method="GET" action="quiz.asp">
  <tr>
    <td colspan="11">
      <font color="#006699"><b>�����������������ʺ�������</b></font>&nbsp;
      <input type="text" name="info" size="35" value="<%=strInfo%>">&nbsp;
      <input type="submit" value="����" name="btnSrh"></td>
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