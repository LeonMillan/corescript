#==============================================================================
# ■ [追加]:Popup_Data
#------------------------------------------------------------------------------
# 　戦闘中のポップアップをまとめて扱うクラス。ポップアップスプライトの
# initialize 時に自身を参照させて、ポップアップ内容を定義する際にも使います。
#==============================================================================

class Popup_Data
  #--------------------------------------------------------------------------
  # ● クラス変数
  #--------------------------------------------------------------------------
  @@make_methods = {} # ポップアップ作成メソッドのハッシュ
  #--------------------------------------------------------------------------
  # ● 定数(ポップアップのタイプID)
  #--------------------------------------------------------------------------
  SPRING_LARGE  = 0
  SPRING_SMALL  = 1
  RISING_LARGE  = 2
  RISING_SMALL  = 3
  SLIDING_LARGE = 4
  SLIDING_SMALL = 5
  OVERLAY_LARGE = 6
  OVERLAY_SMALL = 7
  LEVELUP       = :levelup
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :type       # ポップアップのタイプ
  attr_accessor :popup      # 表示する内容
  attr_accessor :popup_size # ポップアップの大きさ
  attr_accessor :color      # 色
  attr_accessor :deco       # 修飾文字
  attr_accessor :battler    # ポップアップするバトラー
  attr_accessor :delay      # 表示開始までの時間
  attr_accessor :viewport   # ビューポート
  attr_accessor :popup_wait # ポップアップウェイト
  attr_accessor :buff_data  # 能力強化/弱体 <<ver1.10>>
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    @sprites = []
    @viewport = Viewport.new
    @viewport.z = 120 # ポップアップの Z 座標
    spb = Sprite_PopupBase.new
    spb.create_number
    spb.dispose
    set_methods
    refresh
  end
  #--------------------------------------------------------------------------
  # ● ポップアップ生成メソッドの登録
  #--------------------------------------------------------------------------
  def set_methods
    @@make_methods[SPRING_LARGE]  = method(:makeup_spring_large)
    @@make_methods[SPRING_SMALL]  = method(:makeup_spring_small)
    @@make_methods[RISING_LARGE]  = method(:makeup_rising_large)
    @@make_methods[RISING_SMALL]  = method(:makeup_rising_small)
    @@make_methods[SLIDING_LARGE] = method(:makeup_sliding_large)
    @@make_methods[SLIDING_SMALL] = method(:makeup_sliding_small)
    @@make_methods[OVERLAY_LARGE] = method(:makeup_overlay_large)
    @@make_methods[OVERLAY_SMALL] = method(:makeup_overlay_small)
    @@make_methods[LEVELUP]       = method(:makeup_levelup)
  end
  #--------------------------------------------------------------------------
  # ● スプライト解放
  #--------------------------------------------------------------------------
  def dispose
    @sprites.each {|sprite| sprite.dispose}
    @viewport.dispose
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    @sprites.each do |sprite|
      sprite.update
      @sprites.delete(sprite) if sprite.disposed?
    end
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    @type  = 0
    @popup = nil
    @popup_size = :large
    @color = :hp_damage
    @deco = ["", -1] # [テキスト, テキストの位置]
    @battler = nil
    @delay = 0
    @popup_wait = false
    # <<ver1.10>> 能力強化/弱体ポップアップを画像で表示する際に利用
    @buff_data = [-1, -1] # [能力, 強化or弱体or解除]
  end
  #--------------------------------------------------------------------------
  # ● ポップアップを生成
  #--------------------------------------------------------------------------
  def makeup
    if @@make_methods[@type]
      @@make_methods[@type].call
      @popup_wait = true
    end
  end
  #--------------------------------------------------------------------------
  # ● ポップアップウェイト
  # 　バトルログタイプが [2:ヘルプ表示] の場合のみ実行されます。
  #--------------------------------------------------------------------------
  def add_wait
    return if LNX11::BATTLELOG_TYPE != 2 || !@popup_wait
    LNX11::POPUP_ADD_WAIT.times {BattleManager.log_window.abs_wait(1)}
    @popup_wait = false
  end
  #--------------------------------------------------------------------------
  # ● ポップアップ生成メソッド
  # 　これらのメソッドを @@make_methods に登録して呼び出します。
  # これはポップアップタイプの拡張を容易にするための仕様です。
  #--------------------------------------------------------------------------
  def makeup_spring_large
    # @type   0 : 跳ねるポップアップ(大)
    @popup_size = :large
    @sprites.push(Sprite_PopupSpring.new(self))
  end
  def makeup_spring_small
    # @type   1 : 跳ねるポップアップ(小)
    @popup_size = :small
    @delay = @battler.popup_delay[1]
    @sprites.push(Sprite_PopupSpring.new(self))
  end
  def makeup_rising_large
    # @type   2 : ゆっくり上昇(大)
    @popup_size = :large
    @delay = @battler.popup_delay[2]
    @sprites.push(Sprite_PopupRising.new(self))
  end
  def makeup_rising_small
    # @type   3 : ゆっくり上昇(小)
    @popup_size = :small
    @delay = @battler.popup_delay[2]
    @sprites.push(Sprite_PopupRising.new(self))
  end
  def makeup_sliding_large
    # @type   4 : スライド(大)
    @popup_size = :large
    @delay = @battler.popup_delay[3]
    @sprites.push(Sprite_PopupSliding.new(self))
  end
  def makeup_sliding_small
    # @type   5 : スライド(小)
    @popup_size = :small
    @delay = @battler.popup_delay[3]
    @sprites.push(Sprite_PopupSliding.new(self))
  end
  def makeup_overlay_large
    # @type   6 : オーバーレイ(大)
    @popup_size = :large
    @sprites.push(Sprite_PopupOverlay.new(self))
  end
  def makeup_overlay_small
    # @type   7 : オーバーレイ(小)
    @popup_size = :small
    @sprites.push(Sprite_PopupOverlay.new(self))
  end
  def makeup_levelup
    # @type :levelup : レベルアップ
    @battler.popup_delay[3] = 0
    @popup_size = :large
    @sprites.push(Sprite_PopupLevelUp.new(self))
  end
  #--------------------------------------------------------------------------
  # ● TP のポップアップが有効か？
  #--------------------------------------------------------------------------
  def tp_popup_enabled?(target)
    return false if !$data_system.opt_display_tp
    return true  if LNX11::TP_POPUP_TYPE == 0 # すべてポップアップ
    return true  if LNX11::TP_POPUP_TYPE == 1 && target.actor? # アクターのみ
    false # ポップアップしない
  end
  #--------------------------------------------------------------------------
  # ● 任意のポップアップ
  #--------------------------------------------------------------------------
  def popup_custom(target, popup, type = 0, color = :hp_damage, deco = nil)
    refresh
    @battler = target
    @popup = popup
    type = LNX11::POPUP_TYPE[type] if type.is_a?(Symbol)
    @type = type
    @color = color
    @deco = LNX11::DECORATION_NUMBER[deco] if deco.is_a?(Symbol)
    # ポップアップ作成
    makeup
  end
  #--------------------------------------------------------------------------
  # ● レベルアップのポップアップ
  #--------------------------------------------------------------------------
  def popup_levelup(target)
    # 戦闘に参加している場合のみポップアップ
    return unless $game_party.battle_members.include?(target)
    refresh
    @type = :levelup
    @battler = target
    @popup = LNX11::POPUP_VOCAB[:levelup]
    @color = :levelup
    # ポップアップ作成
    makeup
  end
  #--------------------------------------------------------------------------
  # ● 単一テキストのポップアップ
  #--------------------------------------------------------------------------
  def popup_text(target, type)
    refresh
    @type = LNX11::POPUP_TYPE[type]
    @battler = target
    @popup = LNX11::POPUP_VOCAB[type]
    @color = type
    # ポップアップ作成
    makeup
  end
  #--------------------------------------------------------------------------
  # ● ミスのポップアップ
  #--------------------------------------------------------------------------
  def popup_miss(target, item)
    refresh
    @type = LNX11::POPUP_TYPE[:miss]
    @battler = target
    @popup = LNX11::POPUP_VOCAB[:miss]
    @color = :hp_damage
    # ポップアップ作成
    makeup
  end
  #--------------------------------------------------------------------------
  # ● HP ダメージポップアップ
  #--------------------------------------------------------------------------
  def popup_hp_damage(target, item)
    return if target.result.hp_damage == 0 && item && !item.damage.to_hp?
    refresh
    @popup = target.result.hp_damage
    @battler = target
    if target.result.hp_drain > 0
      # 被吸収
      @type = LNX11::POPUP_TYPE[:hp_drain]
      # 弱点/耐性
      if target.result.element_rate > 1
        @deco = LNX11::DECORATION_NUMBER[:weakness]
        @color = :weakness
      elsif target.result.element_rate < 1
        @deco = LNX11::DECORATION_NUMBER[:resist]
        @color = :resist
      else
        @color = :hp_damage
      end
    elsif target.result.hp_damage > 0
      # ダメージ
      @type = LNX11::POPUP_TYPE[:hp_damage]
      @color = :hp_damage
      if target.result.critical
        # クリティカル
        @deco = LNX11::DECORATION_NUMBER[:critical]
        @color = :critical
      end
      # 弱点/耐性
      if target.result.element_rate > 1
        @deco = LNX11::DECORATION_NUMBER[:weakness]
        @color = :weakness if @color != :critical
      elsif target.result.element_rate < 1
        @deco = LNX11::DECORATION_NUMBER[:resist]
        @color = :resist if @color != :critical
      end
    elsif target.result.hp_damage < 0
      # 回復
      @type = LNX11::POPUP_TYPE[:hp_recovery]
      @color = :hp_recovery
    else
      # 0 ダメージ
      @type = LNX11::POPUP_TYPE[:hp_damage]
      @color = :hp_damage
    end
    # ポップアップ作成
    makeup
  end
  #--------------------------------------------------------------------------
  # ● MP ダメージポップアップ
  #--------------------------------------------------------------------------
  def popup_mp_damage(target, item)
    return if target.dead? || target.result.mp_damage == 0
    refresh
    @popup = target.result.mp_damage
    @battler = target
    @deco = LNX11::DECORATION_NUMBER[:mp_damage]
    if target.result.mp_drain > 0
      # 被吸収
      @type = LNX11::POPUP_TYPE[:mp_drain]
      @color = :mp_damage
    elsif target.result.mp_damage > 0
      # ダメージ
      @type = LNX11::POPUP_TYPE[:mp_damage]
      @color = :mp_damage
    elsif target.result.mp_damage < 0
      # 回復
      @type = LNX11::POPUP_TYPE[:mp_recovery]
      @color = :mp_recovery
    end
    # ポップアップ作成
    makeup
  end
  #--------------------------------------------------------------------------
  # ● TP ダメージポップアップ
  #--------------------------------------------------------------------------
  def popup_tp_damage(target, item)
    return unless tp_popup_enabled?(target)
    return if target.dead? || target.result.tp_damage == 0
    refresh
    @popup = target.result.tp_damage
    @battler = target
    deco = target.result.tp_damage > 0 ? :tp_minus : :tp_plus
    @deco = LNX11::DECORATION_NUMBER[deco]
    @type = LNX11::POPUP_TYPE[:tp_damage]
    @color = :tp_damage
    # ポップアップ作成
    makeup
  end
  #--------------------------------------------------------------------------
  # ● HP 吸収回復
  #--------------------------------------------------------------------------
  def popup_hp_drain(target, hp_drain)
    return if hp_drain == 0
    refresh
    @popup = hp_drain
    @battler = target
    @type = LNX11::POPUP_TYPE[:hp_drainrecv]
    @color = :hp_recovery
    # ポップアップ作成
    makeup
  end
  #--------------------------------------------------------------------------
  # ● MP 吸収回復
  #--------------------------------------------------------------------------
  def popup_mp_drain(target, mp_drain)
    return if mp_drain == 0
    refresh
    @popup = mp_drain
    @battler = target
    @deco = LNX11::DECORATION_NUMBER[:mp_damage]
    @type = LNX11::POPUP_TYPE[:mp_drainrecv]
    @color = :mp_recovery
    # ポップアップ作成
    makeup
  end
  #--------------------------------------------------------------------------
  # ● ステート付加のポップアップ
  #--------------------------------------------------------------------------
  def popup_added_states(target)
    refresh
    @battler = target
    target.result.added_state_objects.each do |state|
      next if state.id == target.death_state_id
      next if state.icon_index == 0 && LNX11::INDEXZERO_NO_POPUP
      next if state.add_no_display?
      if state.add_no_decoration?
        @popup = state.add_display_name
      else
        @popup = sprintf(LNX11::DECORATION_TEXT[:add_state],
                         state.add_display_name)
      end
      type = state.advantage? ? :add_state : :add_badstate
      if state.add_popup_type
        @type = state.add_popup_type
      else
        @type = LNX11::POPUP_TYPE[type]
      end
      @color = type
      # ポップアップ作成
      makeup
    end
  end
  #--------------------------------------------------------------------------
  # ● ステート解除のポップアップ
  #--------------------------------------------------------------------------
  def popup_removed_states(target)
    refresh
    @type = LNX11::POPUP_TYPE[:rem_badstate]
    @battler = target
    target.result.removed_state_objects.each do |state|
      next if state.id == target.death_state_id
      next if state.icon_index == 0 && LNX11::INDEXZERO_NO_POPUP
      next if state.remove_no_display?
      if state.remove_no_decoration?
        @popup = state.remove_display_name
      else
        @popup = sprintf(LNX11::DECORATION_TEXT[:rem_state],
                         state.remove_display_name)
      end
      type = state.advantage? ? :rem_state : :rem_badstate
      if state.remove_popup_type
        @type = state.remove_popup_type
      else
        @type = LNX11::POPUP_TYPE[type]
      end
      @color = type
      # ポップアップ作成
      makeup
    end
  end
  #--------------------------------------------------------------------------
  # ● 能力強化／弱体のポップアップ
  #--------------------------------------------------------------------------
  def popup_buffs(target, buffs, fmt)
    return if buffs.empty?
    refresh
    @battler = target
    case fmt
    when Vocab::BuffAdd
      buffdeco = LNX11::DECORATION_TEXT[:add_buff]
      @type = LNX11::POPUP_TYPE[:add_buff]
      @color = :add_buff
      @buff_data[1] = 0
    when Vocab::DebuffAdd
      buffdeco = LNX11::DECORATION_TEXT[:add_debuff]
      @type = LNX11::POPUP_TYPE[:add_debuff]
      @color = :add_debuff
      @buff_data[1] = 1
    when Vocab::BuffRemove
      buffdeco = LNX11::DECORATION_TEXT[:rem_buff]
      @type = LNX11::POPUP_TYPE[:rem_buff]
      @color = :rem_buff
      @buff_data[1] = 2
    end
    buffs.each do |param_id|
      @popup = sprintf(buffdeco, LNX11::POPUP_VOCAB_PARAMS[param_id])
      @buff_data[0] = param_id
      # ポップアップ作成
      makeup
      @popup_wait = false
    end
  end
  #--------------------------------------------------------------------------
  # ● HP 再生
  #--------------------------------------------------------------------------
  def popup_regenerate_hp(target, hp_damage, paycost = false)
    return if hp_damage == 0
    refresh
    @popup = hp_damage
    @battler = target
    if hp_damage > 0
      # ダメージ
      @type = LNX11::POPUP_TYPE[:hp_slipdamage]
      @color = :hp_damage
    elsif hp_damage < 0
      # 回復
      @type = LNX11::POPUP_TYPE[:hp_regenerate]
      @color = :hp_recovery
    end
    # ポップアップ作成
    makeup
  end
  #--------------------------------------------------------------------------
  # ● MP 再生
  #--------------------------------------------------------------------------
  def popup_regenerate_mp(target, mp_damage, paycost = false)
    return if mp_damage == 0
    refresh
    @popup = mp_damage
    @battler = target
    @deco = LNX11::DECORATION_NUMBER[mp_damage > 0 ? :mp_minus : :mp_plus]
    if mp_damage > 0
      # ダメージ
      @type = LNX11::POPUP_TYPE[paycost ? :mp_paycost : :mp_slipdamage]
      @color = :mp_damage
    elsif mp_damage < 0
      # 回復
      @type = LNX11::POPUP_TYPE[paycost ? :mp_paycost : :mp_regenerate]
      @color = :mp_recovery
    end
    # ポップアップ作成
    makeup
  end
  #--------------------------------------------------------------------------
  # ● TP 再生
  #--------------------------------------------------------------------------
  def popup_regenerate_tp(target, tp_damage, paycost = false)
    return unless tp_popup_enabled?(target)
    return if tp_damage == 0
    refresh
    @popup = tp_damage
    @battler = target
    @deco = LNX11::DECORATION_NUMBER[tp_damage > 0 ? :tp_minus : :tp_plus]
    @type = LNX11::POPUP_TYPE[paycost ? :tp_paycost : :tp_regenerate]
    @color = :tp_damage
    # ポップアップ作成
    makeup
  end
  #--------------------------------------------------------------------------
  # ● TP チャージ
  #--------------------------------------------------------------------------
  def popup_tp_charge(target, tp_damage)
    return unless tp_popup_enabled?(target)
    return if tp_damage == 0
    refresh
    @popup = tp_damage
    @battler = target
    @deco = LNX11::DECORATION_NUMBER[tp_damage > 0 ? :tp_minus : :tp_plus]
    @type = LNX11::POPUP_TYPE[:tp_charge]
    @color = :tp_damage
    # ポップアップ作成
    makeup
  end
  #--------------------------------------------------------------------------
  # ● TP 得
  #--------------------------------------------------------------------------
  def popup_tp_gain(target, tp_damage)
    return unless tp_popup_enabled?(target)
    return if tp_damage == 0
    refresh
    @popup = tp_damage
    @battler = target
    @deco = LNX11::DECORATION_NUMBER[tp_damage > 0 ? :tp_minus : :tp_plus]
    @type = LNX11::POPUP_TYPE[:tp_gain]
    @color = :tp_damage
    # ポップアップ作成
    makeup
  end
end
