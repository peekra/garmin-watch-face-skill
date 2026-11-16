import Toybox.Lang;

//! Colour palettes (0xRRGGBB). Every colour exists once per background (light, dark) and once per display
//! type, selected at compile time by the annotations in monkey.jungle. MIP values use only the 64 MIP
//! colours (each channel 00, 55, AA, FF). apply() copies one set into the active variables that the
//! renderer uses. tests/ColorTest.mc checks every pair of text colour and background for contrast, so a
//! new colour that is hard to read fails the tests instead of reaching the watch.
module UiColors {
    (:amoled) const IS_MIP = false;
    (:mip) const IS_MIP = true;

    //! Selectable accent colours, index = stored value of the "Accent" property. Never renumber.
    const ACCENT_RED = 0;
    const ACCENT_BLUE = 1;
    const ACCENT_GREEN = 2;
    const ACCENT_COUNT = 3;

    (:amoled) const LIGHT_BACKGROUND = 0xE9E5DA;
    (:amoled) const LIGHT_INK = 0x161514;
    //                                   red       blue      green
    (:amoled) const LIGHT_ACCENTS =    [0xB01E14, 0x1D4FA8, 0x1F6B2E] as Array<Number>;
    (:amoled) const DARK_BACKGROUND = 0x000000;
    (:amoled) const DARK_INK = 0xEDEDED;
    (:amoled) const DARK_ACCENTS =     [0xFF5A47, 0x5AA2FF, 0x4FD06A] as Array<Number>;

    (:mip) const LIGHT_BACKGROUND = 0xFFFFFF;
    (:mip) const LIGHT_INK = 0x000000;
    (:mip) const LIGHT_ACCENTS =       [0xAA0000, 0x0000AA, 0x005500] as Array<Number>;
    (:mip) const DARK_BACKGROUND = 0x000000;
    (:mip) const DARK_INK = 0xFFFFFF;
    (:mip) const DARK_ACCENTS =        [0xFF5555, 0x55AAFF, 0x55FF55] as Array<Number>;

    //! Always-on view (AMOLED only): dim grey keeps the lit pixels low. Not part of the contrast test.
    const ALWAYS_ON_INK = 0x555555;

    var background as Number = LIGHT_BACKGROUND;
    var ink as Number = LIGHT_INK;
    var accent as Number = LIGHT_ACCENTS[ACCENT_RED];

    //! accentIndex outside 0..ACCENT_COUNT-1 gives the first colour.
    function apply(dark as Boolean, accentIndex as Number) as Void {
        var index = (accentIndex >= 0 && accentIndex < ACCENT_COUNT) ? accentIndex : ACCENT_RED;
        background = dark ? DARK_BACKGROUND : LIGHT_BACKGROUND;
        ink = dark ? DARK_INK : LIGHT_INK;
        accent = dark ? DARK_ACCENTS[index] : LIGHT_ACCENTS[index];
    }
}
