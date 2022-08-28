import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;

class WatchFaceDraemonView extends WatchUi.WatchFace {
	var center;
	var bmBluetooth;
	var bmNotify;
	var fnSmall;
	var fnMedium;
	var fnLarge;
	var fnNormal;
	var fnTiny;
	var myBackgroundImage;
	
    function initialize() {
        WatchFace.initialize();
        
        bmBluetooth = WatchUi.loadResource(Rez.Drawables.BluetoothIcon);
        bmNotify = WatchUi.loadResource(Rez.Drawables.NotificationIcon);
        
		fnSmall = Graphics.FONT_NUMBER_MILD;        
		fnMedium = Graphics.FONT_NUMBER_MEDIUM;
		fnLarge = Graphics.FONT_NUMBER_HOT;
        fnNormal = Graphics.FONT_MEDIUM;
		fnTiny = Graphics.FONT_TINY;
        
        myBackgroundImage = WatchUi.loadResource(Rez.Drawables.myBitmap);
    }
    
    // 時分を描画する    
    function drawHM(dc, time) {
    	var timeString = "         " + Lang.format("$1$:$2$", [time.hour, time.min.format("%02d")]);
    	var wh = dc.getTextDimensions(timeString, fnMedium);
    	dc.drawText(center[0], center[1] - Graphics.getFontAscent(fnMedium),
    		fnMedium, timeString, Graphics.TEXT_JUSTIFY_CENTER);
    }

    // 曜日を描画する
    function drawDayWeek(dc, timeM, timeS) {
    	var dayString = "               " + Lang.format("$1$/$2$ $3$", [timeS.month, timeS.day, timeM.day_of_week]);
    	dc.drawText(center[0], center[1]
    		 - Graphics.getFontAscent(fnSmall)
    		 - Graphics.getFontAscent(fnNormal),
    		fnNormal, dayString,
    		Graphics.TEXT_JUSTIFY_CENTER);
    }
        // バッテリーパーセンテージを表示
    function drawBattery(dc) {
    	dc.drawText(center[0], dc.getHeight() - dc.getFontHeight(fnTiny),
    		fnTiny, "SoC:" + System.getSystemStats().battery.format("%3.0f") + "%",
    		Graphics.TEXT_JUSTIFY_CENTER);
    }
    // 心拍数を求める
    private function retrieveHeartrateText() {
		var currentHeartrate = ActivityMonitor.getHeartRateHistory(1, true).next().heartRate;
		if (currentHeartrate != ActivityMonitor.INVALID_HR_SAMPLE) {
			return currentHeartrate.format("%d");
		}
		else {
			return "---";
		}
    }    
    
    // 歩数・心拍数などの情報を表示
    function drawInformation(dc) {
        var info = ActivityMonitor.getInfo();

//		var valueString = info.stepGoal.format("%5d") + "/" + info.steps.format("%5d");
		var valueString = "                  " + "Steps:" + info.steps.format("%5d");
		if(ActivityMonitor has :INVALID_HR_SAMPLE) {
			valueString += "\n" + "            " + "HR:"+ retrieveHeartrateText();
		}
    	dc.drawText(center[0], center[1],
    		fnNormal, valueString,
    		Graphics.TEXT_JUSTIFY_CENTER);
    }
    
    // Bluetoothとイベント通知アイコンの表示
    function drawNotify(dc) {
    	var info = System.getDeviceSettings();
    	var y = center[1] + dc.getFontHeight(fnNormal) *2.5;
//    	if (info.notificationCount > 0) {
//    		// メールアイコンの表示
//    		dc.drawBitmap(center[0] * 1.5, y - bmNotify.getHeight() / 2, bmNotify);
//    	}
    	if (info.phoneConnected) {
    		// BLEアイコンの表示
    		var wh = [bmBluetooth.getWidth(), bmBluetooth.getHeight()];
    		var tl = [center[0], y - wh[1] / 2];
    		dc.setColor(Graphics.COLOR_DK_BLUE, Graphics.COLOR_BLACK);
    		// dc.fillEllipse(tl[0] + 12, y, wh[0] / 2 - 1, wh[1] / 2 - 1);
    		dc.drawBitmap(tl[0], tl[1], bmBluetooth);
    	}
    }
    function drawBackgroundImage(dc) {
    	if (myBackgroundImage){
    		dc.drawBitmap(0, 0, myBackgroundImage);
    	
    	}
    }
    

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        center = [dc.getWidth()/2, dc.getHeight()/2];
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
    	dc.clear();
    	
    	var now = Time.now();
        var nowM = Time.Gregorian.info(now, Time.FORMAT_MEDIUM);
        var nowS = Time.Gregorian.info(now, Time.FORMAT_SHORT);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        drawBackgroundImage(dc);
        drawHM(dc, nowS);
        drawDayWeek(dc, nowM, nowS);        
        drawInformation(dc);
        drawNotify(dc);
        
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        drawBattery(dc);
    }


    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

}
