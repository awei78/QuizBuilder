//数据发送管理类...

class Data {
	private var quizObj: Object;
	private var dataSet: Object;
	private var textObj: Object;
	private var timeObj: Object;
	private var _posted: Boolean = false;
		
	//构造函数
  public function Data(dataSet: Object) {
    this.quizObj = _global.quizObj;
		this.dataSet = dataSet;
		this.textObj = _global.textObj;
		this.timeObj = _global.timeObj;
	}
	
	//发送
	private function doPost(): Void {
		//此处用self特别转换的原因，是因为doPost()在_global.msgBox中做回调时，所指的self参数已不能访问，故用全局赋之
		var self: Data = _global.dataObj;
    var passed: Boolean = self.quizObj.userScore >= self.quizObj.passScore;
		//接收变量
    var lv_load: LoadVars = new LoadVars();
    lv_load.onLoad = function(success) {
      _root.mc_top.mc_tool.btn_data.enabled = true;      
      if (success) {
				self._posted = true;
				//非自动发送，显示提示信息
				if (self.dataSet.type == 0) {
				  _global.sound.play("succ");
					_global.msgBox.show(this.feedMsg, MsgBox.MB_OK, null, "iflag");
        }
			}
			//连接失败
      else if (self.dataSet.type == 0) {
				_global.sound.play("error");
        _global.msgBox.show(self.textObj.connErr, MsgBox.MB_OK, null, "iflag");
      }
    }
		
		//发送变量
    var lv_send: LoadVars = new LoadVars();
    lv_send.fromQuiz    = "true";
    lv_send.quizId      = self.quizObj.id;
    lv_send.quizTitle   = self.quizObj.topic;
    lv_send.userId      = self.quizObj.userId;
    lv_send.userMail    = self.quizObj.userMail;
    lv_send.userScore   = self.quizObj.userScore;
    lv_send.totalScore  = self.quizObj.totalScore;
    lv_send.passScore   = self.quizObj.passScore;
    lv_send.passState   = passed ? "True" : "False";
		lv_send.quesInfo    = _global.getQuesInfo();
    lv_send.regMail     = self.quizObj.regMail;
    lv_send.regCode     = self.quizObj.regCode;
		//时间信息
		if (timeObj != undefined) {
			lv_send.timeLength = self.timeObj._length;
			lv_send.elapsed    = self.timeObj._elapse;
			lv_send.remaining  = self.timeObj._length - self.timeObj._elapse;
		}

		//发送
    lv_send.sendAndLoad(self.dataSet.url, lv_load, "POST");
	}
	
	//重新发送
	private function rePost(): Void {
    _global.msgBox.show(textObj.postAgain, MsgBox.MB_YESNO, doPost, "qflag");
	}
	
	//发送数据
  public function post(): Void {
		//发送网址不对或预览模式，不发送
    if (dataSet.url == undefined || quizObj.viewMode) {
      return;
    }
		
    if (!_posted) {
      doPost();
    }
    else if (dataSet.type != 1) {
      rePost();
    }
  }
	
	//类型
	public function get type(): Number {
		return dataSet.type;
	}
	
	//是否已发送过
	public function get posted(): Boolean {
		return _posted;
	}
}