const cpx = require('cpx');
const { readFileSync } = require('fs');
const watch = require('node-watch');

const concatSource = require('./concat.js');

const root = './game/www';

JSON.parse(readFileSync('./modules.json').toString())
    .map(name => ({ name, target: `./js/${name}` }))
    .forEach(({ name, target }) => {
        watch(target, () => {
            concatSource(name);

            cpx.copySync('./template/**/*', root, { update: true });
            cpx.copySync('./dist/*', root + '/js', { update: true });
            cpx.copySync('./js/libs/*', root + '/js/libs', { update: true });
            cpx.copySync('./js/extras_img/*', root + '/img/system', { update: true });
            cpx.copySync('./plugins/*', root + '/js/plugins', { update: true });

            console.log(`${target} changed. copy ${name}.js`);
        });
    });
