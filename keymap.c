#include QMK_KEYBOARD_H

/* qmk_firmware/keyboards/jj40/keymaps/dns/keymap.c */

#include "../../config.h"


#define _QWERTY 0
#define _XNUM  1
#define _XSFT  2
#define _XCTL  3
#define _XREAD 4

enum custom_keycodes {
  QWERTY = SAFE_RANGE,
  XNUM,
  XSFT,
  XCTL,
  XREAD,
};

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {

[_QWERTY] = LAYOUT_ortho_4x12( \
  KC_Q,    KC_W,    KC_E,          KC_R,        KC_T,     _______,    _______,   KC_Y,        KC_U,       KC_I,      KC_O,    KC_P,    \
  KC_A,    KC_S,    KC_D,          KC_F,        KC_G,     _______,    _______,    KC_H,        KC_J,       KC_K,      KC_L,    KC_SPC,  \
  KC_Z,    KC_X,    KC_C,          KC_V,        KC_B,     _______,    _______,   KC_N,        KC_M,       KC_COMM,   KC_DOT,  KC_SLSH, \
  KC_LGUI, KC_BSPC, KC_LALT,       MO(_XCTL),   KC_ESC,   KC_LCTL,   KC_ENT,    KC_LSFT,     MO(_XSFT),  MO(_XNUM), KC_TAB,  KC_LGUI  \
),

/*
` { } \ ~     : _ [ ] +
@ $ # & *     % - ( ) :
' " ^ | ;     ! = < > ?
 */
[_XSFT] = LAYOUT_ortho_4x12( \
  KC_GRV,   S(KC_LBRC),  S(KC_RBRC),  KC_BSLS,    S(KC_GRV),   _______,_______,    _______,    S(KC_MINS), KC_LBRC,    KC_RBRC,   S(KC_EQL),  \
  S(KC_2),  S(KC_4),     S(KC_3),     S(KC_7),    S(KC_8),     _______,_______,    S(KC_5),    KC_MINS,    S(KC_9),    S(KC_0),   S(KC_SCLN), \
  KC_QUOT,  S(KC_QUOT),  S(KC_6),     S(KC_BSLS), KC_SCLN,     _______,_______,    S(KC_1),    KC_EQL,     S(KC_COMM), S(KC_DOT), S(KC_SLSH), \
  _______, S(KC_5),      _______,     _______,    _______,     _______,_______,    _______, _______, _______, _______, _______ \
),

[_XNUM] = LAYOUT_ortho_4x12( \
  TO(_XREAD), _______, _______, KC_5, _______, _______, _______, KC_5, KC_6, KC_7, KC_8, KC_9, \
  _______,    _______, _______, KC_0, _______, _______, _______, KC_0, KC_1, KC_2, KC_3, KC_4, \
  _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, \
  RGB_TOG, RGB_MOD, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______  \
),

[_XCTL] = LAYOUT_ortho_4x12( \
  LCTL(KC_Q),    LCTL(KC_W),    LCTL(KC_E),    LCTL(KC_R),        LCTL(KC_T), _______, _______, LCTL(KC_Y),    LCTL(KC_U),    KC_TAB,     LCTL(KC_O),    LCTL(KC_P),    \
  LCTL(KC_A),    LCTL(KC_S),    LCTL(KC_D),    LCTL(KC_F),        LCTL(KC_G), _______, _______, KC_LEFT,       KC_DOWN,       KC_UP,      KC_RIGHT,      LCTL(KC_SPC) , \
  LCTL(KC_Z),    LCTL(KC_X),    LCTL(KC_C),    LCTL(KC_V),        LCTL(KC_B), _______, _______, KC_BSPC,       KC_ENT,        KC_LANG1,   KC_LANG2,      LCTL(KC_K),        \
  _______,       KC_MS_BTN1,    KC_MS_BTN2,       _______,          _______,    _______, _______, _______,       _______,       KC_LALT, _______, _______ \
),

[_XREAD] = LAYOUT_ortho_4x12( \
  TO(_QWERTY), _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, \
  _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, \
  KC_TAB, S(KC_TAB), _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, \
  KC_SPC, S(KC_SPC), _______, _______, _______, _______, _______, _______, _______, _______, _______, _______ \
),

};

// Loop
void matrix_scan_user(void) {
  // Empty
};
