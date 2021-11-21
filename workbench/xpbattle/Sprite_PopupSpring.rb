
#==============================================================================
# ■ [追加]:Sprite_PopupSpring
#------------------------------------------------------------------------------
# 　通常の跳ねるポップアップ。
#==============================================================================

class Sprite_PopupSpring < Sprite_PopupBase
  #--------------------------------------------------------------------------
  # ● ポップアップ Z 座標
  #--------------------------------------------------------------------------
  def base_z
    14
  end
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  def start
    # 動き設定
    set_movement
    # ディレイ設定 同じタイプのポップアップが重ならないようにする
    if @popup_size == :small
      self.oy -= @battler.popup_delay[1]
      @delay_clear = (@delay == 0)
      dy = self.bitmap.height * 0.8
      @battler.popup_delay[1] += dy
      @delay = 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 終了処理
  #--------------------------------------------------------------------------
  def terminate
    # 一番上のポップアップなら、ディレイを初期化する
    @battler.popup_delay[1] = 0 if @delay_clear
  end
  #--------------------------------------------------------------------------
  # ● 投射運動の設定
  #--------------------------------------------------------------------------
  def set_movement
    if @popup_size == :large
      movement = LNX11::LARGE_MOVEMENT
    else
      movement = LNX11::SMALL_MOVEMENT
    end
    @fall       = -movement[:inirate]
    @gravity    =  movement[:gravity]
    @side       =  movement[:side_scatter] * rand(0) * (rand(2) == 0 ? -1 : 1)
    @ref_move   =  movement[:ref_height]
    @ref_factor =  movement[:ref_factor]
    @ref_count  =  movement[:ref_count]
    @duration   =  movement[:duration]
    @fadeout    =  movement[:fadeout]
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update_popup
    update_freefall
  end
  #--------------------------------------------------------------------------
  # ● 投射運動の更新
  #--------------------------------------------------------------------------
  def update_freefall
    if @ref_count >= 0
      # X:左右移動
      @rx += @side
      # Y:自由落下
      @ry += @fall
      @ref_move -= @fall
      @fall += @gravity
      # 跳ね返り
      if @ref_move <= 0 && @fall >= 0
        @ref_count -= 1
        @fall = -@fall * @ref_factor
      end
    end
  end
end
