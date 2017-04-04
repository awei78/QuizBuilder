//定时器管理类...

class Time {
  private var time_mc: MovieClip;
	private var _length: Number;
	private var _elapse: Number;
	private var _timeId: Number;
	private var _textObj: Object;
	private var formatTime: Function;
		
	//构造函数
  public function Time(time_mc: MovieClip, time_len: Number) {
    this.time_mc = time_mc;
		this._length = (isNaN(time_len) || time_len < 6) ? 6 : time_len;
		this._elapse = 0;
		
		_textObj = _global.textObj;
		formatTime = _global.formatTime;
		time_mc.txt_time_cap.text = _textObj.remaining;
		time_mc.txt_time.text = formatTime(this._length);
	}
	
	//执行定时器操作
	private function showTime(): Void {
    _elapse++;
		
    if (_elapse == _length) {
      clearInterval(_timeId);
      _global.dealTimeout();
    }
		
		//显示时间
    time_mc.txt_time.text = formatTime(_length - _elapse);
		var _frame: Number = Math.round(time_mc._totalframes * _elapse / _length);
		time_mc.gotoAndStop(_frame);
		
		updateAfterEvent();
  }

	//启动定时器
  public function start(): Void {		
		if (_timeId != null) {
      clearInterval(_timeId);
		}
		
    _timeId = setInterval(this, "showTime", 1000);
  }
	
	//停止定时器
	public function stop(): Void {
		clearInterval(_timeId);
	}
	
	//获取时间长度
	public function get length(): Number {
	  return this._length;
	}
	
	//获取已用时间
	public function get elapse(): Number {
		return this._elapse;
	}
}