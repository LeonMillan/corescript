//-----------------------------------------------------------------------------
//  Galv's Action Indicators
//-----------------------------------------------------------------------------
//  For: RPGMAKER MV
//  GALV_ActionIndicators.js
//-----------------------------------------------------------------------------
//  2017-05-26 - Version 1.4 - fixed a bug when looking at same icon indicator
//                           - wouldn't do popup effect
//  2015-03-06 - Version 1.3 - now works with events 'under' the player as well
//                           - as counters
//  2015-12-08 - Version 1.2 - added opacity, z and hiding options.
//  2015-12-07 - Version 1.1 - fixed a crash when you deleted events.
//  2015-12-04 - Version 1.0 - release
//-----------------------------------------------------------------------------
// Terms can be found at:
// galvs-scripts.com
//-----------------------------------------------------------------------------
var Imported = Imported || {};
Imported.Galv_ActionIndicators = true;

var Galv = Galv || {};        // Galv's main object
Galv.pCmd = Galv.pCmd || {};  // Plugin Command manager
Galv.AI = Galv.AI || {};      // Galv's plugin stuff


//-----------------------------------------------------------------------------
//  CODE STUFFS
//-----------------------------------------------------------------------------
(function() {
Galv.AI.y = 8;
Galv.AI.z = 5;
Galv.AI.opacity = 188;
Galv.AI.autoHide = true;

Galv.AI.needRefresh = false;
/*
//-----------------------------------------------------------------------------
// Game_System

var Galv_Game_System_initialize = Game_System.prototype.initialize;
Game_System.prototype.initialize = function() {
  Galv_Game_System_initialize.call(this);
  this.actionIndicatorVisible = true;
};

//-----------------------------------------------------------------------------
// Game_Map

var Galv_Game_Map_requestRefresh = Game_Map.prototype.requestRefresh;
Game_Map.prototype.requestRefresh = function(mapId) {
  Galv_Game_Map_requestRefresh.call(this, mapId);
  Galv.AI.needRefresh = true;
};

//-----------------------------------------------------------------------------
// Game_Player

var Galv_Game_CharacterBase_moveStraight = Game_CharacterBase.prototype.moveStraight;
Game_CharacterBase.prototype.moveStraight = function(d) {
  Galv_Game_CharacterBase_moveStraight.call(this, d);
  Galv.AI.needRefresh = true;
};

Galv.AI.checkActionIcon = function() {
  if (!ConfigManager.eventIcons) {
    $gamePlayer.actionIconTarget = { 'eventId': 0, 'iconId': 0 };
    return; 
  }
  
  var x2 = $gameMap.roundXWithDirection($gamePlayer._x, $gamePlayer._direction);
  var y2 = $gameMap.roundYWithDirection($gamePlayer._y, $gamePlayer._direction);
  var action = null;
  
  // CHECK EVENT STANDING ON
  $gameMap.eventsXy($gamePlayer._x, $gamePlayer._y).forEach(function (event) {
    action = Galv.AI.checkEventForIcon(event);
  });
  
  // CHECK EVENT IN FRONT
  if (!action) {
    $gameMap.eventsXy(x2, y2).forEach(function(event) {
      if (event.isNormalPriority()) {
        action = Galv.AI.checkEventForIcon(event);
      };
    });
  };
  
  // CHECK COUNTER
  if (!action && $gameMap.isCounter(x2, y2)) {
    var direction = $gamePlayer.direction();
    var x3 = $gameMap.roundXWithDirection(x2, direction);
    var y3 = $gameMap.roundYWithDirection(y2, direction);

    $gameMap.eventsXy(x3, y3).forEach(function(event) {
      if (event.isNormalPriority()) {
        action = Galv.AI.checkEventForIcon(event);
      };
    });
  };
  action = action || {'eventId': 0, 'iconId': 0};
  $gamePlayer.actionIconTarget = action;
};

Galv.AI.checkEventForIcon = function(event) {
  const eventPage = event.page();
  if (eventPage) {
    var listCount = eventPage.list.length;

    if (listCount > 0 && eventPage.trigger <= 2) {
      const iconId = eventPage.trigger === 0 ? 1 : 2;
      return { eventId: event._eventId, iconId };
    }		
  };

  return null;
};

//-----------------------------------------------------------------------------
// Spriteset_Map

var Galv_Spriteset_Map_createLowerLayer = Spriteset_Map.prototype.createLowerLayer;
Spriteset_Map.prototype.createLowerLayer = function() {
  Galv_Spriteset_Map_createLowerLayer.call(this);
  this.createActionIconSprite();
};

Spriteset_Map.prototype.createActionIconSprite = function() {
  this._actionIconSprite = new Sprite_ActionIcon();
  this._tilemap.addChild(this._actionIconSprite);
};

//-----------------------------------------------------------------------------
// Sprite_ActionIcon

function Sprite_ActionIcon() {
    this.initialize.apply(this, arguments);
}

Sprite_ActionIcon.prototype = Object.create(Sprite.prototype);
Sprite_ActionIcon.prototype.constructor = Sprite_ActionIcon;

Sprite_ActionIcon.prototype.initialize = function() {
  Sprite.prototype.initialize.call(this);
  
  $gamePlayer.actionIconTarget = $gamePlayer.actionIconTarget || {'eventId': 0, 'iconId': 0}; 
  this._iconIndex = 0;
  this.z = Galv.AI.z;
  this.changeBitmap();
  this._tileWidth = $gameMap.tileWidth();
  this._tileHeight = $gameMap.tileHeight();
  this._offsetX = -(Window_Base._iconWidth / 2);
  this._offsetY = -38 + Galv.AI.y;
  this.anchor.y = 1;
  this._float = 0.1;
  this.mod = 0.2;
  Galv.AI.needRefresh = true;
};

Sprite_ActionIcon.prototype.changeBitmap = function() {
  Galv.AI.needRefresh = false;
  
  if ($gamePlayer.actionIconTarget.eventId <= 0) {
    this._iconIndex = 0;
  } else {
    this._iconIndex = $gamePlayer.actionIconTarget.iconId;
  };

  var pw = Window_Base._iconWidth;
  var ph = Window_Base._iconHeight;
  var sx = this._iconIndex % 16 * pw;
  var sy = Math.floor(this._iconIndex / 16) * ph;
  
  this.bitmap = new Bitmap(pw, ph);
  if (this._iconIndex <= 0) return;
  
  var bitmap = ImageManager.loadSystem('ActionIcon');
  this.bitmap.blt(bitmap, sx, sy, pw, ph, 0, 0);
};

Sprite_ActionIcon.prototype.initPopVars = function() {
  this.scale.y = 0.1;
  this.opacity = 0;
  this.mod = 0.2;
  this._float = 0.1;
};

if (Galv.AI.autoHide) {
  Sprite_ActionIcon.prototype.updateOpacity = function() {
    if ($gameMap.isEventRunning()) {
      this.opacity -= 40;
    } else {
      this.opacity = $gameSystem.actionIndicatorVisible ? Galv.AI.opacity : 0;
    };
  };
} else {
  Sprite_ActionIcon.prototype.updateOpacity = function() {
    this.opacity = $gameSystem.actionIndicatorVisible ? Galv.AI.opacity : 0;
  };
};

Sprite_ActionIcon.prototype.update = function() {
    Sprite.prototype.update.call(this);
  
  if (Galv.AI.needRefresh) Galv.AI.checkActionIcon();
  
  if ($gamePlayer.actionIconTarget.eventId != this._eventId) {
    this.initPopVars();
    this._eventId = $gamePlayer.actionIconTarget.eventId;
  }
  
  if (this._iconIndex !== $gamePlayer.actionIconTarget.iconId) this.changeBitmap();
  if (this._iconIndex <= 0) return;

  this.x = $gameMap.event($gamePlayer.actionIconTarget.eventId).screenX() + this._offsetX;
  this.y = $gameMap.event($gamePlayer.actionIconTarget.eventId).screenY() + this._offsetY + this._float;
  this.scale.y = Math.min(this.scale.y + 0.1,1);	
  this.updateOpacity();

  this._float += this.mod;
  if (this._float < -0.1) {
    this.mod = Math.min(this.mod + 0.01, 0.2);
  } else if (this._float >= 0.1) {
    this.mod = Math.max(this.mod - 0.01, -0.2);
  };

};*/

  let refreshCycle = 0;
  function requestRefresh() {
    refreshCycle = (refreshCycle + 1) % 99;
  }

  const _Game_Map__requestRefresh = Game_Map.prototype.requestRefresh;
  Game_Map.prototype.requestRefresh = function (mapId) {
    _Game_Map__requestRefresh.call(this, mapId);
    requestRefresh();
  };

  const _Sprite_Character__setCharacter = Sprite_Character.prototype.setCharacter;
  Sprite_Character.prototype.setCharacter = function (character) {
    _Sprite_Character__setCharacter.call(this, character);
    if (ConfigManager.eventIcons && character instanceof Game_Event) {
      setTimeout(() => {
        this._actionIndicator = new Sprite_ActionIndicator(character);
        this.parent.addChild(this._actionIndicator);
      }, 0);
    }
  };

  const _Game_CharacterBase__setMovementSuccess = Game_CharacterBase.prototype.setMovementSuccess;
  Game_CharacterBase.prototype.setMovementSuccess = function (success) {
    _Game_CharacterBase__setMovementSuccess.call(this, success);
    if (success) requestRefresh();
  };

  const _Game_Interpreter__terminate = Game_Interpreter.prototype.terminate;
  Game_Interpreter.prototype.terminate = function () {
    _Game_Interpreter__terminate.call(this);
    requestRefresh();
  };

  class Sprite_ActionIndicator extends Sprite_Base {
    constructor(character) {
      super(character);
      this.initialize.apply(this, arguments);
    }

    initialize(character) {
      super.initialize();
      this.character = character;
      this.x = character.screenX();
      this.y = character.screenY() - 40;
      this.z = 5;
      this.anchor.x = 0.5;
      this.anchor.y = 1;
      this.opacity = 0;
      this.bounceFactor = 0;
      this.inRadius = this.isWithinRadius();
      this.refreshRef = refreshCycle;
      this.triggerType = this.getTriggerType();
      this.loadBitmap();
    }

    loadBitmap() {
      this.bitmap = ImageManager.loadSystem('ActionIcon');
      this.setFrameCellIndex(32, 32, this.triggerType, 0);
    }

    update() {
      if (this.refreshRef !== refreshCycle) this.refresh();
      if (this.triggerType > 0) {
        this.updateOpacity();
        this.updateBounce();
        this.updatePosition();
      }
      super.update();
    }

    updateOpacity() {
      if ($gameMap.isEventRunning()) {
        this.opacity -= 51;
      } else if (this.inRadius) {
        this.opacity += 17;
      } else {
        this.opacity -= 24;
      }
    }

    updateBounce() {
      this.bounceFactor += 0.1;
      if (this.bounceFactor >= Math.PI) {
        this.bounceFactor -= Math.PI;
      }
    }

    updatePosition() {
      if (this.opacity > 0) {
        this.x = this.character.screenX();
        this.y = this.character.screenY() - 40 - Math.abs(Math.sin(this.bounceFactor)) * 9;
      }
    }

    refresh() {
      const updatedInRadius = this.isWithinRadius();

      if (!this.inRadius && updatedInRadius) {
        this.bounceFactor = -Math.PI;
      }

      this.inRadius = updatedInRadius;
      this.triggerType = this.getTriggerType();
      this.loadBitmap();

      this.refreshRef = refreshCycle;
    }

    isWithinRadius() {
      return this.character.distanceTo($gamePlayer.x, $gamePlayer.y) < 5;
    }

    getTriggerType() {
      if (!this.character.isTriggerIn([0, 1, 2])) return 0;
      
      const eventList = this.character.list();
      const hasCommands = eventList.some((item) => item.code !== 0);
      if (!hasCommands) return 0;

      return this.character._trigger === 0 ? 1 : 2;
    }
  }

})();
