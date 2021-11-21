
  #--------------------------------------------------------------------------
  # ● バトルステータス更新
  #--------------------------------------------------------------------------
  # LNX11.バトルステータス更新
  def self.battle_status_refresh
    $game_temp.battle_status_refresh
  end
  def self.バトルステータス更新
    self.battle_status_refresh
  end
  #--------------------------------------------------------------------------
  # ● アクターエリア表示/非表示
  #--------------------------------------------------------------------------
  # LNX11.アクターエリア表示
  def self.actor_area_show
    self.actor_show
    self.status_show
    self.actor_bg_show
  end
  def self.アクターエリア表示
    self.actor_area_show
  end
  # LNX11.アクターエリア非表示
  def self.actor_area_hide
    self.actor_hide
    self.status_hide
    self.actor_bg_hide
  end
  def self.アクターエリア非表示
    self.actor_area_hide
  end
  #--------------------------------------------------------------------------
  # ● アクター表示/非表示
  #--------------------------------------------------------------------------
  # LNX11.アクター表示
  def self.actor_show
    $game_party.actor_invisible = false
  end
  def self.アクター表示
    self.actor_show
  end
  # LNX11.アクター非表示
  def self.actor_hide
    $game_party.actor_invisible = true
  end
  def self.アクター非表示
    self.actor_hide
  end
  #--------------------------------------------------------------------------
  # ● バトルステータス表示/非表示
  #--------------------------------------------------------------------------
  # LNX11.バトルステータス表示
  def self.status_show
    $game_party.status_invisible = false
    self.battle_status_refresh
  end
  def self.バトルステータス表示
    self.status_show
  end
  # LNX11.バトルステータス非表示
  def self.status_hide
    $game_party.status_invisible = true
    self.battle_status_refresh
  end
  def self.バトルステータス非表示
    self.status_hide
  end
  #--------------------------------------------------------------------------
  # ● アクター背景表示/非表示
  #--------------------------------------------------------------------------
  # LNX11.アクター背景表示
  def self.actor_bg_show
    $game_party.actor_bg_invisible = false
  end
  def self.アクター背景表示
    self.actor_bg_show
  end
  # LNX11.アクター背景非表示
  def self.actor_bg_hide
    $game_party.actor_bg_invisible = true
  end
  def self.アクター背景非表示
    self.actor_bg_hide
  end
  #--------------------------------------------------------------------------
  # ● バトラーグラフィックのスクリプト指定
  #--------------------------------------------------------------------------
  # LNX11.バトラーグラフィック(id, filename)
  def self.battler_graphic(id ,filename)
    if id.is_a?(Numeric) && filename.is_a?(String)
      p "LNX11a:バトラーグラフィックを変更しました:ID#{id} #{filename}"
      $game_actors[id].battler_graphic_name = filename
    else
      errormes =  "LNX11a:バトラーグラフィック指定の引数が正しくありません。"
      p errormes, "LNX11a:バトラーグラフィックの指定は行われませんでした。"
      msgbox errormes
    end
  end
  def self.バトラーグラフィック(id ,filename)
    self.battler_graphic(id ,filename)
  end
  #--------------------------------------------------------------------------
  # ● 任意のポップアップを生成
  #--------------------------------------------------------------------------
  # LNX11.ポップアップ(battler, popup, type, color, deco)
  def self.make_popup(battler, popup, type = 0, color = :hp_damage, deco = nil)
    return unless $game_party.in_battle
    target = self.battler_search(battler)
    unless target.is_a?(Game_Battler)
      p "LNX11a:任意のポップアップの生成に失敗しました。バトラー指定が"
      p "LNX11a:間違っているか、バトラーが存在していない可能性があります。"
      return
    end
    $game_temp.popup_data.popup_custom(target, popup, type, color, deco)
  end
  def self.ポップアップ(battler, popup, type=0, color=:hp_damage, deco=nil)
    self.make_popup(battler, popup, type, color, deco)
  end
  #--------------------------------------------------------------------------
  # ● バトラー指定
  #--------------------------------------------------------------------------
  def self.battler_search(val)
    if val.is_a?(String)
      # 名前指定
      a = ($game_party.members + $game_troop.members).find {|b| b.name == val }
      return a
    elsif val.is_a?(Array)
      # インデックス指定
      case val[0]
      when :actor ; return $game_party.members[val[1]]
      when :enemy ; return $game_troop.members[val[1]]
      else        ; return nil
      end
    else
      # オブジェクト
      return val
    end
  end
  #--------------------------------------------------------------------------
  # ● バトルログプッシュ
  #--------------------------------------------------------------------------
  # LNX11.バトルログ(text)
  def self.battle_log_push(text)
    return unless $game_party.in_battle
    case BATTLELOG_TYPE
    when 0..1 # バトルログ
      BattleManager.log_window.add_text(text)
    when 2 # 簡易ヘルプ表示
      BattleManager.helpdisplay_set(text, 0)
    end
  end
  def self.バトルログ(text)
    self.battle_log_push(text)
  end
  #--------------------------------------------------------------------------
  # ● バトルログ消去
  #--------------------------------------------------------------------------
  # LNX11.バトルログ消去
  def self.battle_log_clear
    return unless $game_party.in_battle
    case BATTLELOG_TYPE
    when 0 # バトルログ
      BattleManager.log_window.clear
    when 1 # 蓄積型
      BattleManager.log_window.clear
      $game_temp.battlelog_clear = true
      self.battle_wait(1)
    when 2 # 簡易ヘルプ
      BattleManager.helpdisplay_clear(0)
    end
  end
  def self.バトルログ消去
    self.battle_log_clear
  end
  #--------------------------------------------------------------------------
  # ● バトルウェイト
  #--------------------------------------------------------------------------
  # LNX11.バトルウェイト(duration)
  def self.battle_wait(duration)
    return unless $game_party.in_battle
    BattleManager.log_window.abs_wait(duration)
  end
  def self.バトルウェイト(duration)
    self.battle_wait(duration)
  end
