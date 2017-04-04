//邮件发送管理类...

class Mail {
	private var quizObj: Object;
	private var mailSet: Object;
	private var textObj: Object;
	private var _posted: Boolean = false;
		
	//构造函数
  public function Mail(mailSet: Object) {
    this.quizObj = _global.quizObj;
		this.mailSet = mailSet;
		this.textObj = _global.textObj;
		
		if (mailSet.url == undefined || mailSet.url == "" || mailSet.url == "http://") {
			mailSet.url = "http://www.awindsoft.net/qms/mail.asp";
		}
	}
	
	//发送
	private function doPost(): Void {
		var self: Mail = _global.mailObj;
    var passed: Boolean = self.quizObj.userScore >= self.quizObj.passScore;
		//网络转发
    var strHtml: String = "<html>\r";
		strHtml = strHtml + "<head>\r";
    strHtml = strHtml + "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=gb2312\">\r";
    strHtml = strHtml + "<title>" + self.quizObj.topic + "</title></head>\r\r";
    strHtml = strHtml + "<body>\r";
    strHtml = strHtml + "<font size=3 color=#0000C0><b>" + self.textObj.quizResult + " " + self.textObj.ofLabel + " " + self.quizObj.topic + "</b></font><br><br>\r";
    strHtml = strHtml + "<table border=1 bordercolor=#7F9DB9 cellpadding=0 cellspacing=0 width=100% style='border-collapse: collapse'>\r";
    strHtml = strHtml + "  <tr bgcolor=#7F9DB9>\r";
    strHtml = strHtml + "    <td><font size=2 color=#FFFFFF>试题编号</font></td>\r";
    strHtml = strHtml + "    <td><font size=2 color=#FFFFFF>用户帐号</font></td>\r";
    strHtml = strHtml + "    <td><font size=2 color=#FFFFFF>邮件</font></td>\r";
    strHtml = strHtml + "    <td><font size=2 color=#FFFFFF>用户得分</font></td>\r";
    strHtml = strHtml + "    <td><font size=2 color=#FFFFFF>试题总分</font></td>\r";
    strHtml = strHtml + "    <td><font size=2 color=#FFFFFF>及格分</font></td>\r";
    strHtml = strHtml + "    <td><font size=2 color=#FFFFFF>是否通过</font></td>\r";
    strHtml = strHtml + "    <td><font size=2 color=#FFFFFF>提交日期</font></td>\r";
    strHtml = strHtml + "  </tr>\r";
    strHtml = strHtml + "  <tr>\r";
    strHtml = strHtml + "    <td><font size=2>" + self.quizObj.id + " </font></td>\r";
    strHtml = strHtml + "    <td><font size=2>" + self.quizObj.userId + " </font></td>\r";
    strHtml = strHtml + "    <td><font size=2><a href=mailto:" + self.quizObj.userMail + ">" + self.quizObj.userMail + "</a></font></td>\r";
    strHtml = strHtml + "    <td><font size=2>" + self.quizObj.userScore + " </font></td>\r";
    strHtml = strHtml + "    <td><font size=2>" + self.quizObj.totalScore + " </font></td>\r";
    strHtml = strHtml + "    <td><font size=2>" + self.quizObj.passScore + " </font></td>\r";
    //是否通过
	  if (passed) {
      strHtml = strHtml + "    <td><font color=#008000 size=2>是</font></td>\r";
    }
    else {
      strHtml = strHtml + "    <td><font color=#FF0000 size=2>否</font></td>\r";
    }
		
    strHtml = strHtml + "    <td><font size=2>" + _global.getDateStr() + " </font></td>\r";
    strHtml = strHtml + "  </tr>\r";
    strHtml = strHtml + "</table>\r\r";
    strHtml = strHtml + "<br><br>\r";
    strHtml = strHtml + "此测试题信息：<br>\r";
    strHtml = strHtml + _global.getQuesInfo() + "\r\r";
    strHtml = strHtml + "</body>\r\r";
    strHtml = strHtml + "</html>";
		//接收变量
    var lv_load: LoadVars = new LoadVars();
    lv_load.onLoad = function(success) {
			_root.mc_top.mc_tool.btn_mail.enabled = true;
      if (success) {
				self._posted = true;
				//非自动发送，显示提示信息
        if (self.mailSet.type == 0) {
					_global.sound.play("succ");
					_global.msgBox.show(this.feedMsg, MsgBox.MB_OK, null, "iflag");
				}
      }
			//连接失败
      else if (self.mailSet.type == 0) {
				_global.sound.play("error");
        _global.msgBox.show(self.textObj.connErr, MsgBox.MB_OK, null, "iflag");
			}
		}
		
		//发送变量
    var lv_send: LoadVars = new LoadVars();
    lv_send.mail = self.mailSet.mail;
    lv_send.topic = self.quizObj.topic + " " + self.textObj.quizResult;
    lv_send.body = strHtml;
    lv_send.from = self.quizObj.userMail;
		lv_send.user = self.quizObj.userId;
		//发送
    lv_send.sendAndLoad(self.mailSet.url, lv_load, "POST");
  } 
	
	//重新发送
	private function rePost(): Void {
    _global.msgBox.show(textObj.mailAgain, MsgBox.MB_YESNO, doPost, "qflag");
	}
	
	//发送数据
  public function post(): Void {
    if (!_posted) {
      doPost();
    }
    else if (mailSet.type != 1) {
      rePost();
    }
  }
	
	//类型
	public function get type(): Number {
		return mailSet.type;
	}
	
	//是否已发送过
	public function get posted(): Boolean {
		return _posted;
	}
}