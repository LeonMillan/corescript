
#==============================================================================
# ■ [追加]:Sprite_PopupBase
#------------------------------------------------------------------------------
# 　戦闘中のダメージ表示等をポップアップ表示するためのスプライトの
# スーパークラス。サブクラスで細かい動きを定義します。
#==============================================================================

class Sprite_PopupBase < Sprite
  #--------------------------------------------------------------------------
  # ● クラス変数
  #--------------------------------------------------------------------------
  @@cache_number = []
  @@cache_text   = {}
  @@w = []
  @@h = []
  @@priority = 0
  @@count    = 0
  @@buf_bitmap = nil
  #--------------------------------------------------------------------------
  # ● 定数
  #--------------------------------------------------------------------------
  NUMBER_COLOR_SIZE = 8
  NUMBERS    = [0,1,2,3,4,5,6,7,8,9]
  COLOR_KEYS = LNX11::POPUP_COLOR.keys
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #     data : ポップアップデータ
  #--------------------------------------------------------------------------
  def initialize(data = nil)
    if data == nil || !data.battler.battle_member?
      # 非表示のポップアップ
      super(nil)
      @remove = true
      return
    end
    # ポップアップデータを適用
    super(data.viewport)
    @battler = data.battler # ポップアップを表示するバトラー
    @delay   = data.delay   # ディレイ(遅延) ※サブクラスによって扱いが違います
    @popup_size = data.popup_size # ポップアップの大きさ 大/小
    # 基本設定
    @duration = 60  # 消え始める時間
    @fadeout  = 16  # 消える速さ
    @rx = ry  = 0   # XY座標
    # Z座標
    @rz = base_z * 128 + priority
    popup_add
    self.visible = false
    # ポップアップデータからビットマップを作成
    if data.popup.is_a?(Numeric)
      # ダメージ値
      self.bitmap = number(data.popup, data.color, data.popup_size, data.deco)
    elsif data.popup.is_a?(String)
      # テキスト
      self.bitmap = text(data.popup, data.color,
                         data.popup_size, data.buff_data)
    end
    # 位置設定
    self.ox = self.width  / 2
    self.oy = self.height / 2
    set_position
    start
  end
  #--------------------------------------------------------------------------
  # ● 解放
  #--------------------------------------------------------------------------
  def dispose
    popup_remove
    terminate
    self.bitmap.dispose if self.bitmap
    super
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    return if removed? || delay?
    update_popup
    update_xy
    @duration -= 1
    self.opacity -= @fadeout if @duration <= 0
    dispose if self.opacity == 0
  end
  #--------------------------------------------------------------------------
  # ● 開始処理(サブクラスで定義)
  #--------------------------------------------------------------------------
  def start
  end
  #--------------------------------------------------------------------------
  # ● 終了処理(サブクラスで定義)
  #--------------------------------------------------------------------------
  def terminate
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新(サブクラスで定義)
  #--------------------------------------------------------------------------
  def update_popup
  end
  #--------------------------------------------------------------------------
  # ● ポップアップ Z 座標
  #--------------------------------------------------------------------------
  def base_z
    0
  end
  #--------------------------------------------------------------------------
  # ● ポップアップのプライオリティを返す
  # 　同一Z座標のポップアップで、後から生成されたものが手前に表示されるように
  # Z座標の修正値をクラス変数で管理しています。
  #--------------------------------------------------------------------------
  def priority
    @@priority * 2
  end
  #--------------------------------------------------------------------------
  # ● ポップアップ追加
  #--------------------------------------------------------------------------
  def popup_add
    @@priority += 1
    @@count += 1
  end
  #--------------------------------------------------------------------------
  # ● ポップアップ消去
  #--------------------------------------------------------------------------
  def popup_remove
    @remove = true
    @@count -= 1
    @@priority = 0 if @@count <= 0
  end
  #--------------------------------------------------------------------------
  # ● ディレイが残っている？
  # 　サブクラスの update メソッドで使用します。
  #--------------------------------------------------------------------------
  def delay?
    @delay -= 1
    self.visible = (@delay <= 0)
    !self.visible
  end
  #--------------------------------------------------------------------------
  # ● ポップアップ消去済み？
  #--------------------------------------------------------------------------
  def removed?
    @remove
  end
  #--------------------------------------------------------------------------
  # ● 座標更新
  #--------------------------------------------------------------------------
  def update_xy
    self.x = @rx
    self.y = @ry
    self.z = @rz
  end
  #--------------------------------------------------------------------------
  # ● ポップアップ位置の設定
  #--------------------------------------------------------------------------
  def set_position
    @rx = @battler.screen_x
    if @battler.actor?
      pos = LNX11::ACTOR_POPUP_POSITION
    else
      pos = [LNX11::ENEMY_POPUP_POSITION, 2].min
    end
    case pos
    when 0 ; @ry = @battler.screen_y        # 足元
    when 1 ; @ry = @battler.screen_y_center # 中心
    when 2 ; @ry = @battler.screen_y_top    # 頭上
    when 3 ; @ry = Graphics.height + LNX11::ACTOR_POPUP_Y # Y座標統一(アクター)
    end
  end
  #--------------------------------------------------------------------------
  # ● 描画するテキストの矩形を取得
  #--------------------------------------------------------------------------
  def text_size(str, name, size, bold = false)
    @@buf_bitmap = Bitmap.new(4, 4) if !@@buf_bitmap || @@buf_bitmap.disposed?
    @@buf_bitmap.font.name = name
    @@buf_bitmap.font.size = size
    @@buf_bitmap.font.bold = bold
    return @@buf_bitmap.text_size(str)
  end
  #--------------------------------------------------------------------------
  # ● 数字ビットマップの取得
  #--------------------------------------------------------------------------
  def bitmap_number(size = :large)
    return @@cache_number[size == :large ? 0 : 1]
  end
  #--------------------------------------------------------------------------
  # ● 数字ビットマップキャッシュの作成
  #--------------------------------------------------------------------------
  def create_number
    return if @@cache_number[0] && !@@cache_number[0].disposed?
    n_index = NUMBER_COLOR_SIZE
    @@cache_number.clear
    colors = LNX11::POPUP_COLOR.values # 色
    name = LNX11::NUMBER_FONT
    # 大・小の 2 パターンを作成する(ループ)
    [LNX11::LARGE_NUMBER, LNX11::SMALL_NUMBER].each_with_index do |n_size, i|
      next if get_number(i)
      size = n_size[:fontsize]
      # 数字の幅・高さ
      w = NUMBERS.collect{|n| text_size(n.to_s, name, size).width}.max + 4
      nh = NUMBERS.collect{|n| text_size(n.to_s, name, size).height}.max
      h = n_size[:line_height]
      @@w[i] = w
      @@h[i] = h
      # ビットマップ作成
      bitmap = Bitmap.new(w * NUMBERS.size, h * [colors.size, n_index].min)
      bitmap.font.name = LNX11::NUMBER_FONT
      bitmap.font.size = n_size[:fontsize]
      y = ((h - nh) / 2) - 1
      # 色ごとに分けて描画する(ループ)
      n_index.times do |col|
        # 色を変更
        bitmap.font.color.set(colors[col][0])
        bitmap.font.out_color.set(colors[col][1])
        # 文字ごとに分けて描画(ループ)
        NUMBERS.size.times do |num|
          bitmap.draw_text(num * w, (col * h) + y, w, nh, NUMBERS[num], 2)
        end
      end
      @@cache_number.push(bitmap)
    end
    p "LNX11a:数字ビットマップのキャッシュを作成しました。"
    # 数字ビットマップを表示する(テスト用)
    # s = Sprite.new
    # s.z = 1000000
    # s.bitmap = @@cache_number[1] # 0 or 1
    # loop do Graphics.update end
  end
  #--------------------------------------------------------------------------
  # ● 数字ビットマップの取得
  #--------------------------------------------------------------------------
  def get_number(i)
    case i
    when 0 # 大
      return false if LNX11::LARGE_NUMBER_NAME.empty?
      bitmap = Cache.system(LNX11::LARGE_NUMBER_NAME)
    when 1 # 小
      return false if LNX11::SMALL_NUMBER_NAME.empty?
      bitmap = Cache.system(LNX11::SMALL_NUMBER_NAME)
    end
    @@cache_number.push(bitmap)
    @@w[i] = bitmap.width / NUMBERS.size
    @@h[i] = bitmap.height / NUMBER_COLOR_SIZE
    true
  end
  #--------------------------------------------------------------------------
  # ● ダメージ数を描画したビットマップの取得
  #--------------------------------------------------------------------------
  def number(num, color, size = :large, deco = nil)
    # 数値を文字列の配列にする
    numbers = (num.abs.to_s).split(//)
    # 色番号を取得
    color_index = COLOR_KEYS.index(color)
    # ポップアップサイズを設定
    n_bitmap = bitmap_number(size)
    if size == :large
      n_size = LNX11::LARGE_NUMBER
      i = 0
    else
      n_size = LNX11::SMALL_NUMBER
      i = 1
    end
    spacing = n_size[:spacing]
    w = @@w[i]
    h = @@h[i]
    # ダメージ値のビットマップサイズ
    @bw = w * numbers.size + spacing * (numbers.size - 1)
    @bh = h
    # 修飾文字の描画
    @offset_x = @offset_y = 0
    text_bitmap = deco_text(deco,color,n_size[:fontsize]) if deco[1] >= 0
    # ビットマップを作成
    bitmap = Bitmap.new(@bw, @bh)
    # 塗りつぶし(テスト用)
    # bitmap.fill_rect(bitmap.rect, Color.new(0,0,0,128))
    # ダメージ値を描画
    rect = Rect.new(0, h * color_index, w, h)
    numbers.size.times do |n|
      rect.x = numbers[n].to_i * w
      bitmap.blt(w * n + spacing * n + @offset_x, @offset_y, n_bitmap, rect)
    end
    # 修飾文字の描画をコールバック
    @decoblt.call(bitmap) if @decoblt
    @decoblt = nil
    # ビットマップを返す
    bitmap
  end
  #--------------------------------------------------------------------------
  # ● 修飾文字の描画
  #--------------------------------------------------------------------------
  def deco_text(deco, color, sizerate)
    # 元の幅・高さ
    ow = @bw
    oh = @bh
    case deco[1]
    when 2 # ダメージ値の下
      # テキストのビットマップを取得
      size = decosize(deco[0], sizerate, :top_bottom)
      text_bitmap = text(deco[0], color, size)
      # テキストの幅・高さ
      tw = text_bitmap.width
      th = text_bitmap.height * 0.8
      # 最終的なビットマップのサイズ
      @bw = [@bw, tw].max
      @bh += th
      # ダメージ値の描画位置の修正
      @offset_x = (@bw - ow) / 2
      @offset_y = 0
      # 修飾文字の描画位置を設定
      x = (@bw - tw) / 2
      y = oh * 0.8
    when 4 # ダメージ値の左
      # テキストのビットマップを取得
      size = decosize(deco[0], sizerate, :left_right)
      text_bitmap = text(deco[0], color, size)
      # テキストの幅・高さ
      tw = text_bitmap.width
      th = text_bitmap.height
      # 最終的なビットマップのサイズ
      @bw += tw
      @bh = [@bh, th].max
      # ダメージ値の描画位置の修正
      @offset_x = tw
      @offset_y = (@bh - oh) / 2
      # 修飾文字の描画位置を設定
      x = 2
      y = (@bh - th) / 2
    when 6 # ダメージ値の右
      # テキストのビットマップを取得
      size = decosize(deco[0], sizerate, :left_right)
      text_bitmap = text(deco[0], color, size)
      # テキストの幅・高さ
      tw = text_bitmap.width
      th = text_bitmap.height
      # 最終的なビットマップのサイズ
      @bw += tw
      @bh = [@bh, th].max
      # ダメージ値の描画位置の修正
      @offset_x = 0
      @offset_y = (@bh - oh) / 2
      # 修飾文字の描画位置を設定
      x = ow
      y = (@bh - th) / 2
    when 8 # ダメージ値の上
      # テキストのビットマップを取得
      size = decosize(deco[0], sizerate, :top_bottom)
      text_bitmap = text(deco[0], color, size)
      # テキストの幅・高さ
      tw = text_bitmap.width
      th = text_bitmap.height * 0.8
      # 最終的なビットマップのサイズ
      @bw = [@bw, tw].max
      @bh += th
      # ダメージ値の描画位置の修正
      @offset_x = (@bw - ow) / 2
      @offset_y = @bh - oh
      # 修飾文字の描画位置を設定
      x = (@bw - tw) / 2
      y = 0
    end
    # 修飾文字の描画(コールバック)
    @decoblt = Proc.new {|bitmap|
    bitmap.blt(x, y, text_bitmap, text_bitmap.rect)
    text_bitmap.dispose}
    return text_bitmap
  end
  #--------------------------------------------------------------------------
  # ● 修飾文字のサイズ
  #--------------------------------------------------------------------------
  def decosize(text, size, pos)
    if text.length != text.bytesize
      return size * LNX11::TEXT_SIZERATE[pos] * LNX11::TEXT_SIZERATE_MCS
    else
      return size * LNX11::TEXT_SIZERATE[pos]
    end
  end
  #--------------------------------------------------------------------------
  # ● テキストを描画したビットマップの取得
  # 　ステートやダメージ値の修飾文字の描画に使用します。
  #--------------------------------------------------------------------------
  def text(text, color, size = :large, buff_data = [-1, -1])
    # キャッシュがあればそれを返す(無ければ作成)
    key = text + color.to_s + size.to_s
    if @@cache_text[key] && !@@cache_text[key].disposed?
      return @@cache_text[key].clone
    end
    # 用語の置き換え
    text.gsub!("\hp") { Vocab::hp_a } if text.include?("\hp")
    text.gsub!("\mp") { Vocab::mp_a } if text.include?("\mp")
    text.gsub!("\tp") { Vocab::tp_a } if text.include?("\tp")
    # <<ver1.10>> テキストの頭に _ があれば対応する画像ファイルを参照する
    if text[/^[\_]./]
      bitmap = get_text_bitmap(text, color, size)
      # キャッシュに保存
      @@cache_text[key] = bitmap
      # ビットマップを返す
      return bitmap.clone
    end
    # <<ver1.10>>
    # 能力強化/弱体のポップアップで、ファイル名が指定されていればそれを返す
    if buff_data[0] >= 0 &&
      (size == :large && !LNX11::LARGE_BUFFS_NAME.empty?) ||
      (size == :small && !LNX11::SMALL_BUFFS_NAME.empty?)
      bitmap = get_buff_bitmap(buff_data, size)
      # キャッシュに保存
      @@cache_text[key] = bitmap
      # ビットマップを返す
      return bitmap.clone
    end
    # テキストにマルチバイト文字があれば日本語用フォントを使う
    if text.length != text.bytesize
      fontname = LNX11::TEXT_FONT_MCS
      sizerate = LNX11::TEXT_SIZERATE[:normal] * LNX11::TEXT_SIZERATE_MCS
    else
      fontname = LNX11::TEXT_FONT
      sizerate = LNX11::TEXT_SIZERATE[:normal]
    end
    # ポップアップサイズを設定
    case size
    when :large ; fontsize = LNX11::LARGE_NUMBER[:fontsize] * sizerate
    when :small ; fontsize = LNX11::SMALL_NUMBER[:fontsize] * sizerate
    else        ; fontsize = size
    end
    # テキストサイズ計算
    rect = text_size(text, fontname, fontsize)
    rect.width += 2
    # ビットマップを作成
    bitmap = Bitmap.new(rect.width, rect.height)
    # 塗りつぶし(テスト用)
    # bitmap.fill_rect(bitmap.rect, Color.new(0,0,0,128))
    # フォント設定
    bitmap.font.name = fontname
    bitmap.font.size = fontsize
    bitmap.font.color.set(LNX11::POPUP_COLOR[color][0])
    bitmap.font.out_color.set(LNX11::POPUP_COLOR[color][1])
    # テキスト描画
    bitmap.draw_text(rect, text, 1)
    # キャッシュに保存
    @@cache_text[key] = bitmap
    # ビットマップを返す
    bitmap.clone
  end
  #--------------------------------------------------------------------------
  # ● 能力強化/弱体ビットマップの取得 <<ver1.10>>
  #--------------------------------------------------------------------------
  def get_buff_bitmap(buff_data, size)
    case size
    when :large ; src_bitmap = Cache.system(LNX11::LARGE_BUFFS_NAME)
    when :small ; src_bitmap = Cache.system(LNX11::SMALL_BUFFS_NAME)
    end
    src_rect = Rect.new
    src_rect.width  = src_bitmap.width  / 2
    src_rect.height = src_bitmap.height / 12
    src_rect.x = (buff_data[0] / 4) * src_rect.width
    src_rect.y = (buff_data[0] % 4) * src_rect.height * 3 +
                  buff_data[1] * src_rect.height
    bitmap = Bitmap.new(src_rect.width, src_rect.height)
    bitmap.blt(0, 0, src_bitmap, src_rect)
    bitmap
  end
  #--------------------------------------------------------------------------
  # ● テキストビットマップの取得 <<ver1.10>>
  #--------------------------------------------------------------------------
  def get_text_bitmap(text, color, size)
    # クリティカルカラーかつ、弱点/耐性なら参照するビットマップを変更
    if LNX11::POPUP_COLOR[color] == LNX11::POPUP_COLOR[:critical] &&
      (text == LNX11::DECORATION_NUMBER[:weakness][0] ||
       text == LNX11::DECORATION_NUMBER[:resist][0])
      # ファイル名に _critcolor を加える
      text += "_critcolor"
    end
    # MPダメージ/回復(符号なし)なら参照するビットマップを変更
    if text == LNX11::DECORATION_NUMBER[:mp_damage][0]
      # カラーに応じてファイル名を変更
      case LNX11::POPUP_COLOR[color]
      when LNX11::POPUP_COLOR[:mp_damage]   ; text += "_damage"
      when LNX11::POPUP_COLOR[:mp_recovery] ; text += "_recovery"
      end
    end
    # popup_xxxxxx_(large or small)
    Cache.system("popup" + text + (size == :large ? "_large" : "_small"))
  end
end
