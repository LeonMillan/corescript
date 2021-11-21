
#==============================================================================
# ■ Window_BattleStatus
#------------------------------------------------------------------------------
# 　バトル画面で、パーティメンバーのステータスを表示するウィンドウです。
#==============================================================================

class Window_BattleStatus < Window_Selectable
  #--------------------------------------------------------------------------
  # ● [追加]:公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader :min_offset   # ステータス描画 X 座標の位置修正
  #--------------------------------------------------------------------------
  # ● [エイリアス]:オブジェクト初期化
  #--------------------------------------------------------------------------
  alias :lnx11a_initialize :initialize
  def initialize
    @actor_last_status = Array.new($game_party.max_battle_members) { nil }
    # 元のメソッドを呼ぶ
    lnx11a_initialize
    # ウィンドウを最初から表示
    self.openness = 255
    self.opacity = 0
    update_invisible
  end
  #--------------------------------------------------------------------------
  # ● [オーバーライド]:行の高さを取得
  #--------------------------------------------------------------------------
  def line_height
    return LNX11::STATUS_LINE_HEIGHT
  end
  #--------------------------------------------------------------------------
  # ● [オーバーライド]:標準パディングサイズの取得
  #--------------------------------------------------------------------------
  def standard_padding
    return 0
  end
  #--------------------------------------------------------------------------
  # ● [オーバーライド]:表示行数の取得
  #--------------------------------------------------------------------------
  def visible_line_number
    return $data_system.opt_display_tp ? 4 : 3
  end
  #--------------------------------------------------------------------------
  # ● [オーバーライド]:桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    return [item_max, 1].max
  end
  #--------------------------------------------------------------------------
  # ● [オーバーライド]:横に項目が並ぶときの空白の幅を取得
  #--------------------------------------------------------------------------
  def spacing
    return 0
  end
  #--------------------------------------------------------------------------
  # ● [オーバーライド]:項目の高さを取得
  #--------------------------------------------------------------------------
  def item_height
    self.height
  end
  #--------------------------------------------------------------------------
  # ● [再定義]:ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:ウィンドウ高さの取得
  #--------------------------------------------------------------------------
  alias :lnx11a_window_height :window_height
  def window_height
    # 一行目(名前・ステート)の高さを確保する
    lnx11a_window_height - line_height + [24, line_height].max
  end
  #--------------------------------------------------------------------------
  # ● [オーバーライド]:カーソルの更新
  #--------------------------------------------------------------------------
  def update_cursor
    # カーソルを表示しない
    cursor_rect.empty
  end
  #--------------------------------------------------------------------------
  # ● [オーバーライド]:システム色の取得
  # 　ゲージ幅が短すぎる場合、HP,MP,TP の文字を非表示にします。
  #--------------------------------------------------------------------------
  def system_color
    gauge_area_width - @min_offset >= 52 ? super : Color.new
  end
  #--------------------------------------------------------------------------
  # ● [オーバーライド]:ゲージ背景色の取得
  #   ゲージの透明度を適用します。
  #--------------------------------------------------------------------------
  def gauge_back_color
    color = super
    color.alpha *= LNX11::STATUS_GAUGE_OPACITY / 255.0
    color
  end
  #--------------------------------------------------------------------------
  # ● [オーバーライド]:ゲージの描画
  #   ゲージの透明度を適用します。
  #--------------------------------------------------------------------------
  def draw_gauge(x, y, width, rate, color1, color2)
    oparate = LNX11::STATUS_GAUGE_OPACITY / 255.0
    color1.alpha *= oparate
    color2.alpha *= oparate
    super
  end
  #--------------------------------------------------------------------------
  # ● [オーバーライド]:フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    update_invisible
  end
  #--------------------------------------------------------------------------
  # ● [追加]:表示状態更新
  #--------------------------------------------------------------------------
  def update_invisible
    self.contents_opacity = $game_party.status_invisible ? 0 : 255
  end
  #--------------------------------------------------------------------------
  # ● [追加]:アクターオブジェクト取得
  #--------------------------------------------------------------------------
  def actor
    $game_party.members[@index]
  end
  #--------------------------------------------------------------------------
  # ● [追加]:座標の設定
  #--------------------------------------------------------------------------
  def set_xy
    # ステータス位置の調整:画面からはみ出ないようにする
    pw = $game_party.members_screen_x.last + LNX11::STATUS_OFFSET[:x]
    pw += gauge_area_width / 2
    right_end = Graphics.width - LNX11::STATUS_SIDE_PADDING
    min_offset = pw > right_end ? pw - right_end : 0
    # ステータスのオフセットを適用
    self.x = LNX11::STATUS_OFFSET[:x] - min_offset
    self.y = LNX11::STATUS_OFFSET[:y] + Graphics.height - self.height
    # ステータス幅の自動調整:位置を調整した分だけ幅を縮める
    @min_offset = LNX11::STATUS_AUTOADJUST ? min_offset : 0
  end
  #--------------------------------------------------------------------------
  # ● [再定義]:ゲージエリアの幅を取得
  #--------------------------------------------------------------------------
  def gauge_area_width
    return LNX11::STATUS_WIDTH
  end
  #--------------------------------------------------------------------------
  # ● [追加]:表示するステート数の取得
  #--------------------------------------------------------------------------
  def states(actor, width)
    icons = (actor.state_icons + actor.buff_icons)[0, width / 24]
    icons.size
  end
  #--------------------------------------------------------------------------
  # ● [追加]:名前とステートの描画(1行表示)
  # 　width の範囲で名前を左揃え、ステートアイコンを右揃えで描画します。
  # ステートを優先して表示するため、アイコンが多すぎて名前の表示領域が
  # 極端に狭くなる場合は名前を描画しません。
  #--------------------------------------------------------------------------
  def draw_actor_name_with_icons(actor, x, y, width = 128, draw_name = true)
    # アイコンのY座標補正
    iy = ([line_height, 24].max - 24) / 2
    # 名前のY座標補正
    ny = ([line_height, 24].max - LNX11::STATUS_NAME_SIZE) / 2
    # 表示するステート数を取得
    icon = states(actor, width)
    if icon > 0
      # 表示するべきステートがある場合
      name_width = width - icon * 24
      ix = x + width - icon * 24
      if name_width >= contents.font.size * 2 && draw_name
        # 名前の表示領域(width) が フォントサイズ * 2 以上なら両方を描画
        draw_actor_name(actor, x, y + ny,  name_width)
        iw = width - name_width
        draw_actor_icons(actor, ix, y + iy, iw)
      else
        # ステートのみ描画
        draw_actor_icons(actor, ix, y + iy, width)
      end
    elsif draw_name
      # ない場合、名前のみ描画
      draw_actor_name(actor, x, y + ny, width)
    end
  end
  #--------------------------------------------------------------------------
  # ● [再定義]:リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    set_xy
    draw_all_items
  end
  #--------------------------------------------------------------------------
  # ● [オーバーライド]:項目を描画する矩形の取得
  #--------------------------------------------------------------------------
  def item_rect(index)
    rect = super
    rect.x = $game_party.members_screen_x[index] - gauge_area_width / 2
    rect.width = gauge_area_width
    rect
  end
  #--------------------------------------------------------------------------
  # ● [再定義]:基本エリアの矩形を取得
  #--------------------------------------------------------------------------
  def basic_area_rect(index)
    rect = item_rect(index)
    rect
  end
  #--------------------------------------------------------------------------
  # ● [再定義]:ゲージエリアの矩形を取得
  #--------------------------------------------------------------------------
  def gauge_area_rect(index)
    rect = basic_area_rect(index)
    rect.y += [24, line_height].max
    rect.x += @min_offset
    rect
  end
  #--------------------------------------------------------------------------
  # ● [再定義]:基本エリアの描画
  #--------------------------------------------------------------------------
  def draw_basic_area(rect, actor)
    # フォントサイズ変更
    contents.font.size = [LNX11::STATUS_NAME_SIZE, 8].max
    # 名前とステートを描画
    dn = LNX11::STATUS_NAME_SIZE > 0 # 名前を描画するか？
    width = gauge_area_width - @min_offset
    rest  = width % 24
    width += 24 - rest if rest > 0
    draw_actor_name_with_icons(actor, rect.x, rect.y, width, dn)
    # フォントサイズを元に戻す
    reset_font_settings
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:ゲージエリアの描画
  #--------------------------------------------------------------------------
  alias :lnx11a_draw_gauge_area :draw_gauge_area
  def draw_gauge_area(*args)
    # フォントサイズ変更
    contents.font.size = LNX11::STATUS_PARAM_SIZE
    # 元のメソッドを呼ぶ
    lnx11a_draw_gauge_area(*args)
    # フォントサイズを元に戻す
    reset_font_settings
  end
  #--------------------------------------------------------------------------
  # ● [再定義]:ゲージエリアの描画（TP あり）
  #--------------------------------------------------------------------------
  def draw_gauge_area_with_tp(rect, actor)
    width = gauge_area_width - @min_offset
    draw_actor_hp(actor, rect.x, rect.y,                   width)
    draw_actor_mp(actor, rect.x, rect.y + line_height,     width)
    draw_actor_tp(actor, rect.x, rect.y + line_height * 2, width)
  end
  #--------------------------------------------------------------------------
  # ● [再定義]:ゲージエリアの描画（TP なし）
  #--------------------------------------------------------------------------
  def draw_gauge_area_without_tp(rect, actor)
    draw_actor_hp(actor, rect.x, rect.y,               gauge_area_width)
    draw_actor_mp(actor, rect.x, rect.y + line_height, gauge_area_width)
  end
  #--------------------------------------------------------------------------
  # ● [再定義]:項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    actor = $game_party.battle_members[index]
    a_status = status(actor)
    # ステータスが変化した場合のみ描画する
    return if @actor_last_status[index] == a_status
    @actor_last_status[index] = a_status
    contents.clear_rect(item_rect(index))
    draw_basic_area(basic_area_rect(index), actor)
    draw_gauge_area(gauge_area_rect(index), actor)
  end
  #--------------------------------------------------------------------------
  # ● [追加]:アクターのステータス配列を返す
  #--------------------------------------------------------------------------
  def status(actor)
    if $data_system.opt_display_tp
      return [actor.name, actor.state_icons + actor.buff_icons,
              actor.mhp, actor.hp, actor.mmp, actor.mp, actor.max_tp, actor.tp]
    else
      # TP を除くステータス配列
      return [actor.name, actor.state_icons + actor.buff_icons,
              actor.mhp, actor.hp, actor.mmp, actor.mp]
    end
  end
  #--------------------------------------------------------------------------
  # ● [追加]:内容の消去
  #--------------------------------------------------------------------------
  def all_clear
    contents.clear
    @actor_last_status = Array.new($game_party.max_battle_members) { nil }
  end
end
