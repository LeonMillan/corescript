
#==============================================================================
# ■ Window_BattleActor
#------------------------------------------------------------------------------
# 　バトル画面で、行動対象のアクターを選択するウィンドウです。
# 選択機能だけを持つ不可視のウィンドウとして扱います。
#==============================================================================

class Window_BattleActor < Window_BattleStatus
  include LNX11_Window_TargetHelp
  #--------------------------------------------------------------------------
  # ● [エイリアス]:オブジェクト初期化
  #--------------------------------------------------------------------------
  alias :lnx11a_wba_initialize :initialize
  def initialize(info_viewport)
    # 元のメソッドを呼ぶ
    lnx11a_wba_initialize(info_viewport)
    # ウィンドウを画面外に移動
    self.y = Graphics.height
  end
  #--------------------------------------------------------------------------
  # ● [オーバーライド]:ヘルプテキスト更新
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_item(targetcursor)
  end
  #--------------------------------------------------------------------------
  # ● [追加]:ターゲットカーソルに渡すオブジェクト
  #--------------------------------------------------------------------------
  def targetcursor
    @cursor_all ? :party : actor
  end
  #--------------------------------------------------------------------------
  # ● [オーバーライド]:ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    64
  end
  #--------------------------------------------------------------------------
  # ● [オーバーライド]:全項目の描画
  #--------------------------------------------------------------------------
  def draw_all_items
    # 何もしない
  end
  #--------------------------------------------------------------------------
  # ● [オーバーライド]:項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    # 何もしない
  end
  #--------------------------------------------------------------------------
  # ● [オーバーライド]:リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    # 何もしない
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:ウィンドウの表示
  #--------------------------------------------------------------------------
  alias :lnx11a_show :show
  def show
    # 元のメソッドを呼ぶ
    lnx11a_show
    # 最後に選択したアクターを選択
    last_target = $game_temp.last_target_cursor[:actor]
    if last_target && $game_party.members.include?(last_target) &&
       LNX11::LAST_TARGET
      select($game_party.members.index(last_target))
    end
    # スマートターゲットセレクト
    if LNX11::SMART_TARGET_SELECT && !@cursor_fix
      if @dead_friend && (!last_target || last_target && last_target.alive?)
        dead_actor = $game_party.dead_members[0]
        select($game_party.members.index(dead_actor)) if dead_actor
      elsif !@dead_friend && (!last_target || last_target && last_target.dead?)
        alive_actor = $game_party.alive_members[0]
        select($game_party.members.index(alive_actor)) if alive_actor
      end
    end
    self
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:ウィンドウの非表示
  #--------------------------------------------------------------------------
  alias :lnx11a_hide :hide
  def hide
    # 元のメソッドを呼ぶ
    lnx11a_hide
    # 選択したアクターを記憶
    $game_temp.last_target_cursor[:actor] = actor
    self
  end
end
