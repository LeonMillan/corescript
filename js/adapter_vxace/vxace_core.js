// ============================================================================
//  Core bundle

Bitmap.minFontSize = 36;

redefine(Bitmap.prototype, 'initialize', function (method, ...args) {
  method(...args);
  this.fontSize = 20;
  this.outlineColor = "rgba(0, 0, 0, 0)";
  this.outlineWidth = 3;
});

redefine(Tilemap.prototype, 'initialize', function (method, ...args) {
  method(...args);
  this._tileWidth = 32;
  this._tileHeight = 32;
});

redefine(Graphics, '_setupProgress', function (method, ...args) {
  method(...args);
  this._progressElement.width = 400;
  this._progressElement.height = 300;
});

Input.rgssKeyCodes = {
  2: "down",
  4: "left",
  6: "right",
  8: "up",

  11: "shift",    // A
  12: "cancel",   // B
  13: "ok",       // C
  14: "",         // X
  15: "",         // Y
  16: "",         // Z
  17: "pageup",   // L
  18: "pagedown", // R
};

Input.asKey = function (keyName) {
  return (typeof keyName === "number") ? Input.rgssKeyCodes[keyName] : keyName;
};

redefine(Input, "isPressed", function(method, keyName) {
  return method(Input.asKey(keyName));
});

redefine(Input, "isTriggered", function (method, keyName) {
  return method(Input.asKey(keyName));
});

redefine(Input, "isRepeated", function (method, keyName) {
  return method(Input.asKey(keyName));
});

redefine(Input, "isLongPressed", function (method, keyName) {
  return method(Input.asKey(keyName));
});

ShaderTilemap.prototype._paintTiles = function (startX, startY, x, y) {
  // Changed since VX Ace doesn't have the same number of layers
  var mx = startX + x;
  var my = startY + y;
  var dx = x * this._tileWidth,
      dy = y * this._tileHeight;

  var tileId0 = this._readMapData(mx, my, 0);
  var tileId1 = this._readMapData(mx, my, 1);
  var tileId2 = this._readMapData(mx, my, 2);
  var shadowBits = this._readMapData(mx, my, 3);
  var upperTileId1 = this._readMapData(mx, my - 1, 1);
  var lowerLayer = this.lowerLayer.children[0];
  var upperLayer = this.upperLayer.children[0];

  this._drawTile(this._isHigherTile(tileId0) ? upperLayer : lowerLayer, tileId0, dx, dy);
  this._drawTile(this._isHigherTile(tileId1) ? upperLayer : lowerLayer, tileId1, dx, dy);

  this._drawShadow(lowerLayer, shadowBits, dx, dy);

  if (this._isTableTile(upperTileId1) && !this._isTableTile(tileId1)) {
    if (!Tilemap.isShadowingTile(tileId0)) {
      this._drawTableEdge(lowerLayer, upperTileId1, dx, dy);
    }
  }

  if (this._isOverpassPosition(mx, my)) {
    this._drawTile(upperLayer, tileId2, dx, dy);
  } else {
    this._drawTile(this._isHigherTile(tileId2) ? upperLayer : lowerLayer, tileId2, dx, dy);
  }
};

Tilemap.prototype._paintTiles = function (startX, startY, x, y) {
  var tableEdgeVirtualId = 10000;
  var mx = startX + x;
  var my = startY + y;
  var dx = (mx * this._tileWidth).mod(this._layerWidth);
  var dy = (my * this._tileHeight).mod(this._layerHeight);
  var lx = dx / this._tileWidth;
  var ly = dy / this._tileHeight;
  var tileId0 = this._readMapData(mx, my, 0);
  var tileId1 = this._readMapData(mx, my, 1);
  var tileId2 = this._readMapData(mx, my, 2);
  var shadowBits = this._readMapData(mx, my, 3);
  var upperTileId1 = this._readMapData(mx, my - 1, 1);
  var lowerTiles = [];
  var upperTiles = [];

  if (this._isHigherTile(tileId0)) {
    upperTiles.push(tileId0);
  } else {
    lowerTiles.push(tileId0);
  }
  if (this._isHigherTile(tileId1)) {
    upperTiles.push(tileId1);
  } else {
    lowerTiles.push(tileId1);
  }

  lowerTiles.push(-shadowBits);

  if (this._isTableTile(upperTileId1) && !this._isTableTile(tileId1)) {
    if (!Tilemap.isShadowingTile(tileId0)) {
      lowerTiles.push(tableEdgeVirtualId + upperTileId1);
    }
  }

  if (this._isOverpassPosition(mx, my)) {
    upperTiles.push(tileId2);
  } else {
    if (this._isHigherTile(tileId2)) {
      upperTiles.push(tileId2);
    } else {
      lowerTiles.push(tileId2);
    }
  }

  var lastLowerTiles = this._readLastTiles(0, lx, ly);
  if (
    !lowerTiles.equals(lastLowerTiles) ||
    (Tilemap.isTileA1(tileId0) && this._frameUpdated)
  ) {
    this._lowerBitmap.clearRect(dx, dy, this._tileWidth, this._tileHeight);
    for (var i = 0; i < lowerTiles.length; i++) {
      var lowerTileId = lowerTiles[i];
      if (lowerTileId < 0) {
        this._drawShadow(this._lowerBitmap, shadowBits, dx, dy);
      } else if (lowerTileId >= tableEdgeVirtualId) {
        this._drawTableEdge(this._lowerBitmap, upperTileId1, dx, dy);
      } else {
        this._drawTile(this._lowerBitmap, lowerTileId, dx, dy);
      }
    }
    this._writeLastTiles(0, lx, ly, lowerTiles);
  }

  var lastUpperTiles = this._readLastTiles(1, lx, ly);
  if (!upperTiles.equals(lastUpperTiles)) {
    this._upperBitmap.clearRect(dx, dy, this._tileWidth, this._tileHeight);
    for (var j = 0; j < upperTiles.length; j++) {
      this._drawTile(this._upperBitmap, upperTiles[j], dx, dy);
    }
    this._writeLastTiles(1, lx, ly, upperTiles);
  }
};

Decrypter.readEncryptionkey = function () {
  // Encryption not implemented for VX Ace adapter
  this._encryptionKey = '';
};
