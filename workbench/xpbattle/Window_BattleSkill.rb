
#==============================================================================
# ■ Window_BattleSkill
#------------------------------------------------------------------------------
# 　いくつかのモジュールをインクルードします。
#==============================================================================

class Window_BattleSkill < Window_SkillList
  include LNX11_Window_ActiveVisible
  include LNX11_Window_FittingList
end
