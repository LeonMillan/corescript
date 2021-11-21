#==============================================================================
# ■ Bitmap
#==============================================================================

class Bitmap
  #--------------------------------------------------------------------------
  # ● [追加]:カーソル用三角形の描画
  #--------------------------------------------------------------------------
  def lnx_cursor_triangle(size, color, oy = 0, grad = 1)
    color = color.clone
    x = (self.width - size) / 2
    y = (self.height - size) / 2 + oy
    rect = Rect.new(x, y, size, 1)
    count = size / 2
    minus = 128 / count / 2
    count.times do
      clear_rect(rect)
      fill_rect(rect, color)
      color.red   = [color.red   - minus * grad, 0].max
      color.green = [color.green - minus * grad, 0].max
      color.blue  = [color.blue  - minus * grad, 0].max
      rect.y += rect.height
      clear_rect(rect)
      fill_rect(rect, color)
      color.red   = [color.red   - minus * grad, 0].max
      color.green = [color.green - minus * grad, 0].max
      color.blue  = [color.blue  - minus * grad, 0].max
      rect.x += 1
      rect.y += rect.height
      rect.width -= 2
    end
  end
end
