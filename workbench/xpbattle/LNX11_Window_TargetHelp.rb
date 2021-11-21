
#==============================================================================
# ■ LNX11_Window_TargetHelp
#------------------------------------------------------------------------------
# 　バトル画面で、ターゲット選択中にヘルプウィンドウを表示するための
# ウィンドウ用モジュールです。
# Window_BattleActor, Window_BattleEnemy でインクルードされます。
#==============================================================================

module LNX11_Window_TargetHelp
  #--------------------------------------------------------------------------
  # ● [追加]:ターゲットチェック
  #--------------------------------------------------------------------------
  def set_target(actor_selection_item)
    @cursor_fix = @cursor_all = @cursor_random = false
    item = actor_selection_item
    if actor_selection_item && !item.lnx11a_need_selection?
      # カーソルを固定
      @cursor_fix = true
      # 全体
      @cursor_all = item.for_all?
      # ランダム
      if item.for_random?
        @cursor_all = true
        @cursor_random = true
        @random_number = item.number_of_targets
      end
    end
    # 戦闘不能の味方が対象か？
    @dead_friend = item.for_dead_friend?
  end
  #--------------------------------------------------------------------------
  # ● [追加]:ターゲットチェック(リフレッシュ後)
  #--------------------------------------------------------------------------
  def set_target_refresh(actor_selection_item, actor)
    item = actor_selection_item
    # 使用者が対象なら、使用者にカーソルを合わせる
    select($game_party.members.index(actor)) if @cursor_fix && item.for_user?
  end
  #--------------------------------------------------------------------------
  # ● [オーバーライド]:ウィンドウの表示
  #--------------------------------------------------------------------------
  def show
    @help_window.show
    super
  end
  #--------------------------------------------------------------------------
  # ● [オーバーライド]:ウィンドウの非表示
  #--------------------------------------------------------------------------
  def hide
    @help_window.hide
    super
  end
end
