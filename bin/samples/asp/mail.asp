<%
  If Request.Form("topic") = "" Then
    Response.Write "��Ч���ʼ����ݣ���ҳ��Ϊ�����ʦ�����ɵ����������ã�����ֱ�����������"
    Response.End
  End If
  
  Dim strMail, strFrom, strUser, strSubject, strBody
  strMail    = Request.Form("mail")
  strSubject = Request.Form("topic")
  strBody    = Request.Form("body")
  strFrom    = Request.Form("from")
  If strFrom = "" Then strFrom = "quiz@awindsoft.net"
  strUser    = Request.Form("user")
  if strUser = "" Then strUser = strFrom

  On Error Resume Next
  '�����ʼ�
  Dim JMail    
  Set JMail = Server.CreateObject("JMail.Message")  
  JMail.Charset = "gb2312" 
  JMail.ContentType = "text/html"
  '���Է��֣�JMail.From�������뷢�ʼ����ʺ���ͬ������һ��ʱ�䣬������
  JMail.From = "quiz@awindsoft.net"
  JMail.FromName = strUser
  
  Dim i, arrMail
  arrMail = Split(strMail, ",")
  For i = LBound(arrMail) To UBound(arrMail)
    JMail.AddRecipient Trim(arrMail(i))
  Next
		
  JMail.Subject = strSubject 
  JMail.HTMLBody = strBody
  JMail.MailServerUserName = "quiz@awindsoft.net"
  JMail.MailServerPassword = "98765432"
  JMail.Priority = 3 
		
  '����
  JMail.Send("smtp.awindsoft.net") 
  JMail.Close()
  Set JMail=Nothing  
	
  '������Ϣ 
  If Err.Number <> 0 Then 
    Response.Write "feedMsg=�ʼ�����ʧ�ܣ�"
  Else 
    Response.Write "feedMsg=�ʼ��ѳɹ����͡�"
  End If 
%>