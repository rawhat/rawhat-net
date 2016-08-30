var Koa = require('koa');
var app = new Koa();

var router = require('koa-router')();

var compress = require('koa-compress');
app.use(compress())

var serve = require('koa-static');
app.use(serve('./static'));

var views = require('koa-views');
app.use(views(__dirname + '/views', {
	slm: 'slim'
}));

router.get('/', async (ctx) => {
	await ctx.render('index.slm');
});

app.use(router.routes());
app.use(router.allowedMethods());

app.listen(3000);