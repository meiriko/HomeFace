<html>
	<head>
		<link href="./styles/image.css" rel="stylesheet" type="text/css">
		<script type="text/javascript" src="app/js/paper-full.js"></script>
		<script type="text/javascript" src="app/js/jquery.min.js"></script>
		<script type="text/javascript" src="app/js/utils.js"></script>
		<script type="text/javascript">
			// Only executed our code once the DOM is ready.
			var points;
			var mainPath ;
			var mainGroup;
			var raster;
			var imageMargin = 50;
			window.onload = function() {
				// Get a reference to the canvas object
				var canvas = document.getElementById('homeCanvas');
				// Create an empty project and a view for the canvas:
				paper.setup(canvas);
				// Create a Paper.js Path to draw a line into it:
				points = JSON.parse({{.Points}});

				mainPath = new paper.Path();
				mainGroup = new paper.Group();
				raster = new paper.Raster({{.ImageUrl}});
				raster.onLoad = function(){
					var scale = 1;
					if( this.width > 700 ) {
						scale = 700 / this.width ;
					}
					if( this.height > 500 ) {
						scale = Math.min(scale, 500 / this.height);
					}
					if(scale < 1){
						this.scale(scale);
					}
					console.log('post width ', this.width);
					this.position = new paper.Point(imageMargin + scale * this.width/2 - {{.DX}}, imageMargin + scale * this.height/2 - {{.DY}} ) ;
					this.moveBelow(mainPath);
					this.moveBelow(mainGroup);
				}
			}

			function rect(x,y,w,h,config){
				config = config || {"strokeColor":"red"};
				if(! config.hasOwnProperty("strokeColor")){
					config.strokeColor = "red";
				}
				var val = new paper.Path.Rectangle( imageMargin + x * {{.SX}}, imageMargin + y * {{.SY}},w * {{.SX}}, h * {{.SY}});
				// var val = new paper.Path.Rectangle( imageMargin + x * {{.SX}}, imageMargin + y * {{.SY}},w * {{.SX}}, h * {{.SY}});
				val.strokeColor = config.strokeColor;
				return val;
			}

			function path(points, config){
				config = config || {"strokeColor":"red"};
				if(! config.hasOwnProperty("strokeColor")){
					config.strokeColor = "red";
				}
				var val = new paper.Path(config);
				val.moveTo( new paper.Point( imageMargin + points[0][0] * {{.SX}}, imageMargin + points[0][1] * {{.SY}} ) );
				for( var i = 1 ; i < points.length ; i++ ){
					val.lineTo( new paper.Point( imageMargin + points[i][0] * {{.SX}}, imageMargin + points[i][1] * {{.SY}} ) );
				}
				return val;
			}

			function drawShapes(config,group){
				if( group === mainGroup ) {
					mainGroup.removeChildren();
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
								drawShapes( shape , subGroup );
							});
						} else {
							group.addChild(eval(config[key]));
						}
					}
				});
				if( group === mainGroup ){
					// mainGroup.strokeColor = 'red';
					mainGroup.strokeWidth = 2;
					paper.view.draw();
				}
			}

			function changeOpacity(shape, val){
				shape.opacity = val;
			}
		</script>
		<script>
			$.getJSON('configTitles', function(data) {
				var $select = $("#config");
				$select.on('change', function(){
					if( this.value && this.value.length ){
						console.log('changed to ' , this.value);
						$.getJSON('config',{key:this.value}, function(data){
							drawShapes(JSON.parse(data.Config), mainGroup);
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
		<h2>Image drawing</h2>
		<div>Select config: <select id="config" style="width: 200px;"></select></div>
		<div><canvas id="homeCanvas" width="640" height="480" ></canvas></div>
		<div class="range-box">
			<input type="range" min="0.0" max="1" value="1" step="0.02" onchange="changeOpacity(raster, this.value)"></input>
			<div class="range-label">image opacity</div>
		</div>
		<div class="range-box">
			<input type="range" min="0.0" max="1" value="1" step="0.02" onchange="changeOpacity(mainGroup, this.value)"></input>
			<div class="range-label">drawing opacity</div>
		</div>
	</body>
</html>
