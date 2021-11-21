
#==============================================================================
# ■ Scene_Battle
#------------------------------------------------------------------------------
# 　バトル画面の処理を行うクラスです。
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● [追加]:簡易ヘルプのメソッド設定
  #--------------------------------------------------------------------------
  def set_helpdisplay_methods
    BattleManager.update_for_wait_method = method(:update_for_wait)
    BattleManager.helpdisplay_set_method = method(:helpdisplay_set)
    BattleManager.helpdisplay_clear_method = method(:helpdisplay_clear)
    BattleManager.helpdisplay_wait_short_method=method(:helpdisplay_wait_short)
  end
  #--------------------------------------------------------------------------
  # ● [追加]:簡易ヘルプ表示
  #--------------------------------------------------------------------------
  def helpdisplay_set(item, duration = nil)
    @wait_short_disabled = false
    @targethelp_window.show.set_item(item)
    @targethelp_window.update
    wait(duration ? duration : 20)
  end
  #--------------------------------------------------------------------------
  # ● [追加]:簡易ヘルプ消去
  #--------------------------------------------------------------------------
  def helpdisplay_clear(duration = nil)
    return if !@targethelp_window.visible
    @wait_short_disabled = false
    @targethelp_window.clear
    @targethelp_window.hide
    wait(duration ? duration : 10)
  end
  #--------------------------------------------------------------------------
  # ● [追加]:簡易ヘルプ・短時間ウェイト
  #--------------------------------------------------------------------------
  def helpdisplay_wait_short
    return if !@targethelp_window.visible || @wait_short_disabled
    @wait_short_disabled = true # 連続で短時間ウェイトが実行されないように
    @targethelp_window.clear
    abs_wait_short
  end
  #--------------------------------------------------------------------------
  # ● [追加]:バトラーのエフェクト実行中？
  #--------------------------------------------------------------------------
  def battler_effect?
    @spriteset.effect?
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:コマンド［逃げる］
  #--------------------------------------------------------------------------
  alias :lnx11a_command_escape :command_escape
  def command_escape
    @party_command_window.close
    @party_command_window.openness = 0 if LNX11::MESSAGE_TYPE == 2
    @status_window.unselect
    # 元のメソッドを呼ぶ
    lnx11a_command_escape
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:スキル／アイテムの使用
  #--------------------------------------------------------------------------
  alias :lnx11a_use_item :use_item
  def use_item
    # 簡易ヘルプ表示
    item = @subject.current_action.item
    if LNX11::BATTLELOG_TYPE == 2 && !item.no_display
      helpdisplay_set(item, item.display_wait)
    end
    # 元のメソッドを呼ぶ
    lnx11a_use_item
    # 簡易ヘルプ消去・エフェクトが終わるまで待つ
    if LNX11::BATTLELOG_TYPE == 2
      wait(item.end_wait)
      helpdisplay_clear
    end
    wait_for_effect
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:開始処理
  #--------------------------------------------------------------------------
  alias :lnx11a_start :start
  def start
    set_helpdisplay_methods
    @last_party_members = party_members
    $game_temp.method_battle_status_refresh = method(:refresh_status)
    $game_temp.clear_last_target_cursor
    $game_party.all_members.each {|actor| actor.last_actor_command = 0 }
    reset_sprite_effects
    standby_message_window_position
    create_targetcursor
    create_popup
    #元のメソッドを呼ぶ
    lnx11a_start
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:終了処理
  #--------------------------------------------------------------------------
  alias :lnx11a_terminate :terminate
  def terminate
    $game_message.clear
    dispose_targetcursor
    dispose_popup
    # 元のメソッドを呼ぶ
    lnx11a_terminate
  end
  #--------------------------------------------------------------------------
  # ● [追加]:アクターのスプライト情報の初期化
  #--------------------------------------------------------------------------
  def reset_sprite_effects
    $game_party.battle_members.each do |actor|
      actor.popup_delay_clear
      actor.set_state_animation
    end
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:全ウィンドウの作成
  #--------------------------------------------------------------------------
  alias :lnx11a_create_all_windows :create_all_windows
  def create_all_windows
    # 元のメソッドを呼ぶ
    lnx11a_create_all_windows
    create_targethelp_window
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:ステータスウィンドウの作成
  #--------------------------------------------------------------------------
  alias :lnx11a_create_status_window :create_status_window
  def create_status_window
    # 元のメソッドを呼ぶ
    lnx11a_create_status_window
    @status_window.set_xy
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:情報表示ビューポートの作成
  #--------------------------------------------------------------------------
  alias :lnx11a_create_info_viewport :create_info_viewport
  def create_info_viewport
    # 元のメソッドを呼ぶ
    lnx11a_create_info_viewport
    # ビューポートを修正
    @info_viewport.rect.y = Graphics.height - LNX11::ACTOR_BACKGROUND_HEIGHT
    @info_viewport.rect.height = LNX11::ACTOR_BACKGROUND_HEIGHT
    @status_window.viewport = nil
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:パーティコマンドウィンドウの作成
  #--------------------------------------------------------------------------
  alias :lnx11a_create_party_command_window :create_party_command_window
  def create_party_command_window
    # 元のメソッドを呼ぶ
    lnx11a_create_party_command_window
    @party_command_window.viewport = nil
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:アクターコマンドウィンドウの作成
  #--------------------------------------------------------------------------
  alias :lnx11a_create_actor_command_window :create_actor_command_window
  def create_actor_command_window
    # 元のメソッドを呼ぶ
    lnx11a_create_actor_command_window
    @actor_command_window.viewport = nil
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:ログウィンドウの作成
  #--------------------------------------------------------------------------
  alias :lnx11a_create_log_window :create_log_window
  def create_log_window
    # 元のメソッドを呼ぶ
    lnx11a_create_log_window
    # ウェイトメソッド
    @log_window.method_wait_for_animation = method(:wait_for_animation)
  end
  #--------------------------------------------------------------------------
  # ● [追加]:ターゲットカーソルの作成
  #--------------------------------------------------------------------------
  def create_targetcursor
    @targetcursor = Sprite_TargetCursor.new
    $game_temp.target_cursor_sprite = @targetcursor
  end
  #--------------------------------------------------------------------------
  # ● [追加]:ターゲットカーソルの解放
  #--------------------------------------------------------------------------
  def dispose_targetcursor
    @targetcursor.dispose
  end
  #--------------------------------------------------------------------------
  # ● [追加]:ターゲットヘルプウィンドウの作成
  #--------------------------------------------------------------------------
  def create_targethelp_window
    @targethelp_window = Window_TargetHelp.new
    @targethelp_window.visible = false
    # ターゲット選択ウィンドウに関連付ける
    @actor_window.help_window = @targethelp_window
    @enemy_window.help_window = @targethelp_window
  end
  #--------------------------------------------------------------------------
  # ● [追加]:ポップアップの作成
  #--------------------------------------------------------------------------
  def create_popup
    $game_temp.popup_data = Popup_Data.new
  end
  #--------------------------------------------------------------------------
  # ● [追加]:ポップアップの解放
  #--------------------------------------------------------------------------
  def dispose_popup
    $game_temp.popup_data.dispose
  end
  #--------------------------------------------------------------------------
  # ● [追加]:ポップアップデータの取得
  #--------------------------------------------------------------------------
  def popup_data
    $game_temp.popup_data
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:フレーム更新（基本）
  #--------------------------------------------------------------------------
  alias :lnx11a_update_basic :update_basic
  def update_basic
    # 元のメソッドを呼ぶ
    lnx11a_update_basic
    # 追加したオブジェクトの更新
    update_targetcursor
    update_popup
    refresh_actors
  end
  #--------------------------------------------------------------------------
  # ● [追加]:パーティメンバーの ID 配列の取得
  #--------------------------------------------------------------------------
  def party_members
    $game_party.battle_members.collect {|actor| actor.id }
  end
  #--------------------------------------------------------------------------
  # ● [追加]:メンバーが入れ替わったらオブジェクトを再作成する
  #--------------------------------------------------------------------------
  def refresh_actors
    a_party_members = party_members
    return if @last_party_members == a_party_members
    @last_party_members = a_party_members
    $game_party.battle_members.each {|actor| actor.sprite_effect_type=:appear }
    reset_sprite_effects
    @spriteset.dispose_actors
    @spriteset.create_actors
    status_clear
    refresh_status
    Graphics.frame_reset
  end
  #--------------------------------------------------------------------------
  # ● [追加]:ステータスウィンドウの情報を更新(メンバー交代用)
  #--------------------------------------------------------------------------
  def status_clear
    @status_window.all_clear
  end
  #--------------------------------------------------------------------------
  # ● [追加]:メッセージウィンドウの位置の初期化
  # 　毎フレーム呼び出すことで、イベントコマンド以外のメッセージの位置を
  # 固定します。
  #--------------------------------------------------------------------------
  def standby_message_window_position
    $game_message.background = LNX11::MESSAGE_WINDOW_BACKGROUND
    $game_message.position = LNX11::MESSAGE_WINDOW_POSITION
  end
  #--------------------------------------------------------------------------
  # ● [再定義]:メッセージウィンドウを開く処理の更新
  #    ステータスウィンドウなどが閉じ終わるまでオープン度を 0 にする。
  #--------------------------------------------------------------------------
  def update_message_open
    if $game_message.busy?
      @party_command_window.close
      @actor_command_window.close
      $game_temp.battlelog_clear = true
    else
      standby_message_window_position
    end
  end
  #--------------------------------------------------------------------------
  # ● [追加]:ターゲットカーソル更新
  #--------------------------------------------------------------------------
  def update_targetcursor
    # 選択中のバトラーの座標を設定する
    if @actor_window.active
      # アクター選択ウィンドウがアクティブ
      @targetcursor.set(@actor_window.targetcursor, true)
    elsif @enemy_window.active
      # 敵キャラ選択ウィンドウがアクティブ
      @targetcursor.set(@enemy_window.targetcursor, true)
    elsif @status_window.index >= 0
      # ステータスウィンドウがアクティブ
      @targetcursor.set(@status_window.actor)
    else
      # どれもアクティブでない場合は非表示
      @targetcursor.hide
    end
    @targetcursor.update
  end
  #--------------------------------------------------------------------------
  # ● [追加]:ポップアップ更新
  #--------------------------------------------------------------------------
  def update_popup
    # ポップアップスプライトの更新
    popup_data.update
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:パーティコマンド選択の開始
  #--------------------------------------------------------------------------
  alias :lnx11a_start_party_command_selection :start_party_command_selection
  def start_party_command_selection
    # 元のメソッドを呼ぶ
    lnx11a_start_party_command_selection
    # バトルログ削除
    @log_window.lines_clear
    $game_temp.battlelog_clear = LNX11::STORAGE_TURNEND_CLEAR
    @actor_command = false
    # 2ターン目以降のパーテイコマンドスキップ
    return unless @party_command_skip
    @party_command_skip = false
    command_fight if !scene_changing? && @party_command_window.active
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:アクターコマンド選択の開始
  #--------------------------------------------------------------------------
  alias :lnx11a_start_actor_command_selection :start_actor_command_selection
  def start_actor_command_selection
    # 元のメソッドを呼ぶ
    lnx11a_start_actor_command_selection
    @actor_command = true
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:ターン終了
  #--------------------------------------------------------------------------
  alias :lnx11a_turn_end :turn_end
  def turn_end
    @party_command_skip = (LNX11::PARTY_COMMAND_SKIP && @actor_command)
    @actor_command = false
    # 元のメソッドを呼ぶ
    lnx11a_turn_end
  end
  #--------------------------------------------------------------------------
  # ● [追加]:アクターの選択したアイテム・スキルを返す
  #--------------------------------------------------------------------------
  def actor_selection_item
    case @actor_command_window.current_symbol
    when :attack ; $data_skills[BattleManager.actor.attack_skill_id]
    when :skill  ; @skill
    when :item   ; @item
    when :guard  ; $data_skills[BattleManager.actor.guard_skill_id]
    else ; nil
    end
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:コマンド［防御］
  #--------------------------------------------------------------------------
  alias :lnx11a_command_guard :command_guard
  def command_guard
    if LNX11::GUARD_TARGET_CHECKE
      BattleManager.actor.input.set_guard
      # アクター選択
      select_actor_selection
    else
      # 元のメソッドを呼ぶ
      lnx11a_command_guard
    end
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:アクター選択の開始
  #--------------------------------------------------------------------------
  alias :lnx11a_select_actor_selection :select_actor_selection
  def select_actor_selection
    # ターゲットチェック
    @actor_window.set_target(actor_selection_item)
    # 元のメソッドを呼ぶ
    lnx11a_select_actor_selection
    # ターゲットチェック
    @actor_window.set_target_refresh(actor_selection_item, BattleManager.actor)
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:敵キャラ選択の開始
  #--------------------------------------------------------------------------
  alias :lnx11a_select_enemy_selection :select_enemy_selection
  def select_enemy_selection
    # ターゲットチェック
    @enemy_window.set_target(actor_selection_item)
    # 元のメソッドを呼ぶ
    lnx11a_select_enemy_selection
    # ターゲットチェック
    @enemy_window.set_target_refresh(actor_selection_item, BattleManager.actor)
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]アクター［キャンセル］
  #--------------------------------------------------------------------------
  alias :lnx11a_on_actor_cancel :on_actor_cancel
  def on_actor_cancel
    # 元のメソッドを呼ぶ
    lnx11a_on_actor_cancel
    # 防御の場合
    case @actor_command_window.current_symbol
    when :guard
      @actor_command_window.activate
    end
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:攻撃アニメーションの表示
  #--------------------------------------------------------------------------
  alias :lnx11a_show_attack_animation :show_attack_animation
  def show_attack_animation(targets)
    if @subject.actor?
      lnx11a_show_attack_animation(targets)
    else
      # 敵の通常攻撃アニメーション
      show_normal_animation(targets, @subject.atk_animation, false)
    end
  end
end
