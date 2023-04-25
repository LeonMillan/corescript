const cpx = require("cpx");
const fs = require("fs");
const concatSource = require("./concat.js");

const root = "../www";

const bundles = fs.readdirSync("./build_bundles");
bundles.forEach((bundle) => {
  const bundleName = bundle.replace(".json", "");
  concatSource(bundleName);
});

cpx.copySync("./template/**/*", root, { update: true });
cpx.copySync("./js/main.js", root + "/js", { update: true });
cpx.copySync("./js/libs/*", root + "/js/libs", { update: true });
cpx.copySync("./plugins/*", root + "/js/plugins", { update: true });
