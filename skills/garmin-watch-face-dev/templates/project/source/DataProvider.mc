import Toybox.Activity;
import Toybox.ActivityMonitor;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;

//! Fills WatchData from the system APIs. Every read is guarded: a missing value becomes null,
//! nothing here throws.
class DataProvider {

    function initialize() {
    }

    function update(data as WatchData) as Void {
        var clock = System.getClockTime();
        data.hour = clock.hour;
        data.minute = clock.min;
        data.second = clock.sec;

        var info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        data.day = info.day;
        data.year = info.year;
        // FORMAT_SHORT delivers Numbers; guard anyway because the API also allows Strings.
        var month = info.month;
        if (month instanceof Number) {
            data.month = month;
        }

        data.heartRate = readHeartRate();
        data.steps = readSteps();
        data.phoneConnected = System.getDeviceSettings().phoneConnected;
    }

    //! Current heart rate, else the newest valid sample of the history, else null.
    private function readHeartRate() as Number or Null {
        var activityInfo = Activity.getActivityInfo();
        if (activityInfo != null) {
            var current = activityInfo.currentHeartRate;
            if (current != null) {
                return current;
            }
        }
        if (ActivityMonitor has :getHeartRateHistory) {
            var sample = ActivityMonitor.getHeartRateHistory(1, true).next();
            if (sample != null) {
                var value = sample.heartRate;
                if (value != null && value != ActivityMonitor.INVALID_HR_SAMPLE) {
                    return value;
                }
            }
        }
        return null;
    }

    private function readSteps() as Number or Null {
        var info = ActivityMonitor.getInfo();
        if (info has :steps) {
            return info.steps;
        }
        return null;
    }
}
