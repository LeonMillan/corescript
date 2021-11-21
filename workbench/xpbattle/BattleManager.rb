
#==============================================================================
# ■ BattleManager
#------------------------------------------------------------------------------
# 　戦闘の進行を管理するモジュールです。
#==============================================================================

class << BattleManager
  #--------------------------------------------------------------------------
  # ● [追加]:公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :preemptive             # 先制攻撃フラグ
  attr_reader   :surprise               # 不意打ちフラグ
  attr_accessor :log_window             # バトルログウィンドウ
  attr_accessor :update_for_wait_method # ウェイト中のフレーム更新
  attr_accessor :helpdisplay_set_method        # 簡易ヘルプ表示
  attr_accessor :helpdisplay_clear_method      # 簡易ヘルプ消去
  attr_accessor :helpdisplay_wait_short_method # 簡易ヘルプ・短時間ウェイト
  #--------------------------------------------------------------------------
  # ● [追加]:簡易ヘルプ表示
  #--------------------------------------------------------------------------
  def helpdisplay_set(*args)
    @helpdisplay_set_method.call(*args) if @helpdisplay_set_method
  end
  #--------------------------------------------------------------------------
  # ● [追加]:簡易ヘルプ消去
  #--------------------------------------------------------------------------
  def helpdisplay_clear(*args)
    @helpdisplay_clear_method.call(*args) if @helpdisplay_clear_method
  end
  #--------------------------------------------------------------------------
  # ● [追加]:簡易ヘルプ・短時間ウェイト
  #--------------------------------------------------------------------------
  def helpdisplay_wait_short
    @helpdisplay_wait_short_method.call if @helpdisplay_wait_short_method
  end
  #--------------------------------------------------------------------------
  # ● [追加]:キー入力待ち
  #--------------------------------------------------------------------------
  def helpdisplay_wait_input
    return if $game_message.helpdisplay_texts.empty?
    return if LNX11::MESSAGE_TYPE == 0
    return if !@helpdisplay_wait_input || !@update_for_wait_method
    update_for_wait_method.call while !Input.press?(:B) && !Input.press?(:C)
  end
  #--------------------------------------------------------------------------
  # ● [追加]:メッセージ進行の SE 再生
  #--------------------------------------------------------------------------
  def messagedisplay_se_play
    return if !@helpdisplay_se
    @helpdisplay_se.play
    @helpdisplay_se = nil if @helpdisplay_se == LNX11::LEVELUP_SE
  end
  #--------------------------------------------------------------------------
  # ● [追加]:メッセージ進行
  #--------------------------------------------------------------------------
  def process_messagedisplay(wait)
    return if $game_message.helpdisplay_texts.empty?
    return if LNX11::MESSAGE_TYPE == 0
    $game_temp.battlelog_clear = true
    BattleManager.log_window.update
    if LNX11::BATTLELOG_TYPE == 2 || LNX11::MESSAGE_TYPE == 2
      # 簡易ヘルプ
      $game_message.helpdisplay_texts.each do |text|
        helpdisplay_wait_short
        messagedisplay_se_play
        helpdisplay_set(text, wait)
        helpdisplay_wait_input
      end
      helpdisplay_clear
    elsif LNX11::BATTLELOG_TYPE == 0
      # VXAceデフォルト
      BattleManager.log_window.clear
      $game_message.helpdisplay_texts.each do |text|
        messagedisplay_se_play
        BattleManager.log_window.add_text(text)
        BattleManager.log_window.abs_wait(wait)
        helpdisplay_wait_input
        max = BattleManager.log_window.max_line_number
        # 表示がいっぱいになったら消去
        if BattleManager.log_window.line_number >= max
          BattleManager.log_window.clear
        end
      end
      BattleManager.log_window.clear
    elsif LNX11::BATTLELOG_TYPE == 1
      # 蓄積型
      $game_message.helpdisplay_texts.each do |text|
        messagedisplay_se_play
        BattleManager.log_window.add_text(text)
        BattleManager.log_window.abs_wait(wait)
        helpdisplay_wait_input
      end
      $game_temp.battlelog_clear = true
      BattleManager.log_window.update
    end
    $game_message.helpdisplay_texts.clear
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:メッセージ表示が終わるまでウェイト
  #--------------------------------------------------------------------------
  alias :lnx11a_wait_for_message :wait_for_message
  def wait_for_message
    # 簡易ヘルプ表示
    process_messagedisplay(@helpdisplay_wait ? @helpdisplay_wait : 60)
    return if $game_message.texts.empty?
    # 元のメソッドを呼ぶ
    lnx11a_wait_for_message
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:戦闘開始
  #--------------------------------------------------------------------------
  alias :lnx11a_battle_start :battle_start
  def battle_start
    @helpdisplay_wait = LNX11::MESSAGE_WAIT[:battle_start][0]
    @helpdisplay_wait_input = LNX11::MESSAGE_WAIT[:battle_start][1]
    # メッセージウィンドウへのテキスト追加を禁止する
    $game_message.add_disabled
    # 元のメソッドを呼ぶ
    lnx11a_battle_start
    # メッセージウィンドウへのテキスト追加を許可する
    $game_message.add_enabled
    @helpdisplay_wait = nil
    @helpdisplay_wait_input = nil
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:勝利の処理
  #--------------------------------------------------------------------------
  alias :lnx11a_process_victory :process_victory
  def process_victory
    @helpdisplay_wait = LNX11::MESSAGE_WAIT[:victory][0]
    @helpdisplay_wait_input = LNX11::MESSAGE_WAIT[:victory][1]
    # メッセージウィンドウへのテキスト追加を禁止する
    $game_message.add_disabled
    # 元のメソッドを呼ぶ
    success = lnx11a_process_victory
    # メッセージウィンドウへのテキスト追加を許可する
    $game_message.add_enabled
    @helpdisplay_wait = nil
    @helpdisplay_wait_input = nil
    return success
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:逃走の処理
  #--------------------------------------------------------------------------
  alias :lnx11a_process_escape :process_escape
  def process_escape
    @helpdisplay_wait = LNX11::MESSAGE_WAIT[:escape][0]
    @helpdisplay_wait_input = LNX11::MESSAGE_WAIT[:escape][1]
    # メッセージウィンドウへのテキスト追加を禁止する
    $game_message.add_disabled
    # 元のメソッドを呼ぶ
    success = lnx11a_process_escape
    # メッセージウィンドウへのテキスト追加を許可する
    $game_message.add_enabled
    @helpdisplay_wait = nil
    @helpdisplay_wait_input = nil
    return success
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:敗北の処理
  #--------------------------------------------------------------------------
  alias :lnx11a_process_defeat :process_defeat
  def process_defeat
    @helpdisplay_wait = LNX11::MESSAGE_WAIT[:defeat][0]
    @helpdisplay_wait_input = LNX11::MESSAGE_WAIT[:defeat][1]
    # メッセージウィンドウへのテキスト追加を禁止する
    $game_message.add_disabled
    # 元のメソッドを呼ぶ
    success = lnx11a_process_defeat
    # メッセージウィンドウへのテキスト追加を許可する
    $game_message.add_enabled
    @helpdisplay_wait = nil
    @helpdisplay_wait_input = nil
    return success
  end
  #--------------------------------------------------------------------------
  # ● [エイリアス]:ドロップアイテムの獲得と表示
  #--------------------------------------------------------------------------
  alias :lnx11a_gain_drop_items :gain_drop_items
  def gain_drop_items
    helpdisplay_clear
    @helpdisplay_wait = LNX11::MESSAGE_WAIT[:drop_item][0]
    @helpdisplay_wait_input = LNX11::MESSAGE_WAIT[:drop_item][1]
    @helpdisplay_se = LNX11::DROPITEM_SE
    # 元のメソッドを呼ぶ
    lnx11a_gain_drop_items
    @helpdisplay_wait = nil
    @helpdisplay_wait_input = nil
    @helpdisplay_se = nil
  end
  #--------------------------------------------------------------------------
  # ● [再定義]:経験値の獲得とレベルアップの表示
  #--------------------------------------------------------------------------
  def gain_exp
    @helpdisplay_wait = LNX11::MESSAGE_WAIT[:levelup][0]
    @helpdisplay_wait_input = LNX11::MESSAGE_WAIT[:levelup][1]
    $game_party.all_members.each do |actor|
      @helpdisplay_se = LNX11::LEVELUP_SE
      actor.gain_exp($game_troop.exp_total)
      # レベルアップ毎にメッセージ表示ウェイト
      wait_for_message
    end
    @helpdisplay_wait = nil
    @helpdisplay_wait_input = nil
    @helpdisplay_se = nil
  end
end
