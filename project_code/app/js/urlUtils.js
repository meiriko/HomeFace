function getUrlParameters(staticURL){
	var currLocation = (staticURL && staticURL.length)? staticURL : window.location.search;
	var result = {};
	if(currLocation.indexOf("?") == 0) {
		currLocation = currLocation.substring(1);
	}
	var parArr = currLocation.split("&");
	// var parArr = currLocation.split("?")[1].split("&");

	for(var i = 0; i < parArr.length; i++){
		parr = parArr[i].split("=");
		result[parr[0]] = parr[1];
	}

	return result;
}

