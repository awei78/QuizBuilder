//关于及显示图片对话框管理类...
class AboutBox {
	private var about_mc: MovieClip;
	private var mask_mc: MovieClip;
	var _textObj: Object;
	var _auObj: Object;
	
	public function AboutBox(about_mc: MovieClip) {
		this.about_mc = about_mc;
		this.mask_mc = about_mc._parent.mc_mask;
		this._textObj = _global.textObj;
		this._auObj = _global.auObj;
		
		initData();
	}
	
	//初始化数据
	private function initData(): Void {
		var self: AboutBox = this;
	  with (about_mc) {
		  var _textObj = self._textObj;
			var _auObj = self._auObj;
			ldr_img._visible = false;
			ldr_img.scaleContent = false;
		  txt_caption.text = _global.quizObj.topic;
			txt_author_cap.text = _textObj.author;
		  txt_author.text = _auObj.name;
			txt_mail_cap.text = _textObj.email;
		  mc_mail.txt_mail.text = _auObj.mail;
			txt_url_cap.text = _textObj.url;
			mc_url.txt_url.text = _auObj.url;
			txt_des_cap.text = _textObj.des;
		  txt_des.text = _auObj.des;
		  sb_des.setScrollTarget(txt_des);
		  sb_des.setSize(sb_des._width, txt_des._height);
			mc_top.useHandCursor = false;
		
		  //相关事件...
		  btn_close.onRelease = function() {
			  self.close();
		  }
		  mc_top.onRelease = function() {
			  this._parent.stopDrag();
		  }
		  mc_top.onReleaseOutside = mc_top.onRelease;
		  //邮件
		  mc_mail.onRelease = function() {
			  getURL("mailto:" + this.txt_mail.text + "?subject=测试结果-" +_global.quizObj.topic);
		  }
		  mc_mail.onRollOver = function() {
			  this.txt_mail.textColor = "0x0000FF";
		  }
		  mc_mail.onRollOut = function() {
			  this.txt_mail.textColor = "0x000000";
		  }
			//主页
		  mc_url.onRelease = function() {
			  getURL(this.txt_url.text, "_blank");
		  }
		  mc_url.onRollOver = function() {
			  this.txt_url.textColor = "0x0000FF";
		  }
		  mc_url.onRollOut = function() {
			  this.txt_url.textColor = "0x000000";
		  }
	    //拖动
  		mc_top.onPress = function() {
			  this._parent.startDrag(false, 0, 0, Stage.width - this._parent.back._width, Stage.height - this._parent.back._height);
  		}
	  }
	}
	
	//显示对话框
	public function show(): Void {
		with (about_mc) {
			//重置宽度
			mc_top._width = 324;
			back._width = 325;
			back._height = 190;
			//关闭按钮位置
			btn_close._x = 307.5;			
			//图片隐藏
			ldr_img.contentPath = "";
			ldr_img._visible = false;
			//居中
			_x = (Stage.width - _width) / 2;
		  _y = (Stage.height - _height) / 2;
			//显示
			txt_author_cap._visible = true;
			txt_author._visible = true;
			txt_mail_cap._visible = true;
			mc_mail._visible = true;
			txt_url_cap._visible = true;
			mc_url._visible = true;
			txt_des_cap._visible = true;
			txt_des._visible = true;
			sb_des._visible = txt_des.textHeight >= 96.5;
			mc_line._visible = true;
			//显示
		  _visible = true;
		  Selection.setFocus(txt_author);
			Selection.setSelection(0, 0);
		}
		
		//遮照显示
    mask_mc._visible = true;
    mask_mc.gotoAndPlay(2);
	}
	
	//显示图片
	public function showImage(img_id: String) {
		with (about_mc) {
		  //隐藏作者信息
			txt_author_cap._visible = false;
			txt_author._visible = false;
			txt_mail_cap._visible = false;
			mc_mail._visible = false;
			txt_url_cap._visible = false;
			mc_url._visible = false;
			txt_des_cap._visible = false;
			txt_des._visible = false;
			sb_des._visible = false;
			mc_line._visible = false;
			//显示图片信息
			ldr_img.contentPath = img_id;
			ldr_img._visible = true;
			ldr_img.useHandCursor = false;
			ldr_img.onRelease = function() {
				//do nothing
			}
			//大小设置...对于插入的超过640x480的Flash处理
			if (ldr_img._width > 640) {
				ldr_img._width = 640;
			}
			if (ldr_img._height > 480) {
				ldr_img._height = 480;
			}
			//位置赋值
			var img_w: Number = ldr_img._width;
			var img_h: Number = ldr_img._height;
			//关闭按钮位置
			btn_close._x = img_w - 15.5;
			//设置大小
			mc_top._width = img_w;
			back._width = img_w + 1.5;
			back._height = mc_top._height + img_h + 1;
			//居中
			_x = (Stage.width - back._width) / 2;
		  _y = (Stage.height - back._height) / 2;
			//显示
		  _visible = true;
			Selection.setFocus(txt_author);
		}
		
		//遮照显示
    mask_mc._visible = true;
    mask_mc.gotoAndStop(1);
  }
	
	//关闭对话框
	public function close(): Void {
		about_mc._visible = false;
		mask_mc._visible = false;
	}
	
	//是否可见
	public function get _visible(): Boolean {
		return about_mc._visible;
	}
	
	//闪烁标题栏
	public function flash(): Void {
		_global.sound.play("box");
		about_mc.mc_top.gotoAndPlay(1);
	}
}