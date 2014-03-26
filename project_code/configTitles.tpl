{{$keys := .Keys}} { {{range $i,$k := .Vals}} {{if gt $i 0}},{{end}}"{{(index $keys $i).Encode}}":"{{.Title}}"{{end}} }
