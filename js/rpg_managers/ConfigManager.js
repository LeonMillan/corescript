//-----------------------------------------------------------------------------
// ConfigManager
//
// The static class that manages the configuration data.

function ConfigManager() {
    throw new Error('This is a static class');
}

ConfigManager.alwaysDash        = false;
ConfigManager.dashSpeed         = 1.0;
ConfigManager.commandRemember   = false;
ConfigManager.encounterRate     = 1.0;
ConfigManager.transitionTime    = 24;
ConfigManager.fastforwardSpeed  = 1;
ConfigManager.battleSpeed       = 0;
ConfigManager.eventIcons        = false;

Object.defineProperty(ConfigManager, 'bgmVolume', {
    get: function() {
        return AudioManager._bgmVolume;
    },
    set: function(value) {
        AudioManager.bgmVolume = value;
    },
    configurable: true
});

Object.defineProperty(ConfigManager, 'bgsVolume', {
    get: function() {
        return AudioManager.bgsVolume;
    },
    set: function(value) {
        AudioManager.bgsVolume = value;
    },
    configurable: true
});

Object.defineProperty(ConfigManager, 'meVolume', {
    get: function() {
        return AudioManager.meVolume;
    },
    set: function(value) {
        AudioManager.meVolume = value;
    },
    configurable: true
});

Object.defineProperty(ConfigManager, 'seVolume', {
    get: function() {
        return AudioManager.seVolume;
    },
    set: function(value) {
        AudioManager.seVolume = value;
    },
    configurable: true
});

ConfigManager.load = function() {
    var json;
    var config = {};
    try {
        json = StorageManager.load(-1);
    } catch (e) {
        console.error(e);
    }
    if (json) {
        config = JSON.parse(json);
    }
    this.applyData(config);
};

ConfigManager.save = function() {
    StorageManager.save(-1, JSON.stringify(this.makeData()));
};

ConfigManager.makeData = function() {
    var config = {};
    config.alwaysDash = this.alwaysDash;
    config.dashSpeed = this.dashSpeed;
    config.commandRemember = this.commandRemember;
    config.encounterRate = this.encounterRate;
    config.transitionTime = this.transitionTime;
    config.fastforwardSpeed = this.fastforwardSpeed;
    config.battleSpeed = this.battleSpeed;
    config.eventIcons = this.eventIcons;
    config.bgmVolume = this.bgmVolume;
    config.bgsVolume = this.bgsVolume;
    config.meVolume = this.meVolume;
    config.seVolume = this.seVolume;
    return config;
};

ConfigManager.applyData = function(config) {
    this.alwaysDash = this.readFlag(config, 'alwaysDash');
    this.dashSpeed = this.readValue(config, 'dashSpeed') || 1.0;
    this.commandRemember = this.readFlag(config, 'commandRemember');
    this.encounterRate = this.readValue(config, 'encounterRate') || 1.0;
    this.transitionTime = this.readValue(config, 'transitionTime') || 24;
    this.fastforwardSpeed = this.readValue(config, 'fastforwardSpeed') || 1;
    this.battleSpeed = this.readValue(config, 'battleSpeed') || 0;
    this.eventIcons = this.readFlag(config, 'eventIcons');
    this.bgmVolume = this.readVolume(config, 'bgmVolume');
    this.bgsVolume = this.readVolume(config, 'bgsVolume');
    this.meVolume = this.readVolume(config, 'meVolume');
    this.seVolume = this.readVolume(config, 'seVolume');
};

ConfigManager.readValue = function (config, name) {
    return config[name];
};

ConfigManager.readFlag = function(config, name) {
    return !!config[name];
};

ConfigManager.readVolume = function(config, name) {
    var value = config[name];
    if (value !== undefined) {
        return Number(value).clamp(0, 100);
    } else {
        return 100;
    }
};
