<html>
	<head>
		<link href="./styles/image.css" rel="stylesheet" type="text/css">
		<link href="./styles/colpick.css" rel="stylesheet" type="text/css"/>
		<script type="text/javascript" src="app/js/paper-full.js"></script>
		<script type="text/javascript" src="app/js/jquery.min.js"></script>
		<script type="text/javascript" src="app/js/utils.js"></script>
		<script type="text/javascript" src="app/js/urlUtils.js"></script>
		<script type="text/javascript" src="app/js/stringUtils.js"></script>
		<script type="text/javascript" src="app/js/colpick.js"></script>

		<script type="text/javascript">
			// Only executed our code once the DOM is ready.
			var mainPathGroup;
			var mainGroup;
			var rasters = [];
			var points;
			var imgData;
			var loadedImages = [];
			var imageMargin = 50;
			var maxSx = 0;
			var keysNum = 0;

			var controlTemplate = '\
				<div class="control-box">\
					<div>\
						<div class="color-box" itemIndex="$index"></div>\
						<div class="range-label">$imageName\
							<input type="checkbox" checked="true" onchange="rasters[$index].visible=this.checked;loadedImages[$index].mainGroup.visible=this.checked;"/>\
						</div>\
					</div>\
					<div class="range-box">\
						<input type="range" min="0.0" max="1" value="$rasterOpacity" step="0.02" onchange="changeOpacity(rasters[$index], this.value)"></input>\
						<div class="range-label">image opacity</div>\
					</div>\
					<div class="range-box">\
						<input type="range" min="0.0" max="1" value="$drawingOpacity" step="0.02" onchange="changeOpacity(loadedImages[$index].mainGroup, this.value)"></input>\
						<div class="range-label">drawing opacity</div>\
					</div>\
				</div>\
			';

			window.onload = function() {
				// alert(getUrlParameters());
				params = getUrlParameters();
				if(params.hasOwnProperty('keys')){
					var keys = decodeURIComponent(params.keys).split(',');
					keysNum = keys.length;
					keys.forEach(function(key){
						loadByKey(key);
					});
				}
				// Get a reference to the canvas object
				var canvas = document.getElementById('canvas');
				// Create an empty project and a view for the canvas:
				paper.setup(canvas);
				// Create a Paper.js Path to draw a line into it:
				// points = JSON.parse({{.Points}});

				mainPathGroup = new paper.Group();
				mainGroup = new paper.Group();
			}

			function rasterLoaded(){
				this.opacity = 0.5;
				this.moveBelow(mainPathGroup);
				this.moveBelow(mainGroup);
				
				if( rasters.length == keysNum ) {
					unifyScale(true);
				}
			}

			function unifyScale(rastersOnly) {
				for( var i = 0 ; i < loadedImages.length ; i++ ) {
					var rescaleX = maxSx / loadedImages[i].SX ;
					if( rastersOnly ){
						var scale = 1;
						if( rasters[i].width > 700 ) {
							scale = 700 / rasters[i].width ;
						}
						if( rasters[i].height > 500 ) {
							scale = Math.min(scale, 500 / rasters[i].height);
						}
						var relevantImageData = loadedImages[i];
						rasters[i].scale(rescaleX * scale, new paper.Point(0,0));
						rasters[i].position = new paper.Point(imageMargin + rescaleX*(scale * rasters[i].width/2 - relevantImageData.DX) , imageMargin + rescaleX * (scale * rasters[i].height/2 - relevantImageData.DY ) ) ;
					} else {
						loadedImages[i].SX *= rescaleX;
						loadedImages[i].SY *= rescaleX;
					}
				}
			}

			function loadByKey(key){
				$.getJSON('/imageData', {key: key}, function(image){
					maxSx = Math.max( maxSx, image.SX );
					loadedImages.push(image);
					var raster = new paper.Raster(image.ImageUrl);
					image.raster = raster;
					rasters.push(raster);
					raster.onLoad = rasterLoaded;
				});
			}

			function rect(x,y,w,h,config){
				config = config || {"strokeColor":"red"};
				if(! config.hasOwnProperty("strokeColor")){
					config.strokeColor = "red";
				}
				var val = new paper.Path.Rectangle( imageMargin + x * imgData.SX, imageMargin + y * imgData.SY,w * imgData.SX, h * imgData.SY);
				val.strokeColor = config.strokeColor;
				return val;
			}

			function path(points, config){
				config = config || {"strokeColor":"red"};
				if(! config.hasOwnProperty("strokeColor")){
					config.strokeColor = "red";
				}
				var val = new paper.Path(config);
				val.moveTo( new paper.Point( imageMargin + points[0][0] * imgData.SX, imageMargin + points[0][1] * imgData.SY ) );
				for( var i = 1 ; i < points.length ; i++ ){
					val.lineTo( new paper.Point( imageMargin + points[i][0] * imgData.SX, imageMargin + points[i][1] * imgData.SY ) );
				}
				return val;
			}

			function drawShapesOnImages(config){
				unifyScale(false);
				loadedImages.forEach(function(image, index){
					if(! image.hasOwnProperty('mainGroup')){
						image.mainGroup = new paper.Group();
						image.mainGroup.opacity = 0.9;
						mainGroup.addChild(image.mainGroup);
						var controlString = stringTemplate(controlTemplate, {$imageName:loadedImages[index].Title, $index: index, $rasterOpacity: rasters[index].opacity, $drawingOpacity: image.mainGroup.opacity});
						$('#controls').append( controlString );
						$('.color-box').colpick({
							colorScheme:'dark',
							layout:'rgbhex',
							color:'ffffff',
							onSubmit:function(hsb,hex,rgb,el) {
								var ind = parseInt($(el).attr('itemIndex'));
								loadedImages[ind].mainGroup.strokeColor = '#'+hex;
								$(el).css('background-color', '#'+hex);
								$(el).colpickHide();
							}
						}).css('background-color', '#ffffff');
					}

					points = JSON.parse(image.Points);
					imgData = image;
					drawShapes(config, image.mainGroup, true);
				});

				paper.view.draw();
			}

			function drawShapes(config,group,clear){
				if( clear ){
					group.removeChildren();
				}
				Object.keys(config).forEach(function(key){
					if( key === 'name' ){
						console.log('drawing ' , config[key]);
					} else {
						var child = config[key];
						if(Array.isArray(child)){
							console.log('sub shapes!!!!');
							var shapes = child;
							var subGroup = new paper.Group();
							group.addChild(subGroup);
							shapes.forEach(function(shape){
								drawShapes( shape , subGroup, false);
							});
						} else {
							group.addChild(eval(config[key]));
						}
					}
				});
				if( clear ){
					// mainGroup.strokeColor = 'red';
					group.strokeWidth = 2;
					paper.view.draw();
				}
			}

			function changeOpacity(shape, val){
				if(Array.isArray(shape)){
					shape.forEach(function(item){
						item.opacity = val;
					});
				} else {
					shape.opacity = val;
				}
			}

			function extractProperty(array, property){
				return array.map(function(item){
					return item[property];
					} );
			}

			function changeVisibility(array, visibility){
				array.forEach(function(item){
					item.visible = visibility;
				});
			}
		</script>
		<script>
			$.getJSON('configTitles', function(data) {
				var $select = $("#config");
				$select.on('change', function(){
					if( this.value && this.value.length ){
						$.getJSON('config',{key:this.value}, function(data){
							drawShapesOnImages(JSON.parse(data.Config), mainGroup);
						});
					}
				});
				$select.append($("<option>", { value: "", html: "select" }));
				Object.keys(data).forEach(function(key){
					$select.append($("<option>", { value: key, html: data[key] }));
				});
			}).fail(function(jqxhr, textStatus, error) {
				console.log( textStatus );
			});

		</script>
	</head>
	<body>
		<h2>Images comparison</h2>
		<div>Select config: <select id="config" style="width: 200px;"></select></div>
		<div><canvas id="canvas" width="640" height="480" ></canvas></div>
		<div id="controls">
			<div class="control-box">
				<div class="range-label">all images
					<input type="checkbox" checked="true" onchange="changeVisibility(rasters,this.checked)"/>
				</div>
				<div class="range-label">all drawings
					<input type="checkbox" checked="true" onchange="changeVisibility(extractProperty(loadedImages,'mainGroup'),this.checked)"/>
				</div>
				<div class="range-box">
					<input type="range" min="0.0" max="1" value="$rasterOpacity" step="0.02" onchange="changeOpacity(rasters, this.value)"></input>
					<div class="range-label">image opacity</div>
				</div>
				<div class="range-box">
					<input type="range" min="0.0" max="1" value="$drawingOpacity" step="0.02" onchange="changeOpacity(extractProperty(loadedImages,'mainGroup'), this.value)"></input>
					<div class="range-label">drawing opacity</div>
				</div>
			</div>
		</div>
	</body>
</html>
