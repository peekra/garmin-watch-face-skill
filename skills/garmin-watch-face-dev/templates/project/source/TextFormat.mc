import Toybox.Lang;

//! Pure helpers without API calls. This is where most unit tests go.
module TextFormat {

    const MISSING = "--";

    //! 7 -> "07"
    function pad2(value as Number) as String {
        return value.format("%02d");
    }

    //! Number as text, "--" for null.
    function numberOrDash(value as Number or Null) as String {
        if (value == null) {
            return MISSING;
        }
        return value.format("%d");
    }

    //! "DD-MM-YYYY"
    function date(day as Number, month as Number, year as Number) as String {
        return pad2(day) + "-" + pad2(month) + "-" + year.format("%04d");
    }

    //! A stored property value as Boolean; anything else gives the default.
    function booleanOrDefault(value as Object or Null, defaultValue as Boolean) as Boolean {
        if (value instanceof Boolean) {
            return value;
        }
        return defaultValue;
    }

    //! A stored property value as Number inside 0..count-1; anything else gives the default.
    function indexOrDefault(value as Object or Null, count as Number, defaultValue as Number) as Number {
        if (value instanceof Number && value >= 0 && value < count) {
            return value;
        }
        return defaultValue;
    }
}
