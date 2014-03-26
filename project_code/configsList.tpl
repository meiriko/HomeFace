<html>
  <head>
		<link href="./styles/configsList.css" rel="stylesheet" type="text/css">
  </head>
  <body>
  	<h2>saved configs list</h2>
    {{range .}}
		<div class="config-item">
		  <div class="config-title">{{.Title}}</div>
		  <div class="config-content">{{.Config}}</div>
		</div>
    {{end}}
  </body>
</html>
