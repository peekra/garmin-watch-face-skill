import Toybox.Lang;
import Toybox.Test;

// Soft assertions: every check logs a readable line on failure and returns false, so one test can
// report all mismatches instead of stopping at the first.
// Usage: ok = TestCheck.str(logger, "label", actual, "expected") && ok;
(:test)
module TestCheck {

    function str(logger as Test.Logger, label as String, actual as String, expected as String) as Boolean {
        if (actual.equals(expected)) {
            return true;
        }
        logger.error(label + ": expected '" + expected + "', got '" + actual + "'");
        return false;
    }

    function bool(logger as Test.Logger, label as String, actual as Boolean, expected as Boolean) as Boolean {
        if (actual == expected) {
            return true;
        }
        logger.error(label + ": expected " + expected + ", got " + actual);
        return false;
    }

    //! Fails if the contrast of two colours (0xRRGGBB) is below minimum. The line names both colours.
    function contrast(logger as Test.Logger, label as String, color as Number, background as Number,
            minimum as Float) as Boolean {
        var ratio = ColorMath.contrast(color, background);
        if (ratio >= minimum) {
            return true;
        }
        logger.error(label + ": contrast " + ratio.format("%.2f") + " of 0x" + color.format("%06X")
            + " on 0x" + background.format("%06X") + ", needed " + minimum.format("%.1f"));
        return false;
    }

    //! Fails if the colour is not one of the 64 MIP colours.
    function mipColor(logger as Test.Logger, label as String, color as Number) as Boolean {
        if (ColorMath.isMipColor(color)) {
            return true;
        }
        logger.error(label + ": 0x" + color.format("%06X") + " is not a MIP colour (channels 00, 55, AA, FF)");
        return false;
    }
}
