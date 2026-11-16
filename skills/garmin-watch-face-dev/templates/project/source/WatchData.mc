import Toybox.Lang;

//! Plain data object between logic and UI. One instance, updated in place by DataProvider.
//! Metrics are nullable: null means "not available" and the UI shows "--".
class WatchData {
    // Time: 0..23
    public var hour as Number = 0;
    public var minute as Number = 0;
    public var second as Number = 0;
    // Date
    public var day as Number = 1;      // 1..31
    public var month as Number = 1;    // 1..12
    public var year as Number = 2026;
    // Metrics
    public var heartRate as Number or Null = null;   // bpm
    public var steps as Number or Null = null;
    // Status
    public var phoneConnected as Boolean = false;

    function initialize() {
    }
}
