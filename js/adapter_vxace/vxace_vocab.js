const RubyVocab = {
  // Shop Screen
  shopBuy         : "Buy",
  shopSell        : "Sell",
  shopCancel      : "Cancel",
  possession      : "Possession",

  // Status Screen
  expTotal        : "Current Exp",
  expNext         : "To Next %1",

  // Save/Load Screen
  saveMessage     : "Save to which file?",
  loadMessage     : "Load which file?",
  file            : "File",

  // Display when there are multiple members
  partyName       : "%1's Party",

  // Basic Battle Messages
  emerge          : "%1 emerged!",
  preemptive      : "%1 got the upper hand!",
  surprise        : "%1 was surprised!",
  escapeStart     : "%1 has started to escape!",
  escapeFailure   : "However, it was unable to escape!",

  // Battle Ending Messages
  victory         : "%1 was victorious!",
  defeat          : "%1 was defeated.",
  obtainExp       : "%1 EXP received!",
  obtainGold      : "%1\\G found!",
  obtainItem      : "%1 found!",
  levelUp         : "%1 is now %2 %3!",
  obtainSkill     : "%1 learned!",

  // Use Item
  useItem         : "%1 uses %2!",

  // Critical Hit
  criticalToEnemy : "An excellent hit!!",
  criticalToActor : "A painful blow!!",

  // Results for Actions on Actors
  actorDamage     : "%1 took %2 damage!",
  actorRecovery   : "%1 recovered %2 %3!",
  actorGain       : "%1 gained %2 %3!",
  actorLoss       : "%1 lost %2 %3!",
  actorDrain      : "%1 was drained of %2 %3!",
  actorNoDamage   : "%1 took no damage!",
  actorNoHit      : "Miss! %1 took no damage!",

  // Results for Actions on Enemies
  enemyDamage     : "%1 took %2 damage!",
  enemyRecovery   : "%1 recovered %2 %3!",
  enemyGain       : "%1 gained %2 %3!",
  enemyLoss       : "%1 lost %2 %3!",
  enemyDrain      : "Drained %1 %2 from %3!",
  enemyNoDamage   : "%1 took no damage!",
  enemyNoHit      : "Missed! %1 took no damage!",

  // Evasion/Reflection
  evasion         : "%1 evaded the attack!",
  magicEvasion    : "%1 nullified the magic!",
  magicReflection : "%1 reflected the magic!",
  counterAttack   : "%1 counterattacked!",
  substitute      : "%1 protected %2!",

  // Buff/Debuff
  buffAdd         : "%1's %2 went up!",
  debuffAdd       : "%1's %2 went down!",
  buffRemove      : "%1's %2 returned to normal.",

  // Skill or Item Had No Effect
  actionFailure   : "There was no effect on %1!",

  // Error Message
  playerPosError  : "Player's starting position is not set.",
  eventOverflow   : "Common event calls exceeded the limit.",


  // Alfador Compatibility
  options         : "Options",
  alwaysDash      : "Always Dash",
  commandRemember : "Remember Command",
  bgmVolume       : "BGM Volume",
  bgsVolume       : "BGS Volume",
  meVolume        : "ME Volume",
  seVolume        : "SE Volume",
};

TextManager.rubyText = function (textId) {
  return RubyVocab[textId];
};

TextManager.basic = function (textId) {
  return $dataSystem.terms.basic[textId] || this.rubyText(textId) || "";
};

TextManager.param = function (textId) {
  return $dataSystem.terms.params[textId] || this.rubyText(textId) || "";
};

TextManager.command = function (textId) {
  return $dataSystem.terms.commands[textId] || this.rubyText(textId) || "";
};

TextManager.message = function (textId) {
  return this.rubyText(textId) || "";
};

Object.defineProperties(TextManager, {
  buy             : TextManager.getter('message', 'shopBuy'),
  sell            : TextManager.getter('message', 'shopSell'),
  options         : TextManager.getter('message', 'options'),
});
