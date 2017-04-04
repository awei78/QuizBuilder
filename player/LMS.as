//lms类设置...
class LMS {
	private var quizObj: Object;
	private var _ver: String;
	private var _iaCount: Number;
	
	public function LMS(ver: String) {
		this.quizObj = _global.quizObj;
		this._ver = ver;
		
		fscommand("LMSInitialize");
	}
	
	//结束
	public function finish(): Void {
		fscommand("LMSFinish");
	}
	
	//获取值
	public function getValue(param: String): Void {
		fscommand("LMSGetValue", param);
	}
	
	//设置值
	public function setValue(param: String): Void {
		fscommand("LMSSetValue", param);
	}
	
	//发送
	public function commit(): Void {
	  fscommand("LMSCommit");
  }
	
	//获取lms的题类型
  private function getLmsType(itemObj): String {
    var strType: String = "";
    switch (itemObj._type) {
    case 1:
      strType = "true-false";
      break;
    case 2:
    case 3:
      strType = "choice";
      break;
    case 4:
      strType = "fill-in";
      break;
    case 8:
      strType = this._ver == "1.2" ? "fill-in" : "long-fill-in";
      break;
    case 5:
      strType = "matching";
      break;
    case 6:
      strType = "sequencing";
      break;
    default:
      strType = "performance";
    }
        
	  return strType;
  }
	
	//获取每个lms题的对错
  function getLmsResult(itemObj): String {
    if (itemObj._type < 8) {
      if (!itemObj.correct) {
        return (this._ver == "1.2") ? "wrong" : "incorrect";
      }
      else {
        return "correct";
      }
    }
    else {
      return "neutral";
    }
  }
	
	//设置每个ques的值
	public function postData(): Void {
		_iaCount = int(_iaCount);
    for (var i = 0; i <= quizObj.items.length - 1; i++) {
      setValue("cmi.interactions." + (i + _iaCount) + ".id,Q_" + (i + 1));
      setValue("cmi.interactions." + (i + _iaCount) + ".type," + getLmsType(quizObj.items[i]));
			if (quizObj.items[i]._type != 4) {
        setValue("cmi.interactions." + (i + _iaCount) + ".correct_responses.0.pattern," + _global.getItemAnswer(quizObj.items[i]));
			}
			//填空题把每个正确答案写入
			else {
				var ansObj: Object = quizObj.items[i].ans;
				for (var j = 0; j <= ansObj.items.length - 1; j++) {
				  setValue("cmi.interactions." + (i + _iaCount) + ".correct_responses." + j + ".pattern," + ansObj.items[j].value);
    		}
			}
      if (this._ver == "1.2") {
        setValue("cmi.interactions." + (i + _iaCount) + ".student_response," + _global.getUserAnswer(quizObj.items[i]));
        setValue("cmi.interactions." + (i + _iaCount) + ".time," + quizObj.items[i].dealTime);
      }
      else {
        setValue("cmi.interactions." + (i + _iaCount) + ".learner_response," + _global.getUserAnswer(quizObj.items[i]));
        setValue("cmi.interactions." + (i + _iaCount) + ".timestamp," + _global.getYearStr() + "T" + quizObj.items[i].dealTime);
      }
      setValue("cmi.interactions." + (i + _iaCount) + ".result," + getLmsResult(quizObj.items[i]));
    }
		
    commit();
	}

	//版本
	public function get ver(): String {
		return this._ver;
	}
	
	//interactions开始序号
	public function set iaCount(value: Number) {
		this._iaCount = value;
	}
}