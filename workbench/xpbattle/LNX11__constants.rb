module LNX11
  #--------------------------------------------------------------------------
  # ● 設定値
  # 　※ 設定を変更する場合、LNX11aconf を使用してください。
  #--------------------------------------------------------------------------
  # <<ver1.00>>
  if !$lnx_include[:lnx11aconf] ||
     $lnx_include[:lnx11aconf] && $lnx_include[:lnx11aconf] < 100
  DEFAULT_BATTLER_GRAPHIC = 0
  DEFAULT_BG_COLOR        = [Color.new(0, 0, 0, 0), Color.new(0, 0, 0, 0)]
  ACTOR_SCREEN_TONE       = false
  TP_POPUP_TYPE           = 1
  INDEXZERO_NO_POPUP      = true
  ACTOR_BACKGROUND        = 2
  ACTOR_BACKGROUND_HEIGHT = 112
  ACTOR_BG_GRADIENT_COLOR = [Color.new(0, 0, 0, 96), Color.new(0, 0, 0, 224)]
  BATTLELOG_TYPE  =  1
  STORAGE_LINE_NUMBER     = 6
  STORAGE_LINE_HEIGHT     = 20
  STORAGE_UP_MESSAGE_TIME = 90
  STORAGE_TURNEND_CLEAR   = true
  STORAGE_OFFSET = {:x => 0, :y => 6}
  STORAGE_FONT   = {:size => 20, :out_color => Color.new(0, 0, 0, 192)}
  STORAGE_GRADIENT_COLOR = [Color.new(0, 0, 0, 128), Color.new(0, 0, 0, 0)]
  POPUP_ADD_WAIT          = 6
  HELPDISPLAY_TYPE        = 1
  HELPDISPLAT_WAIT        = 20
  HELPDISPLAT_END_WAIT    = 24
  HELPDISPLAY_DESCRIPTION = {:size => 20, :delimiter => " "}
  MESSAGE_TYPE  =  2
  MESSAGE_WINDOW_BACKGROUND  = 1
  MESSAGE_WINDOW_POSITION    = 0
  MESSAGE_WAIT = {:battle_start => [120, false], :victory   => [ 60, false],
                  :defeat       => [120, false], :escape    => [120, false],
                  :drop_item    => [ 60,  true], :levelup   => [ 60,  true]}
  MESSAGE_WINDOW_ENEMY_NAMES = false
  LEVELUP_SE  = RPG::SE.new("Up4", 90, 100)
  DROPITEM_SE = RPG::SE.new("Item3", 80, 125)
  ACTOR_CENTERING  =  true
  ACTOR_SPACING_ADJUST = 32
  ACTOR_OFFSET  = {:x => -16, :y => 0}
  ACTOR_PADDING = {:side => 4, :bottom => 8}
  SCREEN_ANIMATION_OFFSET = 128
  STATUS_OFFSET = {:x => 64, :y => -12}
  STATUS_SIDE_PADDING   = 6
  STATUS_WIDTH          = 72
  STATUS_AUTOADJUST     = true
  STATUS_LINE_HEIGHT    = 22
  STATUS_NAME_SIZE      = 20
  STATUS_PARAM_SIZE     = 23
  STATUS_GAUGE_OPACITY  = 192
  ACTOR_COMMAND_NOSCROLL   = true
  ACTOR_COMMAND_HORIZON    = false
  ACTOR_COMMAND_ALIGNMENT  = 0
  ACTOR_COMMAND_WIDTH      = 128
  ACTOR_COMMAND_POSITION   = 0
  ACTOR_COMMAND_Y_POSITION = 0
  ACTOR_COMMAND_OFFSET  = {:x => 0, :y => -16}
  PARTY_COMMAND_HORIZON   = true
  PARTY_COMMAND_ALIGNMENT = 1
  PARTY_COMMAND_WIDTH     = Graphics.width
  PARTY_COMMAND_XY        = {:x => 0, :y => 0}
  CURSOR_NAME       = ""
  CURSOR_TONE     = Tone.new(-34, 0, 68)
  CURSOR_ANI_SPEED  = 3
  CURSOR_SPEED      = 3
  CURSOR_BLINK      = true
  CURSOR_MINMAX     = {:min => 48, :max => Graphics.height}
  CURSOR_OFFSET     = {:x => 0, :y => 0}
  HELP_ACTOR_PARAM = {:hp => true ,:mp => true ,:tp => true ,:state => true }
  HELP_ENEMY_PARAM = {:hp => false,:mp => false,:tp => false,:state => true }
  HELP_PARAM_WIDTH    = 72
  RANDOMSCOPE_DISPLAY = 1
  ACTOR_POPUP_POSITION   = 3
  ENEMY_POPUP_POSITION   = 1
  LEVELUP_POPUP_POSITION = 3
  ACTOR_POPUP_Y     =  -100
  LEVELUP_POPUP_Y   =  -112
  NUMBER_FONT   =  ["Arial Black", "VL Gothic"]
  TEXT_FONT     =  ["Arial Black", "VL Gothic"]
  TEXT_FONT_MCS =  ["VL Gothic"]
  LARGE_NUMBER  =  {:fontsize => 38, :spacing => -4, :line_height => 26}
  SMALL_NUMBER  =  {:fontsize => 28, :spacing => -4, :line_height => 20}
  TEXT_SIZERATE     = {:normal => 0.8, :left_right => 0.7, :top_bottom => 0.6}
  TEXT_SIZERATE_MCS = 0.9
  DECORATION_NUMBER = {
  :critical    => ["CRITICAL", 8], :weakness    => ["WEAKNESS", 8],
  :resist      => ["RESIST"  , 8], :mp_damage   => ["\mp"     , 4],
  :mp_plus     => ["\mp+"    , 4], :mp_minus    => ["\mp-"    , 4],
  :tp_plus     => ["\tp+"    , 4], :tp_minus    => ["\tp-"    , 4]}
  DECORATION_TEXT = {
  :add_state   => "+%s",      :rem_state   => "-%s",
  :add_buff    => "%s UP",    :add_debuff  => "%s DOWN",
  :rem_buff    => "-%s Buff"}
  POPUP_VOCAB = {
  :miss        => "MISS!",      :counter     => "Counter",
  :reflection  => "Reflection", :substitute  => "Substitute",
  :levelup     => "LEVELUP!"}
  POPUP_VOCAB_PARAMS = [
  "MAX\hp","MAX\mp","ATK","DEF","MATK","MDEF","AGI","LUCK"]
  POPUP_COLOR = {
  :hp_damage     => [Color.new(255, 255, 255), Color.new(  0,   0,   0)],
  :critical      => [Color.new(255, 255,  80), Color.new(224,  32,   0)],
  :weakness      => [Color.new(255, 255, 255), Color.new(  0,  56, 144)],
  :resist        => [Color.new(232, 224, 216), Color.new( 56,  48,  40)],
  :hp_recovery   => [Color.new( 96, 255, 128), Color.new(  0,  64,  32)],
  :mp_damage     => [Color.new(248,  80, 172), Color.new( 48,   0,  32)],
  :mp_recovery   => [Color.new(160, 240, 255), Color.new( 32,  48, 144)],
  :tp_damage     => [Color.new(248, 240,  64), Color.new(  0,  80,  40)],
  :add_state     => [Color.new(255, 255, 255), Color.new(  0,  56, 144)],
  :rem_state     => [Color.new(224, 232, 240), Color.new( 32,  64, 128, 128)],
  :add_badstate  => [Color.new(255, 255, 255), Color.new(  0,   0,   0)],
  :rem_badstate  => [Color.new(224, 224, 224), Color.new( 32,  32,  32, 128)],
  :add_buff      => [Color.new(255, 255, 192), Color.new( 96,  64,   0)],
  :add_debuff    => [Color.new(200, 224, 232), Color.new( 40,  48,  56)],
  :rem_buff      => [Color.new(224, 224, 224), Color.new( 32,  32,  32, 128)],
  :counter       => [Color.new(255, 255, 224), Color.new(128,  96,   0)],
  :reflection    => [Color.new(224, 255, 255), Color.new(  0,  96, 128)],
  :substitute    => [Color.new(224, 255, 224), Color.new(  0, 128,  64)],
  :levelup       => [Color.new(255, 255, 255), Color.new(  0,   0,   0)],
  }
  POPUP_TYPE = {
  :miss          =>   0,:hp_damage     =>   0,:hp_slipdamage =>   1,
  :hp_recovery   =>   0,:hp_regenerate =>   1,:hp_drain      =>   0,
  :hp_drainrecv  =>   0,:mp_damage     =>   0,:mp_slipdamage =>   1,
  :mp_recovery   =>   0,:mp_regenerate =>   1,:mp_drain      =>   0,
  :mp_drainrecv  =>   0,:mp_paycost    =>  -1,:tp_damage     =>   1,
  :tp_charge     =>  -1,:tp_gain       =>   7,:tp_regenerate =>   1,
  :tp_paycost    =>  -1,:add_state     =>   2,:rem_state     =>   2,
  :add_badstate  =>   2,:rem_badstate  =>   2,:add_debuff    =>   3,
  :rem_buff      =>   3,:counter       =>   6,:reflection    =>   6,
  :substitute    =>   4,}
  LARGE_MOVEMENT = {
  :inirate    => 6.4,  :gravity      => 0.68,  :side_scatter => 1.2,
  :ref_height =>  32,  :ref_factor   => 0.60,  :ref_count    =>   2,
                       :duration     =>   40,  :fadeout      =>  20 }
  SMALL_MOVEMENT = {
  :inirate    => 4.4,  :gravity      => 0.60,  :side_scatter => 0.0,
  :ref_height =>  12,  :ref_factor   => 0.70,  :ref_count    =>   0,
                       :duration     =>   60,  :fadeout      =>  16 }
  RISE_MOVEMENT     = {:rising_speed => 0.75,  :line_spacing => 0.9,
                       :duration     =>   40,  :fadeout      =>   8 }
  SLIDE_MOVEMENT    = {:x_speed      =>    2,  :line_spacing => 0.9,
                       :duration     =>   50,  :fadeout      =>  32 }
  OVERLAY_MOVEMENT  = {:duration     =>   36,  :fadeout      =>  32 }
  FIX_TARGET_CHECKE     = true
  GUARD_TARGET_CHECKE   = true
  SMART_TARGET_SELECT   = true
  LAST_TARGET           = true
  LAST_PARTY_COMMAND    = true
  LAST_ACTOR_COMMAND    = true
  TROOP_X_SORT          = true
  PARTY_COMMAND_SKIP    = true
  FITTING_LIST          = true
  ENHANCED_WHITEN       = true
  DISABLED_DAMAGE_SHAKE = true
  TROOP_X_SCREEN_FIX    = true
  TROOP_Y_OFFSET        = 0
  end
  # <<ver1.10>>
  if !$lnx_include[:lnx11aconf] ||
    $lnx_include[:lnx11aconf] && $lnx_include[:lnx11aconf] < 110
  LARGE_NUMBER_NAME = ""
  SMALL_NUMBER_NAME = ""
  LARGE_BUFFS_NAME  = ""
  SMALL_BUFFS_NAME  = ""
end
