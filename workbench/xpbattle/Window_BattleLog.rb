#==============================================================================
# ■ Window_BattleLog
#------------------------------------------------------------------------------
# 　戦闘の進行を実況表示するウィンドウです。
#==============================================================================

class Window_BattleLog < Window_Selectable
  #--------------------------------------------------------------------------
  # ● [エイリアス]:オブジェクト初期化
  #--------------------------------------------------------------------------
  alias :lnx11a_initialize :initialize
  def initialize
    lnx11a_initialize
    # バトルログタイプが 1 以上なら非表示にする
    @storage_number = 0
    hide if LNX11::BATTLELOG_TYPE >= 1
    BattleManager.log_window = self
  end
  #--------------------------------------------------------------------------
  # ● [追加]:文章の配列のクリア
  #--------------------------------------------------------------------------
  def lines_clear
    @lines.clear if LNX11::BATTLELOG_TYPE == 1
  end
  #--------------------------------------------------------------------------
  # ● [追加]:指定ウェイト
  #--------------------------------------------------------------------------
  def abs_wait(wait)
    @method_wait.call(wait) if @method_wait
  end
  #--------------------------------------------------------------------------
  # ● [再定義]:メッセージ速度の取得
  #--------------------------------------------------------------------------
  def message_speed
    return 20
  end
  #--------------------------------------------------------------------------
  # ● [再定義]:エフェクト実行が終わるまでウェイト
  #--------------------------------------------------------------------------
  def wait_for_effect
    return if LNX11::BATTLELOG_TYPE > 0
    @method_wait_for_effect.call if @method_wait_for_effect
  end
  #--------------------------------------------------------------------------
  # ● [追加]:アニメーションのウェイト用メソッドの設定
  #--------------------------------------------------------------------------
  def method_wait_for_animation=(method)
    @method_wait_for_animation = method
  end
  #--------------------------------------------------------------------------
  # ● [追加]:アニメーション再生が終わるまでウェイト
  #--------------------------------------------------------------------------
  def wait_for_animation
    @method_wait_for_animation.call if @method_wait_for_animation
  end

  #--------------------------------------------------------------------------
  # ● [エイリアス]:ウィンドウ高さの取得
  #--------------------------------------------------------------------------
  alias :lnx11a_window_height :window_height
  def window_height
    LNX11::BATTLELOG_TYPE == 1 ? fitting_height(1) : lnx11a_window_height
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:最大行数の取得
  #--------------------------------------------------------------------------
  alias :lnx11a_max_line_number :max_line_number
  def max_line_number
    num = LNX11::STORAGE_LINE_NUMBER
    LNX11::BATTLELOG_TYPE == 1 ? num : lnx11a_max_line_number
  end
  #--------------------------------------------------------------------------
  # ● [オーバーライド]:行の高さを取得
  #--------------------------------------------------------------------------
  def line_height
    LNX11::BATTLELOG_TYPE == 1 ? LNX11::STORAGE_LINE_HEIGHT : super
  end
  #--------------------------------------------------------------------------
  # ● [オーバーライド]:フォント設定のリセット
  #--------------------------------------------------------------------------
  def reset_font_settings
    super
    return unless LNX11::BATTLELOG_TYPE == 1
    contents.font.size = LNX11::STORAGE_FONT[:size]
    contents.font.out_color.set(LNX11::STORAGE_FONT[:out_color])
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:データ行数の取得
  #--------------------------------------------------------------------------
  alias :lnx11a_line_number :line_number
  def line_number
    return 0 if LNX11::BATTLELOG_TYPE == 2
    LNX11::BATTLELOG_TYPE == 1 ? @storage_number : lnx11a_line_number
  end
  #--------------------------------------------------------------------------
  # ● [再定義]:背景スプライトの作成
  #--------------------------------------------------------------------------
  alias :lnx11a_create_back_sprite :create_back_sprite
  def create_back_sprite
    if LNX11::BATTLELOG_TYPE == 1
      # 蓄積型
      create_message_sprite
    else
      # 背景
      lnx11a_create_back_sprite
    end
  end
  #--------------------------------------------------------------------------
  # ● [再定義]:背景スプライトの解放
  #--------------------------------------------------------------------------
  alias :lnx11a_dispose_back_sprite :dispose_back_sprite
  def dispose_back_sprite
    if LNX11::BATTLELOG_TYPE == 1
      # 蓄積型
      dispose_message_sprite
    else
      # 背景
      lnx11a_dispose_back_sprite
    end
  end
  #--------------------------------------------------------------------------
  # ● [追加]:メッセージスプライトの作成
  #--------------------------------------------------------------------------
  def create_message_sprite
    # メッセージスプライト 行数分だけ作成する
    @mes_position = 0 # 次にメッセージを表示させる位置
    @mesup_count = LNX11::STORAGE_UP_MESSAGE_TIME # ログが進行するまでの時間
    @mes_sprites = Array.new(max_line_number + 1) {
    Sprite_OneLine_BattleLog.new(self.width, line_height, max_line_number)}
  end
  #--------------------------------------------------------------------------
  # ● [追加]:メッセージスプライトの解放
  #--------------------------------------------------------------------------
  def dispose_message_sprite
    @mes_sprites.each {|sprite| sprite.dispose }
  end
  #--------------------------------------------------------------------------
  # ● [追加]:メッセージスプライトを表示
  #--------------------------------------------------------------------------
  def show_message_sprite
    @mes_sprites.each {|sprite| sprite.show }
  end
  #--------------------------------------------------------------------------
  # ● [追加]:メッセージスプライトを非表示
  #--------------------------------------------------------------------------
  def hide_message_sprite
    @mes_sprites.each {|sprite| sprite.hide }
    @mes_position = 0
  end
  #--------------------------------------------------------------------------
  # ● [追加]:メッセージスプライトを一つ進める
  #--------------------------------------------------------------------------
  def up_message_sprite
    @mes_sprites.each {|sprite| sprite.up_position }
  end
  #--------------------------------------------------------------------------
  # ● [追加]:空のメッセージスプライトを返す
  #--------------------------------------------------------------------------
  def empty_message_sprite
    @mes_sprites.each {|sprite| return sprite if sprite.mes_empty? }
    @mes_sprites[0]
  end
  #--------------------------------------------------------------------------
  # ● [追加]:メッセージスプライトの更新
  #--------------------------------------------------------------------------
  def update_message_sprite
    # バトルログ消去フラグが有効
    if $game_temp.battlelog_clear
      $game_temp.battlelog_clear = false
      # スプライトが表示されていれば非表示にする
      if @mes_sprites[0].visible?
        hide_message_sprite
        lines_clear
      end
    end
    # ログの自動進行
    @mesup_count -= 1
    if @mesup_count <= 0 && @mes_position > 0
      up_message_sprite
      @mes_position -= 1
      @mesup_count = LNX11::STORAGE_UP_MESSAGE_TIME
    end
    @mes_sprites.each {|sprite| sprite.update }
  end
  #--------------------------------------------------------------------------
  # ● [追加]:メッセージスプライトのリフレッシュ
  #--------------------------------------------------------------------------
  def refresh_message_sprite
    # 文章が無ければ何もしない
    return if @lines.empty?
    # スプライトを表示する
    show_message_sprite unless @mes_sprites[0].visible?
    # 文章の描画
    contents.clear
    @lines[0] = last_text
    return if @lines[0].empty?
    draw_line(0)
    @storage_number += 1
    # ウィンドウの内容をスプライトにコピー
    empty_message_sprite.set_text(self, @mes_position)
    # スプライト位置の変動
    if @mes_position < max_line_number
      @mes_position += 1
    elsif @mesup_count > 0
      up_message_sprite
    end
    @mesup_count = (LNX11::STORAGE_UP_MESSAGE_TIME * 1.5).truncate
  end
  #--------------------------------------------------------------------------
  # ● [オーバーライド]:フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    update_message_sprite if LNX11::BATTLELOG_TYPE == 1
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:リフレッシュ
  #--------------------------------------------------------------------------
  alias :lnx11a_refresh :refresh
  def refresh
    return if LNX11::BATTLELOG_TYPE == 2
    LNX11::BATTLELOG_TYPE == 1 ? refresh_message_sprite : lnx11a_refresh
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:クリア
  #--------------------------------------------------------------------------
  alias :lnx11a_clear :clear
  def clear
    return if LNX11::BATTLELOG_TYPE == 2
    LNX11::BATTLELOG_TYPE == 1 ? @storage_number = 0 : lnx11a_clear
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:一行戻る
  #--------------------------------------------------------------------------
  alias :lnx11a_back_one :back_one
  def back_one
    if LNX11::BATTLELOG_TYPE == 1
      # 蓄積型
      @storage_number = [@storage_number - 1, 0].max
    else
      # 通常
      lnx11a_back_one
    end
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:指定した行に戻る
  #--------------------------------------------------------------------------
  alias :lnx11a_back_to :back_to
  def back_to(line_number)
    if LNX11::BATTLELOG_TYPE == 1
      # 蓄積型
      @storage_number -= 1 while @storage_number > line_number
    else
      # 通常
      lnx11a_back_to(line_number)
    end
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:ウェイト
  #--------------------------------------------------------------------------
  alias :lnx11a_wait :wait
  def wait
    return if LNX11::BATTLELOG_TYPE == 2
    # 元のメソッドを呼ぶ
    lnx11a_wait
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:スキル／アイテム使用の表示
  # 　使用時アニメーションの処理を追加します。
  #--------------------------------------------------------------------------
  alias :lnx11a_display_use_item :display_use_item
  def display_use_item(subject, item)
    if item.use_animation > 0
      # 使用時アニメーションが設定されていれば再生
      subject.animation_id = item.use_animation
      subject.animation_mirror = false
    end
    # 元のメソッドを呼ぶ
    lnx11a_display_use_item(subject, item)
    # アニメーションのウェイト
    wait_for_animation if item.use_animation > 0
  end
  #--------------------------------------------------------------------------
  # ● [追加]:ポップアップデータの取得
  #--------------------------------------------------------------------------
  def popup_data
    $game_temp.popup_data
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:反撃の表示
  #--------------------------------------------------------------------------
  alias :lnx11a_display_counter :display_counter
  def display_counter(target, item)
    # ポップアップ
    popup_data.popup_text(target, :counter)
    # 元のメソッドを呼ぶ
    lnx11a_display_counter(target, item)
    # ポップアップウェイト
    popup_data.add_wait
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:反射の表示
  #--------------------------------------------------------------------------
  alias :lnx11a_display_reflection :display_reflection
  def display_reflection(target, item)
    # ポップアップ
    popup_data.popup_text(target, :reflection)
    # 元のメソッドを呼ぶ
    lnx11a_display_reflection(target, item)
    # ポップアップウェイト
    popup_data.add_wait
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:身代わりの表示
  #--------------------------------------------------------------------------
  alias :lnx11a_display_substitute :display_substitute
  def display_substitute(substitute, target)
    # ポップアップ
    popup_data.popup_text(substitute, :substitute)
    # 元のメソッドを呼ぶ
    lnx11a_display_substitute(substitute, target)
    # ポップアップウェイト
    popup_data.add_wait
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:失敗の表示
  #--------------------------------------------------------------------------
  alias :lnx11a_display_failure :display_failure
  def display_failure(target, item)
    if target.result.hit? && !target.result.success
      # ポップアップ (ミスと同じ扱いにする)
      popup_data.popup_miss(target, item)
    end
    # 元のメソッドを呼ぶ
    lnx11a_display_failure(target, item)
    # ポップアップウェイト
    popup_data.add_wait
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:ミスの表示
  #--------------------------------------------------------------------------
  alias :lnx11a_display_miss :display_miss
  def display_miss(target, item)
    # ポップアップ
    popup_data.popup_miss(target, item)
    # 元のメソッドを呼ぶ
    lnx11a_display_miss(target, item)
    # ポップアップウェイト
    popup_data.add_wait
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:回避の表示
  #--------------------------------------------------------------------------
  alias :lnx11a_display_evasion :display_evasion
  def display_evasion(target, item)
    # ポップアップ (ミスと同じ扱いにする)
    popup_data.popup_miss(target, item)
    # 元のメソッドを呼ぶ
    lnx11a_display_evasion(target, item)
    # ポップアップウェイト
    popup_data.add_wait
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:HP ダメージ表示
  #--------------------------------------------------------------------------
  alias :lnx11a_display_hp_damage :display_hp_damage
  def display_hp_damage(target, item)
    # ポップアップ
    popup_data.popup_hp_damage(target, item)
    # 元のメソッドを呼ぶ
    lnx11a_display_hp_damage(target, item)
    # ポップアップウェイト
    popup_data.add_wait
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:MP ダメージ表示
  #--------------------------------------------------------------------------
  alias :lnx11a_display_mp_damage :display_mp_damage
  def display_mp_damage(target, item)
    # ポップアップ
    popup_data.popup_mp_damage(target, item)
    # 元のメソッドを呼ぶ
    lnx11a_display_mp_damage(target, item)
    # ポップアップウェイト
    popup_data.add_wait
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:TP ダメージ表示
  #--------------------------------------------------------------------------
  alias :lnx11a_display_tp_damage :display_tp_damage
  def display_tp_damage(target, item)
    # ポップアップ
    popup_data.popup_tp_damage(target, item)
    # 元のメソッドを呼ぶ
    lnx11a_display_tp_damage(target, item)
    # ポップアップウェイト
    popup_data.add_wait
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:ステート付加の表示
  #--------------------------------------------------------------------------
  alias :lnx11a_display_added_states :display_added_states
  def display_added_states(target)
    # ポップアップ
    popup_data.popup_added_states(target)
    # 元のメソッドを呼ぶ
    lnx11a_display_added_states(target)
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:ステート解除の表示
  #--------------------------------------------------------------------------
  alias :lnx11a_display_removed_states :display_removed_states
  def display_removed_states(target)
    # ポップアップ
    popup_data.popup_removed_states(target)
    # 元のメソッドを呼ぶ
    lnx11a_display_removed_states(target)
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:能力強化／弱体の表示（個別）
  #--------------------------------------------------------------------------
  alias :lnx11a_display_buffs :display_buffs
  def display_buffs(target, buffs, fmt)
    # ポップアップ
    popup_data.popup_buffs(target, buffs, fmt)
    # 元のメソッドを呼ぶ
    lnx11a_display_buffs(target, buffs, fmt)
  end
end
