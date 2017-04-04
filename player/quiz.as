w/****************************************************************
  文件：quiz.as
	作者：刘景威
	说明：player.fla所公用数据单元 v 1.1.5
	更新：
	     2008-01-31找到Button类的labelPath可表示代表其label的TextField，代替自处理RadioButton、CheckBox的拆行处理
       2008-02-29完成对运行时随机设置的处理
			 2009-01-04加入对按题型随机出题的处理
			 2009-02-19加入对场景页的处理，其题型标记为9
	
	题型：
	    1 - 判断题
	    2 - 单选题
			3 - 多选题
			4 - 填空题
	    5 - 匹配题
	    6 - 排序题
			7 - 热区题
			8 - 简答题
			9 - 场景页
****************************************************************/

this._lockroot = true;
_focusrect = false;
System.security.allowDomain("*");

//定义常量层
var MSG_DEPTH   = 9000;
var LIST_DEPTH  = 9999;
var MASK_DEPTH  = 10000;
var ABOUT_DEPTH = 10001;
var BOX_DEPTH   = 10002;
var QUES_FRAME  = 7;
var g_stageWidth  = 720;
var g_stageHeight = 540;
var sp_width  = 678;
var sp_height = 390;
var lastX = 70;

var fmtAns: TextFormat = new TextFormat();
fmtAns.font = "_sans";
fmtAns.size = plObj.ansSize;
fmtAns.color = plObj.ansColor;
fmtAns.bold = plObj.ansBold;

//初始化lms对象
if (quizObj.lmsVer != undefined) {
	_global.lmsObj = new LMS(quizObj.lmsVer);
}

//试题声音对象
_global.sndQues = new SoundEx(mc_mask);

//设置影片剪辑颜色
_global.setClipColor = function(mc: MovieClip, color) {
 if (color == undefined) {
   return;
 }
		
 var clr: Color = new Color(mc);
 clr.setRGB(color);
 delete clr;
}

//一些取值函数...
function getStrSize(s: String, fontSize: Number, isWidth: Boolean): Number {
  var txt_len = this.createTextField("txt_len", 1000, 0, 0, 20, 20);
  txt_len.text = trim(s);
  var fmt: TextFormat = new TextFormat();
  fmt.size = fontSize;
  txt_len.setTextFormat(fmt);
  txt_len.autoSize = true;
  delete fmt;
	var nSize: Number = isWidth ? txt_len._width : txt_len._height;
  txt_len.removeTextField();
  
	return int(nSize);
}

function getStrWidth(s: String, fontSize: Number): Number  {
	return getStrSize(s, fontSize, true);
} 

function getStrHeight(s: String, fontSize: Number): Number  {
  return getStrSize(s, fontSize, false);
}

//拖放、匹配题条目高度
function getDragHeight(ansObj: Object, lineWidth: Number): Number {
	var strMax: String = "";
  for (var i = 0; i <= ansObj.items.length - 1; i++) {
    strMax = getStrWidth(ansObj.items[i].value, plObj.ansSize) > getStrWidth(strMax, plObj.ansSize) ? ansObj.items[i].value : strMax;
		
		//匹配题
		if (ansObj.items[i].topic != undefined) {
      strMax = getStrWidth(ansObj.items[i].topic, plObj.ansSize) > getStrWidth(strMax, plObj.ansSize) ? ansObj.items[i].topic : strMax;
		}
  }

	var nRow: Number = Math.ceil(getStrWidth(strMax, plObj.ansSize) / lineWidth);
	//此处的(nRow - 1) * 4，是因为实际折行时，两行之间的间隔不是两个TextField之间的间隔
	return nRow * getStrHeight("abcde", plObj.ansSize) - (nRow - 1) * 4;
} 

//获取数组
function getArray(len: Number, rnd: Boolean, maxLen: Number): Array {
	var arr: Array = new Array();
	if (maxLen == undefined) {
		maxLen = len;
	}
	
 	if (quizObj.rndAns || rnd) {	
	  var i: Number = 0;
  	var nCur: Number = 0;
    while (i < len) {
      nCur = random(maxLen);
      for (var j = 0; j < i; j++) {
        if (nCur == arr[j]) {
          break;
        }
      }
      if (j == i) {
        arr[i] = nCur;
        i++;
      }
    }
	
		//是否不随机
		if (len > 2) {
  		var isOrder: Boolean = true;
		  for (var i = 0; i <= arr.length - 1; i++) {
		    isOrder = isOrder && arr[i] == i;
  	  }
  	  if (isOrder) {
		    var nTmp: Number = arr[arr.length - 1];
  		  arr[arr.length - 1] = arr[0];
		    arr[0] = nTmp;
			}
	  }
	}
	else {
		for (var i = 0; i <= len - 1; i++) {
			arr.push(i);
		}
	}
	
	return arr;
}

//按题型随机数组
function addRndArray(arr: Array, rndCount, quesType: Number): Void {
	var arrIds: Array = new Array();
	var arrTmp: Array = new Array();
  var itemObj: Object;	
	var i: Number = 0, j: Number = 0;
	
	if (rndCount != 0) {
		arrIds.splice(0, arrIds.length);
		for (i = 0; i <= quizObj.items.length - 1; i++) {
			itemObj = quizObj.items[i];
			if (itemObj._type == quesType) {
				arrIds.push(i);
			}
		}
		//取随机id
		arrTmp = getArray(rndCount, true, arrIds.length); 
		for (i = 0; i <= arrTmp.length - 1; i++) {
		  arr.push(arrIds[arrTmp[i]]);
		}
	}
	
	delete arrIds;
	delete arrTmp;
}

function getRndArray(): Array {
	var arr: Array = new Array();
	var arrTmp: Array = new Array();
	var arrRnd: Array = new Array();
	
  //判断题
	addRndArray(arr, quizObj.rndJudge, 1);
	//单选题
	addRndArray(arr, quizObj.rndSingle, 2);
	//多选题
	addRndArray(arr, quizObj.rndMulti, 3);	
	//填空题
	addRndArray(arr, quizObj.rndBlank, 4);		
  //匹配题	
  addRndArray(arr, quizObj.rndMatch, 5);			
	//排序题
	addRndArray(arr, quizObj.rndSeque, 6);				
	//热区题
	addRndArray(arr, quizObj.rndHotSpot, 7);					
	//简答题
	addRndArray(arr, quizObj.rndEssay, 8);					

	//此处所取题为按题型排列，再做一次随机处理
	arrRnd = arr.slice(0, arr.length);
	arr.splice(0, arr.length);
	arrTmp = getArray(arrRnd.length, true, arrRnd.length); 
	for (i = 0; i <= arrTmp.length - 1; i++) {
		arr.push(arrRnd[arrTmp[i]]);
	}
	delete arrRnd;
	delete arrTmp;
	
	return arr;
}

//是否可放大
function isBigImg(src: String): Boolean {
	var mc_tmp: MovieClip = this.createEmptyMovieClip("mc_tmp" , this.getNextHighestDepth());
	mc_tmp._visible = false;
	mc_tmp.attachMovie(src, src, 0);
	var isBig: Boolean = mc_tmp._width > 200 || mc_tmp._height > 150;
	mc_tmp.removeMovieClip();
	
	return isBig;
}

//********
//建立题目
function createTopic(itemObj: Object) {
	var ldr = itemObj.ldr;
	//序号
	var lbl_i = ldr.createTextField("lbl_i_" + itemObj.id, ldr.getNextHighestDepth(), 0, 0, 20, 20);
  var fmt: TextFormat = new TextFormat();
	fmt.font = "_sans";
  fmt.size = plObj.topicSize;
 	fmt.color = plObj.topicColor;
  fmt.bold = plObj.topicBold;
	if (quizObj.showQuesNo) {
  	lbl_i.text = (itemObj.id != "") ? itemObj.id + ". " : "";
	  lbl_i.selectable = false;
    lbl_i.autoSize = true;
  	lbl_i.setTextFormat(fmt);
	}
	else {
		lbl_i._width = 2;
	}
	//尺寸
	var nWidth: Number = plObj.width - lastX;
	if (itemObj.sndObj != undefined && !itemObj.sndObj.autoPlay) {
		nWidth -= 45;
	}
	//题目
	lbl_t = ldr.createTextField("lbl_" + itemObj.id, ldr.getNextHighestDepth(), lbl_i._width, 0, nWidth, 20);
	lbl_t.html = true;
	lbl_t.htmlText = itemObj.topic;
	lbl_t.wordWrap = true;
	lbl_t.autoSize = true;
	lbl_t.selectable = false;
	lbl_t.setTextFormat(fmt);
	delete fmt;
	
	//声音控制条
	if (itemObj.sndObj != undefined && !itemObj.sndObj.autoPlay) {
		var mc_play: MovieClip = ldr.createObject("play_clip", "mc_play", ldr.getNextHighestDepth());	
		itemObj.playClip = mc_play;
		mc_play._x = plObj.width - 90;
		mc_play._y = lbl_t._height - 18;
		//附加值
		mc_play.sndObj = itemObj.sndObj;
		mc_play.sndQues = sndQues; 
		sndQues.onSoundComplete = function() {
			mc_play.gotoAndStop(1);
			mc_play.sndObj.pos = 0;
		}
	}

	//显示图片
	if (itemObj.img != undefined) {
		var mc_img: MovieClip = ldr.createEmptyMovieClip("mc_img" + itemObj.id, ldr.getNextHighestDepth());
		mc_img._x = plObj.width - 251;
		mc_img._y = lbl_t._height + 7;
		var ldr_img = mc_img.createClassObject(mx.controls.Loader, "ldr_img" + itemObj.id, 0, {_width: 200, _height: 150});
		ldr_img._lockroot = true;
		ldr_img.contentPath = itemObj.img;
		ldr_img.content.stop();
		//引用影片
		itemObj.movie = ldr_img.content;
		//小图放大
		if (isBigImg(itemObj.img)) {
			ldr_img.onRelease = function() {
				aboutBox.showImage(itemObj.img);
			}
		}
	}

	return (lbl_t._y + lbl_t._height + 8);
}

//判断、单选题
function buildSingleSelect(lastY: Number, itemObj: Object) {
	var ansObj: Object = itemObj.ans;
	if (ansObj.items.length == 0) {
		return;
	}
	
	//答案排列处理
 	var arrAns = getArray(ansObj.items.length);
	var strAns: String = "";
	var nWidth: Number = itemObj.img == undefined ? sp_width - lastX - 25 : sp_width - 200 - lastX - 25;
	var index: Number = 0;
	for (var i = 0; i <= arrAns.length - 1; i++) {
		index = arrAns[i];
		strAns = ansObj.items[index].value;
		var rb_ans = itemObj.ldr.createClassObject(mx.controls.RadioButton, "rb_ans" + itemObj.id + index, itemObj.ldr.getNextHighestDepth(), {label: strAns});
		rb_ans.setSize(nWidth + 60, rb_ans.height);
		//记录控件
		ansObj.items[index].clip = rb_ans;
		rb_ans.useHandCursor = true;
		//设置其label的属性
		rb_ans.label = strAns;
		rb_ans.labelPath._width = rb_ans._width - 12;
		rb_ans.labelPath.setTextFormat(fmtAns);
		//rb_ans.labelPath.multiline = true;
		rb_ans.labelPath.wordWrap = true;
		rb_ans.labelPath.autoSize = true;
    rb_ans.fontSize = plObj.ansSize;
    rb_ans.color = plObj.ansColor;
		rb_ans.fontWeight = plObj.ansBold ? "bold" : "none";
		rb_ans.groupName = "group_" + itemObj.id;
		rb_ans._x = (quizObj.showQuesNo) ? itemObj.ldr["lbl_" + itemObj.id]._x : itemObj.ldr["lbl_" + itemObj.id]._x + 16;
		rb_ans._y = lastY;
		lastY += rb_ans._height + 2;

		//点击声音
		var els: Object = new Object();
		els.click = function(evt_obj: Object) {
			sound.play("click");
		};
		rb_ans.addEventListener("click", els);
	}
}

//多选题
function buildMulSelect(lastY: Number, itemObj: Object) {
	var ansObj: Object = itemObj.ans;
	if (ansObj.items.length == 0) {
		return;
	}
	
	//答案排列处理
	var arrAns = getArray(ansObj.items.length);
	var strAns: String = "";
	var nWidth: Number = itemObj.img == undefined ? sp_width - lastX - 25 : sp_width - 200 - lastX - 25;
	var index: Number = 0;
	for (var i = 0; i <= arrAns.length - 1; i++) {
		index = arrAns[i];
		strAns = ansObj.items[index].value;
		var cb_ans = itemObj.ldr.createClassObject(mx.controls.CheckBox, "cb_ans" + itemObj.id + index, itemObj.ldr.getNextHighestDepth(), {label: strAns});
		cb_ans.setSize(nWidth + 60, cb_ans.height);
		//记录控件
		ansObj.items[index].clip = cb_ans;
		cb_ans.useHandCursor = true;
		//设置其label的属性
		cb_ans.label = strAns;
		cb_ans.labelPath._width = cb_ans._width - 12;
		cb_ans.labelPath.setTextFormat(fmtAns);
		//cb_ans.labelPath.multiline = true;
		cb_ans.labelPath.wordWrap = true;
		cb_ans.labelPath.autoSize = true;
    cb_ans.fontSize = plObj.ansSize;
    cb_ans.color = plObj.ansColor;
		cb_ans.fontWeight = plObj.ansBold ? "bold" : "none";
		cb_ans._x = (quizObj.showQuesNo) ? itemObj.ldr["lbl_" + itemObj.id]._x : itemObj.ldr["lbl_" + itemObj.id]._x + 16;
		cb_ans._y = lastY;
    lastY += cb_ans._height + 2;
		
		//点击声音
		var els: Object = new Object();
		els.click = function(evt_obj: Object) {
			if (evt_obj.target.selected) {
  			sound.play("click");
			}
		};
		cb_ans.addEventListener("click", els);
	}
}

//填空题
function buildFillBlank(lastY: Number, itemObj: Object) {
	var ansObj: Object = itemObj.ans;
	if (ansObj.items.length == 0) {
		return;
	}
	//输入框...
  var txt = itemObj.ldr.createTextField("txt_ans" + itemObj.id, itemObj.ldr.getNextHighestDepth(), itemObj.ldr["lbl_" + itemObj.id]._x, lastY, 325, 25);
  txt.border = true;
  txt.type = "input";
  txt.setStyle("borderColor", "0x7F9DB9");
  txt.setNewTextFormat(fmtAns);
  ansObj.clip = txt;
	txt._x = (quizObj.showQuesNo) ? itemObj.ldr["lbl_" + itemObj.id]._x : itemObj.ldr["lbl_" + itemObj.id]._x + 16;
  var nHeight: Number = getStrHeight("abcde", plObj.ansSize);
  nHeight = nHeight > txt.height - 5 ? nHeight : txt.height - 5;
  txt.setSize(325, nHeight);
}

//匹配题
function buildDragMatch(lastY: Number, itemObj: Object) {
	var ansObj: Object = itemObj.ans;
	if (ansObj.items.length == 0) {
		return;
	}

	var txt_w: Number = (itemObj.img != undefined) ? 200 : 250;
	var itemHeight: Number = getDragHeight(ansObj, txt_w) + 4;
	var areaHeight: Number = itemHeight * ansObj.items.length + (ansObj.items.length + 1) * 4;
	//背景区域
	var mc_back: MovieClip = itemObj.ldr.createEmptyMovieClip("mc_back" + itemObj.id, itemObj.ldr.getNextHighestDepth());
	mc_back._x = (quizObj.showQuesNo) ? itemObj.ldr["lbl_" + itemObj.id]._x : itemObj.ldr["lbl_" + itemObj.id]._x + 16;
	mc_back._y = lastY;
	if (itemObj.img != undefined) {
    mc_back._xscale = 74;
  }
	//画底色
	with (mc_back) {
		moveTo(0, 0);
		lineStyle(1, 0x999999);
		beginFill(0xDDDDDD, 60);
		lineTo(595, 0);
		lineTo(595, areaHeight);
		lineTo(0, areaHeight); 
		lineTo(0, 0);
	}
	
	//题目
	for (var i = 0; i <= ansObj.items.length - 1; i++) {
		var mc_dt: MovieClip = mc_back.createObject("dt_clip", "mc_dragt" + itemObj.id + i, mc_back.getNextHighestDepth(), {});
		mc_dt.back._height = itemHeight;
		mc_dt.back.frame._visible = false;
		mc_dt.txt.text = ansObj.items[i].topic + " ";
		mc_dt.txt.autoSize = true;
		mc_dt.txt.setTextFormat(fmtAns);

		mc_dt._x = 16;
		mc_dt._y = itemHeight * i + 4 * (i + 1);
	}
	//答案
	var arrAns = getArray(ansObj.items.length, true);
	var index: Number = 0;
	for (var i = 0; i <= arrAns.length - 1; i++) {
		index = arrAns[i];
		var mc_da: MovieClip = mc_back.createObject("da_clip", "mc_draga" + itemObj.id + index, mc_back.getNextHighestDepth(), {});
		mc_da.back.setStyle("_height", itemHeight);
		mc_da.txt.text = ansObj.items[index].value + " ";
		mc_da.txt.autoSize = true;
		mc_da.txt.setTextFormat(fmtAns);
		
		ansObj.items[index].clip = mc_da;
		ansObj.items[index].YPos = itemHeight * index + (index + 1) * 4;
		mc_da._x = 309;
		mc_da._y = itemHeight * i + (i + 1) * 4;
		
		//拖动事件...
		var oldX, oldY: Number;
		mc_da.back.btn.onPress = function() {
			this._parent._parent.pressed = true;
			this._parent._parent.swapDepths(this._parent._parent._parent.getNextHighestDepth());
			this._parent._parent.startDrag(false, 0, 0, 325, areaHeight - itemHeight);
			oldX = this._parent._parent._x;
			oldY = this._parent._parent._y != 0 ? this._parent._parent._y : oldY;
		}
		
		//对应显示
		mc_da.onMouseMove = function() {
			if (!this.pressed) {
				return;
			}

			//对应显示
			for (var j = 0; j <= arrAns.length - 1; j++) {
				var mc_t: MovieClip = mc_back["mc_dragt" + itemObj.id + j];
				mc_t.back.frame._visible = false;

				if (this.hitTest(mc_t) && Math.abs(mc_t._y - this._y) <= this._height / 2) {
					mc_t.back.frame._visible = true;
				}
			}
		}
		
		//题对应或返回原位
		mc_da.back.btn.onRelease = function() {
			if (!this._parent._parent.pressed) {
				return;
			}

			this._parent._parent.pressed = false;
			this._parent._parent.stopDrag();
			var mc_t_cur: MovieClip = undefined;
			for (var j = 0; j <= arrAns.length - 1; j++) {
				var mc_t = mc_back["mc_dragt" + itemObj.id + j];
				mc_t.back.frame._visible = false;
				//对应之题目项
				if (this._parent._parent.hitTest(mc_t) && Math.abs(mc_t._y - this._parent._parent._y) <= this._parent._parent._height / 2) {
					mc_t_cur = mc_t;
				}
			}
      //对应或归位
			if (this._parent._parent._x <= 309 && mc_t_cur != undefined) {
				if (oldX == 309 || oldY != mc_t_cur._y) {
  				sound.play("roll");
				}
				this._parent._parent._x = 279;
				this._parent._parent._y = mc_t_cur._y;
				
				//若原已有对应，则交换位置
			  for (var j = 0; j <= arrAns.length - 1; j++) {
				  var mc_a: MovieClip = mc_back["mc_draga" + itemObj.id + j];
					if (mc_a._y == mc_t_cur._y && mc_a != this._parent._parent) {
						mc_a._x = 309;
						mc_a._y = oldY;
						break;
				  }
				}
			} 
			else {
				this._parent._parent._x = 309;
				this._parent._parent._y = oldY;
			}
		}
		mc_da.back.btn.onReleaseOutside = mc_da.back.btn.onRelease;
	}
}

//排序题
function buildDragSort(lastY: Number, itemObj: Object) {
	var ansObj: Object = itemObj.ans;
	if (ansObj.items.length == 0) {
		return;
	}
	
	var txt_w: Number = (itemObj.img != undefined) ? 375 : 475;
	var itemHeight: Number = getDragHeight(ansObj, txt_w) + 2;
	var areaHeight: Number = itemHeight * ansObj.items.length + (ansObj.items.length + 1) * 4;
	//背景区域
	var mc_back: MovieClip = itemObj.ldr.createEmptyMovieClip("mc_back" + itemObj.id, itemObj.ldr.getNextHighestDepth());
	mc_back._x = (quizObj.showQuesNo) ? itemObj.ldr["lbl_" + itemObj.id]._x : itemObj.ldr["lbl_" + itemObj.id]._x + 16;
	mc_back._y = lastY;
	if (itemObj.img != undefined) {
    mc_back._xscale = 78;
  }
	//画底色
	with (mc_back) {
		moveTo(0, 0);
		lineStyle(1, 0x999999);
		beginFill(0xDDDDDD, 60);
		lineTo(560, 0);
		lineTo(560, areaHeight);
		lineTo(0, areaHeight);
		lineTo(0, 0);
	}
	
	//画分界线
	for (var i = 0; i <= ansObj.items.length - 1; i++) {
		var lbl = mc_back.createClassObject(mx.controls.Label, "lbl_" + itemObj.id + i, mc_back.getNextHighestDepth(), {text: (i + 1) + ". "});
		lbl.fontSize = plObj.ansSize;
    lbl.color = plObj.ansColor;
		lbl.autoSize = true;
		lbl._x = 4;
		lbl._y = (itemHeight + 4) * i + 8;
		with (mc_back) {
			moveTo(24, (itemHeight + 4) * (i + 1));
			lineStyle(1, 0x666666);
			lineTo(530, (itemHeight + 4) * (i + 1));
		}
	}
	
	//出排列条
	var arrAns = getArray(ansObj.items.length, true);
	var index: Number = 0;
	for (var i = 0; i <= arrAns.length - 1; i++) {
		index = arrAns[i];
		var mc_ds: MovieClip = mc_back.createObject("dsort_clip", "mc_dsort" + itemObj.id + index, mc_back.getNextHighestDepth(), {});
		mc_ds.btn._height = itemHeight;
	  mc_ds.frame._visible = false;
  	mc_ds.frame._y = mc_ds.btn._y + mc_ds.btn._height + 2; 
		mc_ds.txt.text = ansObj.items[index].value + " ";
		mc_ds.txt.autoSize = true;
		mc_ds.txt.setTextFormat(fmtAns);
		mc_ds._x = 24;
		mc_ds._y = (itemHeight + 4) * i + 2;
		ansObj.items[index].clip = mc_ds;
		ansObj.items[index].YPos = (itemHeight + 4) * index + 2;
		
		//拖放事件
		var oldX: Number = 24;
		var oldY: Number;
		mc_ds.btn.onPress = function() {
			this._parent.pressed = true;
			this._parent.swapDepths(this._parent._parent.getNextHighestDepth());
			this._parent.startDrag(false, 0, 0, 50, areaHeight - itemHeight);
			oldY = this._parent._y != 0 ? this._parent._y : oldY;
		}
		
		//对应显示
		mc_ds.onMouseMove = function() {
			if (!this.pressed) {
				return;
			}

			for (var i = 0; i <= arrAns.length - 1; i++) {
				var mc_d: MovieClip = mc_back["mc_dsort" + itemObj.id + i];
				mc_d.frame._visible = false;
				if (this.hitTest(mc_d) && this != mc_d && Math.abs(mc_d._y - this._y) <= this._height / 2) {
					mc_d.frame._visible = true;
				}
			}
		}
		
		//题交换或返回原位
		mc_ds.btn.onRelease = function() {
			if (!this._parent.pressed) {
				return;
			}

			this._parent.pressed = false;
			this._parent.stopDrag();
			var mc_d_cur: MovieClip = undefined;
			for (var j = 0; j <= arrAns.length - 1; j++) {
				var mc_d: MovieClip = mc_back["mc_dsort" + itemObj.id + j];
				mc_d.frame._visible = false;
				//对应之题目项
				if (this._parent.hitTest(mc_d) && this._parent != mc_d && Math.abs(mc_d._y - this._parent._y) <= this._parent._height / 2) {
					mc_d_cur = mc_d;
				}
			}

			if (mc_d_cur != undefined) {
				if (oldY != mc_t_cur._y) {
  				sound.play("roll");
				}
				
				ansObj.hasDeal = true;
				this._parent._x = oldX;
				this._parent._y = mc_d_cur._y;
				mc_d_cur._x = oldX;
				mc_d_cur._y = oldY;
			} 
			else {
				this._parent._x = oldX;
				this._parent._y = oldY;
			}
		}
		mc_ds.btn.onReleaseOutside = mc_ds.btn.onRelease;
	}
}

//热区题
function buildHotArea(lastY: Number, itemObj: Object) {
	var ansObj: Object = itemObj.ans;
	if (ansObj == undefined) {
		return;
	}
	
	var mc_area: MovieClip = itemObj.ldr.createEmptyMovieClip("mc_area" + itemObj.id, itemObj.ldr.getNextHighestDepth());
	mc_area._x = 12;
	mc_area._y = lastY;
	mc_area.attachMovie(ansObj.src, "", 0);
	var btn: MovieClip = itemObj.ldr.createObject("mask_btn", "btn_mask" + itemObj.id, itemObj.ldr.getNextHighestDepth());
	btn._alpha = 0;
	btn._x = mc_area._x;
	btn._y = mc_area._y;
	btn._width = mc_area._width;
	btn._height = mc_area._height;
	
	//按钮鼠标事件
	btn.onRelease = function() {
		sound.play("click");
		//指示点
		var mc_hot: MovieClip = itemObj.ldr["mc_hot" + itemObj.id];
		if (mc_hot == undefined) {
			mc_hot = itemObj.ldr.createObject("hot_clip", "mc_hot" + itemObj.id, itemObj.ldr.getNextHighestDepth(), {});
		}
		
		ansObj.clip = mc_hot;
		mc_hot._visible = true;
		mc_hot._xscale = 75;
		mc_hot._yscale = 75;
		mc_hot._x = itemObj.ldr._xmouse - 34;
		mc_hot._y = itemObj.ldr._ymouse - 34;
	}
}

//简答题
function buildShortEssay(lastY: Number, itemObj: Object) {
  var ta_ans = itemObj.ldr.createClassObject(mx.controls.TextArea, "ta_ans" + itemObj.id, itemObj.ldr.getNextHighestDepth(), {});
  ta_ans.setStyle("borderStyle", "solid");
  ta_ans.setStyle("borderColor", "0x7F9DB9");
  ta_ans.fontSize = plObj.ansSize;
  ta_ans.color = plObj.ansColor;
	ta_ans.fontWeight = plObj.ansBold ? "bold" : "none";
  ta_ans.hScrollPolicy = "off";
  ta_ans.wordWrap = true;
	if (itemObj.img != undefined) {
    ta_ans.setSize(435, 145);
	}
	else {		
		ta_ans.setSize(525, 145);
	}
	//ta_ans.setSize(395, 125);
  ta_ans._x = (quizObj.showQuesNo) ? itemObj.ldr["lbl_" + itemObj.id]._x : itemObj.ldr["lbl_" + itemObj.id]._x + 16;
  ta_ans._y = lastY;
  itemObj.ans.clip = ta_ans;
}

//场景页
function buildScenePage(lastY: Number, itemObj: Object) {
  var ta_ans = itemObj.ldr.createClassObject(mx.controls.TextArea, "ta_ans" + itemObj.id, itemObj.ldr.getNextHighestDepth(), {});
  ta_ans.setStyle("borderStyle", "none");
	ta_ans.setStyle("editable", false);
	ta_ans.text = itemObj.ans.refAns;
  ta_ans.fontSize = plObj.ansSize;
  ta_ans.color = plObj.ansColor;
	ta_ans.fontWeight = plObj.ansBold ? "bold" : "none";
  ta_ans.hScrollPolicy = "off";
  ta_ans.wordWrap = true;
	if (itemObj.img != undefined) {
    ta_ans.setSize(445, 300);
	}
	else {		
		ta_ans.setSize(650, 300);
	}
  ta_ans._x = itemObj.ldr["lbl_" + itemObj.id]._x;
  ta_ans._y = lastY;
  itemObj.ans.clip = ta_ans;	
}

//初始化quiz出题信息，第2帧
function buildCourse() {
  var yPos: Number = plObj.showTop ? 100 : 32;
  var sp_quiz = createClassObject(mx.containers.ScrollPane, "sp_quiz", 0);
  sp_quiz.tabEnabled = false;
  sp_quiz.borderStyle = "none";
  sp_quiz.contentPath = "blank_clip";
  sp_quiz.setSize(sp_width, sp_height + 100 - yPos);
  sp_quiz.hScrollPolicy = "off";
  sp_quiz.move(20, yPos);
	
	if (quizObj.runRnd) {
		var arrRnd: Array = (quizObj.rndType == 0) ? getArray(quizObj.rndCount, true, quizObj.items.length) : getRndArray();
		_global.g_totalPage = quizObj.rndCount;
		
		//另建一数组对象处理运行时随机问题
		var tmpObj: Object = new Object();
		tmpObj.items = new Array();
		for (var i = 0; i <= arrRnd.length - 1; i++) {
		  tmpObj.items.push(quizObj.items[arrRnd[i]]);
		}
		
		//清空原quizObj.items数据组
		quizObj.items.splice(0, quizObj.items.length);
		//再赋回quizObj
		for (var i = 0; i <= tmpObj.items.length - 1; i++) {
			tmpObj.items[i].id = i + 1;
			quizObj.items.push(tmpObj.items[i]);
		}
		
		delete tmpObj;
	}
	//下一帧，出题
  nextFrame();
}

//出每个ques题，第3帧
var x_i: Number = 0;
function buildQuestion() {
	var lastY: Number = 0;
	var itemObj: Object;
	
	for (var i = x_i; i <= quizObj.items.length - 1; i++) {
		//试用版版处理
		if (g_trialVer && i >= 15) {
			return;
		}
		
		itemObj = quizObj.items[i];
    mc_loader.mask._width = 325 * i / quizObj.items.length;
    mc_loader.txt.text = textObj.buildQuiz + " " + Math.round(i * 100 / quizObj.items.length) + " %";		
		var ldr = sp_quiz.content.createClassObject(mx.controls.Loader, "ldr" + i, i, {_visible: false});
		itemObj.ldr = ldr;
		lastY = createTopic(itemObj);
		quizObj.totalScore += itemObj.score;

		switch (itemObj._type) {
		case 1:
		case 2:
			buildSingleSelect(lastY, itemObj);
			break;
		case 3:
			buildMulSelect(lastY, itemObj);
			break;
		case 4:
			buildFillBlank(lastY, itemObj);
			break;
		case 5:
			buildDragMatch(lastY, itemObj);
			break;
		case 6:
			buildDragSort(lastY, itemObj);
			break;
		case 7:
			buildHotArea(lastY, itemObj);
			break;
		case 8:
			buildShortEssay(lastY, itemObj);
			break;
		case 9: 
		  buildScenePage(lastY, itemObj);
			break;
		default:
			trace("build course: course type error!");
		}
		
		x_i = i + 1;
		nextFrame();
		return;
	}

	//及格分
  quizObj.passScore = quizObj.totalScore * parseFloat(passObj.rate) / 100;
	gotoAndPlay(_currentframe + 2);
}

//初始化简介信息，第5帧
function initInfoData() {
	//背景声音
	if (bsObj != undefined) {
		_global.sndBG = new SoundEx();
		sndBG.attachSound(bsObj.snd);
		sndBG.start();
		if (bsObj.loop) {
			sndBG.onSoundComplete = function() {
				this.start();
			}
		}
	}
	
	//构建一些对象
	_global.aboutBox = new AboutBox(mc_about);
  _global.msgBox = new MsgBox(mc_box);
	_global.sound = new SoundEx(mc_mask);
		//初始化数据、邮件发送对象
	if (dataSet != undefined) {
		_global.dataObj = new Data(dataSet);
	}
	if (mailSet != undefined) {
		_global.mailObj = new Mail(mailSet);
	}
	
	//公用组件
  mc_about._visible = false;
  mc_box._visible = false;
	mc_hint._visible = false;
	txt_title._visible = plObj.showTopic;
	txt_title.text = quizObj.topic;
	txt_title.textColor = plObj.titleColor
	//设置工具条
	with (mc_top) {
		_visible = plObj.showTop;
		txt.text = textObj.quizInfo;
		setClipColor(back, plObj.barColor);
		
		with (mc_tool) {
			_visible = plObj.showTool;
		  btn_data._visible = false;
		  btn_mail._visible = false;
			mc_audio._visible = plObj.showAudio;
			btn_info._visible = plObj.showAuthor;
		  //位置计算
			if (_visible) {
		    var fDataX, fMailX, fAudioX, fInfoX: Number;
				fInfoX = 104.3;
				fAudioX = plObj.showAuthor ? fInfoX - 34.2 : fInfoX;
				fMailX = plObj.showAudio ? fAudioX - 35 : fAudioX;
				fDataX = plObj.showMail ? fMailX - 35 : fMailX;
				btn_data._x = fDataX;
				btn_mail._x = fMailX;
				mc_audio._x = fAudioX;
			}
		}
	}
	//信息&图片
	if (quizObj.showInfo) {
		sb_info.setScrollTarget(txt_info);
	  txt_info._y = plObj.showTop ? 115 : 50;
		sb_info._y = txt_info._y;
		//显示图片
		if (quizObj.img != undefined) {
  		txt_info.setStyle("_width", 425);
			sb_info._x = txt_info._x + txt_info._width;
      var mc_img: MovieClip = this.createEmptyMovieClip("quiz_img", 900);
      mc_img._x = sb_info._x + 32;
      mc_img._y = txt_info._y;
      var ldr_img = mc_img.createClassObject(mx.controls.Loader, "ldr_img", 0, {_width: 200, _height: 150});
      var mc_img_mask: MovieClip = mc.createObject("hrect_clip", "mc_mask_img", 1, {_x: quiz_img._x, _y: quiz_img._y});
      ldr_img.setMask(mc_img_mask);
      ldr_img._lockroot = true;
      ldr_img.contentPath = quizObj.img;
		  //小图放大
		  if (isBigImg(quizObj.img)) {
			  ldr_img.onRelease = function() {
				  aboutBox.showImage(quizObj.img);
				}
			}
		}
		if (quizObj.info != undefined) {
			txt_info.html = true;
      txt_info.htmlText = quizObj.info;
    }
    sb_info.visible = txt_info.textHeight >= 305;
	}
	
	//加入键盘事件
	addKeyListener();
	//蒙板设定
	with (mc_mask) {
		_x = 0;
		_y = 0;
		_width = Stage.width;
		_height = Stage.height;
		_visible = false;
	}
	mc_mask.useHandCursor = false;
	//模拟对话框事件...
	mc_mask.onRelease = function() {
		if (aboutBox._visible) {
			aboutBox.flash();
		}
		if (msgBox._visible) {
			msgBox.flash();
		}
	}
	
	//层交换。此处交换之后，其元件才能为其它没有放置它们的帧所用，否则其为空
  mc_mask.swapDepths(MASK_DEPTH);
  mc_about.swapDepths(ABOUT_DEPTH);
  mc_box.swapDepths(BOX_DEPTH);
	
  mc_start.caption = textObj.startCap;
	//加载用户帐号
  setUserInfo();	
	//开始按钮
	mc_start.btn.onRelease = function() {
		doStart();
	}
}

//设置用户信息
function setUserInfo() {
  mc_user.id.txt_label.text = textObj.userID;
  mc_user.mail.txt_label.text = textObj.userMail;
  mc_user.cb_keep.label = textObj.keepCap;
  Selection.setFocus(mc_user.txt_userid);
	Selection.setSelection(0, 0);
	
	//设置位置
	with (mc_user) {
    _visible = quizObj.showUser || quizObj.showMail;
    id._visible = quizObj.showUser;
    txt_userid._visible = id._visible;
    mail._visible = quizObj.showMail;
    txt_mail._visible = mail._visible;
    if (!id._visible) {
      mail._x = id._x;
      txt_mail._x = id._x + 56;
		}
  }	
	//取值
  if (lmsObj != undefined) {
    mc_user.cb_keep._visible = false;
		lmsObj.getValue("cmi.interactions._count,_root.g_iaCount");
    if (lmsObj.ver == "1.2") {
			lmsObj.getValue("cmi.core.student_id,mc_user.user_id");
    }
    else {
			lmsObj.getValue("cmi.learner_id,mc_user.user_id");
    } 
		lmsObj.commit();
  }
  else {
		var so: SharedObject = SharedObject.getLocal("userObj");
		if (so.data.enabled) {
			mc_user.cb_keep.selected = true;
      mc_user.user_id = (so.data.userId == undefined) ? "" : so.data.userId;
      mc_user.user_mail = (so.data.userMail == undefined) ? "" : so.data.userMail;
		}

		//取登录用户ID
		if (lgObj.userId != undefined && (mc_user.user_id == "" || mc_user.user_id == undefined)) {
			if (!lgObj.allowChange) {
				//不允许修改
        mc_user.txt_userid.type = "dynamic";
        Selection.setFocus(mc_user.txt_mail);
			}
      mc_user.user_id = lgObj.userId;
    } 
	}
	//取外部传入数据，此为最优先
	if (userId != undefined && userId != "") {
    mc_user.txt_userid.type = "dynamic";
    mc_user.user_id = userId;		
	}
	if (userMail != undefined && userMail != "") {
    mc_user.txt_mail.type = "dynamic";
    mc_user.user_mail = userMail;		
	}
}

//简介页面开始按钮执行函数
function doStart() {
  quizObj.userId = (mc_user.user_id == undefined) ? "" : mc_user.user_id;
  if (quizObj.userId == "" && !quizObj.blankUser) {
		msgBox.show(textObj.noBlankUser, MsgBox.MB_OK, null);
    Selection.setFocus(mc_user.txt_userid);
    return;
  } 
  quizObj.userMail = mc_user.user_mail;
	
	//写SharedObject记录帐号
  var so = SharedObject.getLocal("userObj");
	so.data.enabled = mc_user.cb_keep.selected
	if (so.data.enabled) {
    so.data.userId = quizObj.userId;
    so.data.userMail = quizObj.userMail;
	}
  so.flush();
  delete so;
	
	nextFrame();
}

//初始化课程信息，第6帧
function initCourse() {	
	this.getInstanceAtDepth(LIST_DEPTH).removeMovieClip();
	mc_list.swapDepths(LIST_DEPTH);
  //设置ques数据
  initQuizData();
  if (quizObj.hasDone) {
    return;
  }
	
	//启动定时器
	if (timeSet != undefined && plObj.showTime) {	
    _global.timeObj = new Time(mc_time, timeSet.length);
    timeObj.start();
	}
	else {
		mc_time._visible = false;
	}

	//标签赋值
  mc_prev.caption = textObj.prevItem;
  mc_next.caption = textObj.nextItem;
  quiz_img.removeMovieClip();
	
	//跳到第一题
	firstPage();
}

//设置导航条偏移及当前题边框
_global.setQuesPos = function(moveDown: Boolean) {
	if (mc_list.list == undefined) {
		return;
	}
	
	with (mc_list.list) {
		var areaHeight: Number = 352;
		var quesTop: Number = g_curPage * 21;
		var offV: Number = (sp_list.content._width > 195) ? 17 : 0;
		//位置
		if (moveDown && quesTop >= areaHeight + sp_list.vPosition - (2 + offV)) {
      sp_list.vPosition = quesTop - areaHeight + 23 + offV;
		}
		else if (quesTop <= sp_list.vPosition) {
			sp_list.vPosition = quesTop;
		}
	  //边框
	  sp_list.content.showBound(sp_list.content["item" + g_curPage]);
	}
}

//获取题之总数
function getQuesCount(): Number {
	var nCount: Number = 0;
	var itemObj: Object;
	for (i = 0; i <= quizObj.items.length - 1; i++) {
		itemObj = quizObj.items[i];
		if (itemObj._type != 9) {
			nCount++;
		}
	}
	
	return nCount;
}

//设置单个ques状态
function setQuesInfo(itemObj: Object) {
  var strFlag: String = "";
  if (quizObj.hasDone || itemObj.hasDone) {
		//只处理不是简答题的
    if (itemObj._type < 8) {
      if (itemObj.correct) {
				if (itemObj.feedBack != undefined) {
          strFlag = " \\ <font size=\'14\' color=\'" + replace(plObj.crtColor, "0x", "#") + "\'><b>" + textObj.crtCap + "</b></font>";
				}
				if (mc_list.list.sp_list != undefined) {
          with (mc_list.list.sp_list.content["item" + itemObj.index]) {
            mc_crt._visible = true;
            mc_err._visible = false;
            mc_sv._visible = false;
						mc_sp._visible = false;
            txt_order.textColor = plObj.crtColor;
            txt_cap.textColor = plObj.crtColor;
          }
        }
			} 
      else {
				if (itemObj.feedBack != undefined) {
          strFlag = " \\ <font size=\'14\'><font color=\'" + replace(plObj.errColor, "0x", "#") + "\'><b>" + textObj.errCap + "</b></font></font>";
				}
				if (mc_list.list.sp_list != undefined) {
          with (mc_list.list.sp_list.content["item" + itemObj.index]) {
            mc_err._visible = true;
            mc_crt._visible = false;
            mc_sv._visible = false;
						mc_sp._visible = false;
            txt_order.textColor = plObj.errColor;
            txt_cap.textColor = plObj.errColor;
          }
        }
      }
    }
		//对应简答题...
    else if (mc_list.list.sp_list != undefined) {
      with (mc_list.list.sp_list.content["item" + itemObj.index]) {
        mc_sv._visible = itemObj._type == 8;
				mc_sp._visible = itemObj._type == 9;
        mc_crt._visible = false;
        mc_err._visible = false;
        txt_order.textColor = (itemObj._type == 8) ? 0x0000FF : 0xFF6600;
        txt_cap.textColor = txt_order.textColor;
      }
    }
  }

	//其它信息
	var strInfo = "";
	if (plObj.showType) {
		strInfo = getItemType(itemObj);
	}
  if (plObj.showPoint && itemObj._type < 8) {
		strInfo = (strInfo == "") ? itemObj.score + " " + textObj.point : strInfo + " \\ " + itemObj.score + " " + textObj.point;
  }
  if (plObj.showLevel && itemObj._type < 8) {
		strInfo = (strInfo == "") ? itemObj.level : strInfo + " \\ " + itemObj.level;
  }
  if (strInfo != "") {
    strInfo = " \\ " + strInfo;
  }
  strInfo = strInfo + strFlag;
  mc_top.txt.html = true;
	if (itemObj._type != 9) {
    mc_top.txt.htmlText = textObj.quesCap + " " + itemObj.id + " " + textObj.ofLabel + " " + getQuesCount() + strInfo;
	}
	else {
		//mc_top.txt.htmlText = "<font color=\'#FF6600\'>" + getItemType(itemObj) + "</font>";
		mc_top.txt.htmlText = getItemType(itemObj);
	}
  setClipColor(mc_top.back, plObj.barColor);
}

function initQuizData() {
	if (txt_msg != undefined) {
		txt_msg.removeTextField();
	}
	//设置当前题信息
  setQuesInfo(quizObj.items[g_curPage]);
  mc_top.mc_tool.btn_data._visible = false;
  mc_top.mc_tool.btn_mail._visible = false;
  btn_list._visible = plObj.showList;
  mc_submit.caption = quizObj.hasDone ? textObj.viewResult : textObj.submit;
  mc_prev._visible = false;
  mc_next._visible = false;
  mc_prev.caption = textObj.prevItem;
  mc_next.caption = textObj.nextItem;
  var nWidth: Number = getStrWidth(mc_submit.caption, 14);
  if (nWidth > 75) {
    mc_submit.txt._width = nWidth + 3;
    mc_submit.btn._width = mc_submit.txt._width;
  }
	//跳回上次页面
  if (quizObj.hasDone) {
    gotoPage(g_curPage);
  }
}

//处理课程结果，第7帧
//发送数据...
_global.sendData = function() {
	if (g_viewMode) {
		msgBox.show("This operation is not supported in preview mode.", MsgBox.MB_OK, null);
	}
	else {	
  	hideHint();
	  mc_top.mc_tool.btn_data.enabled = false;
	  dataObj.post();
	}
}

//发送邮件...
_global.sendMail = function() {
	if (g_viewMode) {
		msgBox.show("This operation is not supported in preview mode.", MsgBox.MB_OK, null);
	}
	else {	
	  hideHint();
  	mc_top.mc_tool.btn_mail.enabled = false;
	  mailObj.post();
	}
}

function dealResult() {
	sp_quiz.vScrollPolicy = "off";
	var firstTo: Boolean = quizObj.hasDone != true;
	//置已做过标记
	quizObj.hasDone = true;
	mc_view._visible = plObj.showView;
	//收起列表
	if (mc_list._currentframe != 1) {
		mc_list.gotoAndStop(1);
	}
	//时间停止
	if (timeObj != undefined) {
		timeObj.stop();
	}
	
	//自动发送
  if (!g_viewMode && dataObj != undefined && dataObj.type == 1 && !dataObj.posted) {
    dataObj.post();
  }
  if (!g_viewMode && mailObj != undefined && mailObj.type == 1 && !mailObj.posted) {
    mailObj.post();
  }
	
  //设置工具栏
	with (mc_top.mc_tool) {
    btn_data._visible = plObj.showData;
    btn_mail._visible = plObj.showMail;
  }
	mc_top.txt.text = textObj.quizResult;
	//是否显示结果
	mc_score._visible = passObj.msgText == undefined;
	mc_count._visible = mc_score._visible;
  mc_rst._visible = mc_score._visible;
	if (passObj.msgText != undefined) {
		var txt_msg: TextField = this.createTextField("txt_msg", MSG_DEPTH, 95, 175, 520, 32); 
		txt_msg.text = passObj.msgText;
		var fmt: TextFormat = new TextFormat;
		fmt.font = "_sans";
		fmt.bold = true;
		fmt.size = 16;
		fmt.align = "center";
		fmt.color = 0xFF6600;
		txt_msg.setTextFormat(fmt);
		delete fmt;
	}
	//置标签文本
	if (mc_score._visible) {
    mc_score.lbl_uscore.text = textObj.userScore;
    mc_score.lbl_pscore.text = textObj.passScore;
		mc_score.lbl_tscore.text = textObj.totalScore;
		mc_count.lbl_qc.text = textObj.quesCount;
		mc_count.lbl_pc.text = textObj.passQues;
		mc_count.lbl_pc.textColor = plObj.crtColor;
		mc_count.lbl_fc.text = textObj.failQues;
		mc_count.lbl_fc.textColor = plObj.errColor; 
    mc_rst.lbl_result.text = textObj.showResult;
	}
	mc_view.caption = textObj.view;
	mc_view._visible = plObj.showView;
  mc_exit.caption = textObj.finish;
	//通过计算
  var nPer: Number = Math.round(quizObj.userScore * 100 / quizObj.totalScore);
  if (nPer.toString() == "NaN") {
    nPer = 0;
  }
	
	//lms结果
  if (lmsObj != undefined) {
		//发送每题结果
		lmsObj.iaCount = (g_iaCount == undefined || g_iaCount == "") ? 0 : g_iaCount;
    lmsObj.postData();
    if (lmsObj.ver == "1.2") {
			lmsObj.setValue("cmi.core.score.raw," + nPer.toString());
			lmsObj.setValue("cmi.core.score.min,0");
			lmsObj.setValue("cmi.core.score.max,100");
    }
    else {
			lmsObj.setValue("cmi.score.raw," + nPer.toString());
			if (nPer != 100) {
        lmsObj.setValue("cmi.score.scaled,0." + nPer);
			}
			else {
			  lmsObj.setValue("cmi.score.scaled,1");
			}
			lmsObj.setValue("cmi.score.min,0");
			lmsObj.setValue("cmi.score.max,100");
    }
	}
	//填充分数结果
	if (mc_score._visible) {
    with (mc_score) {
      txt_score.text = quizObj.userScore + " " + textObj.point;
      txt_per.text = nPer + " %";
      txt_pscore.text = (Math.round(quizObj.totalScore * parseFloat(passObj.rate)) * 100 / 10000) + " " + textObj.point;
      txt_pper.text = passObj.rate + " %";
			txt_tscore.text = quizObj.totalScore + " " + textObj.point;
			txt_tper.text = "100%";
    }
	}
	//填充做对错信息
	if (mc_count._visible) {
  	with (mc_count) {
		  txt_qc.text = getQuesCount();
  		//做对题数
		  var passCount: Number = 0;
  		for (var i = 0; i <= quizObj.items.length - 1; i++) {
				//简答及场景题不参与计数
				if (quizObj.items[i]._type >= 8) {
					continue;
				}
			  if (quizObj.items[i].correct) {
				  passCount++;
  			}
		  }
  		txt_pc.text = passCount;
  		txt_pc.textColor = plObj.crtColor;
		  //做错题数
  		var failCount: Number = 0;
		  for (var i = 0; i <= quizObj.items.length - 1; i++) {
				if (quizObj.items[i]._type >= 8) {
					continue;
				}
			  if (!quizObj.items[i].correct) {
				  failCount++;
  			}
		  }
  		txt_fc.text = failCount;
		  txt_fc.textColor = plObj.errColor;
  	}
	}
	//分数信息
  var passed: Boolean = quizObj.userScore >= quizObj.passScore && quizObj.totalScore != 0;
	var clrRst: String;
  if (passed) {
		//播放声音
		if (firstTo && esObj.sndPass != undefined) {
			sound.play(esObj.sndPass);
		}
		
		mc_rst.txt_rst.html = true;
    mc_rst.txt_rst.htmlText = quizObj.userId == "" ? passObj.passInfo : quizObj.userId + ", " + passObj.passInfo;
		clrRst = plObj.crtColor;
    //置lms信息
    if (lmsObj != undefined) {
			if (lmsObj.ver == "1.2") {
				lmsObj.setValue("cmi.core.lesson_status,passed");
			}
			else {
				lmsObj.setValue("cmi.success_status,passed");
			}
			lmsObj.commit();
		}
  }
  else {
		//播放声音
		if (firstTo && esObj.sndFail != undefined) {
			sound.play(esObj.sndFail);
		}

    mc_rst.txt_rst.text = quizObj.userId == "" ? passObj.failInfo : (quizObj.userId + ", " + passObj.failInfo);
		clrRst = plObj.errColor;
    //置lms信息
    if (lmsObj != undefined) {
      if (lmsObj.ver == "1.2") {
				lmsObj.setValue("cmi.core.lesson_status,failed");
			}
			else {
				lmsObj.setValue("cmi.success_status,failed");
			}
      lmsObj.commit();
		}
  }
	
	if (lmsObj != undefined) {
    if (lmsObj.ver == "1.2") {
			lmsObj.setValue("cmi.core.exit,");
		}
		else {
			lmsObj.setValue("cmi.completion_status,completed");
      lmsObj.setValue("cmi.exit,normal");
		}
		lmsObj.finish();
		
		//请除lms对象
		delete lmsObj;
	}

	//设置颜色
	if (mc_score._visible) {
  	setClipColor(mc_top.back, clrRst);
	  mc_score.txt_score.textColor = clrRst;
  	mc_score.txt_per.textColor = clrRst;
	  mc_rst.txt_rst.textColor = clrRst;

  	mc_rst.sb_rst.setScrollTarget(mc_rst.txt_rst);
    mc_rst.sb_rst.visible = mc_rst.txt_rst.textHeight >= 121;
	}
}

//浏览
_global.viewQuiz = function() {
	prevFrame();
}

//退出
_global.quitQuiz = function() {
	//关闭操作
  var playerType: String = System.capabilities.playerType;
  if ((playerType == "ActiveX" || playerType == "PlugIn") && !g_viewMode && !g_exeMode) {
		var strJs: String = "";
    strJs = strJs + "if (window.top != window && window.top != null) {";
    strJs = strJs + "  window.top.close();";
    strJs = strJs + "}";
    strJs = strJs + "else {";
    strJs = strJs + "  window.close();";
    strJs = strJs + "}";
     
		getURL("javascript: " + strJs, "");
  }
  else {
    fscommand("quit");
  }
	//跳转
	var passed: Boolean = quizObj.userScore >= quizObj.passScore && quizObj.totalScore != 0 || quizObj.totalScore == 0;
	var nType: Number = passed ? quitObj.passType : quitObj.failType;
	var strUrl: String = passed ? quitObj.passUrl : quitObj.failUrl;
	if (nType == 1) {
    getURL(strUrl, "");
	}
}

//隐藏课程
_global.hideCourse = function() {
  for (var i = 0; i <= quizObj.items.length - 1; i++) {
    quizObj.items[i].ldr.visible = false;
    quizObj.items[i].movie.stop();
  } 
}

//发送题之数据...
//指定题是否已处理
_global.getItemDone = function(itemObj: Object, showBox: Boolean) {
  var ansObj: Object = itemObj.ans;
  var hasDone: Boolean = false;
	//是否显示提示框
  if (showBox == undefined) {
     showBox = true;
  }
	
  //分类型判断
	switch (itemObj._type) {
  case 1:
  case 2:
  case 3:
		for (var i = 0; i <= ansObj.items.length - 1; i++) {
			hasDone = hasDone || ansObj.items[i].clip.selected
		}
    break;
  case 4:
  case 8:
	  var strAns: String = ansObj.clip.text.toLowerCase();
    hasDone = trim(strAns) != "";
    break;
  case 5:
    hasDone = true;
    for (var i = 0; i <= ansObj.items.length - 1; i++) {
			hasDone = hasDone && ansObj.items[i].clip._x == 279;
		}
    break;
  case 6:
	  hasDone = ansObj.hasDeal;
    break;
  case 7:
	  hasDone = ansObj.clip != undefined;
		break;
	case 9:
	  hasDone = true;
		break;
  default:
    trace("get item done: course type error!");
  }
	
	//结果处理
  if (!hasDone && showBox) {
		var strSnd: String = (esObj.sndTry == undefined) ? "try" : esObj.sndTry;
		sound.play(strSnd);
    msgBox.show(textObj.uncplInfo, MsgBox.MB_TRY, null);
  }
	
  return hasDone;
}

//获取指定题结果：0、正确；-1、错误；-2、简答题；及处理答案显示等
function getItemResult(itemObj: Object): Number {
	var ansObj: Object = itemObj.ans;
  var correct: Boolean = true;
  //分类型判断
	switch (itemObj._type) {
  case 1:
  case 2:
  case 3:
    for (var i = 0; i <= ansObj.items.length - 1; i++) {
  	  correct = ansObj.items[i].correct ? correct && ansObj.items[i].clip.selected : correct;
			if (itemObj._type == 3 && !ansObj.items[i].correct) {
			  correct = correct && !ansObj.items[i].clip.selected;
			}
			//存储单选题之答案级反馈
			if (itemObj._type == 2 && itemObj.feedAns && ansObj.items[i].clip.selected) {
				itemObj.feedStr = ansObj.items[i].feedBack;
			}
		}
		//答题次数
		if (itemObj.attempt <= 1 || correct) {
		  for (var i = 0; i <= ansObj.items.length - 1; i++) {
			  ansObj.items[i].clip.enabled = false;
				//答案指示
				if (quizObj.showAns && ansObj.items[i].correct) {
          var mc_flag: MovieClip = itemObj.ldr.createObject("cflag_clip", "mc_cflag" + itemObj.id + i, itemObj.ldr.getNextHighestDepth(), {});
          mc_flag._x = ansObj.items[i].clip._x - mc_flag._width - 4;
          mc_flag._y = ansObj.items[i].clip._y + (ansObj.items[i].clip._height - mc_flag._height) / 2 - 1;
				}
			}
		}
    break;
	case 4:
    correct = false;
 	  var strAns: String = ansObj.clip.text.toLowerCase();
		for (var i = 0; i <= ansObj.items.length - 1; i++) {
			correct = correct || strAns == ansObj.items[i].value.toLowerCase();
  	}
		//答题次数
		if (itemObj.attempt <= 1 || correct) {
      ansObj.clip.type = "dynamic";
      ansObj.clip.selectable = false;
      ansObj.clip.textColor = 0x848284;
			//答案指示
      if (quizObj.showAns) {
				var strAll: String = "<b>" + textObj.accepts + "</b>";
				for (var i = 0; i <= ansObj.items.length - 1; i++) {
					strAll += "\n    " + ansObj.items[i].value;
				}
				
        strAll = strAll + "\n  ";
        var txt_ans = itemObj.ldr.createTextField("txt_dis" + itemObj.id, itemObj.ldr.getNextHighestDepth(), 0, 0, 575, 225);
        var fmt:TextFormat = new TextFormat();
        fmt.font = "_sans";
				txt_ans.setNewTextFormat(fmt);
				delete fmt;
				txt_ans.html = true;
        txt_ans.htmlText = strAll;
        txt_ans.textColor = 0x009900;
        txt_ans.wordWrap = true;
        txt_ans.selectable = itemObj._type == 8;
        txt_ans._x = ansObj.clip._x;
        txt_ans._y = ansObj.clip._y + ansObj.clip._height + 12;
			}
		}
    break;
  case 5:
	  var lbl_x: Number = ansObj.items[0].clip._x == 279 ? itemObj.ldr["mc_back" + itemObj.id]._width - 20 : itemObj.ldr["mc_back" + itemObj.id]._width - 15 ;
    if (itemObj.img != undefined) {
			lbl_x = lbl_x * 100 / 74;
			if (ansObj.items[0].clip._x != 279) {
				lbl_x = lbl_x + 6;
			}
		}
		for (var i = 0; i <= ansObj.items.length - 1; i++) {
			correct = correct && ansObj.items[i].clip._x == 279 && ansObj.items[i].YPos == ansObj.items[i].clip._y;
		}
		//答题次数
		if (itemObj.attempt <= 1 || correct) {
		  for (var i = 0; i <= ansObj.items.length - 1; i++) {
			  ansObj.items[i].clip.back.btn.enabled = false;
				//答案指示
				if (quizObj.showAns) {
          var mc_back: MovieClip = itemObj.ldr["mc_back" + itemObj.id];
          var lbl = mc_back.createClassObject(mx.controls.Label, "lbl_dis" + itemObj.id + i, mc_back.getNextHighestDepth(), {text: (i + 1)});
          lbl.setStyle(fontSize, plObj.ansSize);
          lbl.setStyle("fontWeight", "bold");
          //颜色标记
					if (ansObj.items[i].clip._x == 279 && ansObj.items[i].YPos == ansObj.items[i].clip._y) {
            lbl.setStyle("color", 0x009900);
          }
          else {
            lbl.setStyle("color", 0xFF0000);
          }
          //位置
					lbl._x = lbl_x;
          lbl._y = ansObj.items[i].clip._y + (ansObj.items[i].clip._height - lbl._height) / 2;
        }
			}
		}
    break;
	case 6:
    for (var i = 0; i <= ansObj.items.length - 1; i++) {
  	  correct = correct && ansObj.items[i].YPos == ansObj.items[i].clip._y;
		}
		//答题次数
		if (itemObj.attempt <= 1 || correct) {
			//获取答案指示数组
			var arrCur: Array = new Array();
			for (var i = 0; i <= ansObj.items.length - 1; i++) {
				for (var j = 0; j <= ansObj.items.length - 1; j++) {
					if (ansObj.items[i].YPos == ansObj.items[j].clip._y) {
						arrCur.push(j);
					}
				}
			}

			for (var i = 0; i <= ansObj.items.length - 1; i++) {
			  ansObj.items[i].clip.btn.enabled = false;
				//答案指示
				if (quizObj.showAns) {
          var mc_back: MovieClip = itemObj.ldr["mc_back" + itemObj.id];
          var lbl = mc_back["lbl_" + itemObj.id + i];
					lbl.text = (arrCur[i] + 1) + ". ";
          lbl.setStyle(fontSize, plObj.ansSize);
          lbl.setStyle("fontWeight", "bold");
          //颜色标记
					if (ansObj.items[i].YPos == ansObj.items[i].clip._y) {
            lbl.setStyle("color", 0x009900);
          }
          else {
            lbl.setStyle("color", 0xFF0000);
          }
        }
			}
		}
    break;
  case 7:
    var curX: Number = ansObj.clip._x + 34;
    var curY: Number = ansObj.clip._y + 34;
	  var mc_area: MovieClip = itemObj.ldr["mc_area" + itemObj.id];
    correct = ansObj.clip._visible && curX >= mc_area._x + ansObj._x && curX <= mc_area._x + parseFloat(ansObj._x) + parseFloat(ansObj._width) 
		                               && curY >=  mc_area._y + ansObj._y && curY <=  mc_area._y + parseFloat(ansObj._y) + parseFloat(ansObj._height);
    //答题次数
		if (itemObj.attempt <= 1 || correct) {
    	var btn: MovieClip = itemObj.ldr["btn_mask" + itemObj.id];
      if (btn != undefined) {
        btn.enabled = false;
      }
			//答案指示
			if (quizObj.showAns) {  
        var mc_hotarea: MovieClip = itemObj.ldr.createObject("hrect_clip", "mc_hotarea" + itemObj.id, itemObj.ldr.getNextHighestDepth());
        mc_hotarea._visible = true;
        with (mc_hotarea) {
          _alpha = 25;
          _x = mc_area._x + parseFloat(ansObj._x);
					_y = mc_area._y + parseFloat(ansObj._y);
					_width = ansObj._width;
					_height = ansObj._height;
				}
			}
		}
		break;
	case 8:
    //ansObj.clip.enabled = false;
		//模拟不可用状态，只因为enabled = false之后，若有滚动条，则其不能操作的问题
    ansObj.clip.editable = false;
		ansObj.clip.setStyle("color", 0x848384);
		//答案指示
    if (quizObj.showAns) {
			setQuesInfo(itemObj);
			var strAll: String = "<b>" + textObj.referAns + "</b> \n" + ansObj.refAns + "\n  ";
      var txt_ans = itemObj.ldr["txt_dis" + itemObj.id];
      if (txt_ans == undefined) {
        txt_ans = itemObj.ldr.createTextField("txt_dis" + itemObj.id, itemObj.ldr.getNextHighestDepth(), 0, 0, 575, 205);
        var fmt:TextFormat = new TextFormat();
        fmt.font = "_sans";
				txt_ans.setNewTextFormat(fmt);
				delete fmt;
        txt_ans.html = true;
        txt_ans.htmlText = strAll;
        txt_ans.textColor = 0x009900;
        txt_ans.wordWrap = true;
        txt_ans.selectable = itemObj._type == 8;
        txt_ans._x = ansObj.clip._x;
        txt_ans._y = ansObj.clip._y + ansObj.clip._height + 12;
      }
		}
		
		return -2;
    break;
  default:
    trace("get result: course type error!");
	}
	
  //结果处理
  var nScore: Number = correct ? itemObj.score : 0;
  quizObj.userScore += nScore;
  itemObj.correct = correct;
	//此处||itemObj.correct，是为处理有多次尝试机会但答对的情况
	if (itemObj.attempt <= 1 || itemObj.correct) {
		setQuesInfo(itemObj);
	}

  return correct ? 0 : -1;
}

//找下个未做题
function getNextItem(): Number {
	if (quizObj.items[g_curPage + 1] != undefined && quizObj.items[g_curPage + 1]._type == 9) {
		return (g_curPage + 1);
	}
  for (var i = 0; i <= quizObj.items.length - 1; i++) {
    if (!getItemDone(quizObj.items[i], false)) {
      return i;
    }
  }
	
	//若全都做完，返回-1
  return -1;
}

//获取所有结果
function getResult() {
  for (var i = 0; i <= quizObj.items.length - 1; i++) {
		//停止播放其它题之声音
	  sndQues.stop("snd_" + i);

		if (!quizObj.items[i].hasDone) {
		  quizObj.items[i].attempt = 1;
		  quizObj.items[i].hasDone = true;
      getItemResult(quizObj.items[i]);
		}
  }
	
	//到结果显示页面
	hideCourse();
	gotoAndStop("result");
}

//发送单项
function submitOne(itemObj: Object) {
	//返馈信息不可用
	if (itemObj.feedBack == undefined && !itemObj.feedAns) {
		itemObj.hasDone = getItemDone(itemObj)
		if (itemObj.hasDone) {
			itemObj.attempt = 1;
			getItemResult(itemObj);
		}
		else {
			return;
		}
	}
	//题尚未处理 
	if (!itemObj.hasDone) {
		itemObj.hasDone = getItemDone(itemObj)
		if (itemObj.hasDone) {
			var strInfo, strIcon, strSnd: String;
			var nType: Number;
			var redoItem: Boolean = false;
			var nResult: Number = getItemResult(itemObj);
			//正确
			if (nResult == 0) {
				strInfo = (itemObj.feedBack != undefined) ? itemObj.feedBack.crtInfo : "";
				var lineChar: String = (strInfo == "") ? "" : "\n";
				strInfo += (itemObj.feedAns) ? lineChar + itemObj.feedStr : "";
				strIcon = "crt";
				nType = MsgBox.MB_NEXT;
				if (strInfo != "" && strInfo != "\n") {
				  strSnd = (esObj.sndCrt == undefined) ? "succ" : esObj.sndCrt;
			    sound.play(strSnd);
				}
			}
			//错误
			else if (nResult == -1) {
				strInfo = (itemObj.feedBack != undefined) ? itemObj.feedBack.errInfo : "";
				var lineChar: String = (strInfo == "") ? "" : "\n";
				strInfo += (itemObj.feedAns) ? lineChar + itemObj.feedStr : "";
				if (strInfo == "" || strInfo == "\n") {
					itemObj.attempt = 1;
			    getItemResult(itemObj);
				}
				//尝试次数
				if (itemObj.attempt != 0) {
					itemObj.attempt--;
					if (itemObj.attempt == 0) {
						strSnd = (esObj.sndErr == undefined) ? "error" : esObj.sndErr;
						redoItem = false;
						nType = MsgBox.MB_NEXT;
					} 
					else {
						strSnd = (esObj.sndTry == undefined) ? "error" : esObj.sndTry;
						itemObj.hasDone = false;
						redoItem = true;
						nType = MsgBox.MB_TRY;
					}
				} 
				if (strInfo != "" && strInfo != "\n") {
			    sound.play(strSnd);
				}
				strIcon = "err";
			} 
			//简答题
			else {
				strInfo = textObj.essayInfo;
				sound.play("succ");
				strIcon = "iflag";
				nType = MsgBox.MB_NEXT;
			}
			
			//找下一个未做题
			var nextIndex: Number = getNextItem();
			if (nextIndex == -1 && !redoItem) {
				strInfo = strInfo;
				nType = MsgBox.MB_VIEW;
			}

			//回调函数
			var fun: Function = function () {
				//重做
				if (redoItem) {
					return;
				}

				if (nextIndex != -1) {
					gotoPage(nextIndex);
				} 
				else {
					getResult();
				}
			}
			//对话框提示
			if (strInfo != "" && strInfo != "\n") {				
			  msgBox.show(strInfo, nType, fun, strIcon);
			}
			else {
				fun();
			}
		}
		return;
	}

	//当前题已处理的后续处理
	var nextIndex: Number = getNextItem();
	var allDone: Boolean = true;
	if (nextIndex != -1) {
		gotoPage(nextIndex);
	} 
	else if (quizObj.hasDone) {
	  //收起列表
	  if (mc_list._currentframe != 1) {
		  mc_list.gotoAndStop(1);
	  }
		gotoAndStop("result");
	} 
	else {
		for (var i = 0; i <= quizObj.items.length; i++) {
			allDone = allDone && quizObj.items[i].hasDone;
		}
		if (allDone) {
			getResult();
		} 
		else {
			var fun: Function = function() {
				getResult();
			}
			msgBox.show(textObj.postInfoView, MsgBox.MB_YESNO, fun);
		}
	}
}

//发送全部
function submitAll() {
  var fun: Function = function() {
		getResult();
	}
	
	sound.play("succ");
	var strInfo: String = getNextItem() != -1 ? textObj.postInfoNotAll : textObj.postInfoView;
	msgBox.show(strInfo, MsgBox.MB_YESNO, fun);
}

//发送操作	
_global.doSubmit = function() {
	if (quizObj.hasDone) {
		hideCourse();
		gotoAndStop("result");
	} 
	//单独模式
	else if (quizObj.sngMode) {
		submitOne(quizObj.items[g_curPage]);
	} 
	else {
		submitAll();
	}
}

//时间到处理
_global.dealTimeout = function() {
  var fun: Function = function() {
		//lms设值
    if (lmsObj != undefined) {
			lmsObj.setValue("cmi.core.exit,time-out");
		  lmsObj.commit();
		}
		//处理结果
    getResult();
  }
	
	//若有窗口则关闭
	if (msgBox._visible) {
		msgBox.closeBox();
	}
	else if (aboutBox._visible) {
		aboutBox.close();
	}
  sound.play("try");
  msgBox.show(replace(textObj.timeoutInfo, "%s", textObj.okLabel), MsgBox.MB_OK, fun);
}

//题之跳转控制
_global.gotoPage = function(pageIndex) {
  if (pageIndex < 0) {
    pageIndex = 0;
    return;
  }
	else if (pageIndex > g_totalPage - 1) {
    pageIndex = g_totalPage - 1;
    return;
  }

	var itemObj: Object = quizObj.items[pageIndex];	
	//声音播放...
	//停止播放其它题之声音
	for (var i = 0; i <= quizObj.items.length - 1; i++) {
	  sndQues.stop("snd_" + i);
	}
	if (itemObj.hasDone && itemObj.playClip != undefined) {
		itemObj.playClip._visible = false;
	}
	if (!itemObj.hasDone && itemObj.sndObj != undefined) {
		if (itemObj.sndObj.autoPlay) {
			sndQues.play(itemObj.sndObj.snd);
			var loopCount: Number = itemObj.sndObj.loopCount;
			sndQues.onSoundComplete = function() {
				loopCount--;
				if (loopCount > 0) {
					this.start();
				}
			}
		}
		else {
			itemObj.sndObj.pos = 0;
			itemObj.playClip.gotoAndStop(1);
		}
	}
	
  if (itemObj.dealTime == "00:00:00" && !itemObj.hasDone) {
    var d: Date = new Date();
    itemObj.dealTime = formatTime(d.getHours() * 3600 + d.getMinutes() * 60 + d.getSeconds());
  }
	var moveDown: Boolean = g_curPage < pageIndex;
	_global.g_curPage = pageIndex;
  hideCourse();
  itemObj.ldr.visible = true;
  //是否显示滚动条
  sp_quiz.vScrollPolicy = itemObj.ldr._height >= 390 ? "auto" : "off";
  sp_quiz.content._y = 0;
	sp_quiz.vPosition = 0;
  itemObj.movie.play();
	//填空、简答题设定焦点
	if (!itemObj.hasDone && (itemObj._type == 4 || itemObj._type == 8)) {
    Selection.setFocus(itemObj.ans.clip);
  }
  else {
    Selection.setFocus(mc_submit.btn);
  }
	//导航条位置移动，导航条同步显示
	setQuesPos(moveDown);
  setQuesInfo(itemObj);
	mc_submit._visible = quizObj.hasDone || itemObj._type != 9;
  mc_prev._visible = pageIndex > 0 && g_totalPage != 0 && plObj.showPrev;
  mc_next._visible = pageIndex < g_totalPage - 1 && g_totalPage != 0 && plObj.showNext || itemObj._type == 9;
	mc_next.caption = (itemObj._type == 9) ? replace(textObj.startCap, "...", "") : textObj.nextItem;
}

_global.firstPage = function() {
  gotoPage(0);
}

_global.prevPage = function() {
  gotoPage(g_curPage - 1);
}

_global.nextPage = function() {
  gotoPage(g_curPage + 1);
}

_global.lastPage = function() {
  gotoPage(g_totalPage - 1);
}

//处理数据发送之函数群...
//获取对应题型
function getItemType(itemObj: Object): String {
	var strType:String = "";
	switch (itemObj._type) {
	case 1 :
		strType = textObj.judge;
		break;
	case 2 :
		strType = textObj.single;
		break;
	case 3 :
		strType = textObj.multi;
		break;
	case 4 :
		strType = textObj.blank;
		break;
	case 5 :
		strType = textObj.match;
		break;
	case 6 :
		strType = textObj.seque;
		break;
	case 7 :
		strType = textObj.hotSpot;
		break;
	case 8 :
		strType = textObj.essay;
		break;
  case 9 :
    strType = textObj.scene;
    break;
	default :
		trace("get result: ques type error!");
	}   

	return strType;
}

//获取指定题之正确答案
_global.getItemAnswer = function(itemObj: Object): String {
	var ansObj: Object = itemObj.ans;
	var strResult: String = "";
	var strSplit: String = (lmsObj != undefined && lmsObj.ver == "1.3") ? "[,]" : ",";
	strSplit = (lmsObj != undefined) ? strSplit : "\r";
	var strDot: String = (lmsObj != undefined && lmsObj.ver == "1.3") ? "[.]" : ".";

	//分题型判断
	switch (itemObj._type) {
	case 1:
	case 2:
	case 3:
	  for (var i = 0; i <= ansObj.items.length - 1; i++) {
		  if (ansObj.items[i].correct) {
			  strResult = (strResult == "") ? trim(ansObj.items[i].value) : strResult + strSplit + trim(ansObj.items[i].value);
			}
		}

		//lms值需要特别处理
		if (lmsObj != undefined && itemObj._type == 1) {
			//参考Articulate实现方法，第一个为正确答案为true，反之为false
			if (lmsObj.ver == "1.2") {
			  strResult = (ansObj.items[0].correct) ? "t" : "f";
			}
			else {
				strResult = (ansObj.items[0].correct) ? "true" : "false";
			}
		}

		break;
	case 4:
		for (var i = 0; i <= ansObj.items.length - 1; i++) {
			strResult = (strResult == "") ? trim(ansObj.items[i].value) : strResult + "," + trim(ansObj.items[i].value);
		}
		break;
	case 5:
		for (var i = 0; i <= ansObj.items.length - 1; i++) {
			if (lmsObj == undefined) {
			  strResult = (strResult == "") ? trim(ansObj.items[i].topic) + "->" + trim(ansObj.items[i].value) : strResult + strSplit + trim(ansObj.items[i].topic) + "->" + trim(ansObj.items[i].value);
			}
			else {
			  strResult = (strResult == "") ? trim(ansObj.items[i].topic) + strDot + trim(ansObj.items[i].value) : strResult + strSplit + trim(ansObj.items[i].topic) + strDot + trim(ansObj.items[i].value);
			}
		}
		break;
	case 6:
		for (var i = 0; i <= ansObj.items.length - 1; i++) {
			strResult = (strResult == "") ? trim(ansObj.items[i].value) : strResult + strSplit + trim(ansObj.items[i].value);
		}
		break;
	case 7:
		strResult = ansObj._x + "," + ansObj._y + "," + (ansObj._x + ansObj._width) + "," + (ansObj._y + ansObj._height);
		if (lmsObj != undefined && lmsObj.ver == "1.3") {
			strResult = "[.]" + strResult;
		}
		break;
	case 8:
	  strResult = ansObj.refAns;
	  break;
	default:
		strResult = " ";
		trace("get item result: course type error!");
	}

	if (lmsObj != undefined && lmsObj.ver == "1.3") {
		switch (itemObj._type) {
		case 1:
		case 2:
		case 3:
		case 5:
		case 6:
		  strResult = replace(strResult, " ", "_");
		  strResult = replace(strResult, "\r", "_");
		}
	}
	return strResult;
}

//获取指定题之用户答案
_global.getUserAnswer = function(itemObj: Object): String {
	var ansObj: Object = itemObj.ans;
	var strResult: String = "";
	var strSplit: String = (lmsObj != undefined && lmsObj.ver == "1.3") ? "[,]" : ",";
	strSplit = (lmsObj != undefined) ? strSplit : "\r";
	var strDot: String = (lmsObj != undefined && lmsObj.ver == "1.3") ? "[.]" : ".";

	//分题型判断
	switch (itemObj._type) {
	case 1 :
	case 2 :
	case 3 :
	  for (var i = 0; i <= ansObj.items.length - 1; i++) {
		  if (ansObj.items[i].clip.selected) {
			  strResult = (strResult == "") ? trim(ansObj.items[i].value) : strResult + strSplit + trim(ansObj.items[i].value);
			}
		}

		//lms值需要特别处理
		if (lmsObj != undefined && itemObj._type == 1) {
			if (lmsObj.ver == "1.2") {
				strResult = (ansObj.items[0].correct && ansObj.items[0].clip.selected) ? "t" : "f";
			}
			else {
				strResult = (ansObj.items[0].correct && ansObj.items[0].clip.selected) ? "true" : "false";
			}
		}
		break;
	case 4:
	case 8:
		strResult = ansObj.clip.text;
		break;
	case 5:
	  var curIndex: Number = 0;
		for (var i = 0; i <= ansObj.items.length - 1; i++) {
			for (var j = 0; j <= ansObj.items.length - 1; j++) {
				if (ansObj.items[i].YPos == ansObj.items[j].clip._y) {
					curIndex = j;
					break;
				}
			}
			//连接答案
			if (lmsObj == undefined) {
			  strResult = (strResult == "") ? trim(ansObj.items[i].topic) + "->" + trim(ansObj.items[curIndex].value) : strResult + strSplit + trim(ansObj.items[i].topic) + "->" + trim(ansObj.items[curIndex].value);
			}
			else {
			  strResult = (strResult == "") ? trim(ansObj.items[i].topic) + strDot + trim(ansObj.items[curIndex].value) : strResult + strSplit + trim(ansObj.items[i].topic) + strDot + trim(ansObj.items[curIndex].value);
			}
		}
		break;
	case 6:
	  var curIndex: Number = 0;
		for (var i = 0; i <= ansObj.items.length - 1; i++) {
			for (var j = 0; j <= ansObj.items.length - 1; j++) {
				if (ansObj.items[i].YPos == ansObj.items[j].clip._y) {
					curIndex = j;
					break;
				}
			}
			//连接答案
			strResult = (strResult == "") ? trim(ansObj.items[curIndex].value) : strResult + strSplit + trim(ansObj.items[curIndex].value);
		}
		break;
	case 7:
	  if (ansObj.clip == undefined) {
			strResult = "";
		}
		else {
	    var xPos: Number = ansObj.clip._x + 22;
			var yPos: Number = ansObj.clip._y + 7.5;
	
		  if (lmsObj != undefined && lmsObj.ver == "1.3") {
        strResult = strDot + xPos + ","  + yPos;
			}
			else {
				strResult = xPos + ","  + yPos;
			}
		}
		break;
	default :
		strResult = " ";
		trace("get users result: course type error!");
	}

	if (lmsObj != undefined && lmsObj.ver == "1.3") {
		switch (itemObj._type) {
		case 1:
		case 2:
		case 3:
		case 5:
		case 6:
		  strResult = replace(strResult, " ", "_");
		  strResult = replace(strResult, "\r", "_");
		}
	}
	return strResult;
}

//获取quiz主体数据
_global.getQuesInfo = function(): String  {
	function getHtml(s: String): String {
		var str: String = s;
		str = replace(str, "&", "&amp;");
		str = replace(str, "<", "&lt;");
		str = replace(str, ">", "&gt;");
		str = replace(str, "\"", "&quot;");
		str = replace(str, " ", "&nbsp;");
		str = replace(str, "\n", "<br>");
		str = replace(str, "\r", "<br>");
		
		return str;
	}
	
	var strHtml: String = "";
	//表头
	strHtml = strHtml + "<table border=1 bordercolor=#7F9DB9 cellpadding=0 cellspacing=0 width=100% style='border-collapse: collapse; word-break: break-all; word-wrap: break-word'>\r";
	strHtml = strHtml + "  <tr bgcolor=#7F9DB9>\r";
	strHtml = strHtml + "    <td><font size=2 color=#FFFFFF>题目</font></td>\r";
	strHtml = strHtml + "    <td><font size=2 color=#FFFFFF>题型</font></td>\r";
	strHtml = strHtml + "    <td><font size=2 color=#FFFFFF>分值</font></td>\r";
	strHtml = strHtml + "    <td><font size=2 color=#FFFFFF>考生答案</font></td>\r";
	if (quizObj.showAns) {
    strHtml = strHtml + "    <td><font size=2 color=#FFFFFF>正确答案</font></td>\r";
  }
	strHtml = strHtml + "    <td><font size=2 color=#FFFFFF>结果</font></td>\r";
	strHtml = strHtml + "  </tr>\r";
	var clr, strFlag: String;
	for (var i = 0; i <= quizObj.items.length - 1; i++) {
		var itemObj: Object = quizObj.items[i];
		if (itemObj._type < 8) {
			clr = itemObj.correct ? "#008000" : "#FF0000";
		}
		else {
			clr = (itemObj._type == 8) ? "#0000FF" : "#FF6600";
		}
		strHtml = strHtml + "  <tr>\r";
		if (itemObj._type != 9) {
		  strHtml = strHtml + "    <td><font size=2><font color=" + clr + ">" + itemObj.id + "</font>. " + getHtml(itemObj.topic) + "</font></td>\n";
		  strHtml = strHtml + "    <td><font size=2>" + getItemType(itemObj) + "</font></td>\n";
		  strHtml = strHtml + "    <td><font size=2 color=" + clr + ">" + itemObj.score + "</font></td>\n";
		}
		else {
		  strHtml = strHtml + "    <td><font size=2 color=#FF6600>&nbsp;&nbsp;&nbsp;" + getHtml(itemObj.topic) + "</font></td>\n";
		  strHtml = strHtml + "    <td><font size=2 color=#FF6600>" + getItemType(itemObj) + "</font></td>\n";
		  strHtml = strHtml + "    <td></td>\n";
		}
		strHtml = strHtml + "    <td><font size=2>" + getHtml(getUserAnswer(itemObj)) + "</font></td>\n";
		if (quizObj.showAns) {
		  strHtml = strHtml + "    <td><font size=2>" + getHtml(getItemAnswer(itemObj)) + "</font></td>\n";
		}
		//对错标识
		if (itemObj._type < 8) {
			//&#8730:√; &#215:×
			strFlag = itemObj.correct ? "<font color=" + clr + "><b>&#8730</b></font>" : "<font color=" + clr + "><b>&#215</b></font>";
		}
		else {
			strFlag = "";
		}
		strHtml = strHtml + "    <td><font size=2>" + strFlag + "</font></td>\n";
		strHtml = strHtml + "  </tr>\r";
	}
	strHtml = strHtml + "</table>\r";
	if (timeObj != undefined) {
	  strHtml = strHtml + "<br><br>\r";
		strHtml = strHtml + "试题时长：" + formatTime(timeObj._length) + "<br>\r";
		strHtml = strHtml + "已用时间：<font color='#FF0000'>" + formatTime(timeObj._elapse) + "</font><br>\r";
		strHtml = strHtml + "剩余时间：<font color='#009900'>" + formatTime(timeObj._length - timeObj._elapse) + "</font>\r";
	}
	
	return strHtml;
}

//公用函数...
_global.replace = function(str, oldStr, newStr: String): String {
  return str.split(oldStr).join(newStr);
}

_global.trim = function(str: String): String {
	var nStart: Number = 0, nEnd: Number = 0;
  for (var i = 0; i < str.length; i++) {
    if (str.charAt(i) != " " && str.charAt(i) != "\n") {
      nStart = i;
      break;
    } 
  }
  for (var i = str.length - 1; i >= 0; i--) {
    if (str.charAt(i) != " " && str.charAt(i) != "\n") {
      nEnd = i - nStart + 1;
      break;
    } 
	}
	
  return (str.substr(nStart, nEnd));
}

_global.getYearStr = function(): String {
	var date: Date = new Date();
	var m, d: String;
	m = (date.getMonth() + 1 <= 9) ? "0" + (date.getMonth() + 1) : (date.getMonth() + 1);
	d = (date.getDate() <= 9) ? "0" + date.getDate() : date.getDate();
	
	return date.getFullYear() + "-" + m + "-" + d;
}

_global.getDateStr = function(): String {
  var date: Date = new Date();
  var h, m, s: String;
  h = date.getHours() > 9 ? date.getHours() : "0" + date.getHours();
  m = date.getMinutes() > 9 ? date.getMinutes() : "0" + date.getMinutes();
  s = date.getSeconds() > 9 ? date.getSeconds() : "0" + date.getSeconds();
	
  return getYearStr() + " " + h + ":" + m + ":" + s;
}

_global.formatTime = function(seconds: Number): String {
  var h, m, s: String;
  h = int(seconds / 3600).toString();
	h = (h.length == 1) ? "0" + h : h;
  m = int(seconds % 3600 / 60).toString();
	m = (m.length == 1) ? "0" + m : m;
  s = int(seconds % 3600 % 60).toString();
	s = (s.length == 1) ? "0" + s : s;

	return (h + ":" + m + ":" + s);
}

//显示、隐藏提示信息
_global.showHint = function(mc: MovieClip, strHint: String) {
  var nWidth: Number = getStrWidth(strHint);
  with (mc_hint) {
    _visible = true;
    mc_tip.hint = strHint;
    _width = nWidth + nWidth * 0.25;
		_x = mc._parent._x + mc._x + mc._xmouse - nWidth + 12;
    _y = 45;
    gotoAndPlay(1);
  }
}

_global.hideHint = function() {
  mc_hint._visible = false;
}

//键盘事件
function addKeyListener() {
	if (lsk != undefined) {
		return;
	}
	
  lsk = new Object();
  lsk.onKeyDown = function () {
		switch (Key.getCode()) {
		case Key.ENTER:
			if (msgBox._visible) {
				msgBox.closeBox();
			}
			else if (aboutBox._visible) {
				aboutBox.close();
			}
			else {
  			if (quizObj.items[g_curPage]._type == 8 || _currentframe != QUES_FRAME) {
				  return;
  			}
        if ((g_curPage == g_totalPage - 1 || quizObj.sngMode) && mc_submit._visible) {
          doSubmit();
        }
        else {
          nextPage();
        }
			}			
			break;
		case Key.ESCAPE:
			if (msgBox._visible) {
			  msgBox.close();
			}
			if (aboutBox._visible) {
				aboutBox.close();
			}
			break;
		//上一题
		case Key.PGUP:
		case Key.LEFT:
		case Key.UP:
		  if (_currentframe != QUES_FRAME || msgBox._visible || aboutBox._visible) {
        return;
      }
      if (Key.getCode() == Key.LEFT && ((quizObj.items[g_curPage]._type == 4 || quizObj.items[g_curPage]._type == 8) && !quizObj.hasDone)) {
        return;
			}
      if (Key.getCode() == Key.UP && ((quizObj.items[g_curPage]._type == 1 || quizObj.items[g_curPage]._type == 2 || quizObj.items[g_curPage]._type == 8) && !quizObj.hasDone)) {
        return;
      }
      prevPage();
		  break;
		//下一题
		case Key.PGDN:
		case Key.RIGHT:
		case Key.DOWN:
		  if (_currentframe != QUES_FRAME || msgBox._visible || aboutBox._visible) {
        return;
      }
      if (Key.getCode() == Key.RIGHT && ((quizObj.items[g_curPage]._type == 4 || quizObj.items[g_curPage]._type == 8) && !quizObj.hasDone)) {
        return;
			}
      if (Key.getCode() == Key.DOWN && ((quizObj.items[g_curPage]._type == 1 || quizObj.items[g_curPage]._type == 2 || quizObj.items[g_curPage]._type == 8) && !quizObj.hasDone)) {
        return;
      }

			nextPage();
			break;
		default:
		  //do nothing
		}
	}
	
  Key.addListener(lsk);
} 