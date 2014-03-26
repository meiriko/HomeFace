<html>
  <head>
		<link href="./styles/imagesList.css" rel="stylesheet" type="text/css">
		<script src="./app/js/jquery.min.js"></script>
		<script>
			var selectedKeys = {};
			$(document).ready(function() {
				$('.image-checkbox').change(function() {
					$('#textbox1').val($(this).val());
					$(this).siblings('.image-link').toggleClass('selected');
					if($(this).is(':checked')){
						selectedKeys[$(this).val()] = true;
					} else {
						delete selectedKeys[$(this).val()];
					}
					$('#keys').attr('value', Object.keys(selectedKeys).join(","));
				});
			});
		</script>
  </head>
  <body>
  	<h2>saved images list</h2>
	{{$keys := .Keys}}
    {{range $i,$k := .Vals}}
		<div class="image-item">
		  <div class="image-title">{{.Title}}</div>
		  <a href="/show?key={{(index $keys $i).Encode}}" class="image-link">
			  <img width="240" src="{{.ImageUrl}}"></img>
		  </a>
		  <input type="checkbox" class="image-checkbox" value="{{(index $keys $i).Encode}}">select</input>
		</div>
    {{end}}
	<br/>
	<form action="morph">
		<input type="hidden" id="keys" name="keys" value=""></input>
		<input type="submit" value="compare"></input>
	</form>
  </body>
</html>
