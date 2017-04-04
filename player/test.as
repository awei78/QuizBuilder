//初始化Quiz
stop();

_global.lgObj = new Object();
loadLogin(lgObj);
//初始化quizObj，需要用SDK写入
_global.plObj = new Object();
_global.quizObj = new Object();
loadQuiz(quizObj);
_global.textObj = new Object();
loadText(textObj);
_global.plObj = new Object();
loadSet(plObj);

function loadLogin(lgObj: Object) {
  lgObj.type = 0;
  lgObj.userPwd = "1234";
	
	lgObj.type = 1;
	lgObj.checkUrl = "http://127.0.0.1/asp/check.asp";
	
	lgObj.userLabel = "帐号：";
	lgObj.pwdLabel  = "密码：";
	lgObj.btnLabel  = "登录";
	lgObj.errPwd    = "密码错误，请重试";
	lgObj.errAll    = "账号或密码错误，请重试";
}

function loadSet(plObj: Object) {
  plObj.showTop = true;
  plObj.topicSize = 12;
  plObj.topicColor = 0x000000;
  plObj.ansSize = 12;
  plObj.ansColor =0x000000;
  plObj.width = 720;
  plObj.height = 540;
	plObj.showScore = true;
	plObj.showInfo = true;
  plObj.showPrev = true;
  plObj.showNext = true;
  plObj.crtColor = "0x008000";
  plObj.errColor = "0x800000";	
	plObj.barColor = 0x7F9DB9;
	plObj.showTop = true;
  plObj.showTopic = true;
  plObj.showTime = true;
  plObj.showPoint = true;
  plObj.showLevel = true;
  plObj.showTool = true;
  plObj.showData = true;
  plObj.showMail = true;
  plObj.showAudio = true;
  plObj.showAuthor = true;
  plObj.showPrev = true;
  plObj.showNext = true;
  plObj.showList = true;
}

function getLevel(level: Number): String {
	var strLevel: String;
	switch (level) {
	case 0:	
	  strLevel = "容易";
		break;
	case 1:	
	  strLevel = "初级";
		break;
	case 2:	
	  strLevel = "中级";
		break;
	case 3:	
	  strLevel = "高级";
		break;
	case 4:	
	  strLevel = "困难";
		break;
	default:
		strLevel = "中级";
	}
	
	return strLevel;
}

function loadQuiz(quizObj: Object) {
	quizObj.sngMode = true;
	quizObj.rndAns = true;
	quizObj.showAns = true;
	quizObj.blankUser = true;
	quizObj.showQuesNo = true;
	
	
	//数据加载
  var xmlData = new XML();
  xmlData.load("quiz.xml");
  xmlData.ignoreWhite = true;
	
  xmlData.onLoad = function(succ) {
	  if (succ) {
		  var Node: XMLNode;
			
			quizObj.id = xmlData.firstChild.attributes.id;
			quizObj.viewMode = Node.firstChild.attributes.preview == "true";
			for (var i = 0; i <= xmlData.firstChild.childNodes.length - 1; i++) {
			  Node = xmlData.firstChild.childNodes[i];
			  switch (Node.nodeName) {
				case "title":
		      quizObj.topic = Node.firstChild.nodeValue;
			    quizObj.appName = (quizObj.topic != "") ? quizObj.topic : "试题大师";
				  break;
			  case "info":
				  quizObj.showInfo = true;
  				quizObj.info = replace(Node.firstChild.nodeValue, "\r", "");
					quizObj.img = Node.attributes.img;
				  quizObj.showUser = Node.attributes.showUser == "true";
				  quizObj.showMail = Node.attributes.showMail == "true";
					quizObj.blankUser = Node.attributes.blankUser == "true" && quizObj.showUser || !quizObj.showUser;
  				break;
			  case "author":
				  _global.auObj = new Object();
				  ahObj.name = Node.childNodes[0].firstChild.nodeValue != undefined ? Node.childNodes[0].firstChild.nodeValue : "";
				  ahObj.mail = Node.childNodes[1].firstChild.nodeValue != undefined ? Node.childNodes[1].firstChild.nodeValue : "";
				  ahObj.info = Node.childNodes[2].firstChild.nodeValue != undefined ? Node.childNodes[2].firstChild.nodeValue : "";
				  ahObj.info = replace(ahObj.info, "\r", "");
				  break;
  			case "dataOper":
				  _global.dataSet = new Object();
				  dataSet.type = parseInt(Node.attributes.type);
  				dataSet.url = Node.firstChild.nodeValue;
				  break;
			  case "mailOper":
				  _global.mailSet = new Object();
				  mailSet.type = parseInt(Node.attributes.type);
				  mailSet.url = Node.attributes.url == undefined ? "": Node.attributes.url;
				  mailSet.mail = Node.firstChild.nodeValue == undefined ? "@": Node.firstChild.nodeValue;
				  break;
			  case "exitOper":
				  _global.quitObj = new Object();
				  quitObj.passType = parseInt(Node.firstChild.attributes.type);
				  quitObj.passUrl = Node.firstChild.firstChild.nodeValue != undefined ? Node.firstChild.firstChild.nodeValue : "";
				  quitObj.passUrl = quitObj.passUrl.indexOf("http") == -1 ? "http://" + quitObj.passUrl : quitObj.passUrl;
				  quitObj.failType = parseInt(Node.lastChild.attributes.type);
				  quitObj.failUrl = Node.lastChild.firstChild.nodeValue != undefined ? Node.lastChild.firstChild.nodeValue : "";
				  quitObj.failUrl = quitObj.failUrl.indexOf("http") == -1 ? "http://" + quitObj.failUrl : quitObj.failUrl;
				  break;
  			case "passSet":
  				_global.passObj = new Object();
				  passObj.rate = parseFloat(Node.firstChild.firstChild.nodeValue);
  				passObj.passInfo = Node.childNodes[1].firstChild.nodeValue != undefined ? Node.childNodes[1].firstChild.nodeValue : "";
				  passObj.failInfo = Node.lastChild.firstChild.nodeValue != undefined ? Node.lastChild.firstChild.nodeValue : "";
  				passObj.show = Node.attributes.show == "true";
				  //passObj.msgText = Node.lastChild.firstChild.nodeValue != undefined ? (Node.lastChild.firstChild.nodeValue) : ("Thanks for Taking the Quiz.");
  				break;
			  case "timeSet":
				  _global.timeSet = new Object();
				  timeSet.length = parseInt(Node.firstChild.nodeValue);
					if (timeSet.length <= 1 || timeSet.length == Number.NaN) {
						timeSet.length = 6;
  				}
				  break;
			  }
			}
			
			//取题之数据
		  var xnItems: XMLNode = xmlData.firstChild.lastChild;
			quizObj.count = xnItems.childNodes.length;
  		quizObj.userScore = 0;
		  quizObj.totalScore = 0;
		  quizObj.passScore = 0;
			//每题...
		  quizObj.items = new Array();
			var xnAns: XMLNode;
			var ansObj: Object;
			var strAns: String;
			//************
      for (var i = 0; i <= xnItems.childNodes.length - 1; i++) {
        Node = xnItems.childNodes[i];
        quizObj.items[i] = new Object();
        quizObj.items[i].id = i + 1;
        quizObj.items[i].topic = Node.childNodes[0].firstChild.nodeValue;
        quizObj.items[i]._type = parseInt(Node.attributes.type);
        quizObj.items[i].attempt = Node.attributes.attempt == undefined ? 0 : parseInt(Node.attributes.attempt);
        quizObj.items[i].score = quizObj.items[i]._type != 8 ? parseInt(Node.attributes.point) : 0;
        quizObj.totalScore += quizObj.items[i].score;
        quizObj.items[i].correct = false;
        quizObj.items[i].level = getLevel(parseInt(Node.attributes.level));
				quizObj.items[i].img = Node.attributes.img;
				strAns = Node.attributes.ans;
        quizObj.items[i].movie = undefined;
        quizObj.items[i].hasDone = false;
        quizObj.items[i].curTime = "00:00:00";
				//答案
				quizObj.items[i].ans = new Object();
				ansObj = quizObj.items[i].ans;
				//答案是否已处理过，主要判断排序题
				ansObj.hasDeal = false;
				xnAns = Node.childNodes[1];
				//trace(xnAns.childNodes.length);
				//判断、单选、多选、填空、匹配、排序用数组表示
				if (xnAns.childNodes.length > 1) {
  				ansObj.items = new Array();
					for (var j = 0; j <= xnAns.childNodes.length - 1; j++) {
						ansObj.items[j] = new Object();
						ansObj.items[j].value = xnAns.childNodes[j].firstChild.nodeValue;
						if (quizObj.items[i]._type <= 3) {
  						ansObj.items[j].correct = strAns.indexOf(j) != -1;
						}
						else if (quizObj.items[i]._type == 5) {
							ansObj.items[j].topic = xnAns.childNodes[j].attributes.topic;
							//trace(ansObj.items[j].topic);
						}
					}
				}
				//热区、简答题
				else {
					switch (quizObj.items[i]._type) {
					case 7:
					  ansObj.src = xnAns.firstChild.nodeValue;
					  ansObj._x = parseInt(xnAns.attributes.left);
						ansObj._y = parseInt(xnAns.attributes.top);
						ansObj._width = parseInt(xnAns.attributes.width);
						ansObj._height = parseInt(xnAns.attributes.height);
						break;
					case 8:
					  ansObj.refAns = xnAns.firstChild.nodeValue;
					  break;
					}
				}
				
				//反馈信息
				if (Node.childNodes[2] != undefined) {
					quizObj.items[i].feedBack = new Object()
          quizObj.items[i].feedBack.crtInfo = Node.childNodes[2].attributes.crt;
          quizObj.items[i].feedBack.errInfo = Node.childNodes[2].attributes.err;
				}
      }
			
			//全局变量
			_global.g_curPage = 0;
			_global.g_totalPage = xnItems.childNodes.length;
			//及格分
      quizObj.passScore = Math.ceil(quizObj.totalScore * parseFloat(passObj.rate) / 100);
			
			nextFrame();
		}
	  else {
		  trace("parse xml file fail");
		}
	}
}

//初始化字符串
function loadText(textObj: Object) {
	textObj.loadQuiz       = "下载中...";
	textObj.buildQuiz      = "出题中...";
	textObj.startCap       = "开始...";
	textObj.quesCap        = "试题";
	textObj.ofLabel        = " / ";
	textObj.point          = "分";
	textObj.quizInfo       = "试题信息";
	textObj.crtCap         = "正确";
	textObj.errCap         = "错误";
	textObj.userID         = "账号：";
	textObj.userMail       = "邮件：";
	textObj.keepCap        = "记住我";
	textObj.submit         = "提交";
	textObj.viewResult     = "查看结果";
	textObj.prevItem       = "上题";
	textObj.nextItem       = "下题";
	textObj.tryAgain       = "请重试";
	textObj.view           = "浏览";
	textObj.finish         = "完成";
	textObj.okLabel        = "确定";
	textObj.yesLabel       = "是";
	textObj.noLabel        = "否";
	textObj.remaining      = "剩余时间";
	textObj.quesList       = "题目列表";
	textObj.quizResult     = "测试结果";
	textObj.userScore      = "测试得分：";
	textObj.passScore      = "通过分数：";
	textObj.totalScore     = "试题总分：";
	textObj.quesCount      = "a";
	textObj.passQues       = "b";
	textObj.failQues       = "c";
	textObj.showResult     = "结果：";
	textObj.noBlankUser    = "帐号不能为空，请输入";
	textObj.essayInfo      = "本题为简答题，不参与分数计算；请点击[%s]继续";
	textObj.postInfoNotAll = "还有题没有做完，您确定要提交并查看结果吗？";
	textObj.postInfoView   = "您确定要提交并查看结果吗？";
	textObj.timeoutInfo    = "做题截止时间到，请点击[%s]查看结果";
	textObj.accepts        = "可接受的答案：";
	textObj.referAns       = "参考答案：";
	textObj.uncplInfo      = "还有试题没有做，请做完所有题后再继续操作";
	textObj.itemLevel      = "级别";
	textObj.itemLevel0     = "容易";
	textObj.itemLevel1     = "初级";
	textObj.itemLevel2     = "中级";
	textObj.itemLevel3     = "高级";
	textObj.itemLevel4     = "困难";
	textObj.postTip        = "发送测试结果到网络数据库";
	textObj.mailTip        = "发送测试结果到出题人邮箱";
	textObj.audioTip       = "打开/关闭声音";
	textObj.infoTip        = "作者信息";
	textObj.author         = "作者：";
	textObj.email          = "邮件：";
	textObj.url            = "主页：";
	textObj.des            = "描述：";
	textObj.postAgain      = "您想要再次发送测试数据到网络数据库么？";
	textObj.mailAgain      = "您想要再次发送测试数据到出题人邮箱么？";
	textObj.connErr        = "连接服务器失败，请检测网络，或更改Flash播放器安全设置";
}
