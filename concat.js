const fs = require("fs");

const Concat = require("concat-with-sourcemaps");

function concatSource(name, sourceMap) {
  const order = JSON.parse(
    fs.readFileSync(`./build_bundles/${name}.json`).toString()
  );

  let concat = new Concat(true, `${name}.js`, "\n");

  order.forEach((fileName) => {
    const path = `${__dirname}/${fileName}`;
    concat.add(path, fs.readFileSync(path).toString());
  });

  const outFolder = "../www/js";
  if (!fs.existsSync(outFolder)) fs.mkdirSync(outFolder);

  fs.writeFileSync(`./${outFolder}/${name}.js`, concat.content);
  if (sourceMap)
    fs.writeFileSync(`./${outFolder}/${name}.js.map`, concat.sourceMap);
}

if (require.main === module) {
  concatSource(process.argv[2], process.argv[3]);
}

module.exports = concatSource;
