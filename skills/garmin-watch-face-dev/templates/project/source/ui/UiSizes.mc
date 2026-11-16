import Toybox.Lang;

//! All positions and sizes as fractions of the display diameter. No pixel values in the drawers.
module UiSizes {
    const DATE_Y = 0.22;
    const TIME_Y = 0.43;
    const SECONDS_Y = 0.60;
    const DATA_Y = 0.74;
    const HEART_RATE_X = 0.33;
    const STEPS_X = 0.67;
    const STATUS_Y = 0.87;
    const STATUS_DOT_R = 0.015;
    //! Always-on: the time moves by this much every minute (burn-in protection).
    const ALWAYS_ON_SHIFT = 0.02;
}
