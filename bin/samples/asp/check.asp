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
    '请注意这里：若只返回[pass=false]，则登录错误提示信息为您在播放器设置中预设的[帐号或密码错误，请重试]
    '但若是返回[pass=false&msg=提示信息]格式，则登录错误提示信息为msg=后面的[提示信息]。
    '这里您可以结合传入的quizId查询数据库，可实现同一帐号对某个quizId固定的测试题，进行只做一次的处理。
    Response.Write "pass=false"
  End If
  Set rs = Nothing
%>