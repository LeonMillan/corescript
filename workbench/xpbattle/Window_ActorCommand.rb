
#==============================================================================
# ■ Window_ActorCommand
#------------------------------------------------------------------------------
# 　バトル画面で、アクターの行動を選択するウィンドウです。
#==============================================================================

class Window_ActorCommand < Window_Command
  include LNX11_Window_ActiveVisible
  #--------------------------------------------------------------------------
  # ● [オーバーライド]:ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    return LNX11::ACTOR_COMMAND_WIDTH
  end
  #--------------------------------------------------------------------------
  # ● [オーバーライド]:表示行数の取得
  #--------------------------------------------------------------------------
  def visible_line_number
    list_size = LNX11::ACTOR_COMMAND_NOSCROLL ? @list.size : 4
    return LNX11::ACTOR_COMMAND_HORIZON ? 1 : list_size
  end
  #--------------------------------------------------------------------------
  # ● [オーバーライド]:桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    return LNX11::ACTOR_COMMAND_HORIZON ? [@list.size, 1].max :  1
  end
  #--------------------------------------------------------------------------
  # ● [オーバーライド]:アライメントの取得
  #--------------------------------------------------------------------------
  def alignment
    return LNX11::ACTOR_COMMAND_ALIGNMENT
  end
  #--------------------------------------------------------------------------
  # ● [オーバーライド]:横に項目が並ぶときの空白の幅を取得
  #--------------------------------------------------------------------------
  def spacing
    return 8
  end
  #--------------------------------------------------------------------------
  # ● [追加]:X 座標をアクターに合わせる
  #--------------------------------------------------------------------------
  def actor_x(actor)
    ax = $game_party.members_screen_x_nooffset[actor.index] - self.width / 2
    pad = LNX11::STATUS_SIDE_PADDING / 2
    # 画面内に収める
    self.x = [[ax, pad].max, Graphics.width - pad - self.width].min
    self.x += LNX11::ACTOR_COMMAND_OFFSET[:x]
  end
  #--------------------------------------------------------------------------
  # ● [追加]:Y 座標をアクターに合わせる
  #--------------------------------------------------------------------------
  def actor_y(actor)
    self.y = actor.screen_y_top - self.height
    self.y += LNX11::ACTOR_COMMAND_OFFSET[:y]
  end
  #--------------------------------------------------------------------------
  # ● [追加]:固定 Y 座標
  #--------------------------------------------------------------------------
  def screen_y
    if LNX11::ACTOR_COMMAND_Y_POSITION == 0
      self.y = Graphics.height - self.height + LNX11::ACTOR_COMMAND_OFFSET[:y]
    else
      self.y = LNX11::ACTOR_COMMAND_OFFSET[:y]
    end
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:セットアップ
  #--------------------------------------------------------------------------
  alias :lnx11a_setup :setup
  def setup(actor)
    # 前のアクターのコマンドを記憶
    @actor.last_actor_command = @list[index] if @actor
    # 元のメソッドを呼ぶ
    lnx11a_setup(actor)
    self.arrows_visible = !LNX11::ACTOR_COMMAND_NOSCROLL
    self.height = window_height
    self.oy = 0
    # アクターコマンドの表示位置で分岐
    case LNX11::ACTOR_COMMAND_POSITION
    when 0
      # アクターの頭上
      actor_x(actor)
      actor_y(actor)
    when 1
      # Y 座標固定
      actor_x(actor)
      screen_y
    when 2
      # XY固定
      self.x = LNX11::ACTOR_COMMAND_OFFSET[:x]
      screen_y
    end
    # 最後に選択したコマンドを選択
    return unless LNX11::LAST_ACTOR_COMMAND
    last_command = @actor.last_actor_command
    if last_command && @list.include?(last_command)
      select(@list.index(last_command))
    end
  end
end
