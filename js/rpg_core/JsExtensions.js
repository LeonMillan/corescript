//-----------------------------------------------------------------------------
/**
 * This is not a class, but contains some methods that will be added to the
 * standard Javascript objects.
 *
 * @class JsExtensions
 */
function JsExtensions() {
    throw new Error('This is not a class');
}

/**
 * Returns a number whose value is limited to the given range.
 *
 * @method Number.prototype.clamp
 * @param {Number} min The lower boundary
 * @param {Number} max The upper boundary
 * @return {Number} A number in the range (min, max)
 */
Number.prototype.clamp = function(min, max) {
    return Math.min(Math.max(this, min), max);
};

/**
 * Returns a modulo value which is always positive.
 *
 * @method Number.prototype.mod
 * @param {Number} n The divisor
 * @return {Number} A modulo value
 */
Number.prototype.mod = function(n) {
    return ((this % n) + n) % n;
};

/**
 * Replaces %1, %2 and so on in the string to the arguments.
 *
 * @method String.prototype.format
 * @param {Any} ...args The objects to format
 * @return {String} A formatted string
 */
String.prototype.format = function() {
    var args = arguments;
    return this.replace(/%([0-9]+)/g, function(s, n) {
        return args[Number(n) - 1];
    });
};

/**
 * Makes a number string with leading zeros.
 *
 * @method String.prototype.padZero
 * @param {Number} length The length of the output string
 * @return {String} A string with leading zeros
 */
String.prototype.padZero = function(length){
    var s = this;
    while (s.length < length) {
        s = '0' + s;
    }
    return s;
};

/**
 * Makes a number string with leading zeros.
 *
 * @method Number.prototype.padZero
 * @param {Number} length The length of the output string
 * @return {String} A string with leading zeros
 */
Number.prototype.padZero = function(length){
    return String(this).padZero(length);
};

Object.defineProperties(Array.prototype, {
  /**
   * Checks whether the two arrays are same.
   *
   * @method Array.prototype.equals
   * @param {Array} array The array to compare to
   * @return {Boolean} True if the two arrays are same
   */
  equals: {
    enumerable: false,
    value: function (array) {
      if (!array || this.length !== array.length) {
        return false;
      }
      for (var i = 0; i < this.length; i++) {
        if (this[i] instanceof Array && array[i] instanceof Array) {
          if (!this[i].equals(array[i])) {
            return false;
          }
        } else if (this[i] !== array[i]) {
          return false;
        }
      }
      return true;
    },
  },
  /**
   * Makes a shallow copy of the array.
   *
   * @method Array.prototype.clone
   * @return {Array} A shallow copy of the array
   */
  clone: {
    enumerable: false,
    value: function () {
      return this.slice(0);
    },
  },
  /**
   * Checks whether the array contains a given element.
   *
   * @method Array.prototype.contains
   * @param {Any} element The element to search for
   * @return {Boolean} True if the array contains a given element
   */
  contains: {
    enumerable: false,
    value: function (element) {
      return this.indexOf(element) >= 0;
    },
  },
  /**
   * Rotate a 2D table, switching the X and Y axis.
   * Axis dimensions are inferred by the first element of the array.
   *
   * @method Array.prototype.rotate
   * @return {Any[]} the resulting rotated 2D table
   */
  rotate: {
    enumerable: false,
    value: function () {
      if (!Array.isArray(this[0])) return [...this];
      const xsize = this.length;
      const ysize = this[0].length;
      let result = new Array(ysize);
      for (let y = 0; y < ysize; y++) {
        result[y] = [];
        for (let x = 0; x < xsize; x++) {
          result[y][x] = this[x][y];
        }
      }
      return result;
    },
  },
  /**
   * Transform the array into a multi-dimensional table using the provided dimensions list.
   *
   * @method Array.prototype.unflatten
   * @param {number[]} dimensions List of dimensions to be used
   * @return {Any[]} the resulting multi-dimensional table
   */
  unflatten: {
    enumerable: false,
    value: function (dimensions) {
      if (!Array.isArray(dimensions))
        throw new TypeError("Must provide array of dimensions as parameter");
      const sigma = dimensions.reduce((total, curr) => total * curr, 1);
      if (this.length % sigma !== 0)
        throw new Error("Array cannot be split with the provided dimensions");
      let result = [...this];
      for (let dim = dimensions.length - 1; dim >= 0; dim--) {
        result = result.reduce((arr, item, index) => {
          const pos = Math.floor(index / dimensions[dim]);
          if (!arr[pos]) arr[pos] = [];
          arr[pos].push(item);
          return arr;
        }, []);
      }
      return result;
    },
  },
});

/**
 * Checks whether the string contains a given string.
 *
 * @method String.prototype.contains
 * @param {String} string The string to search for
 * @return {Boolean} True if the string contains a given string
 */
String.prototype.contains = function(string) {
    return this.indexOf(string) >= 0;
};

/**
 * Generates a random integer in the range (0, max-1).
 *
 * @static
 * @method Math.randomInt
 * @param {Number} max The upper boundary (excluded)
 * @return {Number} A random integer
 */
Math.randomInt = function(max) {
    return Math.floor(max * Math.random());
};

/**
 * Helper function to redefine a method from an existing class or singleton.
 *
 * @param {Object} obj object that contains the method to be redefined
 * @param {keyof obj} methodName one of the methods from obj
 * @param {Function} func new implementation which also receives the original method
 */
function redefine(obj, methodName, func) {
    const method = obj[methodName];
    obj[methodName] = function(...args) {
        return func.call(this, method.bind(this), ...args);
    };
}
