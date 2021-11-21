let cpx = require('cpx');
let fs = require('fs');

const root = './game/www';
cpx.copySync('./template/**/*', root, { update: true });
cpx.copySync('./dist/*', root + '/js', { update: true });
cpx.copySync('./js/libs/*', root + '/js/libs', { update: true });
cpx.copySync('./js/extras_img/*', root + '/img/system', { update: true });
cpx.copySync('./plugins/*', root + '/js/plugins', { update: true });
