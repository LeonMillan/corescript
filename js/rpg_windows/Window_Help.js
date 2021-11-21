//-----------------------------------------------------------------------------
// Window_Help
//
// The window for displaying the description of the selected item.

function Window_Help() {
    this.initialize.apply(this, arguments);
}

Window_Help.prototype = Object.create(Window_Base.prototype);
Window_Help.prototype.constructor = Window_Help;

Window_Help.prototype.initialize = function(numLines) {
    var width = Graphics.boxWidth;
    var height = this.fittingHeight(numLines || 2);
    Window_Base.prototype.initialize.call(this, 0, 0, width, height);
    this._item = null;
    this._text = '';
};

Window_Help.prototype.update = function () {
    Window_Base.prototype.update.call(this);
    if (this.isOpen() && this._item && Input.isTriggered('tab')) {
        if (!this._exHelp) {
            var width = Graphics.boxWidth;
            var height = Graphics.boxHeight;
            var x = (Graphics.width - width) / 2;
            var y = (Graphics.height - height) / 2;
            const _windowLayer = new WindowLayer();
            _windowLayer.move(x, y, width, height);

            this._exHelp = new Window_HelpEx();
            _windowLayer.addChild(this._exHelp);
            this.parent.addChild(_windowLayer);
            Input.update();
        }
        if (this._exHelp.isOpen()) {
            this._exHelp.close();
        } else if (this._exHelp.isClosed()) {
            this._exHelp.setItem(this._item);
            this._exHelp.open();
        }
    }
    if (this.isOpen() && this._text && Input.isTriggered('copytext')) {
        const clipboard = require('nw.gui').Clipboard.get();
        clipboard.set(this._text, 'text');
        SoundManager.playLoad();
    }
};

Window_Help.prototype.setText = function(text) {
    if (this._text !== text) {
        this._text = text;
        this.refresh();
    }
};

Window_Help.prototype.clear = function() {
    this._item = null;
    this.setText('');
};

Window_Help.prototype.setItem = function(item) {
    this._item = item;
    if (this._exHelp) {
        this._exHelp.setItem(this._item);
    }
    this.setText(item ? item.description : '');
};

Window_Help.prototype.refresh = function() {
    this.contents.clear();
    this.drawTextEx(this._text, this.textPadding(), 0);
};
