class PreloadManagerClass {
  parseEventPage(eventPage) {
    return eventPage.list.reduce((result, item) => {
      const { code, parameters } = item;
      switch (code) {
        // Show Text
        case 101:
          result.push(this.makePreloadingEntry('image', 'face', parameters[0]));
          break;
        // Show Picture
        case 231:
          result.push(this.makePreloadingEntry('image', 'picture', parameters[1]));
          break;
        case 241:
          result.push(this.makePreloadingEntry('audio', 'bgm', parameters[0]));
          break;
        case 245:
          result.push(this.makePreloadingEntry('audio', 'bgs', parameters[0]));
          break;
        case 249:
          result.push(this.makePreloadingEntry('audio', 'me', parameters[0]));
          break;
        case 250:
          result.push(this.makePreloadingEntry('audio', 'se', parameters[0]));
          break;
        // Change Parallax
        case 284:
          result.push(this.makePreloadingEntry('image', 'parallax', parameters[0]));
          break;
        // Show Animation
        case 212:
          this.preloadAnimation(parameters[1]);
          break;
      }
      return result;
    }, []);
  }

  makePreloadingEntry(type, subtype, name) {
    return { type, subtype, name };
  }
}

var PreloadManager = new PreloadManagerClass();
