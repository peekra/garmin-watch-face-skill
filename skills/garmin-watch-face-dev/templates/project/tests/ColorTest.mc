import Toybox.Lang;
import Toybox.Test;

// Readability of the palettes of this build (AMOLED or MIP, see monkey.jungle): every text colour against
// its background, on the light and on the dark face, for every selectable accent colour. Run it on one
// AMOLED and one MIP device. A new colour or background belongs into this loop.
(:test)
module ColorTest {

    (:test)
    function testContrast(logger as Test.Logger) as Boolean {
        var ok = true;
        for (var dark = 0; dark < 2; dark++) {
            for (var accent = 0; accent < UiColors.ACCENT_COUNT; accent++) {
                UiColors.apply(dark == 1, accent);
                var where = (dark == 1 ? "dark" : "light") + ", accent " + accent;
                ok = TestCheck.contrast(logger, "ink on " + where, UiColors.ink, UiColors.background,
                    ColorMath.MIN_TEXT) && ok;
                ok = TestCheck.contrast(logger, "accent on " + where, UiColors.accent, UiColors.background,
                    ColorMath.MIN_TEXT) && ok;
            }
        }
        return ok;
    }

    //! MIP builds only: a colour outside the 64 is replaced by the system and can lose its contrast.
    (:test)
    function testMipColors(logger as Test.Logger) as Boolean {
        if (!UiColors.IS_MIP) {
            return true;
        }
        var ok = true;
        for (var dark = 0; dark < 2; dark++) {
            for (var accent = 0; accent < UiColors.ACCENT_COUNT; accent++) {
                UiColors.apply(dark == 1, accent);
                var where = (dark == 1 ? "dark" : "light") + ", accent " + accent;
                ok = TestCheck.mipColor(logger, "background " + where, UiColors.background) && ok;
                ok = TestCheck.mipColor(logger, "ink " + where, UiColors.ink) && ok;
                ok = TestCheck.mipColor(logger, "accent " + where, UiColors.accent) && ok;
            }
        }
        return ok;
    }

    (:test)
    function testColorMath(logger as Test.Logger) as Boolean {
        var ok = TestCheck.bool(logger, "black on white is 21", ColorMath.contrast(0x000000, 0xFFFFFF) > 20.9, true);
        ok = TestCheck.bool(logger, "same colour is 1", ColorMath.contrast(0x55AAFF, 0x55AAFF) < 1.01, true) && ok;
        ok = TestCheck.bool(logger, "0xFFAA00 is MIP", ColorMath.isMipColor(0xFFAA00), true) && ok;
        ok = TestCheck.bool(logger, "0xE9E5DA is not MIP", ColorMath.isMipColor(0xE9E5DA), false) && ok;
        return ok;
    }

    (:test)
    function testAccentOutOfRange(logger as Test.Logger) as Boolean {
        UiColors.apply(true, 99);
        var first = UiColors.accent;
        UiColors.apply(true, UiColors.ACCENT_RED);
        return TestCheck.bool(logger, "invalid accent gives the first", first == UiColors.accent, true);
    }
}
