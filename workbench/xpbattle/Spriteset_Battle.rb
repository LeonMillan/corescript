
#==============================================================================
# ■ Spriteset_Battle
#------------------------------------------------------------------------------
# 　バトル画面のスプライトをまとめたクラスです。
#==============================================================================

class Spriteset_Battle
  #--------------------------------------------------------------------------
  # ● [エイリアス]:オブジェクト初期化
  #--------------------------------------------------------------------------
  alias :lnx11a_initialize :initialize
  def initialize
    # 元のメソッドを呼ぶ
    lnx11a_initialize
    # アクターエリアの背景の作成
    create_actor_background
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:解放
  #--------------------------------------------------------------------------
  alias :lnx11a_dispose :dispose
  def dispose
    # アクターエリアの背景の解放
    dispose_actor_background
    # 元のメソッドを呼ぶ
    lnx11a_dispose
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:フレーム更新
  #--------------------------------------------------------------------------
  alias :lnx11a_update :update
  def update
    # 元のメソッドを呼ぶ
    lnx11a_update
    # アクターエリアの背景の更新
    update_actor_background
  end
  #--------------------------------------------------------------------------
  # ● [追加]:アクターのビューポート
  #--------------------------------------------------------------------------
  def actor_viewport
    LNX11::ACTOR_SCREEN_TONE ? @viewport1 : @viewport2
  end
  #--------------------------------------------------------------------------
  # ● [追加]:アクターエリアの背景の作成
  #--------------------------------------------------------------------------
  def create_actor_background
    return if LNX11::ACTOR_BACKGROUND == 0
    viewport = actor_viewport
    height = LNX11::ACTOR_BACKGROUND_HEIGHT
    case LNX11::ACTOR_BACKGROUND
    when 1
      # グラデーション
      @actor_background = Sprite.new
      back = Bitmap.new(Graphics.width, height)
      color = LNX11::ACTOR_BG_GRADIENT_COLOR
      back.gradient_fill_rect(back.rect, color[0], color[1], true)
      @actor_background.bitmap = back
    when 2
      # ウィンドウ
      @actor_background = Window_Base.new(0, 0, Graphics.width, height)
    else
      if LNX11::ACTOR_BACKGROUND.is_a?(String)
        # ファイル指定
        @actor_background = Sprite.new
        @actor_background.bitmap = Cache.system(LNX11::ACTOR_BACKGROUND)
        @actor_background.x = Graphics.width / 2
        @actor_background.ox = @actor_background.bitmap.width / 2
        height = @actor_background.bitmap.height
      end
    end
    @actor_background.viewport = viewport
    @actor_background.y = Graphics.height - height
    @actor_background.z = viewport == @viewport1 ? 120 : -20
    update_actor_background
  end
  #--------------------------------------------------------------------------
  # ● [追加]:アクターエリアの背景の解放
  #--------------------------------------------------------------------------
  def dispose_actor_background
    return unless @actor_background
    @actor_background.bitmap.dispose if @actor_background.is_a?(Sprite)
    @actor_background.dispose
  end
  #--------------------------------------------------------------------------
  # ● [追加]:アクターエリアの背景の更新
  #--------------------------------------------------------------------------
  def update_actor_background
    return unless @actor_background
    @actor_background.visible = !$game_party.actor_bg_invisible
  end
  #--------------------------------------------------------------------------
  # ● [再定義]:アクタースプライトの作成
  #--------------------------------------------------------------------------
  def create_actors
    # 座標とグラフィックの設定
    $game_party.set_members_xyz
    $game_party.set_members_battle_graphic
    # スプライトの作成
    viewport = actor_viewport
    @actor_sprites = $game_party.battle_members.collect do |actor|
      Sprite_Battler.new(viewport, actor)
    end
  end
  #--------------------------------------------------------------------------
  # ● [再定義]:アクタースプライトの更新
  #--------------------------------------------------------------------------
  def update_actors
    @actor_sprites.each {|sprite| sprite.update }
  end
end
