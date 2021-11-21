
#==============================================================================
# ■ Game_Actor
#------------------------------------------------------------------------------
# 　アクターを扱うクラスです。このクラスは Game_Actors クラス（$game_actors）
# の内部で使用され、Game_Party クラス（$game_party）からも参照されます。
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● [追加]:公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :battler_graphic_name    # 後指定のバトラーグラフィック
  attr_accessor :refresh_battler_graphic # バトラーグラフィックの更新フラグ
  attr_accessor :screen_x                # バトル画面 X 座標
  attr_accessor :screen_y                # バトル画面 Y 座標
  attr_accessor :last_actor_command      # 最後に選択したコマンド
  #--------------------------------------------------------------------------
  # ● [再定義]:スプライトを使うか？
  #--------------------------------------------------------------------------
  def use_sprite?
    return true # 使う
  end
  #--------------------------------------------------------------------------
  # ● [追加]:バトル画面 Z 座標の取得
  #--------------------------------------------------------------------------
  def screen_z
    return $game_party.members_screen_z[0] if index == nil
    return $game_party.members_screen_z[index] # Game_EnemyのZ座標は100
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:ダメージ効果の実行
  #--------------------------------------------------------------------------
  alias :lnx11a_perform_damage_effect :perform_damage_effect
  def perform_damage_effect
    # 元のメソッドを呼ぶ
    lnx11a_perform_damage_effect
    # シェイクを無効にしている場合、シェイクをクリア
    $game_troop.screen.clear_shake if LNX11::DISABLED_DAMAGE_SHAKE
  end
  #--------------------------------------------------------------------------
  # ● [再定義]:コラプス効果の実行
  # 　アクターの[特徴>その他>消滅エフェクト]の設定を適用するようにします。
  # 　処理内容は Game_Enemy のものとほぼ同一です。
  #--------------------------------------------------------------------------
  def perform_collapse_effect
    if $game_party.in_battle
      case collapse_type
      when 0
        @sprite_effect_type = :collapse
        Sound.play_actor_collapse
      when 1
        @sprite_effect_type = :boss_collapse
        Sound.play_boss_collapse1
      when 2
        @sprite_effect_type = :instant_collapse
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● [追加]:グラフィック設定の配列を返す
  #--------------------------------------------------------------------------
  def graphic_name_index
    case LNX11::DEFAULT_BATTLER_GRAPHIC
    when 0 ; [@face_name, @face_index]
    when 1 ; [@character_name, @character_index]
    end
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:グラフィックの変更
  #--------------------------------------------------------------------------
  alias :lnx11a_set_graphic :set_graphic
  def set_graphic(*args)
    face = graphic_name_index
    # 元のメソッドを呼ぶ
    lnx11a_set_graphic(*args)
    @refresh_battler_graphic = (face != graphic_name_index)
  end
  #--------------------------------------------------------------------------
  # ● [追加]:デフォルトバトラーグラフィックの取得
  #--------------------------------------------------------------------------
  def facebattler
    $game_temp.actor_battler_graphic[id]
  end
  def facebattler=(bitmap)
    facebattler.dispose if facebattler && !facebattler.disposed?
    $game_temp.actor_battler_graphic[id] = bitmap
  end
  #--------------------------------------------------------------------------
  # ● [追加]:後指定のバトラーグラフィックファイル名の取得
  #--------------------------------------------------------------------------
  def battler_graphic_name
    return @battler_graphic_name if @battler_graphic_name != nil
    @battler_graphic_name = ""
  end
  #--------------------------------------------------------------------------
  # ● [追加]:後指定のバトラーグラフィックファイル名の指定
  #--------------------------------------------------------------------------
  def battler_graphic_name=(filename)
    @battler_graphic_name = filename
    @refresh_battler_graphic = true
  end
  #--------------------------------------------------------------------------
  # ● [追加]:顔グラフィックを描画して返す
  # 　処理内容は Window_Base の draw_face に準じたものです。
  #--------------------------------------------------------------------------
  def draw_face(face_name, face_index, enabled = true)
    fw = 96
    fh = 96
    # ビットマップを作成して返す
    bitmap = Cache.face(face_name)
    rect = Rect.new(face_index % 4 * fw, face_index / 4 * fh, fw, fh)
    face = Bitmap.new(fw, fh)
    color = LNX11::DEFAULT_BG_COLOR
    face.gradient_fill_rect(face.rect, color[0], color[1], true)
    face.blt(0, 0, bitmap, rect)
    bitmap.dispose
    face
  end
  #--------------------------------------------------------------------------
  # ● [追加]:歩行グラフィックを描画して返す
  # 　処理内容は Window_Base の draw_character に準じたものです。
  #--------------------------------------------------------------------------
  def draw_character(character_name, character_index)
    return unless character_name
    bitmap = Cache.character(character_name)
    sign = character_name[/^[\!\$]./]
    if sign && sign.include?('$')
      cw = bitmap.width / 3
      ch = bitmap.height / 4
    else
      cw = bitmap.width / 12
      ch = bitmap.height / 8
    end
    n = character_index
    src_rect = Rect.new((n%4*3+1)*cw, (n/4*4)*ch, cw, ch)
    character = Bitmap.new(cw, ch)
    color = LNX11::DEFAULT_BG_COLOR
    character.gradient_fill_rect(character.rect, color[0], color[1], true)
    character.blt(0, 0, bitmap, src_rect)
    character
  end
  #--------------------------------------------------------------------------
  # ● [追加]:デフォルトバトラーグラフィック設定
  #--------------------------------------------------------------------------
  def default_battler_graphic
    case LNX11::DEFAULT_BATTLER_GRAPHIC
    when 0 # 顔グラフィック
      self.facebattler = draw_face(@face_name, @face_index)
    when 1 # 歩行グラフィック
      self.facebattler = draw_character(@character_name, @character_index)
    end
  end
  #--------------------------------------------------------------------------
  # ● [追加]:バトラーグラフィックの更新
  # 　Sprite_Batter が利用するオブジェクトを更新します。
  #--------------------------------------------------------------------------
  def update_battler_graphic
    @battler_hue = 0
    if !battler_graphic_name.empty?
      # スクリプトで指定されている
      @battler_name = @battler_graphic_name
      dispose_facebattler
    elsif !actor.default_battler_graphic.empty?
      # メモで指定されている
      @battler_name = actor.default_battler_graphic
      dispose_facebattler
    else
      # 何も指定されていない
      @battler_name = ""
      default_battler_graphic
    end
    # 更新したので更新フラグを取り消す
    @refresh_battler_graphic = false
  end
  #--------------------------------------------------------------------------
  # ● [追加]:バトラー用顔グラフィックの解放
  #--------------------------------------------------------------------------
  def dispose_facebattler
    return if self.facebattler == nil
    self.facebattler.dispose
    self.facebattler = nil
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:レベルアップメッセージの表示
  #   レベルアップのポップアップを追加します。
  #--------------------------------------------------------------------------
  alias :lnx11a_display_level_up :display_level_up
  def display_level_up(new_skills)
    popup_data.popup_levelup(self) if $game_party.in_battle
    lnx11a_display_level_up(new_skills)
  end
end
