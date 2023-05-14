// ============================================================================
//  Database adapter and Managers

DataManager._globalId = "RPGMV-VXAce";
SceneManager._screenWidth       = 640;
SceneManager._screenHeight      = 480;
SceneManager._boxWidth          = 640;
SceneManager._boxHeight         = 480;

const SKILL_MAGIC_TYPES = [1, 2];

const DATABASE_ADAPTERS = {
  $dataActors: function (db) {
    return db.map((actor, index) => {
      if (index === 0) return null;
      actor.profile = actor.description;
      actor.traits = actor.features;
      actor.battlerName = "";
      return actor;
    });
  },
  $dataAnimations: function (db) {
    return db.map((anim, index) => {
      if (index === 0) return null;
      anim.frames = anim.frames.map((f) => {
        if (f.cellMax === 0) return [];
        return f.cellData.unflatten([f.cellMax]).rotate();
      });
      return anim;
    });
  },
  $dataArmors: function (db) {
    return db.map((armor, index) => {
      if (index === 0) return null;
      armor.traits = armor.features;
      return armor;
    });
  },
  $dataClasses: function (db) {
    return db.map((heroClass, index) => {
      if (index === 0) return null;
      heroClass.traits = heroClass.features;
      heroClass.params = heroClass.params.unflatten([8]).rotate();
      return heroClass;
    });
  },
  $dataEnemies: function (db) {
    return db.map((enemy, index) => {
      if (index === 0) return null;
      enemy.traits = enemy.features;
      return enemy;
    });
  },
  $dataItems: function (db) {
    return db.map((item, index) => {
      if (index === 0) return null;
      item.traits = item.features;
      return item;
    });
  },
  $dataStates: function (db) {
    return db.map((state, index) => {
      if (index === 0) return null;
      state.traits = state.features;
      return state;
    });
  },
  $dataTroops: function (db) {
    return db.map((troop, index) => {
      if (index === 0) return null;
      troop.pages.map((evPage) => {
        evPage.conditions = evPage.condition;
      });
      return troop;
    });
  },
  $dataWeapons: function (db) {
    return db.map((weapon, index) => {
      if (index === 0) return null;
      weapon.traits = weapon.features;
      return weapon;
    });
  },
  $dataSystem: function (system) {
    system.equipTypes = system.terms.etypes;
    system.magicSkills = SKILL_MAGIC_TYPES;
    system.attackMotions = [];
    system.victoryMe = system.battleEndMe;
    system.defeatMe = system.gameoverMe;
    return system;
  },

  $dataMap: function (map) {
    const eventHash = map.events;
    map.events = [null];
    Object.keys(eventHash).forEach((evId) => {
      const event = eventHash[evId];
      event.pages.map((evPage) => {
        evPage.conditions = evPage.condition;
        evPage.image = evPage.graphic;
      });
      map.events[Number(evId)] = event;
    });
    return map;
  },
};

function convertSnakeToCamel(str) {
  return str.replace(/_([a-z])/g, (_, match) => `${match.toUpperCase()}`);
}

function convertData(data) {
  if (data === null) return null;
  if (Array.isArray(data)) return data.map(convertData);
  if (typeof data !== 'object') return data;

  const newObj = { ...data };
  for (const key in newObj) {
    newObj[key] = convertData(newObj[key]);
    const camelKey = convertSnakeToCamel(key);
    newObj[camelKey] = newObj[key];
  }
  return newObj;
}

redefine(Scene_Boot.prototype, 'start', function (method) {
  DataManager._databaseFiles.forEach((db) => {
    const { name } = db;
    const adapter = DATABASE_ADAPTERS[name];
    window[name] = convertData(window[name]);
    window[name] = adapter ? adapter(window[name]) : window[name];
  });

  method();
});

redefine(Scene_Map.prototype, "onMapLoaded", function (method) {
  const adapter = DATABASE_ADAPTERS.$dataMap;
  $dataMap = convertData($dataMap)
  $dataMap = adapter($dataMap);

  method();
});
