<!-- #include file="conn.asp" -->

<%
  Dim strId, strTitle, strGuide, strResult
  strId = Request.QueryString("id")&""
  If IsNumeric(strId) Then
    Set rs = conn.Execute("SELECT * FROM [quiz] WHERE id=" & strId)
    If Not rs.Eof Then
      strTitle = rs("quizTitle")
	    strGuide = "<table border=1 bordercolor=#7F9DB9 cellpadding=0 cellspacing=0 width=100% style=""border-collapse: collapse"">"& vbCrLf &_
                 "  <tr bgcolor=#7F9DB9>"& vbCrLf  &_
								 "	  <td width=""30%""><font color=""#FFFFFF"">������</font></td>"& vbCrLf  &_
								 "	  <td width=""10%""><font color=""#FFFFFF"">�÷�</font></td>"& vbCrLf  &_
								 "	  <td width=""10%""><font color=""#FFFFFF"">�����ܷ�</font></td>"& vbCrLf  &_
								 "	  <td width=""10%""><font color=""#FFFFFF"">�����</font></td>"& vbCrLf  &_
								 " 	  <td width=""10%""><font color=""#FFFFFF"">�Ƿ�ͨ��</font></td>"& vbCrLf  &_
								 "	  <td width=""30%""><font color=""#FFFFFF"">�ύ����</font></td>"& vbCrLf  &_
								 "	</tr>"& vbCrLf  &_
								 "	<tr>"& vbCrLf  &_
								 "	  <td>"& rs("userId") &"</td>"& vbCrLf  &_
								 "		<td>"& rs("userScore") &"</td>"& vbCrLf  &_
								 "	  <td>"& rs("totalScore") &"</td>"& vbCrLf  &_
								 "	  <td>"& rs("passScore") &"</td>"& vbCrLf  &_
								 "	  <td>"& iif(rs("passState"), "<font color=""#008000"">��</font>", "<font color=""#FF0000"">��</font>") &"</td>"& vbCrLf  &_
								 "	  <td>"& rs("addDate") &"</td>"& vbCrLf  &_
								 "	</tr>"& vbCrLf  &_
                 "</table>"
      strResult = strGuide & vbCrLf &"<br>"& vbCrLf & rs("Result")
    Else
	  Response.Write "��¼δ�ҵ���"
	  Response.End      
    End If 
    rs.Close
    Set rs = Nothing
  Else
    Response.Write "�Ƿ���IDֵ��"
    Response.End
  End If  
%>

<html>

<head>
<meta http-equiv="Content-Type" content="text/html">
<link rel="stylesheet" type="text/css" href="style.css">
<title><%=strTitle%> - ���Խ��</title>
</head>

<body background="images/bg.gif">
<table width="97%" align="center">
  <tr>
    <td align="center"><font size="4"><%=strTitle%></font></td>
  </tr>
  <tr>
    <td><%=strResult%></td>
  </tr>
</table>
<br><br>
<center><a href="#" onClick="javascript: self.opener = null; self.close()">�رմ���</a></center>
</body>

</html>