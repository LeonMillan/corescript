//-----------------------------------------------------------------------------
/**
 * The point class.
 *
 * @class Point
 * @constructor
 * @param {Number} x The x coordinate
 * @param {Number} y The y coordinate
 */
function Point() {
    this.initialize.apply(this, arguments);
}

Point.prototype = Object.create(PIXI.Point.prototype);
Point.prototype.constructor = Point;

Point.prototype.initialize = function(x, y) {
    PIXI.Point.call(this, x, y);
};

Point.prototype.add = function(...args) {
    if (args.length === 1) {
        const [otherPoint] = args;
        return new Point(this.x + otherPoint.x, this.y + otherPoint.y);
    } else if (args.length === 2) {
        const [x, y] = args;
        return new Point(this.x + x, this.y + y);
    }
    throw new Error("Unsupported arguments: " + String(args));
};

/**
 * The x coordinate.
 *
 * @property x
 * @type Number
 */

/**
 * The y coordinate.
 *
 * @property y
 * @type Number
 */
