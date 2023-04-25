const cpx = require("cpx");
const fs = require("fs");
const watch = require("node-watch");
const concatSource = require("./concat.js");

const root = "../www";

const bundles = fs.readdirSync("./build_bundles");

bundles.forEach((bundle) => {
  const bundleName = bundle.replace(".json", "");
  watch(`./js/${bundleName}/`, { recursive: true }, function (name) {
    console.log(`${name} changed, rebuilding ${bundleName}...`);
    concatSource(bundleName);
  });
});

watch(`./template`, { recursive: true }, function (name) {
  console.log(`${name} changed, updating...`);
  cpx.copySync("./template/**/*", root, { update: true });
});

watch(`./plugins`, { recursive: true }, function (name) {
  console.log(`${name} changed, updating...`);
  cpx.copySync("./plugins/*", root + "/js/plugins", { update: true });
});
