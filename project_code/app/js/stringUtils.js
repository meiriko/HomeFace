function escapeRegExp(str) {
	return str.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&");
}

function stringTemplate( str , params ) {
	var result = str;
	Object.keys(params).forEach( function(key) {
		result = result.replace( new RegExp( escapeRegExp(key) , 'g' ), params[key] );
	} );
	return result;
}
