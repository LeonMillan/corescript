//-----------------------------------------------------------------------------
/**
 * Advanced drawing functions for Bitmaps
 */

Bitmap.prototype.drawGraphPolygon = function (x, y, graphOptions) {
  const context = this._context;
  const items = graphOptions.items;
  const radius = graphOptions.radius;
  if (!items || !radius) return;

  const { midColor, midOffset, outColor, outOffset, edgeColor, edgeWidth } = {
    ...Utils.DEFAULT_GRAPH_OPTIONS,
    ...graphOptions,
  };

  const itemsPos = Utils.makeGraphPositions(x, y, graphOptions);

  context.save();
  const grad = context.createRadialGradient(
    x,
    y,
    1 + radius * midOffset,
    x,
    y,
    1 + radius * outOffset
  );
  grad.addColorStop(0, midColor);
  grad.addColorStop(1, outColor);

  context.lineJoin = "round";
  context.lineWidth = edgeWidth;
  context.strokeStyle = edgeColor;
  context.fillStyle = grad;
  context.beginPath();
  context.moveTo(...itemsPos[0]);
  for (var i = 1; i < itemsPos.length; i++) {
    context.lineTo(...itemsPos[i]);
  }
  context.closePath();
  context.fill();
  context.stroke();
  context.restore();

  this._setDirty();
};

Bitmap.prototype.drawGraphAxis = function (x, y, graphOptions) {
  const context = this._context;
  const items = graphOptions.items;
  const radius = graphOptions.radius;
  if (!items || !radius) return;

  const { axisColor, axisWidth } = {
    ...Utils.DEFAULT_GRAPH_OPTIONS,
    ...graphOptions,
  };

  const itemsPos = Utils.makeGraphPositions(x, y, graphOptions, 0);

  context.save();
  context.lineJoin = "round";
  context.lineWidth = axisWidth;
  context.strokeStyle = axisColor;
  context.beginPath();
  for (var i = 0; i < itemsPos.length; i++) {
    context.moveTo(x, y);
    context.lineTo(...itemsPos[i]);
  }
  context.closePath();
  context.stroke();
  context.restore();

  this._setDirty();
};
