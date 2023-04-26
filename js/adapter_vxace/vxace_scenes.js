// ============================================================================
//  Scenes, windows and sprites

Sprite_StateIcon._iconWidth   = 24;
Sprite_StateIcon._iconHeight  = 24;

Window_Command.prototype.windowWidth = function () {
  return 192;
};

Window_TitleCommand.prototype.windowWidth = function () {
  return 160;
};

Window_MenuCommand.prototype.windowWidth = function () {
  return 160;
};

Window_PartyCommand.prototype.windowWidth = function () {
  return 160;
};

Window_ActorCommand.prototype.windowWidth = function () {
  return 160;
};

Window_BattleStatus.prototype.windowWidth = function () {
  return Graphics.boxWidth - 160;
};

Window_BattleEnemy.prototype.windowWidth = function () {
  return Graphics.boxWidth - 160;
};

Window_Gold.prototype.windowWidth = function () {
  return 160;
};

Window_MapName.prototype.windowWidth = function () {
  return 240;
};

Window_MenuStatus.prototype.windowWidth = function () {
  return Graphics.boxWidth - 160;
};

Window_EquipStatus.prototype.windowWidth = function () {
  return 208;
};

Window_ShopBuy.prototype.windowWidth = function () {
  return 304;
};

Window_ShopNumber.prototype.windowWidth = function () {
  return 304;
};

Window_SkillType.prototype.windowWidth = function () {
  return 160;
};

Window_NameEdit.prototype.windowWidth = function () {
  return 360;
};

Window_Options.prototype.windowWidth = function () {
  return 320;
};

Window_Status.prototype.refresh = function () {
  this.contents.clear();
  if (this._actor) {
    var lineHeight = this.lineHeight();
    this.drawBlock1(lineHeight * 0);
    this.drawHorzLine(lineHeight * 1);
    this.drawBlock2(lineHeight * 3);
    this.drawHorzLine(lineHeight * 8);
    this.drawBlock3(lineHeight * 9);
    this.drawHorzLine(lineHeight * 15);
    this.drawBlock4(lineHeight * 16);
  }
};

Window_Status.prototype.drawBlock1 = function (y) {
  this.drawActorName(this._actor, 6, y);
  this.drawActorClass(this._actor, 152, y);
  this.drawActorNickname(this._actor, 432, y);
};

Window_Status.prototype.drawBlock2 = function (y) {
  this.drawActorFace(this._actor, 12, y);
  this.drawBasicInfo(152, y);
  this.drawExpInfo(320, y);
};

Window_Status.prototype.drawBlock3 = function (y) {
  this.drawParameters(40, y);
  this.drawEquipments(360, y);
};

Window_Status.prototype.drawBlock4 = function (y) {
  this.drawProfile(32, y);
};

Window_MenuStatus.prototype.drawItemImage = function(index) {
  var actor = $gameParty.members()[index];
  var rect = this.itemRect(index);
  this.changePaintOpacity(actor.isBattleMember());
  this.drawActorFace(actor, rect.x + 8, rect.y + 8, Window_Base._faceWidth, Window_Base._faceHeight);
  this.changePaintOpacity(true);
};

Window_MenuStatus.prototype.drawItemStatus = function(index) {
  var actor = $gameParty.members()[index];
  var rect = this.itemRect(index);
  var x = rect.x + 128;
  var y = rect.y + rect.height / 2 - this.lineHeight() * 1.5;
  var width = rect.width - x - this.textPadding();
  this.drawActorSimpleStatus(actor, x, y, width);
};

Window_EquipStatus.prototype.drawItem = function (x, y, paramId) {
  this.drawParamName(x + this.textPadding(), y, paramId);
  if (this._actor) {
    this.drawCurrentParam(x + 80, y, paramId);
  }
  this.drawRightArrow(x + 80 + 48, y);
  if (this._tempActor) {
    this.drawNewParam(x + 80 + 48 + 34, y, paramId);
  }
};

Window_SkillStatus.prototype.refresh = function () {
  this.contents.clear();
  if (this._actor) {
    var w = this.width - this.padding * 2;
    var h = this.height - this.padding * 2;
    var y = h / 2 - this.lineHeight() * 1.5;
    var width = w - 162 - this.textPadding();
    this.drawActorFace(this._actor, 8, 0, 96, h);
    this.drawActorSimpleStatus(this._actor, 152, y, width);
  }
};

Spriteset_Battle.prototype.createBattleback = function () {
  this._back1Sprite = new Sprite();
  this._back1Sprite.bitmap = this.battleback1Bitmap();
  this._back1Sprite.x = Graphics.width / 2;
  this._back1Sprite.y = Graphics.height / 2;
  this._back1Sprite.anchor.x = 0.5;
  this._back1Sprite.anchor.y = 0.5;

  this._back2Sprite = new Sprite();
  this._back2Sprite.bitmap = this.battleback2Bitmap();
  this._back2Sprite.x = Graphics.width / 2;
  this._back2Sprite.y = Graphics.height / 2;
  this._back2Sprite.anchor.x = 0.5;
  this._back2Sprite.anchor.y = 0.5;

  this._battleField.addChild(this._back1Sprite);
  this._battleField.addChild(this._back2Sprite);
};

Spriteset_Battle.prototype.locateBattleback = function () {
  var margin = 32;
  var width = Graphics.width + margin * 2;
  var height = Graphics.height + margin * 2;

  const scaleRatio1 = Math.max(
    width / this._back1Sprite.bitmap.width,
    height / this._back1Sprite.bitmap.height
  );
  this._back1Sprite.scale.x = scaleRatio1;
  this._back1Sprite.scale.y = scaleRatio1;

  const scaleRatio2 = Math.max(
    width / this._back2Sprite.bitmap.width,
    height / this._back2Sprite.bitmap.height
  );
  this._back2Sprite.scale.x = scaleRatio2;
  this._back2Sprite.scale.y = scaleRatio2;
};
