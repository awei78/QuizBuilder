<!-- #include file="conn.asp" -->
<!-- #include file="fso.asp" -->

<%
  '���Խ�����ݽ����ļ�
	If Request.Form("fromQuiz") <> "true" Then
	  dim strInfo
	  strInfo = "&nbsp;&nbsp;�������������Ϣ��˵������asp�������������С���ҳ�浱һ���������������Ⲣ��ִ���ύ������" &_
			    "�������ļ��Զ����ã�������Ҫ��������������ҳ����ַ���ʴ�ҳ�档��������ռ����Խ���������������ʦ��" &_
			    "��[��������]->[�������]ҳ�棬ѡ��[���͵��������ݿ�]������[��ַ]������������ҳ����ַ����http://.../receive.asp��" &_
			    "���ң�������������ļ����µ�crossdomain.xml�ļ������ڷ�������Ŀ¼�����������������в�����������ˣ����Ϳ����ռ����������ύ���������ݡ�"

	  Response.Write strInfo
	  Response.End()
	End If

	
	'�����ⲥ������������...
	Dim quizId, quizTitle, userName, userMail, userId, userScore, totalScore, passScore, passState, strResults, regMail, regCode
	quizId     = Replace(Request.Form("quizId"), "'", "''")
	quizTitle  = Replace(Request.Form("quizTitle"), "'", "''")
	userId     = Replace(Request.Form("userId"), "'", "''")
	userMail   = Replace(Request.Form("userMail"), "'", "''")
	userScore  = CDbl(Request.Form("userScore"))
	totalScore = CDbl(Request.Form("totalScore"))
	passScore  = CDbl(Request.Form("passScore"))
	passState  = Replace(Request.Form("passState"), "'", "''")
	strResults = Replace(Request.Form("quesInfo"), "'", "''")
	'��������ɵ������У�ʱ�����ƹ��ܿ��ã��������������ã�����Ϊ��λ��
	'timeLength���������ʱ��
	'elapsed��   �鿴������ʱ��������ʱ��
	'remaining�� �鿴������ʱ��ʣʱ�� 
	
	'ע����Ϣ
	regMail    = Request.Form("regMail")
	regCode    = Request.Form("regCode")
	On Error Resume Next
	
	'���뵽���ݿ�...
	'�洢����Ա��Ϣ
	If regMail&"" <> "" Then
	  Set rs = conn.Execute("SELECT id FROM [admin] WHERE userId='"& regMail &"'")
	  If rs.Eof Then conn.Execute("INSERT INTO [admin](userId, userPwd, sys) VALUES('"& regMail &"', '"& regCode &"', False)")
	  Set rs = Nothing
	End If
	'�洢������Ϣ
	If userId&"" <> "" Then
	  Set rs = conn.Execute("SELECT id FROM [users] WHERE userId='"& userId &"'")
	  If rs.Eof Then conn.Execute("INSERT INTO [users](userId, userPwd, userMail, admin) VALUES('"& userId &"', '654321', '"& userMail &"', '"& regMail &"')")
	  Set rs = Nothing	
	End If
	
	'���������ݿ�
	Dim strSql, affCount
	strSql = "INSERT INTO [quiz](quizId, quizTitle, userId, userMail, userScore, totalScore, passScore, passState, Result, regMail, regCode) " & _
	         "VALUES('"&quizId&"', '"&quizTitle&"', '"&userId&"', '"&userMail&"', "&userScore&", "&totalScore&", "&passScore&", "&passState&", '"&strResults&"', '"&regMail&"', '"&regCode&"')"
	conn.Execute strSql, affCount
	
	'������Ϣ��������...
	If affCount = 1 Then
	  Dim strUrl
	  strUrl = "http://" + Request.ServerVariables("SERVER_NAME") & Request.ServerVariables("PATH_INFO")
      strUrl = Replace(strUrl, "receive.asp", "index.asp")
	  '����html�ļ�
	  '@@identity����Access�У����һ����ADO��ʽ������Զ����ֵ
	  Set rs = conn.Execute("SELECT @@identity as id FROM [quiz]")
	  If Not rs.Eof then
	    Dim strGuide
	    
	    strGuide = "<table border=1 bordercolor=#7F9DB9 cellpadding=0 cellspacing=0 width=100% style=""border-collapse: collapse"">" &_
                 "  <tr bgcolor=#7F9DB9>"& vbCrLf  &_
								 "	  <td width=""30%""><font color=""#FFFFFF"">������</font></td>"& vbCrLf &_
								 "	  <td width=""10%""><font color=""#FFFFFF"">�÷�</font></td>"& vbCrLf &_
								 "	  <td width=""10%""><font color=""#FFFFFF"">�����ܷ�</font></td>"& vbCrLf &_
								 "	  <td width=""10%""><font color=""#FFFFFF"">�����</font></td>"& vbCrLf &_
								 " 	  <td width=""10%""><font color=""#FFFFFF"">�Ƿ�ͨ��</font></td>"& vbCrLf &_
								 "	  <td width=""30%""><font color=""#FFFFFF"">�ύ����</font></td>"& vbCrLf &_
								 "	</tr>"& vbCrLf &_
								 "	<tr>"& vbCrLf &_
								 "	  <td>"& userId &"</td>"& vbCrLf &_
								 "	  <td>"& userScore &"</td>"& vbCrLf &_
								 "	  <td>"& totalScore &"</td>"& vbCrLf &_
								 "	  <td>"& passScore &"</td>"& vbCrLf &_
								 "	  <td>"& iif(passState, "<font color=""#008000"">��</font>", "<font color=""#FF0000"">��</font>") &"</td>"& vbCrLf &_
								 "	  <td>"& Now() &"</td>"& vbCrLf &_
								 "	</tr>"& vbCrLf &_
								 "</table>"
	    
	    Call CreateHtmlFile(rs("id"), quizTitle, strGuide & vbCrLf &"<br>"& vbCrLf & strResults)
	    strUrl = Replace(strUrl, "index.asp", "show.asp?id="&rs("id"))
	  End If
	  Set rs = Nothing
	
      Response.Write("feedMsg=��ϲ�������ݷ��ͳɹ������ɵ�<a href='"& strUrl &"' target='_blank'><font color='#0000FF'>"& strUrl &"</font></a>�鿴���Խ��")	
	Else
	  Response.Write("feedMsg=���ݷ���ʧ�ܣ�")	
	End If
%>