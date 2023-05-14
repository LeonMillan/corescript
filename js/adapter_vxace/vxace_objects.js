// ============================================================================
//  Game objects bundle

Game_System.prototype.isJapanese = function () {
  return $dataSystem.japanese;
};

Game_System.prototype.isChinese = function () {
  return false;
};

Game_System.prototype.isKorean = function () {
  return false;
};

Game_System.prototype.isCJK = function () {
  return $dataSystem.japanese;
};

Game_System.prototype.isRussian = function () {
  return false;
};

Game_System.prototype.isSideView = function () {
  return false;
};

Game_Map.prototype.tileWidth = function () {
  return 32;
};

Game_Map.prototype.tileHeight = function () {
  return 32;
};

Game_Actor.prototype.equipSlots = function () {
  if (this.isDualWield()) {
    return [0, 0, 2, 3, 4];
  }
  return [0, 1, 2, 3, 4];
};
