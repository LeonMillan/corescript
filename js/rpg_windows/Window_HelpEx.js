class Window_HelpEx extends Window_Base {
  constructor() {
    super();
    this.initialize.apply(this, arguments);
  }

  initialize() {
    const width = Graphics.boxWidth - 64;
    const height = Graphics.boxHeight - 112;
    super.initialize(32, 56, width, height);
    this.openness = 0;
    this.setBackgroundType(1);
    this._item = null;
    this._page = 0;
    this._timer = 0;
  }

  dimColor1() {
    return 'rgba(0, 0, 0, 0.85)';
  }

  update() {
    super.update();
    this._timer += 1;
    if (this._timer >= 320) {
      this._timer = 0;
      this._page += 1;
      this.refresh();
    }
    if (this.isOpen()) {
      if (Input.isPressed('ok') || Input.isPressed('cancel')) {
        this.close();
      }
    }
  }

  setItem(item) {
    this._item = item;
    this._page = 0;
    this._timer = 0;
    this.refresh();
  }

  refresh() {
    this.contents.clear();
    this.drawItemName(this._item, 0, 0);
    this.renderOverview();
    this.renderAttributes();
    this.renderParameters();
    this.renderDamage();
  }

  renderOverview() {
    const columnW = (this.contentsWidth() - 32) / 2;
    this.getOverviewList().forEach((text, i) => {
      const { label, color } = text;
      if (color) {
        this.changeTextColor(color);
      } else {
        this.resetTextColor();
      }
      this.drawText(label, 0, (i+1) * this.lineHeight(), columnW);
    });
  }

  renderAttributes() {
    const columnW = (this.contentsWidth() - 32) / 2;
    const x = this.contentsWidth() - columnW;
    const list = [...this.getEffectsList(), ...this.getTraitsList()];
    const showPage = this._page % Math.ceil(list.length / 8);
    const listPage = list.slice(showPage * 8, showPage * 8 + 8);
    listPage.forEach((text, i) => {
      const { label, color, icon } = text;
      if (color) {
        this.changeTextColor(color);
      } else {
        this.resetTextColor();
      }
      if (icon) {
        this.drawIcon(icon, x + 2, (i + 1) * this.lineHeight());
        this.drawText(label, x + Window_Base._iconWidth + 4, (i+1) * this.lineHeight(), columnW);
      } else {
        this.drawText(label, x, (i+1) * this.lineHeight(), columnW);
      }
    });
  }

  renderDamage() {
    if (!this._item || !this._item.damage) return;

    const columnW = (this.contentsWidth() - 48) / 3;
    const fromX = 24;
    const fromY = this.contentsHeight() - this.lineHeight() * 3;

    let hitEffect = '---';
    if (this._item.damage.type === 1) hitEffect = 'HP Damage';
    if (this._item.damage.type === 2) hitEffect = 'MP Damage';
    if (this._item.damage.type === 3) hitEffect = 'HP Healing';
    if (this._item.damage.type === 4) hitEffect = 'MP Healing';
    if (this._item.damage.type === 5) hitEffect = 'HP Drain';
    if (this._item.damage.type === 6) hitEffect = 'MP Drain';

    let element = 'None';
    if (this._item.damage.elementId === -1) element = 'Normal attack';
    if (this._item.damage.elementId > 0) {
      element = $dataSystem.elements[this._item.damage.elementId];
    }

    this.changeTextColor(this.systemColor());
    this.drawText('Hit effect:', fromX, fromY, columnW);
    this.drawText('Element:', fromX, fromY + this.lineHeight(), columnW);
    this.resetTextColor();
    this.drawText(hitEffect, fromX + columnW, fromY, columnW);
    this.drawText(element, fromX + columnW, fromY + this.lineHeight(), columnW);
    this.contents.fontSize = 12;
    this.drawText(this._item.damage.formula, fromX, fromY + this.lineHeight() * 2, columnW * 3);
    this.resetFontSettings();
  }

  renderParameters() {
    if (!this._item || !this._item.params) return;

    const columnW = (this.contentsWidth() - 48) / 4;
    const fromX = 24;
    const fromY = this.contentsHeight() - this.lineHeight() * 4;

    for (let i = 0; i < 8; i++) {
      const x = fromX + columnW * Math.floor(i / 2);
      const y = fromY + this.lineHeight() * 2 * (i % 2);
      const value = this._item.params[i];
      this.changeTextColor(this.systemColor());
      this.drawText(TextManager.param(i), x, y, columnW);
      this.changeTextColor(this.paramchangeTextColor(value));
      this.drawText(value < 0 ? value : `+${value}`, x, y + this.lineHeight(), columnW);
    }
  }

  getOverviewList() {
    if (!this._item) return [];

    const list = [];

    if (this._item.atypeId) {
      list.push(this.makeText($dataSystem.armorTypes[this._item.atypeId], this.systemColor()));
    }
    if (this._item.wtypeId) {
      list.push(this.makeText($dataSystem.weaponTypes[this._item.wtypeId], this.systemColor()));
    }
    if (this._item.stypeId) {
      list.push(this.makeText($dataSystem.skillTypes[this._item.stypeId], this.systemColor()));
    }

    if (this._item.price) list.push(this.makeText(`Price: ${this._item.price}`, this.textColor(21)));
    if (this._item.consumable === false) list.push(this.makeText(`Reusable`, this.textColor(21)));

    if (this._item.scope) {
      let scopeType = '???';
      if (this._item.scope === 1) scopeType = 'One enemy';
      if (this._item.scope === 2) scopeType = 'All enemies';
      if (this._item.scope === 3) scopeType = '1 random enemy';
      if (this._item.scope === 4) scopeType = '2 random enemies';
      if (this._item.scope === 5) scopeType = '3 random enemies';
      if (this._item.scope === 6) scopeType = '4 random enemies';
      if (this._item.scope === 7) scopeType = 'One ally';
      if (this._item.scope === 8) scopeType = 'All allies';
      if (this._item.scope === 9) scopeType = 'One dead ally';
      if (this._item.scope === 10) scopeType = 'All dead allies';
      if (this._item.scope === 11) scopeType = 'User';
      list.push(this.makeText(`Scope: ${scopeType}`, this.textColor(20)));
    }
    if (this._item.speed) list.push(this.makeText(`Speed: ${this._item.speed}`, this.textColor(20)));
    if (this._item.successRate < 100) list.push(this.makeText(`Success: ${this._item.successRate}%`, this.textColor(20)));
  
    if (this._item.hitType === 1) list.push(this.makeText(`Physical hit`, this.textColor(20)));
    if (this._item.hitType === 2) list.push(this.makeText(`Magical hit`, this.textColor(20)));

    if (this._item.tpGain > 0) list.push(this.makeText(`User +${this._item.tpGain} TP`, this.textColor(24)));

    return list;
  }

  getEffectsList() {
    if (!this._item || !this._item.effects) return [];
    
    return this._item.effects.map((effect) => {
      const { code, dataId, value1, value2 } = effect;
      let data;
      let icon;

      switch (code) {
        case 11:
          if (value1 && value2) return this.makeText(`+${Math.round(value1 * 100)}% +${value2} HP`);
          if (value1) return this.makeText(`+${value1 * 100}% HP`);
          return this.makeText(`+${value2} HP`);

        case 12:
          if (value1 && value2) return this.makeText(`+${Math.round(value1 * 100)}% +${value2} MP`);
          if (value1) return this.makeText(`+${Math.round(value1 * 100)}% MP`);
          return this.makeText(`+${value2} MP`);

        case 13:
          return this.makeText(`+${value1} TP`);

        case 21:
          data = dataId > 0 ? $dataStates[dataId].name : 'Attack';
          icon = dataId > 0 ? $dataStates[dataId].iconIndex : 0;
          if (value1 < 1) return this.makeText(`${data} ${Math.round(value1 * 100)}%`, null, icon);
          return this.makeText(`${data}`, null, icon);

        case 22:
          data = dataId > 0 ? $dataStates[dataId].name : 'Attack';
          icon = dataId > 0 ? $dataStates[dataId].iconIndex : 0;
          if (value1 < 1) return this.makeText(`Heal ${data} ${Math.round(value1 * 100)}%`, null, icon);
          return this.makeText(`Heal ${data}`, null, icon);

        case 31:
          data = TextManager.param(dataId);
          if (value1 > 1) return this.makeText(`+${data} ${value1} turns`);
          return this.makeText(`+${param} ${value1} turn`);

        case 32:
          data = TextManager.param(dataId);
          if (value1 > 1) return this.makeText(`-${data} ${value1} turns`);
          return this.makeText(`-${param} ${value1} turn`);

        case 33:
          data = TextManager.param(dataId);
          return this.makeText(`Undo +${data}`);

        case 34:
          data = TextManager.param(dataId);
          return this.makeText(`Undo -${data}`);

        case 41:
          if (dataId === 0) return this.makeText(`Escape battle`);
          return this.makeText(`???`);

        case 42:
          data = TextManager.param(dataId);
          if (value1 < 0) return this.makeText(`${value1} ${data}`);
          return this.makeText(`+${value1} ${data}`);

        case 43:
          data = $dataSkills[dataId];
          return this.makeText(`+ ${data.name}`, null, data.iconIndex);

        case 44:
          return this.makeText(`Special`);

        default:
          return this.makeText(`???`);
      }
    });
  }

  getTraitsList() {
    if (!this._item || !this._item.traits) return [];

    return this._item.traits.map((trait) => {
      const { code, dataId, value } = trait;
      const percentVal = Math.round(value * 100);
      const sign = (value < 0 ? '' : '+');
      let data;

      switch (code) {
        case 11:
          data = $dataSystem.elements[dataId];
          return this.makeText(`${data} Rate × ${percentVal}%`);

        case 12:
          data = TextManager.param(dataId);
          return this.makeText(`-${data} Rate × ${percentVal}%`);

        case 13:
          data = $dataStates[dataId];
          return this.makeText(`+${data.name} Rate × ${percentVal}%`, null, data.iconIndex);

        case 14:
          data = $dataStates[dataId];
          return this.makeText(`Resist ${data.name}`, null, data.iconIndex);

        case 21:
          data = TextManager.param(dataId);
          return this.makeText(`${data} × ${percentVal}%`);

        case 22:
          data = [
            'Hit rate',
            'Evasion rate',
            'Crit rate',
            'Crit eva. rate',
            'Magic eva. rate',
            'Magic reflect',
            'Counter attack',
            'HP regeneration',
            'MP regeneration',
            'TP regeneration',
          ][dataId];
          return this.makeText(`${data} ${sign}${percentVal}%`);

        case 23:
          data = [
            'Target rate',
            'Guard effect',
            'Recovery effect',
            'Pharmacology',
            'MP cost',
            'TP charge',
            'Physical damage',
            'Magical damage',
            'Floor damage',
            'EXP gain rate',
          ][dataId];
          return this.makeText(`${data} × ${percentVal}%`);

        case 31:
          data = $dataSystem.elements[dataId];
          return this.makeText(`${data} attack`);

        case 32:
          data = $dataStates[dataId];
          return this.makeText(`${data.name} on hit ${sign}${percentVal}%`, null, data.iconIndex);

        case 33:
          return this.makeText(`Attack speed ${sign}${value}`);

        case 34:
          return this.makeText(`Attack ${value} times`);

        case 41:
          data = $dataSystem.skillTypes[dataId];
          return this.makeText(`Use ${data}`);

        case 42:
          data = $dataSystem.skillTypes[dataId];
          return this.makeText(`Seal ${data}`);

        case 43:
          data = $dataSkills[dataId];
          return this.makeText(`+ ${data.name}`, null, data.iconIndex);

        case 44:
          data = $dataSkills[dataId];
          return this.makeText(`Seal ${data.name}`, null, data.iconIndex);

        case 51:
          data = $dataSystem.weaponTypes[dataId];
          return this.makeText(`Use ${data}`);

        case 52:
          data = $dataSystem.armorTypes[dataId];
          return this.makeText(`Use ${data}`);

        case 53:
          return this.makeText(`Lock equip`);

        case 54:
          return this.makeText(`Seal equip`);

        case 55:
          if (dataId === 1) return this.makeText(`Dual wield`);
          return this.makeText(`Normal wield`);

        case 61:
          return this.makeText(`Action ${sign}${percentVal}%`);

        case 62:
          if (dataId === 0) return this.makeText(`Berserk`);
          if (dataId === 1) return this.makeText(`Guard`);
          if (dataId === 2) return this.makeText(`Protect`);
          if (dataId === 3) return this.makeText(`Keep TP`);
          return this.makeText(`Special`);

        case 63:
          return this.makeText(`Boss`);

        case 64:
          if (dataId === 0) return this.makeText(`1/2 encounters`);
          if (dataId === 1) return this.makeText(`No encounters`);
          if (dataId === 2) return this.makeText(`Alertness`);
          if (dataId === 3) return this.makeText(`Vigilance`);
          if (dataId === 4) return this.makeText(`Double gold`);
          if (dataId === 5) return this.makeText(`Double item drop`);
          return this.makeText(`Special`);
        
        default:
          return this.makeText(`???`);
      }
    });
  }

  makeText(label, color = null, icon = 0) {
    return { label, color, icon };
  }
}
