<html>
	<head>
		<script src="app/js/jquery.min.js"></script>
		<script src="app/js/jquery-ui.min.js"></script>
		<script type="">
				function saveConfig(){
					var title = document.getElementById('title').value;
					var content = document.getElementById('content').value;
					console.log(title);
					console.log(content);
					var params = {title: title, content: content};
					$.post('/saveConfig' , params , function(data){
						console.log(data);
						alert('saved!');
					});
				}
		</script>
	</head>
	<body>
		<h2>Create drawing config</h2>
		<!-- <form action="/saveConfig" method="post"> -->
			<div>Title: <input type="text" id="title" name="title"></input></div>
			<div><textarea name="content" id="content" rows="20" cols="60"></textarea></div>
			<input type="button" onclick="saveConfig()" value="Save">
		<!-- </form> -->
	</body>
</html>
