//弹出对话框管理类...

class MsgBox {
	private var box_mc: MovieClip;
	private var mask_mc: MovieClip;
	private var _type: Number;
	private var replace: Function;
	public var closeBox: Function;
	//常量
	public static var MB_OK    = 0;
	public static var MB_YESNO = 1;
	public static var MB_NEXT  = 2
	public static var MB_TRY   = 3;	
	public static var MB_VIEW  = 4;	
	
	public function MsgBox(box_mc: MovieClip) {
		this.box_mc = box_mc;
		this.mask_mc = box_mc._parent.mc_mask;
		this._type = 0;
		this.replace = _global.replace;
		
		initData();
	}
	
	//初始化数据
	private function initData(): Void {
		var self: MsgBox = this;
		with (box_mc) {
			txt_caption.text = _global.quizObj.topic;
      _visible = false;
			sb_msg._visible = false;
      mc_top.useHandCursor = false;
		  //滚动绑定
		  sb_msg.setScrollTarget(txt_msg);
			
			//关闭操作
			btn_close.onRelease = function() {
				self.close();
			}
			mc_cancel.btn.onRelease = btn_close.onRelease;
			
			//拖动...
			mc_top.onPress = function() {
        this._parent.startDrag(false, 0, 0, Stage.width - back._width, Stage.height - back._height);
      }			
      mc_top.onRelease = function() {
        this._parent.stopDrag();
      }
      mc_top.onReleaseOutside = mc_top.onRelease;
		}
	}
	
	//显示对话框
	public function show(msg: String, _type: Number, fun: Function, icon_id: String): Void {
		//box_mc.txt_msg.text = "setInterval全面的介绍setInterval动作的作用是在播放动画的时，每隔一定时间就调用函数，方法或对象。如每秒10帧，相当于100毫秒），则按照尽可能接近interval的时间间隔调用函数。而且必须使用updateAfterEvent动作来确保以足够的频率刷新屏幕。如果interval大于动画帧速";
		msg = replace(msg, "\r", "");

		var self: MsgBox = this;
		with (box_mc) {
      if (icon_id == undefined) {
				if (_type != MsgBox.MB_YESNO) {
  				icon_id = "iflag";
				}
				else {
					icon_id = "qflag";
				}
      }
			//显示图标
      mc_icon.attachMovie(icon_id, "", 0);
		  //显示
      _visible = true;
      mc_ok._visible = true;
      mc_cancel._visible = false;
      mc_ok._x = (_width - mc_ok._width) / 2;

			//替换按钮caption
      switch (_type) {
        case MsgBox.MB_OK:
          mc_ok.caption = textObj.okLabel;
          break;
        case MsgBox.MB_YESNO:
          mc_ok.caption = textObj.yesLabel;
          mc_cancel.caption = textObj.noLabel;
          mc_cancel._visible = true;
          mc_ok._x = (_width - mc_ok._width * 2) / 3;
          mc_cancel._x = box_mc._width / 2 + mc_ok._x / 2;
          break;
        case MsgBox.MB_NEXT:
          mc_ok.caption = textObj.nextItem;
          break;
        case MsgBox.MB_TRY:
          mc_ok.caption = textObj.tryAgain;
          break;
        case MsgBox.MB_VIEW:
          mc_ok.caption = textObj.viewResult;
          break;
        default:
           mc_ok.caption = textObj.okLabel;
      }
  		//消息...
			txt_msg.html = true;
      txt_msg.htmlText = replace(msg, "%s", mc_ok.caption);
		}
		
		//关闭操作，执行回调函数
    var closeBox: Function = function() {
      fun();
      self.close();
    }
		//响应外部回车键调用
		self.closeBox = closeBox;
    box_mc.mc_ok.btn.onRelease = function() {
      closeBox();
    }
		//重设位置
		resizeBox();
	}
	
	//关闭对话框
	public function close(): Void {
		box_mc._visible = false;
		mask_mc._visible = false;
	}
	
	//重设对话框尺寸
	private function resizeBox(): Void {
		with (box_mc) {
		  //拉高对话框，不显示滚动条
      if (txt_msg.textHeight > 95 && txt_msg.textHeight < 325) {
        var h: Number = txt_msg.textHeight - 95 + 12;
        txt_msg._height = txt_msg.textHeight + 12;
        back._height = 152 + h;
        sb_msg._visible = false;
        mc_ok._y = txt_msg._y + txt_msg._height + 1.5;
        mc_cancel._y = mc_ok._y;
      }
      else if (txt_msg.textHeight > 325) {
        back._height = 397;
        txt_msg._height = 325;
        sb_msg._visible = true;
        sb_msg._y = txt_msg._y;
        sb_msg._x = txt_msg._x + txt_msg._width;
        sb_msg.setSize(sb_msg._width, txt_msg._height);
        mc_ok._y = txt_msg._y + txt_msg._height + 12;
        mc_cancel._y = mc_ok._y;
      }
      else {
        txt_msg._height = 95;
        sb_msg._visible = false;
        mc_ok._y = 130;
        mc_cancel._y = mc_ok._y;
        back._height = 160;
      }
			Selection.setFocus(txt_msg);
			Selection.setSelection(0, 0);
			
		  //调整位置 
		  _x = (Stage.width - _width) / 2;
		  _y = (Stage.height - _height) / 2;
    }
		
		//遮照显示
    mask_mc._visible = true;
    mask_mc.gotoAndPlay(2);
  }
	
	//判断是否可见
	public function get _visible(): Boolean{
		return box_mc._visible;
	}
	
	//闪烁标题栏
	public function flash(): Void {
		_global.sound.play("box");
		box_mc.mc_top.gotoAndPlay(1);
	}
}