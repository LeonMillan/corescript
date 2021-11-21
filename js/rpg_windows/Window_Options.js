//-----------------------------------------------------------------------------
// Window_Options
//
// The window for changing various settings on the options screen.

function Window_Options() {
    this.initialize.apply(this, arguments);
}

Window_Options.prototype = Object.create(Window_Command.prototype);
Window_Options.prototype.constructor = Window_Options;

Window_Options.prototype.initialize = function() {
    Window_Command.prototype.initialize.call(this, 0, 0);
    this.updatePlacement();
};

Window_Options.prototype.windowWidth = function() {
    return 400;
};

Window_Options.prototype.windowHeight = function() {
    return this.fittingHeight(Math.min(this.numVisibleRows(), 12));
};

Window_Options.prototype.updatePlacement = function() {
    this.x = (Graphics.boxWidth - this.width) / 2;
    this.y = (Graphics.boxHeight - this.height) / 2;
};

Window_Options.prototype.makeCommandList = function() {
    const options = this.getOptionList();
    options.forEach((option) => this.addCommand(option.label, option.symbol, true, option));
};

Window_Options.prototype.getOptionList = function () {
    return [
        { symbol: 'alwaysDash',         type: 'bool',   label: 'Always dash' },
        { symbol: 'dashSpeed',          type: 'list',   label: 'Dash speed', list: [
            { value: 1.0, label: 'Normal' },
            { value: 1.5, label: 'Fast' },
            { value: 2.0, label: 'Faster' },
            { value: 2.5, label: 'Fastest' },
        ] },
        { symbol: 'commandRemember',    type: 'bool',   label: 'Remember command' },
        { symbol: 'encounterRate',      type: 'list',   label: 'Encounter rate', list: [
            { value: 5.0, label: 'Lowest' },
            { value: 3.0, label: 'Lower' },
            { value: 2.0, label: 'Low' },
            { value: 1.0, label: 'Normal' },
            { value: 0.5, label: 'High' },
            { value: 0.2, label: 'Higher' },
            { value: 0.1, label: 'Highest' },
        ] },
        { symbol: 'transitionTime',     type: 'list',   label: 'Transition time', list: [
            { value: 24, label: 'Normal' },
            { value: 12, label: 'Fast' },
            { value: 8,  label: 'Fastest' },
        ] },
        { symbol: 'fastforwardSpeed',   type: 'list',   label: 'Fastforward speed', list: [
            { value: 1, label: '2x' },
            { value: 2, label: '3x' },
            { value: 3, label: '4x' },
            { value: 5, label: '6x' },
            { value: 7, label: '8x' },
        ] },
        { symbol: 'battleSpeed',        type: 'list',   label: 'Battle animations', list: [
            { value: 0, label: 'Normal' },
            { value: 1, label: 'Fast' },
            { value: 2, label: 'Faster' },
            { value: 3, label: 'Fastest' },
            { value: 9, label: 'Disabled' },
        ] },
        { symbol: 'eventIcons',         type: 'bool',   label: 'Event icons' },
        { symbol: 'bgmVolume',          type: 'volume', label: 'BGM Volume' },
        { symbol: 'bgsVolume',          type: 'volume', label: 'BGS Volume' },
        { symbol: 'meVolume',           type: 'volume', label: 'ME Volume' },
        { symbol: 'seVolume',           type: 'volume', label: 'SE Volume' },
    ];
};

Window_Options.prototype.drawItem = function(index) {
    var rect = this.itemRectForText(index);
    var statusWidth = this.statusWidth();
    var titleWidth = rect.width - statusWidth;
    this.resetTextColor();
    this.changePaintOpacity(this.isCommandEnabled(index));
    this.drawText(this.commandName(index), rect.x, rect.y, titleWidth, 'left');
    this.drawText(this.statusText(index), rect.x+titleWidth, rect.y, statusWidth, 'right');
};

Window_Options.prototype.statusWidth = function() {
    return 120;
};

Window_Options.prototype.statusText = function(index) {
    var { type, value, list } = this.getOptionData(index);
    switch (type) {
        case 'list':
            return list.find((item) => item.value === value).label;
        case 'bool':
            return value ? 'ON' : 'OFF';
        case 'volume':
            return value + '%';
        default:
            return value;
    }
};

Window_Options.prototype.processOk = function () {
    var { symbol, type, value, list } = this.getOptionData();
    switch (type) {
        case 'list':
            const currentIndex = list.findIndex((item) => item.value === value);
            const nextIndex = (currentIndex + 1).mod(list.length);
            this.changeValue(symbol, list[nextIndex].value);
            break;
        case 'bool':
            this.changeValue(symbol, !value);
            break;
        case 'volume':
            value += this.volumeOffset();
            if (value > 100) {
                value = 0;
            }
            value = value.clamp(0, 100);
            this.changeValue(symbol, value);
            break;
        default:
            return value;
    }
};

Window_Options.prototype.cursorRight = function (wrap) {
    var { symbol, type, value, list } = this.getOptionData();
    switch (type) {
        case 'list':
            const currentIndex = list.findIndex((item) => item.value === value);
            const nextIndex = (currentIndex + 1).mod(list.length);
            this.changeValue(symbol, list[nextIndex].value);
            break;
        case 'bool':
            this.changeValue(symbol, true);
            break;
        case 'volume':
            value += this.volumeOffset();
            value = value.clamp(0, 100);
            this.changeValue(symbol, value);
            break;
        default:
            return value;
    }
};

Window_Options.prototype.cursorLeft = function (wrap) {
    var { symbol, type, value, list } = this.getOptionData();
    switch (type) {
        case 'list':
            const currentIndex = list.findIndex((item) => item.value === value);
            const nextIndex = (currentIndex - 1).mod(list.length);
            this.changeValue(symbol, list[nextIndex].value);
            break;
        case 'bool':
            this.changeValue(symbol, false);
            break;
        case 'volume':
            value -= this.volumeOffset();
            value = value.clamp(0, 100);
            this.changeValue(symbol, value);
            break;
        default:
            return value;
    }
};

Window_Options.prototype.volumeOffset = function() {
    return 5;
};

Window_Options.prototype.changeValue = function(symbol, value) {
    var lastValue = this.getConfigValue(symbol);
    if (lastValue !== value) {
        this.setConfigValue(symbol, value);
        this.redrawItem(this.findSymbol(symbol));
        SoundManager.playCursor();
    }
};

Window_Options.prototype.getOptionData = function (index) {
    if (index === undefined) index = this.index();

    var ext = this.commandExt(index);
    var value = this.getConfigValue(ext.symbol);
    return {
        ...ext,
        value,
    }
};

Window_Options.prototype.getConfigValue = function(symbol) {
    return ConfigManager[symbol];
};

Window_Options.prototype.setConfigValue = function(symbol, value) {
    ConfigManager[symbol] = value;
};
