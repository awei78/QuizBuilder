<!-- #include file="conn.asp" -->

<%
  Dim strQId , strUser, strPwd, strSql
  strQId = Request.Form("quizId")
  strUser = Request.Form("userId")
  strPwd = Request.Form("userPwd")
  
  strSql = "SELECT id FROM [users] WHERE userId='"& strUser &"' AND userPwd='"& strPwd &"' AND inUse=True"
  Set rs = conn.Execute(strSql)
  If Not rs.EOF Then
    Response.Write "pass=true"
  Else
    '��ע�������ֻ����[pass=false]�����¼������ʾ��ϢΪ���ڲ�����������Ԥ���[�ʺŻ��������������]
    '�����Ƿ���[pass=false&msg=��ʾ��Ϣ]��ʽ�����¼������ʾ��ϢΪmsg=�����[��ʾ��Ϣ]��
    '���������Խ�ϴ����quizId��ѯ���ݿ⣬��ʵ��ͬһ�ʺŶ�ĳ��quizId�̶��Ĳ����⣬����ֻ��һ�εĴ���
    Response.Write "pass=false"
  End If
  Set rs = Nothing
%>