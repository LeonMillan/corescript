
#==============================================================================
# ■ Game_BattlerBase
#------------------------------------------------------------------------------
# 　バトラーを扱う基本のクラスです。
#==============================================================================

class Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● [追加]:ポップアップデータの取得
  #--------------------------------------------------------------------------
  def popup_data
    $game_temp.popup_data
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:スキル使用コストの支払い
  #--------------------------------------------------------------------------
  alias :lnx11a_pay_skill_cost :pay_skill_cost
  def pay_skill_cost(skill)
    rmp = self.mp
    rtp = self.tp
    # 元のメソッドを呼ぶ
    lnx11a_pay_skill_cost(skill)
    return unless $game_party.in_battle
    # ポップアップ
    popup_data.popup_regenerate_mp(self, (rmp - self.mp).truncate, true)
    popup_data.popup_regenerate_tp(self, (rtp - self.tp).truncate, true)
  end
end
