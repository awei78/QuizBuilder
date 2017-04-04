//扩展声音类...

class SoundEx extends Sound {
	private var _enabled: Boolean = true;
	
	public function play(sndId: String, secondOffset: Number) {
		if (!_enabled || sndId == "" || sndId == undefined) {
			return;
		}
		if (secondOffset == undefined) {
			secondOffset = 0
		}
  	//super.stop();
		super.attachSound(sndId);
  	super.start(secondOffset);
	}
	
	public function set enabled(value: Boolean) {
		this._enabled = value;
	}
}