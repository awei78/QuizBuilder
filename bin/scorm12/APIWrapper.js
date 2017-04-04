//SCORM1.2所用到的API文件，由Flash8生成修改而成

var g_bShowApiErrors      = false
var g_strAPINotFound      = "Management system interface not found.";
var g_strAPITooDeep       = "Cannot find API - too deeply nested.";
var g_strAPIInitFailed    = "Found API but LMSInitialize failed.";
var g_strAPISetError      = "Trying to set value but API not available.";
var g_strFSAPIError       = 'LMS API adapter returned error code: "%1"\nWhen FScommand called API.%2\nwith "%3"';
var g_strDisableErrorMsgs = "Select cancel to disable future warnings.";
var g_nfindAPITries       = 0;
var g_objAPI              = null;
var g_bInitDone           = false;
var g_bFinishDone         = false;
var g_bSCOBrowse          = false;
var g_dtmInitialized      = new Date();

function AlertUserOfAPIError(strText) {
	if (g_bShowApiErrors) {
		var s = strText + "\n\n" + g_strDisableErrorMsgs;
		if (!confirm(s)) {
			g_bShowApiErrors = false;
		}
	}
}

function expandString(s) {
	var re = new RegExp("%", "g");
	for (i = arguments.length - 1; i > 0; i--) {
		s2 = "%" + i;
		if (s.indexOf(s2) > -1) {
			re.compile(s2, "g");
			s = s.replace(re, arguments[i]);
		}
	}
	return s;
}

function findAPI(win) {
  if (typeof(win) != 'undefined' ? typeof(win.API) != 'undefined' : false) {
    if (win.API != null ) {
    	return win.API;
    }
  }
  if (win.frames.length > 0) {
  	for (var i = 0 ; i < win.frames.length ; i++) {
	    if (typeof(win.frames[i]) != 'undefined' ? typeof(win.frames[i].API) != 'undefined' : false) {
		    if (win.frames[i].API != null) {
		    	return win.frames[i].API;
		    }
	    }
	  }
	}
  
  return null;
}

function getAPI() {
  var myAPI = null;
  var tries = 0, triesMax = 500;
  while (tries < triesMax && myAPI == null) {
    myAPI = findAPI(window);
    if (myAPI == null && typeof(window.parent) != 'undefined') {
    	myAPI = findAPI(window.parent)
    }
    if (myAPI == null && typeof(window.top) != 'undefined') {
    	myAPI = findAPI(window.top);
    }
    if (myAPI == null && typeof(window.opener) != 'undefined' && window.opener != null && !window.opener.closed) {
    	myAPI = findAPI(window.opener);
    }
    
    tries++;
  }
  
  if (myAPI != null) {
  	g_objAPI = myAPI;
  }
}

function hasAPI() {
	return ((typeof (g_objAPI) != "undefined") && (g_objAPI != null));
}

function SCOInitialize() {
	var err = true;
	if (!g_bInitDone) {
    getAPI();	
    	
		if (!hasAPI()) {
			AlertUserOfAPIError(g_strAPINotFound);
			err = false;
		}
		else {
			err = g_objAPI.LMSInitialize("");
			if (err == "true") {
				g_bSCOBrowse = (g_objAPI.LMSGetValue("cmi.core.lesson_mode") == "browse");
				if (!g_bSCOBrowse) {
					if (g_objAPI.LMSGetValue("cmi.core.lesson_status") == "not attempted") {
						err = g_objAPI.LMSSetValue("cmi.core.lesson_status", "incomplete");
					}
				}
			}
			else {
				AlertUserOfAPIError(g_strAPIInitFailed);
			}
		}
		if (typeof(SCOInitData) != "undefined") {
			SCOInitData();
		}
		
		g_dtmInitialized = new Date();
	}
	
	g_bInitDone = true;
	return (err + "");
}

function SCOFinish() {
	if (hasAPI() && (g_bFinishDone == false)) {
		SCOReportSessionTime();
		if (typeof (SCOSaveData) != "undefined") {
			SCOSaveData();
		}
		g_bFinishDone = (g_objAPI.LMSFinish("") == "true");
	}
	
	return (g_bFinishDone + "");
}

function SCOGetValue(nam) {
	return (hasAPI() ? g_objAPI.LMSGetValue(nam.toString()) : "");
}

function SCOCommit() {
	return (hasAPI() ? g_objAPI.LMSCommit("") : "false");
}

function SCOGetLastError() {
	return (hasAPI() ? g_objAPI.LMSGetLastError() : "-1");
}

function SCOGetErrorString(n) {
	return (hasAPI() ? g_objAPI.LMSGetErrorString(n) : "No API");
}

function SCOGetDiagnostic(p) {
	return (hasAPI() ? g_objAPI.LMSGetDiagnostic(p) : "No API");
}

function SCOSetValue(nam, val) {
	if (!hasAPI()) {
		AlertUserOfAPIError(g_strAPISetError + "\n" + nam + "\n" + val);
		return "false";
	}
	
	return	g_objAPI.LMSSetValue(nam, val.toString() + "");
}

function MillisecondsToCMIDuration(n) {
	var hms = "";
	var dtm = new Date();
	dtm.setTime(n);
	var h = "000" + Math.floor(n / 3600000);
	var m = "0" + dtm.getMinutes();
	var s = "0" + dtm.getSeconds();
	var cs = "0" + Math.round(dtm.getMilliseconds() / 10);
	hms = h.substr(h.length - 4) + ":" + m.substr(m.length - 2) + ":";
	hms += s.substr(s.length - 2) + "." + cs.substr(cs.length - 2);
	return hms;
}

function SCOReportSessionTime() {
	var dtm = new Date();
	var n = dtm.getTime() - g_dtmInitialized.getTime();
	return SCOSetValue("cmi.core.session_time", MillisecondsToCMIDuration(n));
}

var g_bIsIE = navigator.appName.indexOf("Microsoft") != -1;
function sf_DoFSCommand(command, args) {
	var sfObj = g_bIsIE ? document.all.sf : document.sf;
	var myArgs = new String(args);
	var cmd = new String(command);
	var v = "";
	var err = "true";
	var arg1, arg2, n, s, i;
	var sep = myArgs.indexOf(",");
	if (sep > -1) {
		arg1 = myArgs.substr(0, sep);
		arg2 = myArgs.substr(sep + 1);
	}
	else {
		arg1 = myArgs;
	}
	
	if (cmd.substring(0, 3) == "LMS") {
		if (cmd == "LMSInitialize") {
			err = SCOInitialize();
		}
		else if (cmd == "LMSSetValue") {
			err = SCOSetValue(arg1, arg2);
		}
		else if (cmd == "LMSFinish") {
			err = SCOFinish();
		}
		else if (cmd == "LMSCommit") {
			err = SCOCommit();
		}
		else if (arg2 && (arg2.length > 0)) {
			if (cmd == "LMSGetValue") {
				sfObj.SetVariable(arg2, SCOGetValue(arg1));
			}
			else if (cmd == "LMSGetLastError") {
				sfObj.SetVariable(arg2, SCOGetLastError(arg1));
			}
			else if (cmd == "LMSGetErrorString") {
				sfObj.SetVariable(arg2, SCOGetLastError(arg1));
			}
			else if (cmd == "LMSGetDiagnostic") {
				sfObj.SetVariable(arg2, SCOGetDiagnostic(arg1));
			}
			else {
				v = eval('g_objAPI.' + cmd + '(\"' + arg1 + '\")');
				sfObj.SetVariable(arg2, v);
			}
		}
		else if (cmd.substring(0, 3) == "LMSGet") {
			err = "-2: No Flash variable specified";
		}
	}
	if ((g_bShowApiErrors) && (err != "true")) {
		AlertUserOfAPIError(expandString(g_strFSAPIError, err, cmd, args));
	}
	
	return err;
}