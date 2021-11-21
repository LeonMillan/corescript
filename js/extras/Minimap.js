// Source: https://www.youtube.com/watch?v=4KQSqXZqa50
/** /*:
 * @author William Ramsey
 * @plugindesc Minimap
 */

(() => {
  const params = {
    'Enable Automatic Drawing': true,
    'Enable Region Drawing': false,

    'Location':         'TOPLEFT',
    'Background':       'rgba(20, 166, 136, 0.6)',
    'PlayerColor':      'rgba(255, 240, 200, 1)',
    'EventColorMove':   'rgba(255, 244, 44, 0.7)',
    'EventColorFixed':  'rgba(44, 255, 88, 0.7)',
    'Outline Color':    'rgba(12, 204, 180, 0.5)',
    'Impassable Color': 'rgba(22, 40, 50, 0.5)',
    'Disable Outline':  true,
  };

  const MAP_CELL = 6;

  const FOW_CELL = 3;
  const FOW_CELLSIZE = 6 * FOW_CELL;

  const FOW_SCALE = 8;
  const FOW_BRUSH = [1, 1, 1, .9, .9, .7, .5, .3, .2];

  let lastFogX = null;
  let lastFogY = null;
  let scalingDelta = 0;

  const sms = Scene_Map.prototype.start;
  Scene_Map.prototype.start = function () {
    sms.apply(this, arguments);
    // Create minimap bitmap and overlay

    if (!$gameVariables.snapMapShow) { $gameVariables.snapMapShow = true; }

    this.snapMinimapBitmap = new Bitmap($dataMap.width * 6, $dataMap.height * 6);
    this.snapMinimapOverlay = new Bitmap($dataMap.width * 6, $dataMap.height * 6);

    this.snapMinimapBitmap.fillAll(params['Background']);

    //Create shadow array
    if (!$gameVariables.FOG_MAPS) {
      $gameVariables.FOG_MAPS = {};
    }

    if (!$gameVariables.FOG_MAPS[$gameMap._mapId]) {
      $gameVariables.FOG_MAPS[$gameMap._mapId] = {};
      for (let i = 0; i < $dataMap.width; i += FOW_CELL) {
        for (let j = 0; j < $dataMap.height; j += FOW_CELL) {
          $gameVariables.FOG_MAPS[$gameMap._mapId][String(i) + 'x' + String(j)] = 0;
        }
      }
    }

    const blurEffect = 'blur(4px)';
    this.snapMinimapFow = new Bitmap($dataMap.width * 6, $dataMap.height * 6);
    // this.snapMinimapFow.__canvas.style.filter = blurEffect;
    // this.snapMinimapFow.__canvas.style.webkitFilter = blurEffect;
    // this.snapMinimapFow.context.filter = blurEffect;
    this.snapMinimapFow.fillAll('#000');

    for (let i = 0; i < $dataMap.width; i += FOW_CELL) {
      for (let j = 0; j < $dataMap.height; j += FOW_CELL) {
        const target = $gameVariables.FOG_MAPS[$gameMap._mapId][String(i) + 'x' + String(j)];
        if (target > 0) {
          const colorVal = Math.floor(target / FOW_SCALE * 255);
          const color = `rgba(${colorVal}, ${colorVal}, ${colorVal}, 1)`;
          this.snapMinimapFow.fillRect(i * MAP_CELL, j * MAP_CELL, FOW_CELLSIZE, FOW_CELLSIZE, color);
        }
      }
    }

    for (let i = 0; i < $dataMap.width; i++) {
      for (let j = 0; j < $dataMap.height; j++) {
        if (params['Enable Automatic Drawing']) {
          if (!$gameMap.checkPassage(i, j, 0x0f)) {
            if (!params['Disable Outline']) {
              this.snapMinimapBitmap.fillRect(i * 6, 1 + j * 6, 6, 6, params['Outline Color']);
              this.snapMinimapBitmap.clearRect(i * 6, j * 6, 6, 5);
            }
            this.snapMinimapBitmap.fillRect(i * 6, j * 6, 6, 6, params['Impassable Color']);
          }
        }
      }
    }

    this.snapMinimapRender = new Sprite(this.snapMinimapBitmap);
    this.snapMinimapAct = new Sprite(this.snapMinimapOverlay);
    this.snapMinimapFowS = new Sprite(this.snapMinimapFow);

    this.snapMinimapRender.z = 2;
    this.snapMinimapAct.z = 3;
    this.snapMinimapFowS.z = 3;

    let locx; let anchorx;
    let locy; let anchory;

    switch (params['Location']) {
      case 'TOPLEFT':
        locx = 8;
        locy = 8;
        anchorx = 0;
        anchory = 0;
        break;

      case 'TOPRIGHT':
        locx = Graphics.boxWidth - 8;
        locy = 8;
        anchorx = 1;
        anchory = 0;
        break;

      case 'BOTTOMRIGHT':
        locx = Graphics.boxWidth - 8;
        locy = Graphics.boxHeight - 8;
        anchorx = 1;
        anchory = 1;
        break;

      case 'BOTTOMLEFT':
        locx = 8;
        locy = Graphics.boxHeight - 8;
        anchorx = 0;
        anchory = 1;
        break;
    }

    this.snapMinimapRender.move(locx, locy);
    this.snapMinimapRender.anchor.x = anchorx;
    this.snapMinimapRender.anchor.y = anchory;
    this.snapMinimapAct.move(locx, locy);
    this.snapMinimapAct.anchor.x = anchorx;
    this.snapMinimapAct.anchor.y = anchory;
    this.snapMinimapFowS.move(locx, locy);
    this.snapMinimapFowS.anchor.x = anchorx;
    this.snapMinimapFowS.anchor.y = anchory;

    this.mapViewToggle = false;
    
    this.snapMinimapFowS.blendMode = PIXI.BLEND_MODES.MULTIPLY;
    this.snapMinimapFowS.opacity = 212;

    this._spriteset.addChild(this.snapMinimapRender);
    this._spriteset.addChild(this.snapMinimapFowS);
    this._spriteset.addChild(this.snapMinimapAct);
  }

  const smu = Scene_Map.prototype.update;
  Scene_Map.prototype.update = function () {
    smu.apply(this, arguments);
    this.snapMinimapOverlay.clear();
    if ($gameVariables.snapMapShow) {
      $gameMap.events().forEach((event) => {
        const eventPage = event.page();
        if (!eventPage) return;

        const hasCommands = eventPage.list.some((item) => item.code !== 0);
        const _x = event._realX;
        const _y = event._realY;

        if (!hasCommands || eventPage.trigger > 2) return;

        const isNPC = (
          eventPage.moveType !== 0
          || eventPage.image.characterName
        );

        if (isNPC) {
          this.snapMinimapOverlay.drawCircle(
            3 + _x * 6,
            3 + _y * 6,
            2,
            params['EventColorMove'],
          );
        } else {
          this.snapMinimapOverlay.fillRect(
            _x * 6,
            _y * 6,
            6,
            6,
            params['EventColorFixed'],
          );
        }
      });
      this.snapMinimapOverlay.drawCircle(3 + $gamePlayer._realX * 6, 3 + $gamePlayer._realY * 6, 2, params['PlayerColor']);

      let _x = Math.floor($gamePlayer._x / FOW_CELL) * FOW_CELL;
      let _y = Math.floor($gamePlayer._y / FOW_CELL) * FOW_CELL;

      if (_x !== lastFogX || _y !== lastFogY) {
        lastFogX = _x;
        lastFogY = _y;
        const brushSize = FOW_BRUSH.length;
        const fogMap = $gameVariables.FOG_MAPS[$gameMap._mapId];

        for (let i = 0; i < brushSize; i++) {
          for (let j = 0; j < brushSize; j++) {
            const dist = Math.floor(Math.hypot(i, j));
            const intensity = FOW_BRUSH[dist] || 0;
            if (!intensity) continue;
            
            const scaledVal = Math.round(intensity * FOW_SCALE);
            const colorVal = Math.floor(intensity * 255);
            const color = `rgba(${colorVal}, ${colorVal}, ${colorVal}, 1)`;

            if (scaledVal > fogMap[String(_x + i) + 'x' + String(_y + j)]) {
              fogMap[String(_x + i) + 'x' + String(_y + j)] = scaledVal;
              this.snapMinimapFow.fillRect((_x + i) * MAP_CELL, (_y + j) * MAP_CELL, FOW_CELLSIZE, FOW_CELLSIZE, color);
            }
            if (scaledVal > fogMap[String(_x - i) + 'x' + String(_y + j)]) {
              fogMap[String(_x - i) + 'x' + String(_y + j)] = scaledVal;
              this.snapMinimapFow.fillRect((_x - i) * MAP_CELL, (_y + j) * MAP_CELL, FOW_CELLSIZE, FOW_CELLSIZE, color);
            }
            if (scaledVal > fogMap[String(_x + i) + 'x' + String(_y - j)]) {
              fogMap[String(_x + i) + 'x' + String(_y - j)] = scaledVal;
              this.snapMinimapFow.fillRect((_x + i) * MAP_CELL, (_y - j) * MAP_CELL, FOW_CELLSIZE, FOW_CELLSIZE, color);
            }
            if (scaledVal > fogMap[String(_x - i) + 'x' + String(_y - j)]) {
              fogMap[String(_x - i) + 'x' + String(_y - j)] = scaledVal;
              this.snapMinimapFow.fillRect((_x - i) * MAP_CELL, (_y - j) * MAP_CELL, FOW_CELLSIZE, FOW_CELLSIZE, color);
            }
          }
        }
      }
    }

    this.snapMinimapRender.opacity += ($gameMap.isEventRunning() || !$gameVariables.snapMapShow) ? -50 : 50;
    this.snapMinimapAct.opacity = this.snapMinimapRender.opacity;
    this.snapMinimapFowS.opacity = this.snapMinimapRender.opacity * 0.8;
    
    if (this.mapViewToggle) {
      scalingDelta = lerpStep(scalingDelta, 1.0, 0.4);
    } else {
      scalingDelta = lerpStep(scalingDelta, 0.0, 0.5);
    }
    const scale = lerp(1, 1.5, scalingDelta);

    this.snapMinimapRender.transform.scale.x = scale;
    this.snapMinimapRender.transform.scale.y = scale;
    this.snapMinimapAct.transform.scale.x = scale;
    this.snapMinimapAct.transform.scale.y = scale;
    this.snapMinimapFowS.transform.scale.x = scale;
    this.snapMinimapFowS.transform.scale.y = scale;

    let locx; let anchorx;
    let locy; let anchory;

    switch (params['Location']) {
      case 'TOPLEFT':
        locx = 8;
        locy = 8;
        anchorx = 0;
        anchory = 0;
        break;

      case 'TOPRIGHT':
        locx = Graphics.boxWidth - 8;
        locy = 8;
        anchorx = 1;
        anchory = 0;
        break;

      case 'BOTTOMRIGHT':
        locx = Graphics.boxWidth - 8;
        locy = Graphics.boxHeight - 8;
        anchorx = 1;
        anchory = 1;
        break;

      case 'BOTTOMLEFT':
        locx = 8;
        locy = Graphics.boxHeight - 8;
        anchorx = 0;
        anchory = 1;
        break;
    }

    this.snapMinimapRender.move(locx, locy);
    this.snapMinimapRender.anchor.x = anchorx;
    this.snapMinimapRender.anchor.y = anchory;
    this.snapMinimapAct.move(locx, locy);
    this.snapMinimapAct.anchor.x = anchorx;
    this.snapMinimapAct.anchor.y = anchory;
    this.snapMinimapFowS.move(locx, locy);
    this.snapMinimapFowS.anchor.x = anchorx;
    this.snapMinimapFowS.anchor.y = anchory;

    const viewportWidth = lerp(128, 256, scalingDelta);
    const viewportHeight = lerp(128, 256, scalingDelta);
    let frameX = $gamePlayer._realX * 6 - viewportWidth / 2;
    let frameY = $gamePlayer._realY * 6 - viewportHeight / 2;
    if ($dataMap.width * 6 > viewportWidth) {
      frameX = frameX.clamp(0, $dataMap.width * 6 - viewportWidth);
    } else {
      frameX = viewportWidth * anchorx;
    }
    if ($dataMap.height * 6 > viewportHeight) {
      frameY = frameY.clamp(0, $dataMap.height * 6 - viewportHeight);
    } else {
      frameY = viewportHeight * anchory;
    }

    this.snapMinimapRender.setFrame(frameX, frameY, viewportWidth, viewportHeight);
    this.snapMinimapAct.setFrame(frameX, frameY, viewportWidth, viewportHeight);
    this.snapMinimapFowS.setFrame(frameX, frameY, viewportWidth, viewportHeight);

    if (!$gameMap.isEventRunning()) {
      if (!$gameVariables.snapMapShow && Input.isTriggered('map')) {
        $gameVariables.snapMapShow = true;
        SoundManager.playEquip();

      } else if ($gameVariables.snapMapShow && Input.isLongPressed('map')) {
        $gameVariables.snapMapShow = false;
        SoundManager.playEquip();

      } else if (Input.isTriggered('map')) {
        this.mapViewToggle = !this.mapViewToggle;
        try {
          AudioManager.playSe({
            name: 'Miss',
            volume: 80,
            pitch: 130,
          });
        } catch (err) {
          // Ignore
        }
      }
    }
  }

  function lerp(from, to, delta) {
    return from + (to - from) * delta;
  }

  function lerpStep(from, to, delta) {
    if (Math.abs((to - from) * delta) < 0.01) return to;
    return from + (to - from) * delta;
  }
})();
