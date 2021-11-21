#==============================================================================
# ■ [追加]:Sprite_TargetCursor
#------------------------------------------------------------------------------
# 　対象選択されているバトラーや行動選択中のアクターを示すアローカーソルです。
#==============================================================================
class Sprite_TargetCursor < Sprite
  #--------------------------------------------------------------------------
  # ● クラス変数
  #--------------------------------------------------------------------------
  @@cursor_cache = nil
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :battler     # バトラー
  attr_accessor :blink       # 点滅(対象の選択中)
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(viewport = nil)
    super(viewport)
    @wait = LNX11::CURSOR_ANI_SPEED
    @speed = [LNX11::CURSOR_SPEED, 1].max
    @battler = nil
    @sub_cursor = []
    @blink = false
    self.bitmap = cursor_bitmap
    partition = self.bitmap.width / self.height
    self.src_rect.set(0, 0, self.width / partition, self.height)
    self.ox = self.width / 2
    self.oy = self.height / 2
    self.x = @rx = @tx = 0
    self.y = @ry = @ty = 0
    self.z = 98
    self.visible = false
  end
  #--------------------------------------------------------------------------
  # ● 解放
  #--------------------------------------------------------------------------
  def dispose
    dispose_subcursor
    super
  end
  #--------------------------------------------------------------------------
  # ● サブカーソル作成
  # 　メンバー全体にカーソルを表示するために複数のカーソルを作成します。
  #--------------------------------------------------------------------------
  def create_subcursor(members)
    return unless @sub_cursor.empty?
    members.each_with_index do |battler, i|
      @sub_cursor[i] = Sprite_TargetCursor.new(self.viewport)
      @sub_cursor[i].set(@rx - LNX11::CURSOR_OFFSET[:x],
                         @ry - LNX11::CURSOR_OFFSET[:y])
      @sub_cursor[i].set(battler, true)
    end
  end
  #--------------------------------------------------------------------------
  # ● サブカーソル解放
  #--------------------------------------------------------------------------
  def dispose_subcursor
    @sub_cursor.each {|sprite| sprite.dispose }
    @sub_cursor = []
  end
  #--------------------------------------------------------------------------
  # ● サブカーソル更新
  #--------------------------------------------------------------------------
  def update_subcursor
    @sub_cursor.each {|sprite| sprite.update }
  end
  #--------------------------------------------------------------------------
  # ● ビットマップの設定
  #--------------------------------------------------------------------------
  def cursor_bitmap
    if !LNX11::CURSOR_NAME.empty?
      return Cache.system(LNX11::CURSOR_NAME)
    else
      # カーソルファイル名が指定されていなければRGSS側で生成
      return @@cursor_cache if @@cursor_cache && !@@cursor_cache.disposed?
      @@cursor_cache = Bitmap.new(32, 32)
      color = Color.new(0, 0, 0)
      @@cursor_cache.lnx_cursor_triangle(26, color, 2)
      2.times {@@cursor_cache.blur}
      color.set(255, 255, 255)
      @@cursor_cache.lnx_cursor_triangle(24, color, 1, 0.5)
      tone = LNX11::CURSOR_TONE ? LNX11::CURSOR_TONE : $game_system.window_tone
      r = 118 + tone.red
      g = 118 + tone.green
      b = 118 + tone.blue
      color.set(r, g, b, 232)
      @@cursor_cache.lnx_cursor_triangle(20, color,  0)
      @@cursor_cache.lnx_cursor_triangle(20, color,  1)
      p "LNX11a:カーソルビットマップを作成しました。"
      return @@cursor_cache
    end
  end
  #--------------------------------------------------------------------------
  # ● カーソルの表示
  #--------------------------------------------------------------------------
  def show
    self.x = @rx = @tx
    self.y = @ry = @ty
    self.visible = true
  end
  #--------------------------------------------------------------------------
  # ● カーソルの非表示
  #--------------------------------------------------------------------------
  def hide
    dispose_subcursor
    @battler = nil
    self.visible = false
  end
  #--------------------------------------------------------------------------
  # ● 移動平均
  #--------------------------------------------------------------------------
  def sma(a, b, p)
    # a = 目標位置 b = 現在地
    return a if a == b || (a - b).abs < 0.3 || p == 1
    result = ((a + b * (p.to_f - 1)) / p.to_f)
    return (a - result).abs <= 1.0 ? (b < a ? b + 0.3 : b - 0.3) : result
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    update_subcursor
    self.opacity = @sub_cursor.empty? ? 255 : 0
    return if !visible || !@sub_cursor.empty?
    super
    # 点滅
    if LNX11::CURSOR_BLINK
      self.blend_type = @blink && Graphics.frame_count / 3 % 2 == 0 ? 1 : 0
    end
    # アニメーションを進める
    @wait -= 1
    if @wait <= 0
      @wait += LNX11::CURSOR_ANI_SPEED
      self.src_rect.x += self.width
      self.src_rect.x = 0 if self.src_rect.x >= self.bitmap.width
    end
    # カーソルの座標を更新
    set_xy if @battler && @sub_cursor.empty?
    self.x = @rx = sma(@tx, @rx, @speed)
    self.y = @ry = sma(@ty, @ry, @speed)
  end
  #--------------------------------------------------------------------------
  # ● カーソル位置の設定
  #--------------------------------------------------------------------------
  def set(*args)
    if args[0].is_a?(Numeric)
      # 引数一つ目が数値なら、XY指定
      @battler = nil
      set_xy(args[0], args[1])
      @blink = args[2] ? args[2] : false
    else
      # バトラーorシンボル指定
      if @battler != args[0]
        @battler = args[0]
        dispose_subcursor
        case args[0]
        when :party        ; create_subcursor($game_party.members)
        when :troop        ; create_subcursor($game_troop.alive_members)
        when :troop_random ; create_subcursor($game_troop.alive_members)
        else ; args[0] ? set_xy : hide
        end
      end
      @blink = args[1] ? args[1] : false
    end
    # スピードが1かカーソルが非表示なら表示に変える
    show if @sub_cursor.empty? && (@speed == 1 || !visible)
  end
  #--------------------------------------------------------------------------
  # ● カーソル位置をバトラーの位置に設定
  #--------------------------------------------------------------------------
  def set_xy(x = nil, y = nil)
    if x
      # 直接指定
      x += LNX11::CURSOR_OFFSET[:x]
      y += LNX11::CURSOR_OFFSET[:y]
    else
      # バトラーの座標
      x = @battler.screen_x + LNX11::CURSOR_OFFSET[:x]
      y = @battler.screen_y_top + LNX11::CURSOR_OFFSET[:y]
    end
    @tx = x
    minmax = LNX11::CURSOR_MINMAX
    @ty = [[y, minmax[:min] + self.oy].max, minmax[:max]].min
  end
end
