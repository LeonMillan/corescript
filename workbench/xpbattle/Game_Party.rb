
#==============================================================================
# ■ Game_Party
#------------------------------------------------------------------------------
# 　パーティを扱うクラスです。所持金やアイテムなどの情報が含まれます。このクラ
# スのインスタンスは $game_party で参照されます。
#==============================================================================

class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # ● [追加]:公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :actor_invisible     # アクター非表示
  attr_accessor :status_invisible    # バトルステータス非表示
  attr_accessor :actor_bg_invisible  # アクター背景非表示
  attr_accessor :last_party_command  # 最後に選択したパーティコマンド
  attr_accessor :members_screen_x          # バトルメンバー分のX座標配列
  attr_accessor :members_screen_x_nooffset # X:オフセットなし
  attr_accessor :members_screen_y          # バトルメンバー分のY座標配列
  attr_accessor :members_screen_z          # バトルメンバー分のZ座標配列
  #--------------------------------------------------------------------------
  # ● [追加]:バトルメンバーの座標設定
  #--------------------------------------------------------------------------
  def set_members_xyz
    return if members.size == 0
    # 座標をまとめて設定
    set_screen_x
    set_screen_y
    set_screen_z
  end
  #--------------------------------------------------------------------------
  # ● [追加]:バトルメンバーの座標設定
  #--------------------------------------------------------------------------
  def set_members_battle_graphic
    $game_party.battle_members.each {|actor| actor.update_battler_graphic}
  end
  #--------------------------------------------------------------------------
  # ● [追加]:バトル画面 X 座標の設定
  # 　ここで設定した座標は Game_Actor や ステータス表示等で利用されます。
  #--------------------------------------------------------------------------
  def set_screen_x
    @members_screen_x = []
    @members_screen_x_nooffset = []
    padding = LNX11::ACTOR_PADDING[:side]
    if LNX11::ACTOR_CENTERING
      # アクターのセンタリングが有効
      a_spacing = LNX11::ACTOR_SPACING_ADJUST
      padding += (max_battle_members - battle_members.size) * a_spacing
      width = (Graphics.width - padding * 2) / battle_members.size
    else
      # アクターのセンタリングが無効
      width = (Graphics.width - padding * 2) / max_battle_members
    end
    battle_members.each_with_index do |actor, i|
      offset = LNX11::ACTOR_OFFSET[:x]
      @members_screen_x_nooffset[i] = width * i + width / 2 + padding
      @members_screen_x[i] = @members_screen_x_nooffset[i] + offset
      actor.screen_x = @members_screen_x[i]
    end
  end
  #--------------------------------------------------------------------------
  # ● [追加]:バトル画面 Y 座標の設定
  # 　ここで設定した座標は Game_Actor や ステータス表示等で利用されます。
  #--------------------------------------------------------------------------
  def set_screen_y
    offset = LNX11::ACTOR_OFFSET[:y]
    ay = Graphics.height - LNX11::ACTOR_PADDING[:bottom] + offset
    @members_screen_y = Array.new(max_battle_members) {ay}
    battle_members.each {|actor| actor.screen_y = ay}
  end
  #--------------------------------------------------------------------------
  # ● [追加]:バトル画面 Z 座標の設定
  #--------------------------------------------------------------------------
  def set_screen_z
    # 便宜上、XYと同じように配列を作成しておく
    az = LNX11::ACTOR_SCREEN_TONE ? 150 : -10
    @members_screen_z = Array.new(max_battle_members) {az}
  end
  #--------------------------------------------------------------------------
  # ● [オーバーライド]:戦闘開始処理
  #--------------------------------------------------------------------------
  def on_battle_start
    super
    # バトルステータスの更新
    $game_temp.battle_status_refresh
  end
end
