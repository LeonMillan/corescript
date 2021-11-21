
#==============================================================================
# ■ RPG::State
#------------------------------------------------------------------------------
# 　ステートのデータクラス。
#==============================================================================

class RPG::State < RPG::BaseItem
  #--------------------------------------------------------------------------
  # ● [追加]:ステートアニメの取得
  #--------------------------------------------------------------------------
  def state_animation
    # キャッシュがある場合、それを返す
    return @state_animation if @state_animation
    # メモ取得
    re = LNX11::RE_STATE_ANIMATION =~ note
    @state_animation = re ? $1.to_i : 0
  end
  #--------------------------------------------------------------------------
  # ● [追加]:ポップアップ表示名の取得
  # <<ver1.10>>
  # 　このメソッドは付加/解除ポップアップ表示名が設定されていない場合のみ
  # 呼び出されるようになりました。
  #--------------------------------------------------------------------------
  def display_name
    # キャッシュがある場合、それを返す
    return @display_name if @display_name
    # メモ取得
    re = LNX11::RE_STATE_DISPLAY =~ note
    @display_name = re ? $1 : name
  end
  #--------------------------------------------------------------------------
  # ● [追加]:付加ポップアップ表示名の取得 <<ver1.10>>
  #--------------------------------------------------------------------------
  def add_display_name
    # キャッシュがある場合、それを返す
    return @add_display_name if @add_display_name
    # メモ取得
    re = LNX11::RE_STATE_ADD_DISPLAY =~ note
    @add_display_name = re ? $1 : display_name
  end
  #--------------------------------------------------------------------------
  # ● [追加]:解除ポップアップ表示名の取得 <<ver1.10>>
  #--------------------------------------------------------------------------
  def remove_display_name
    # キャッシュがある場合、それを返す
    return @remove_display_name if @remove_display_name
    # メモ取得
    re = LNX11::RE_STATE_REM_DISPLAY =~ note
    @remove_display_name = re ? $1 : display_name
  end
  #--------------------------------------------------------------------------
  # ● [追加]:ポップアップ非表示の取得
  #--------------------------------------------------------------------------
  def no_display?
    # キャッシュがある場合、それを返す
    return @no_display if @no_display
    # 付加/解除のどちらかで設定されていれば無視する
    if LNX11::RE_STATE_ADD_NO_DISPLAY =~ note ||
       LNX11::RE_STATE_REM_NO_DISPLAY =~ note
      return @no_display = false
    end
    # メモ取得
    re = LNX11::RE_STATE_NO_DISPLAY =~ note
    @no_display = re ? true : false
  end
  #--------------------------------------------------------------------------
  # ● [追加]:付加ポップアップ非表示の取得
  #--------------------------------------------------------------------------
  def add_no_display?
    return true if no_display?
    # キャッシュがある場合、それを返す
    return @add_no_display if @add_no_display
    # メモ取得
    re = LNX11::RE_STATE_ADD_NO_DISPLAY =~ note
    @add_no_display = re ? true : false
  end
  #--------------------------------------------------------------------------
  # ● [追加]:解除ポップアップ非表示の取得
  #--------------------------------------------------------------------------
  def remove_no_display?
    return true if no_display?
    # キャッシュがある場合、それを返す
    return @remove_no_display if @remove_no_display
    # メモ取得
    re = LNX11::RE_STATE_REM_NO_DISPLAY =~ note
    @remove_no_display = re ? true : false
  end
  #--------------------------------------------------------------------------
  # ● [追加]:有利なステートの取得
  #--------------------------------------------------------------------------
  def advantage?
    # キャッシュがある場合、それを返す
    return @advantage if @advantage
    # メモ取得
    re = LNX11::RE_STATE_ADVANTAGE =~ note
    @advantage = re ? true : false
  end
  #--------------------------------------------------------------------------
  # ● [追加]:ポップアップタイプの取得
  #--------------------------------------------------------------------------
  def popup_type
    # キャッシュがある場合、それを返す
    return @popup_type if @popup_type != nil
    # 付加/解除のどちらかで設定されていれば無視する
    if LNX11::RE_STATE_ADD_TYPE =~ note ||
       LNX11::RE_STATE_REM_TYPE =~ note
      return @popup_type = false
    end
    # メモ取得
    re = LNX11::RE_STATE_TYPE =~ note
    @popup_type = re ? $1.to_i : false
  end
  #--------------------------------------------------------------------------
  # ● [追加]:付加ポップアップタイプの取得
  #--------------------------------------------------------------------------
  def add_popup_type
    return popup_type if popup_type
    # キャッシュがある場合、それを返す
    return @add_popup_type if @add_popup_type != nil
    # メモ取得
    re = LNX11::RE_STATE_ADD_TYPE =~ note
    @add_popup_type = re ? $1.to_i : false
  end
  #--------------------------------------------------------------------------
  # ● [追加]:解除ポップアップタイプの取得
  #--------------------------------------------------------------------------
  def remove_popup_type
    return popup_type if popup_type
    # キャッシュがある場合、それを返す
    return @remove_popup_type if @remove_popup_type != nil
    # メモ取得
    re = LNX11::RE_STATE_REM_TYPE =~ note
    @remove_popup_type = re ? $1.to_i : false
  end
  #--------------------------------------------------------------------------
  # ● [追加]:修飾文字非表示の取得
  #--------------------------------------------------------------------------
  def no_decoration?
    # キャッシュがある場合、それを返す
    return @no_decoration if @no_decoration
    # 付加/解除のどちらかで設定されていれば無視する
    if LNX11::RE_STATE_ADD_NO_DECORATION =~ note ||
       LNX11::RE_STATE_REM_NO_DECORATION =~ note
      return @no_decoration = false
    end
    # メモ取得
    re = LNX11::RE_STATE_NO_DECORATION =~ note
    @no_decoration = re ? true : false
  end
  #--------------------------------------------------------------------------
  # ● [追加]:付加修飾文字非表示の取得
  #--------------------------------------------------------------------------
  def add_no_decoration?
    return true if no_decoration?
    # キャッシュがある場合、それを返す
    return @add_no_decoration if @add_no_decoration
    # メモ取得
    re = LNX11::RE_STATE_ADD_NO_DECORATION =~ note
    @add_no_decoration = re ? true : false
  end
  #--------------------------------------------------------------------------
  # ● [追加]:解除修飾文字非表示の取得
  #--------------------------------------------------------------------------
  def remove_no_decoration?
    return true if no_decoration?
    # キャッシュがある場合、それを返す
    return @remove_no_decoration if @remove_no_decoration
    # メモ取得
    re = LNX11::RE_STATE_REM_NO_DECORATION =~ note
    @remove_no_decoration = re ? true : false
  end
end
