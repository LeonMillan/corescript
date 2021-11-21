
#==============================================================================
# ■ [追加]:Window_TargetHelp
#------------------------------------------------------------------------------
# 　ターゲットの名前情報やスキルやアイテムの名前を表示します。
#==============================================================================

class Window_TargetHelp < Window_Help
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :random_number  # 効果範囲ランダムの数
  #--------------------------------------------------------------------------
  # ● [オーバーライド]:オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(1) # 1行ヘルプ
  end
  #--------------------------------------------------------------------------
  # ● [オーバーライド]:ウィンドウの非表示
  #--------------------------------------------------------------------------
  def hide
    super
    clear
  end
  #--------------------------------------------------------------------------
  # ● [オーバーライド]:アイテム名設定
  #     item : スキル、アイテム、バトラー等
  #--------------------------------------------------------------------------
  def set_item(item)
    set_text(item ? item : "") # itemの説明ではなく、item自体を渡すようにする
  end
  #--------------------------------------------------------------------------
  # ● ゲージ幅
  #--------------------------------------------------------------------------
  def gauge_width
    LNX11::HELP_PARAM_WIDTH
  end
  #--------------------------------------------------------------------------
  # ● ゲージ幅(余白を含む)
  #--------------------------------------------------------------------------
  def gauge_width_spacing
    LNX11::HELP_PARAM_WIDTH + 4
  end
  #--------------------------------------------------------------------------
  # ● パラメータエリアの幅
  #--------------------------------------------------------------------------
  def param_width(size)
    gauge_width_spacing * size
  end
  #--------------------------------------------------------------------------
  # ● 効果範囲ランダムの数の取得
  #--------------------------------------------------------------------------
  def random_number
    # 全角にして返す
    @random_number.to_s.tr('0-9','０-９')
  end
  #--------------------------------------------------------------------------
  # ● [オーバーライド]:リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    change_color(normal_color)
    if @text == :party
      draw_text(contents.rect, "味方全体", 1)
    elsif @text == :troop
      draw_text(contents.rect, "敵全体", 1)
    elsif @text == :troop_random
      case LNX11::RANDOMSCOPE_DISPLAY
      when 0 ; draw_text(contents.rect, "敵全体 ランダム", 1)
      when 1 ; draw_text(contents.rect, "敵#{random_number}体 ランダム", 1)
      end
    elsif @text.is_a?(Game_Battler)
      # 選択対象の情報を描画
      draw_target_info
    elsif @text.is_a?(RPG::UsableItem)
      # アイテムかスキルならアイテム名を描画
      draw_item_name_help(@text)
    else
      # 通常のテキスト
      super
    end
  end
  #--------------------------------------------------------------------------
  # ● 選択対象の情報の描画
  #--------------------------------------------------------------------------
  def draw_target_info
    # バトラー情報の描画
    param = @text.actor? ? LNX11::HELP_ACTOR_PARAM : LNX11::HELP_ENEMY_PARAM
    # ゲージ付きステータス配列
    status = [param[:hp],param[:mp],param[:tp]&&$data_system.opt_display_tp]
    # 名前
    x = contents_width / 2 - contents.text_size(@text.name).width / 2
    name_width = contents.text_size(@text.name).width + 4
    if !status.include?(true)
      # ゲージ付きステータスを描画しない場合
      draw_targethelp_name(@text, x, name_width, param[:hp])
      x += name_width
      state_width = contents_width - x
    else
      # ゲージ付きステータスを描画する場合
      status.delete(false)
      x -= param_width(status.size) / 2
      draw_targethelp_name(@text, x, name_width, param[:hp])
      x += name_width
      state_width = contents_width - x - param_width(status.size)
    end
    # ステートアイコン
    if param[:state]
      draw_actor_icons(@text, x, 0, state_width)
    end
    # パラメータの描画
    x = contents_width - param_width(status.size)
    # HP
    if param[:hp]
      draw_actor_hp(@text, x, 0, gauge_width)
      x += gauge_width_spacing
    end
    # MP
    if param[:mp]
      draw_actor_mp(@text, x, 0, gauge_width)
      x += gauge_width_spacing
    end
    # TP
    if param[:tp] && $data_system.opt_display_tp
      draw_actor_tp(@text, x, 0, gauge_width)
      x += gauge_width_spacing
    end
  end
  #--------------------------------------------------------------------------
  # ● ターゲットの名前描画
  #--------------------------------------------------------------------------
  def draw_targethelp_name(actor, x, name_width, hp)
    if hp
      # HPゲージを伴う場合(HPが少ない場合、名前の色が変化する)
      draw_actor_name(actor, x, 0, name_width)
    else
      text = actor.name
      draw_text(x, 0, text_size(text).width + 4, line_height, text)
    end
  end
  #--------------------------------------------------------------------------
  # ● アイテムの描画(中央揃え)
  #--------------------------------------------------------------------------
  def draw_item_name_help(item)
    case LNX11::HELPDISPLAY_TYPE
    when 0 # アイコン+名前
      w = contents.text_size(@text.name).width + 28
    when 1 # 名前のみ
      w = contents.text_size(@text.name).width + 4
    end
    # 簡易説明文の描画
    if !@text.short_description.empty?
      des = LNX11::HELPDISPLAY_DESCRIPTION
      contents.font.size = des[:size]
      text = des[:delimiter] + @text.short_description
      rect = contents.text_size(text)
      w += rect.width
      x = (contents_width - w) / 2
      y = (line_height - rect.height) / 2
      draw_text(x, y, w, line_height, text, 2)
      reset_font_settings
    end
    # 名前の描画
    x = (contents_width - w) / 2
    case LNX11::HELPDISPLAY_TYPE
    when 0 # アイコン+名前
      draw_item_name(@text, x, 0, true, w)
    when 1 # 名前のみ
      draw_text(x, 0, contents_width, line_height, @text.name)
    end
  end
end
