
#==============================================================================
# ■ Sprite_Battler
#------------------------------------------------------------------------------
# 　バトラー表示用のスプライトです。
#==============================================================================

class Sprite_Battler < Sprite_Base
  #--------------------------------------------------------------------------
  # ● [追加]:ターゲットカーソルのバトラーの取得
  #--------------------------------------------------------------------------
  def cursor_battler
    $game_temp.target_cursor_sprite.battler
  end
  #--------------------------------------------------------------------------
  # ● [追加]:ターゲットカーソルの点滅状態に対応したシンボルを返す
  #--------------------------------------------------------------------------
  def cursor_effect
    $game_temp.target_cursor_sprite.blink ? :target_whiten : :command_whiten
  end
  #--------------------------------------------------------------------------
  # ● [追加]:対象選択フラッシュの設定
  #--------------------------------------------------------------------------
  def setup_cursor_effect
    if cursor_battler == @battler ||
       (cursor_battler == :party && @battler.actor?) ||
       ([:troop, :troop_random].include?(cursor_battler) && !@battler.actor?)
      if @effect_type == nil || @effect_type != cursor_effect
        start_effect(cursor_effect)
      end
    else
      # フラッシュエフェクト終了
      end_cursor_effect
    end
  end
  #--------------------------------------------------------------------------
  # ● [追加]:対象選択フラッシュの終了
  #--------------------------------------------------------------------------
  def end_cursor_effect
    if [:target_whiten, :command_whiten].include?(@effect_type)
      @effect_type = nil
      @effect_duration = 0
      revert_to_normal
    end
  end
  #--------------------------------------------------------------------------
  # ● [オーバーライド]:アニメーションスプライトの設定
  #--------------------------------------------------------------------------
  def animation_set_sprites(frame)
    o = self.opacity
    self.opacity = 255 if !@battler_visible || @effect_duration > 0
    # スーパークラスのメソッドを呼ぶ
    super(frame)
    self.opacity = o
  end
  #--------------------------------------------------------------------------
  # ● [オーバーライド]:アニメーションの原点設定
  #--------------------------------------------------------------------------
  def set_animation_origin
    # スーパークラスのメソッドを呼ぶ
    super
    # 画面アニメーションがアクターに再生されたら
    if @animation.position == 3 && @battler != nil && @battler.actor?
      # アニメーションのY座標を修正
      @ani_oy += LNX11::SCREEN_ANIMATION_OFFSET
    end
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:転送元ビットマップの更新
  #--------------------------------------------------------------------------
  alias :lnx11a_update_bitmap :update_bitmap
  def update_bitmap
    if @battler.actor? && @battler.refresh_battler_graphic
      # バトラーグラフィックが変更されていれば更新する
      @battler.update_battler_graphic
    end
    if @battler.actor? && @battler.facebattler != nil
      # バトラー用顔グラフィックが作成されていれば、
      # それを Sprite の Bitmap とする
      new_bitmap = @battler.facebattler
      if bitmap != new_bitmap
        self.bitmap = new_bitmap
        init_visibility
      end
    else
      # 元のメソッドを呼ぶ
      lnx11a_update_bitmap
    end
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:新しいアニメーションの設定
  #--------------------------------------------------------------------------
  alias :lnx11a_setup_new_animation :setup_new_animation
  def setup_new_animation
    lnx11a_setup_new_animation
    # ループアニメーションの設定
    if @battler.loop_animation_id > 0 && (@loop_animation == nil ||
       @battler.loop_animation_id != @loop_animation.id)
      animation = $data_animations[@battler.loop_animation_id]
      mirror = @battler.loop_animation_mirror
      start_loop_animation(animation, mirror)
    elsif @battler.loop_animation_id == 0 && @loop_animation
      end_loop_animation
    end
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:新しいエフェクトの設定
  #--------------------------------------------------------------------------
  alias :lnx11a_setup_new_effect :setup_new_effect
  def setup_new_effect
    # 元のメソッドを呼ぶ
    lnx11a_setup_new_effect
    # フラッシュエフェクト設定
    if @battler_visible && cursor_battler
      setup_cursor_effect
    else
      # フラッシュエフェクト終了
      end_cursor_effect
    end
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:エフェクトの開始
  #--------------------------------------------------------------------------
  alias :lnx11a_start_effect :start_effect
  def start_effect(effect_type)
    # エフェクト開始の追加
    @effect_type = effect_type
    case @effect_type
    when :target_whiten
      @effect_duration = 40
      @battler_visible = true
    when :command_whiten
      @effect_duration = 80
      @battler_visible = true
    end
    # 元のメソッドを呼ぶ
    lnx11a_start_effect(effect_type)
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:エフェクトの更新
  #--------------------------------------------------------------------------
  alias :lnx11a_update_effect :update_effect
  def update_effect
    # エフェクト更新の追加
    if @effect_duration > 0
      @effect_duration -= 1
      case @effect_type
      when :target_whiten
        update_target_whiten
      when :command_whiten
        update_command_whiten
      end
      @effect_duration += 1
    end
    # 元のメソッドを呼ぶ
    lnx11a_update_effect
  end
  #--------------------------------------------------------------------------
  # ● [追加]:対象選択フラッシュエフェクトの更新
  #--------------------------------------------------------------------------
  def update_target_whiten
    alpha = @effect_duration < 20 ? @effect_duration : 40 - @effect_duration
    self.color.set(255, 255, 255, 0)
    self.color.alpha = (alpha + 1) * 2
  end
  #--------------------------------------------------------------------------
  # ● [追加]:コマンド選択フラッシュエフェクトの更新
  #--------------------------------------------------------------------------
  def update_command_whiten
    alpha = @effect_duration < 40 ? @effect_duration : 80 - @effect_duration
    self.color.set(255, 255, 255, 0)
    self.color.alpha = alpha * 2
  end
  #--------------------------------------------------------------------------
  # ● [追加]:高さの取得
  #--------------------------------------------------------------------------
  def bitmap_height
    self.bitmap.height
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:位置の更新
  #--------------------------------------------------------------------------
  alias :lnx11a_update_position :update_position
  def update_position
    # 元のメソッドを呼ぶ
    lnx11a_update_position
    # 高さを更新
    @battler.bitmap_height = bitmap_height
    # 可視状態を更新
    self.visible = !$game_party.actor_invisible if @battler.actor?
  end
  if LNX11::ENHANCED_WHITEN
    # 白フラッシュを強めにする
    #------------------------------------------------------------------------
    # ● [再定義]:白フラッシュエフェクトの更新
    #------------------------------------------------------------------------
    def update_whiten
      self.color.set(255, 255, 255, 0)
      self.color.alpha = 192 - (16 - @effect_duration) * 12
    end
  end
  #--------------------------------------------------------------------------
  # ● ループアニメーションの追加
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  # ● [追加]:クラス変数
  #--------------------------------------------------------------------------
  @@loop_ani_checker = []
  @@loop_ani_spr_checker = []
  #--------------------------------------------------------------------------
  # ● [エイリアス]:オブジェクト初期化
  #--------------------------------------------------------------------------
  alias :lnx11a_initialize :initialize
  def initialize(viewport, battler = nil)
    # 元のメソッドを呼ぶ
    lnx11a_initialize(viewport, battler)
    # ループアニメの残り時間
    @loop_ani_duration = 0
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:解放
  #--------------------------------------------------------------------------
  alias :lnx11a_dispose :dispose
  def dispose
    # 元のメソッドを呼ぶ
    lnx11a_dispose
    # ループアニメを解放
    dispose_loop_animation
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:フレーム更新
  #--------------------------------------------------------------------------
  alias :lnx11a_update :update
  def update
    # 元のメソッドを呼ぶ
    lnx11a_update
    update_loop_animation
    @@loop_ani_checker.clear
    @@loop_ani_spr_checker.clear
  end
  #--------------------------------------------------------------------------
  # ● [追加]:ループアニメーション表示中判定
  #--------------------------------------------------------------------------
  def loop_animation?
    @loop_animation != nil
  end
  #--------------------------------------------------------------------------
  # ● [追加]:ループアニメーションの開始
  #--------------------------------------------------------------------------
  def start_loop_animation(animation, mirror = false)
    dispose_loop_animation
    @loop_animation = animation
    if @loop_animation
      @loop_ani_mirror = mirror
      set_loop_animation_rate
      @loop_ani_duration = @loop_animation.frame_max * @loop_ani_rate + 1
      load_loop_animation_bitmap
      make_loop_animation_sprites
      set_loop_animation_origin
    end
  end
  #--------------------------------------------------------------------------
  # ● [追加]:ループアニメーションの速度を設定
  #--------------------------------------------------------------------------
  def set_loop_animation_rate
    if $lnx_include[:lnx09]
      # LNX09 を導入している
      default = LNX09::DEFAULT_BATTLE_SPEED_RATE
      if @loop_animation.speed_rate
        @loop_ani_rate = @loop_animation.speed_rate
      else
        @loop_ani_rate = default
      end
    else
      @loop_ani_rate = 4
    end
  end
  #--------------------------------------------------------------------------
  # ● [追加]:ループアニメーション グラフィックの読み込み
  #--------------------------------------------------------------------------
  def load_loop_animation_bitmap
    animation1_name = @loop_animation.animation1_name
    animation1_hue = @loop_animation.animation1_hue
    animation2_name = @loop_animation.animation2_name
    animation2_hue = @loop_animation.animation2_hue
    @loop_ani_bitmap1 = Cache.animation(animation1_name, animation1_hue)
    @loop_ani_bitmap2 = Cache.animation(animation2_name, animation2_hue)
    if @@_reference_count.include?(@loop_ani_bitmap1)
      @@_reference_count[@loop_ani_bitmap1] += 1
    else
      @@_reference_count[@loop_ani_bitmap1] = 1
    end
    if @@_reference_count.include?(@loop_ani_bitmap2)
      @@_reference_count[@loop_ani_bitmap2] += 1
    else
      @@_reference_count[@loop_ani_bitmap2] = 1
    end
    Graphics.frame_reset
  end
  #--------------------------------------------------------------------------
  # ● [追加]:ループアニメーションスプライトの作成
  #--------------------------------------------------------------------------
  def make_loop_animation_sprites
    @loop_ani_sprites = []
    if @use_sprite && !@@loop_ani_spr_checker.include?(@loop_animation)
      16.times do
        sprite = ::Sprite.new(viewport)
        sprite.visible = false
        @loop_ani_sprites.push(sprite)
      end
      if @loop_animation.position == 3
        @@loop_ani_spr_checker.push(@loop_animation)
      end
    end
    @loop_ani_duplicated = @@loop_ani_checker.include?(@loop_animation)
    if !@loop_ani_duplicated && @loop_animation.position == 3
      @@loop_ani_checker.push(@loop_animation)
    end
  end
  #--------------------------------------------------------------------------
  # ● [追加]:ループアニメーションの原点設定
  #--------------------------------------------------------------------------
  def set_loop_animation_origin
    if @loop_animation.position == 3
      if viewport == nil
        @loop_ani_ox = Graphics.width / 2
        @loop_ani_oy = Graphics.height / 2
      else
        @loop_ani_ox = viewport.rect.width / 2
        @loop_ani_oy = viewport.rect.height / 2
      end
    else
      @loop_ani_ox = x - ox + width / 2
      @loop_ani_oy = y - oy + height / 2
      if @loop_animation.position == 0
        @loop_ani_oy -= height / 2
      elsif @loop_animation.position == 2
        @loop_ani_oy += height / 2
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● [追加]:ループアニメーションの解放
  #--------------------------------------------------------------------------
  def dispose_loop_animation
    if @loop_ani_bitmap1
      @@_reference_count[@loop_ani_bitmap1] -= 1
      if @@_reference_count[@loop_ani_bitmap1] == 0
        @loop_ani_bitmap1.dispose
      end
    end
    if @loop_ani_bitmap2
      @@_reference_count[@loop_ani_bitmap2] -= 1
      if @@_reference_count[@loop_ani_bitmap2] == 0
        @loop_ani_bitmap2.dispose
      end
    end
    if @loop_ani_sprites
      @loop_ani_sprites.each {|sprite| sprite.dispose }
      @loop_ani_sprites = nil
      @loop_animation = nil
    end
    @loop_ani_bitmap1 = nil
    @loop_ani_bitmap2 = nil
  end
  #--------------------------------------------------------------------------
  # ● [追加]:ループアニメーションの更新
  #--------------------------------------------------------------------------
  def update_loop_animation
    return unless loop_animation?
    @loop_ani_duration -= 1
    if @loop_ani_duration % @loop_ani_rate == 0
      if @loop_ani_duration > 0
        frame_index = @loop_animation.frame_max
        speed = (@loop_ani_duration + @loop_ani_rate - 1) / @loop_ani_rate
        frame_index -= speed
        loop_animation_set_sprites(@loop_animation.frames[frame_index])
        @loop_animation.timings.each do |timing|
          loop_animation_process_timing(timing) if timing.frame == frame_index
        end
      else
        # 残り時間を再設定してループ
        @loop_ani_duration = @loop_animation.frame_max * @loop_ani_rate + 1
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● [追加]:ループアニメーションの終了
  #--------------------------------------------------------------------------
  def end_loop_animation
    dispose_loop_animation
  end
  #--------------------------------------------------------------------------
  # ● [追加]:ループアニメーションスプライトの設定
  #     frame : フレームデータ（RPG::Animation::Frame）
  #--------------------------------------------------------------------------
  def loop_animation_set_sprites(frame)
    cell_data = frame.cell_data
    @loop_ani_sprites.each_with_index do |sprite, i|
      next unless sprite
      pattern = cell_data[i, 0]
      if !pattern || pattern < 0
        sprite.visible = false
        next
      end
      sprite.bitmap = pattern < 100 ? @loop_ani_bitmap1 : @loop_ani_bitmap2
      sprite.visible = true
      sprite.src_rect.set(pattern % 5 * 192,
        pattern % 100 / 5 * 192, 192, 192)
      if @loop_ani_mirror
        sprite.x = @loop_ani_ox - cell_data[i, 1]
        sprite.y = @loop_ani_oy + cell_data[i, 2]
        sprite.angle = (360 - cell_data[i, 4])
        sprite.mirror = (cell_data[i, 5] == 0)
      else
        sprite.x = @loop_ani_ox + cell_data[i, 1]
        sprite.y = @loop_ani_oy + cell_data[i, 2]
        sprite.angle = cell_data[i, 4]
        sprite.mirror = (cell_data[i, 5] == 1)
      end
      sprite.z = self.z + 316 + i
      sprite.ox = 96
      sprite.oy = 96
      sprite.zoom_x = cell_data[i, 3] / 100.0
      sprite.zoom_y = cell_data[i, 3] / 100.0
      sprite.opacity = cell_data[i, 6] * self.opacity / 255.0
      sprite.blend_type = cell_data[i, 7]
    end
  end
  #--------------------------------------------------------------------------
  # ● [追加]:SE とフラッシュのタイミング処理
  #     timing : タイミングデータ（RPG::Animation::Timing）
  #--------------------------------------------------------------------------
  def loop_animation_process_timing(timing)
    timing.se.play unless @loop_ani_duplicated
    case timing.flash_scope
    when 1
      self.flash(timing.flash_color, timing.flash_duration * @loop_ani_rate)
    when 2
      if viewport && !@loop_ani_duplicated
        duration = timing.flash_duration * @loop_ani_rate
        viewport.flash(timing.flash_color, duration)
      end
    when 3
      self.flash(nil, timing.flash_duration * @loop_ani_rate)
    end
  end
end
