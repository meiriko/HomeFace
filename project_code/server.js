var express = require('express');
var app = express();
var requestSVC = require('request');

app.get(/^\/pt\/(.*)/, function(req, res){
	// res.end("Hello, " + req.params[0] + ".");
	var ptUrl = req.params[0]
	if( ptUrl.indexOf('http') !== 0 ) {
		ptUrl = 'http://' + ptUrl;
	}
	// res.end('looking for: ' + ptUrl);
	try {
		requestSVC(ptUrl).pipe(res);
	} catch( e ) {
		console.log( e );
	}
});
app.get('/', function(req, res){
	res.redirect('examples/homeface_tester.html');
});
app.use(express.static(__dirname));

app.listen(process.env.PORT || 8080);
