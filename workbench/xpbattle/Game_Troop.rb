
#==============================================================================
# ■ Game_Troop
#------------------------------------------------------------------------------
# 　敵グループおよび戦闘に関するデータを扱うクラスです。
#==============================================================================

class Game_Troop < Game_Unit
  #--------------------------------------------------------------------------
  # ● [エイリアス]:セットアップ
  # 　敵グループの座標修正処理を追加します。
  #--------------------------------------------------------------------------
  alias :lnx11a_setup :setup
  def setup(*args)
    # 元のメソッドを呼ぶ
    lnx11a_setup(*args)
    # 敵グループの座標修正
    @enemies.each do |enemy|
      # X:解像度がデフォルトでない場合に位置を補正する
      if LNX11::TROOP_X_SCREEN_FIX
        enemy.screen_x *= Graphics.width.to_f / 544
        enemy.screen_x.truncate
      end
      enemy.screen_y += LNX11::TROOP_Y_OFFSET
    end
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:敵キャラ名の配列取得
  #--------------------------------------------------------------------------
  alias :lnx11a_enemy_names :enemy_names
  def enemy_names
    LNX11::MESSAGE_WINDOW_ENEMY_NAMES ? lnx11a_enemy_names : []
  end
end
