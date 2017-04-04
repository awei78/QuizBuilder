<!-- #include file="conn.asp" -->
<!-- #include file="fso.asp" -->

<%
  '测试结果数据接收文件
	If Request.Form("fromQuiz") <> "true" Then
	  dim strInfo
	  strInfo = "&nbsp;&nbsp;如果您看到此信息，说明您的asp例子正在运行中。此页面当一个测试者做完试题并且执行提交操作后，" &_
			    "由试题文件自动调用，您不需要在浏览器中输入此页面网址访问此页面。如果您想收集测试结果，请打开秋风试题大师，" &_
			    "在[试题属性]->[结果设置]页面，选中[发送到网络数据库]，并在[网址]输入框中输入此页面网址，如http://.../receive.asp。" &_
			    "而且，您必须把例子文件夹下的crossdomain.xml文件放置在服务器根目录。当您按照上面所列步骤配置完成了，您就可以收集测试者所提交的试题数据。"

	  Response.Write strInfo
	  Response.End()
	End If

	
	'从试题播放器接收数据...
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
	'如果您生成的试题中，时间限制功能可用，则下面变量亦可用，以秒为单位：
	'timeLength：试题的总时长
	'elapsed：   查看试题结果时做题所用时间
	'remaining： 查看试题结果时所剩时间 
	
	'注册信息
	regMail    = Request.Form("regMail")
	regCode    = Request.Form("regCode")
	On Error Resume Next
	
	'加入到数据库...
	'存储管理员信息
	If regMail&"" <> "" Then
	  Set rs = conn.Execute("SELECT id FROM [admin] WHERE userId='"& regMail &"'")
	  If rs.Eof Then conn.Execute("INSERT INTO [admin](userId, userPwd, sys) VALUES('"& regMail &"', '"& regCode &"', False)")
	  Set rs = Nothing
	End If
	'存储考生信息
	If userId&"" <> "" Then
	  Set rs = conn.Execute("SELECT id FROM [users] WHERE userId='"& userId &"'")
	  If rs.Eof Then conn.Execute("INSERT INTO [users](userId, userPwd, userMail, admin) VALUES('"& userId &"', '654321', '"& userMail &"', '"& regMail &"')")
	  Set rs = Nothing	
	End If
	
	'存结果入数据库
	Dim strSql, affCount
	strSql = "INSERT INTO [quiz](quizId, quizTitle, userId, userMail, userScore, totalScore, passScore, passState, Result, regMail, regCode) " & _
	         "VALUES('"&quizId&"', '"&quizTitle&"', '"&userId&"', '"&userMail&"', "&userScore&", "&totalScore&", "&passScore&", "&passState&", '"&strResults&"', '"&regMail&"', '"&regCode&"')"
	conn.Execute strSql, affCount
	
	'返回信息给做题者...
	If affCount = 1 Then
	  Dim strUrl
	  strUrl = "http://" + Request.ServerVariables("SERVER_NAME") & Request.ServerVariables("PATH_INFO")
      strUrl = Replace(strUrl, "receive.asp", "index.asp")
	  '生成html文件
	  '@@identity是在Access中，最近一条用ADO方式插入的自动编号值
	  Set rs = conn.Execute("SELECT @@identity as id FROM [quiz]")
	  If Not rs.Eof then
	    Dim strGuide
	    
	    strGuide = "<table border=1 bordercolor=#7F9DB9 cellpadding=0 cellspacing=0 width=100% style=""border-collapse: collapse"">" &_
                 "  <tr bgcolor=#7F9DB9>"& vbCrLf  &_
								 "	  <td width=""30%""><font color=""#FFFFFF"">测试者</font></td>"& vbCrLf &_
								 "	  <td width=""10%""><font color=""#FFFFFF"">得分</font></td>"& vbCrLf &_
								 "	  <td width=""10%""><font color=""#FFFFFF"">试题总分</font></td>"& vbCrLf &_
								 "	  <td width=""10%""><font color=""#FFFFFF"">及格分</font></td>"& vbCrLf &_
								 " 	  <td width=""10%""><font color=""#FFFFFF"">是否通过</font></td>"& vbCrLf &_
								 "	  <td width=""30%""><font color=""#FFFFFF"">提交日期</font></td>"& vbCrLf &_
								 "	</tr>"& vbCrLf &_
								 "	<tr>"& vbCrLf &_
								 "	  <td>"& userId &"</td>"& vbCrLf &_
								 "	  <td>"& userScore &"</td>"& vbCrLf &_
								 "	  <td>"& totalScore &"</td>"& vbCrLf &_
								 "	  <td>"& passScore &"</td>"& vbCrLf &_
								 "	  <td>"& iif(passState, "<font color=""#008000"">是</font>", "<font color=""#FF0000"">否</font>") &"</td>"& vbCrLf &_
								 "	  <td>"& Now() &"</td>"& vbCrLf &_
								 "	</tr>"& vbCrLf &_
								 "</table>"
	    
	    Call CreateHtmlFile(rs("id"), quizTitle, strGuide & vbCrLf &"<br>"& vbCrLf & strResults)
	    strUrl = Replace(strUrl, "index.asp", "show.asp?id="&rs("id"))
	  End If
	  Set rs = Nothing
	
      Response.Write("feedMsg=恭喜您，数据发送成功；您可到<a href='"& strUrl &"' target='_blank'><font color='#0000FF'>"& strUrl &"</font></a>查看测试结果")	
	Else
	  Response.Write("feedMsg=数据发送失败！")	
	End If
%>