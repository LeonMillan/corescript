
#==============================================================================
# ■ Game_Battler
#------------------------------------------------------------------------------
# 　スプライトに関するメソッドを追加したバトラーのクラスです。
#==============================================================================

class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :loop_animation_id     # ループアニメーション ID
  attr_accessor :loop_animation_mirror # ループアニメーション 左右反転フラグ
  #--------------------------------------------------------------------------
  # ● [エイリアス]:スプライトのエフェクトをクリア
  #--------------------------------------------------------------------------
  alias :lnx11a_clear_sprite_effects :clear_sprite_effects
  def clear_sprite_effects
    # 元のメソッドを呼ぶ
    lnx11a_clear_sprite_effects
    @loop_animation_id = 0
    @loop_animation_mirror = false
  end
  #--------------------------------------------------------------------------
  # ● [再定義]:アニメーション ID の設定
  #--------------------------------------------------------------------------
  def animation_id=(id)
    return unless battle_member?
    @animation_id = id
  end
  #--------------------------------------------------------------------------
  # ● [追加]:ステートのループアニメーションの設定
  #--------------------------------------------------------------------------
  def set_state_animation
    # 表示優先度が高いステートを優先
    sort_states
    anime = @states.collect {|id| $data_states[id].state_animation }
    anime.delete(0)
    @loop_animation_id = anime[0] ? anime[0] : 0
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:ステート情報をクリア
  #--------------------------------------------------------------------------
  alias :lnx11a_clear_states :clear_states
  def clear_states
    # 元のメソッドを呼ぶ
    lnx11a_clear_states
    # ステートアニメ設定
    set_state_animation
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:ステートの付加
  #--------------------------------------------------------------------------
  alias :lnx11a_add_state :add_state
  def add_state(state_id)
    # 元のメソッドを呼ぶ
    lnx11a_add_state(state_id)
    # ステートアニメ設定
    set_state_animation
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:ステートの解除
  #--------------------------------------------------------------------------
  alias :lnx11a_remove_state :remove_state
  def remove_state(state_id)
    # 元のメソッドを呼ぶ
    lnx11a_remove_state(state_id)
    # ステートアニメ設定
    set_state_animation
  end
  #--------------------------------------------------------------------------
  # ● [追加]:ポップアップディレイの取得
  #--------------------------------------------------------------------------
  def popup_delay
    return @popup_delay if @popup_delay
    popup_delay_clear
  end
  #--------------------------------------------------------------------------
  # ● [追加]:ポップアップディレイの設定
  #--------------------------------------------------------------------------
  def popup_delay=(delay)
    @popup_delay = delay
  end
  #--------------------------------------------------------------------------
  # ● [追加]:ポップアップディレイの設定
  #--------------------------------------------------------------------------
  def popup_delay_clear
    @popup_delay = Array.new(16) { 0 }
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:スキル／アイテムの属性修正値を取得
  # 　弱点/耐性の判定を追加します。
  #--------------------------------------------------------------------------
  alias :lnx11a_item_element_rate :item_element_rate
  def item_element_rate(user, item)
    # 元のメソッドを呼ぶ
    rate = lnx11a_item_element_rate(user, item)
    return rate unless $game_party.in_battle
    # レートを結果に保存する
    @result.element_rate = rate
    rate
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:ダメージの処理
  # 　吸収による回復のポップアップを生成します。
  #--------------------------------------------------------------------------
  alias :lnx11a_execute_damage :execute_damage
  def execute_damage(user)
    # 元のメソッドを呼ぶ
    lnx11a_execute_damage(user)
    return unless $game_party.in_battle
    # ポップアップ
    popup_data.popup_hp_drain(user, @result.hp_drain)
    popup_data.popup_mp_drain(user, @result.mp_drain)
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:HP の再生
  #--------------------------------------------------------------------------
  alias :lnx11a_regenerate_hp :regenerate_hp
  def regenerate_hp
    # 元のメソッドを呼ぶ
    lnx11a_regenerate_hp
    return unless $game_party.in_battle
    # ポップアップ
    popup_data.popup_regenerate_hp(self, @result.hp_damage)
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:MP の再生
  #--------------------------------------------------------------------------
  alias :lnx11a_regenerate_mp :regenerate_mp
  def regenerate_mp
    # 元のメソッドを呼ぶ
    lnx11a_regenerate_mp
    return unless $game_party.in_battle
    # ポップアップ
    popup_data.popup_regenerate_mp(self, @result.mp_damage)
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:TP の再生
  #--------------------------------------------------------------------------
  alias :lnx11a_regenerate_tp :regenerate_tp
  def regenerate_tp
    rtp = self.tp.to_i
    # 元のメソッドを呼ぶ
    lnx11a_regenerate_tp
    return unless $game_party.in_battle
    # ポップアップ
    popup_data.popup_regenerate_tp(self, rtp - self.tp.to_i)
  end
  #--------------------------------------------------------------------------
  # ● 被ダメージによる TP チャージ
  #--------------------------------------------------------------------------
  alias :lnx11a_charge_tp_by_damage :charge_tp_by_damage
  def charge_tp_by_damage(damage_rate)
    rtp = self.tp.to_i
    # 元のメソッドを呼ぶ
    lnx11a_charge_tp_by_damage(damage_rate)
    return unless $game_party.in_battle
    # ポップアップ
    popup_data.popup_tp_charge(self, rtp - self.tp.to_i)
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:スキル／アイテムの使用者側への効果(TP 得)
  #--------------------------------------------------------------------------
  alias :lnx11a_item_user_effect :item_user_effect
  def item_user_effect(user, item)
    rtp = user.tp.to_i
    # 元のメソッドを呼ぶ
    lnx11a_item_user_effect(user, item)
    return unless $game_party.in_battle
    # ポップアップ
    popup_data.popup_tp_gain(user, rtp - user.tp.to_i)
  end
  #--------------------------------------------------------------------------
  # ● [追加]:高さの取得
  #--------------------------------------------------------------------------
  def bitmap_height
    return @bitmap_height if @bitmap_height
    @bitmap_height = 0
  end
  #--------------------------------------------------------------------------
  # ● [追加]:高さの設定
  #--------------------------------------------------------------------------
  def bitmap_height=(y)
    @bitmap_height = y
  end
  #--------------------------------------------------------------------------
  # ● [追加]:バトル画面 Y 座標(頭上)の取得
  #--------------------------------------------------------------------------
  def screen_y_top
    screen_y - @bitmap_height
  end
  #--------------------------------------------------------------------------
  # ● [追加]:バトル画面 Y 座標(中心)の取得
  #--------------------------------------------------------------------------
  def screen_y_center
    screen_y - @bitmap_height / 2
  end
end
