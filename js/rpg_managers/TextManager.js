//-----------------------------------------------------------------------------
// TextManager
//
// The static class that handles terms and messages.

function TextManager() {
    throw new Error('This is a static class');
}

TextManager.rubyText = function(textId) {
    return RUBY_TEXT[textId];
}

TextManager.basic = function(textId) {
    return $dataSystem.terms.basic[textId] || this.rubyText(textId) || '';
};

TextManager.param = function(textId) {
    return $dataSystem.terms.params[textId] || this.rubyText(textId) || '';
};

TextManager.command = function(textId) {
    return $dataSystem.terms.commands[textId] || this.rubyText(textId) || '';
};

TextManager.message = function(textId) {
    return this.rubyText(textId) || '';
};

TextManager.getter = function(method, param) {
    return {
        get: function() {
            return this[method](param);
        },
        configurable: true
    };
};

Object.defineProperty(TextManager, 'currencyUnit', {
    get: function() { return $dataSystem.currency_unit; },
    configurable: true
});

const RUBY_TEXT = {
    // Shop Screen
    shopBuy: "Buy",
    shopSell: "Sell",
    shopCancel: "Cancel",
    possession: "Possession",

    // Status Screen
    expTotal: "Current Exp",
    expNext: "To Next %1",

    // Save / Load Screen
    saveMessage: "Save to which file?",
    loadMessage: "Load which file?",
    file: "File",

    // Display when there are multiple members
    partyName: "%1's Party",

    // Basic Battle Messages
    emerge: "%1 emerged!",
    preemptive: "%1 got the upper hand!",
    surprise: "%1 was surprised!",
    escapeStart: "%1 has started to escape!",
    escapeFailure: "However, it was unable to escape!",

    // Battle Ending Messages
    victory: "%1 was victorious!",
    defeat: "%1 was defeated.",
    obtainExp: "%1 EXP received!",
    obtainGold: "%1\\G found!",
    obtainItem: "%1 found!",
    levelUp: "%1 is now %2 %3!",
    obtainSkill: "%1 learned!",

    // Use Item
    useItem: "%1 uses %2!",

    // Critical Hit
    criticalToEnemy: "An excellent hit!!",
    criticalToActor: "A painful blow!!",

    // Results for Actions on Actors
    actorDamage: "%1 took %1 damage!",
    actorRecovery: "%1 recovered %2 %3!",
    actorGain: "%1 gained %2 %3!",
    actorLoss: "%1 lost %2 %3!",
    actorDrain: "%1 was drained of %2 %3!",
    actorNoDamage: "%1 took no damage!",
    actorNoHit: "Miss! %1 took no damage!",

    // Results for Actions on Enemies
    enemyDamage: "%1 took %1 damage!",
    enemyRecovery: "%1 recovered %2 %3!",
    enemyGain: "%1 gained %2 %3!",
    enemyLoss: "%1 lost %2 %3!",
    enemyDrain: "Drained %1 %2 from %3!",
    enemyNoDamage: "%1 took no damage!",
    enemyNoHit: "Missed! %1 took no damage!",

    // Evasion / Reflection
    evasion: "%1 evaded the attack!",
    magicEvasion: "%1 nullified the magic!",
    magicReflection: "%1 reflected the magic!",
    counterAttack: "%1 counterattacked!",
    substitute: "%1 protected %2!",

    // Buff / Debuff
    buffAdd: "%1's %2 went up!",
    debuffAdd: "%1's %2 went down!",
    buffRemove: "%1's %2 returned to normal.",

    // Skill or Item Had No Effect
    actionFailure: "There was no effect on %1!",

    // Error Message
    playerPosError: "Player's starting position is not set.",
    eventOverflow: "Common event calls exceeded the limit.",
}

Object.defineProperties(TextManager, {
    level           : TextManager.getter('basic', 0),
    levelA          : TextManager.getter('basic', 1),
    hp              : TextManager.getter('basic', 2),
    hpA             : TextManager.getter('basic', 3),
    mp              : TextManager.getter('basic', 4),
    mpA             : TextManager.getter('basic', 5),
    tp              : TextManager.getter('basic', 6),
    tpA             : TextManager.getter('basic', 7),
    exp             : TextManager.getter('basic', 8),
    expA            : TextManager.getter('basic', 9),
    fight           : TextManager.getter('command', 0),
    escape          : TextManager.getter('command', 1),
    attack          : TextManager.getter('command', 2),
    guard           : TextManager.getter('command', 3),
    item            : TextManager.getter('command', 4),
    skill           : TextManager.getter('command', 5),
    equip           : TextManager.getter('command', 6),
    status          : TextManager.getter('command', 7),
    formation       : TextManager.getter('command', 8),
    save            : TextManager.getter('command', 9),
    gameEnd         : TextManager.getter('command', 10),
    options         : TextManager.getter('command', 11),
    weapon          : TextManager.getter('command', 12),
    armor           : TextManager.getter('command', 13),
    keyItem         : TextManager.getter('command', 14),
    equip2          : TextManager.getter('command', 15),
    optimize        : TextManager.getter('command', 16),
    clear           : TextManager.getter('command', 17),
    newGame         : TextManager.getter('command', 18),
    continue_       : TextManager.getter('command', 19),
    toTitle         : TextManager.getter('command', 21),
    cancel          : TextManager.getter('command', 22),
    buy             : TextManager.getter('message', 'shopBuy'),
    sell            : TextManager.getter('message', 'shopSell'),
    alwaysDash      : TextManager.getter('message', 'alwaysDash'),
    commandRemember : TextManager.getter('message', 'commandRemember'),
    bgmVolume       : TextManager.getter('message', 'bgmVolume'),
    bgsVolume       : TextManager.getter('message', 'bgsVolume'),
    meVolume        : TextManager.getter('message', 'meVolume'),
    seVolume        : TextManager.getter('message', 'seVolume'),
    possession      : TextManager.getter('message', 'possession'),
    expTotal        : TextManager.getter('message', 'expTotal'),
    expNext         : TextManager.getter('message', 'expNext'),
    saveMessage     : TextManager.getter('message', 'saveMessage'),
    loadMessage     : TextManager.getter('message', 'loadMessage'),
    file            : TextManager.getter('message', 'file'),
    partyName       : TextManager.getter('message', 'partyName'),
    emerge          : TextManager.getter('message', 'emerge'),
    preemptive      : TextManager.getter('message', 'preemptive'),
    surprise        : TextManager.getter('message', 'surprise'),
    escapeStart     : TextManager.getter('message', 'escapeStart'),
    escapeFailure   : TextManager.getter('message', 'escapeFailure'),
    victory         : TextManager.getter('message', 'victory'),
    defeat          : TextManager.getter('message', 'defeat'),
    obtainExp       : TextManager.getter('message', 'obtainExp'),
    obtainGold      : TextManager.getter('message', 'obtainGold'),
    obtainItem      : TextManager.getter('message', 'obtainItem'),
    levelUp         : TextManager.getter('message', 'levelUp'),
    obtainSkill     : TextManager.getter('message', 'obtainSkill'),
    useItem         : TextManager.getter('message', 'useItem'),
    criticalToEnemy : TextManager.getter('message', 'criticalToEnemy'),
    criticalToActor : TextManager.getter('message', 'criticalToActor'),
    actorDamage     : TextManager.getter('message', 'actorDamage'),
    actorRecovery   : TextManager.getter('message', 'actorRecovery'),
    actorGain       : TextManager.getter('message', 'actorGain'),
    actorLoss       : TextManager.getter('message', 'actorLoss'),
    actorDrain      : TextManager.getter('message', 'actorDrain'),
    actorNoDamage   : TextManager.getter('message', 'actorNoDamage'),
    actorNoHit      : TextManager.getter('message', 'actorNoHit'),
    enemyDamage     : TextManager.getter('message', 'enemyDamage'),
    enemyRecovery   : TextManager.getter('message', 'enemyRecovery'),
    enemyGain       : TextManager.getter('message', 'enemyGain'),
    enemyLoss       : TextManager.getter('message', 'enemyLoss'),
    enemyDrain      : TextManager.getter('message', 'enemyDrain'),
    enemyNoDamage   : TextManager.getter('message', 'enemyNoDamage'),
    enemyNoHit      : TextManager.getter('message', 'enemyNoHit'),
    evasion         : TextManager.getter('message', 'evasion'),
    magicEvasion    : TextManager.getter('message', 'magicEvasion'),
    magicReflection : TextManager.getter('message', 'magicReflection'),
    counterAttack   : TextManager.getter('message', 'counterAttack'),
    substitute      : TextManager.getter('message', 'substitute'),
    buffAdd         : TextManager.getter('message', 'buffAdd'),
    debuffAdd       : TextManager.getter('message', 'debuffAdd'),
    buffRemove      : TextManager.getter('message', 'buffRemove'),
    actionFailure   : TextManager.getter('message', 'actionFailure'),
});
