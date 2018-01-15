program define mapforce
	version 14.0
	syntax varlist(min=5 max=5) [if] [in] using/, [replace]
	marksample touse, strok
	qui count if `touse'
	if `r(N)' == 0 exit 2000
	if !strpos(`"`using'"', ".") local using `"`using.html'"'

	if !ustrregexm(`"`using'"', "\.html$") {
		disp as error "the file generated must be a .html file"
		exit 198
	}
	
	if fileexists(`"`using'"') & "`replace'" == "" {
		disp as error "file `using' already exists"
		exit 602
	}
	else if fileexists(`"`using'"') {
		cap erase `"`using'"'
		if _rc != 0 {
			! del `"`using'"' /F
		}
	}

	token `varlist'
	forvalues i = 1/2 {
		if !strpos(`"`: type ``i'''"', "str") {
			disp as error "type mismatch, var`i' must be a string variable"
			exit 109
		}
	}
	forvalues i = 3/5 {
		if strpos(`"`: type ``i'''"', "str") {
			disp as error "type mismatch, var`i' must be a numeric variable"
			exit 109
		}
	}

	mata mapscatter(`"`using'"')
	if ustrregexm(`"`using'"', ".+((/)|(\\))") local path = ustrregexs(0)
	local usings "`path'miserables.json"
	if fileexists(`"`usings'"') {
		cap erase `"`usings'"'
		if _rc != 0 {
			! del `"`usings'"' /F
		}
	}


	mata miserables("`usings'") 
end


cap mata mata drop miserables()
mata
	function miserables(string scalar fileusing) {

		real scalar outputmap
		real scalar count
		real scalar i


		string matrix var1
		string matrix var2
		real matrix var3
		real matrix var4
		real matrix var5
        string matrix var6
        real matrix var7

		var1 = st_sdata(., (st_local("1")), st_local("touse"))
		var2 = st_sdata(., (st_local("2")), st_local("touse"))
		var3 = st_data(., (st_local("3")), st_local("touse"))
		var4 = st_data(., (st_local("4")), st_local("touse"))
		var5 = st_data(., (st_local("5")), st_local("touse"))
		var6 = (var1\var2)
		var7 = (var3\var4)



		outputmap = fopen(fileusing, "rw")
		fwrite(outputmap, sprintf(`"{\r\n"'))
		fwrite(outputmap, sprintf(`"\t"nodes": [\r\n"'))
		fwrite(outputmap, sprintf(`"\r\n\t\t{"id": "%s", "group": %g}"',var6[1],var7[1]))
		for (i = 1; i <= rows(var6); i++) {
			count = 0
			for (j = 1; j <=i-1; j++ ) {
				if (var6[i] == var6[j]) count = count + 1
			}
			if (!count) fwrite(outputmap, sprintf(`",\r\n\t\t{"id": "%s", "group": %g}"',var6[i],var7[i]))
		}
		fwrite(outputmap, sprintf(`"\r\n\t],\r\n"'))
		fwrite(outputmap, sprintf(`"\t"links": [\r\n"'))
		for (i = 1; i <= rows(var1); i++) {
			if (i != rows(var1)) fwrite(outputmap, sprintf(`"\t\t{"source": "%s", "target": "%s", "value": %g},\r\n"',var1[i],var2[i],var5[i]))
			else fwrite(outputmap, sprintf(`"\t\t{"source": "%s", "target": "%s", "value": %g}\r\n"',var1[i],var2[i],var5[i]))
		}
		fwrite(outputmap, sprintf(`"\t]\r\n"'))
		fwrite(outputmap, sprintf(`"}\r\n"'))
		fclose(outputmap)
	}
end





cap mata mata drop mapscatter()
mata
	function mapscatter(fileusing) {
		outputmap = fopen(fileusing, "rw")
		fwrite(outputmap, sprintf(`"<!DOCTYPE html>\r\n"'))
		fwrite(outputmap, sprintf(`"<meta charset="utf-8">\r\n"'))
		fwrite(outputmap, sprintf(`"<style>\r\n"'))
		fwrite(outputmap, sprintf(`".links line {\r\n"'))
		fwrite(outputmap, sprintf(`"\tstroke: #999;\r\n"'))
		fwrite(outputmap, sprintf(`"\tstroke-opacity: 0.6;\r\n"'))
		fwrite(outputmap, sprintf(`"}\r\n"'))
		fwrite(outputmap, sprintf(`".nodes circle {\r\n"'))
		fwrite(outputmap, sprintf(`"\tstroke: #fff;\r\n"'))
		fwrite(outputmap, sprintf(`"\tstroke-width: 1.5px;\r\n"'))
		fwrite(outputmap, sprintf(`"}\r\n"'))
		fwrite(outputmap, sprintf(`"</style>\r\n"'))
		fwrite(outputmap, sprintf(`"<svg width="1500" height="750"></svg>\r\n"'))
		fwrite(outputmap, sprintf(`"<script src="https://d3js.org/d3.v4.min.js"></script>\r\n"'))
		fwrite(outputmap, sprintf(`"<script>\r\n"'))
		fwrite(outputmap, sprintf(`"var svg = d3.select("svg"),\r\n"'))
		fwrite(outputmap, sprintf(`"\twidth = +svg.attr("width"),\r\n"'))
		fwrite(outputmap, sprintf(`"\theight = +svg.attr("height");\r\n"'))
		fwrite(outputmap, sprintf(`"var color = d3.scaleOrdinal(d3.schemeCategory20);\r\n"'))
		fwrite(outputmap, sprintf(`"var simulation = d3.forceSimulation()\r\n"'))
		fwrite(outputmap, sprintf(`"\t.force("link", d3.forceLink().id(function(d) { return d.id; }))\r\n"'))
		fwrite(outputmap, sprintf(`"\t.force("charge", d3.forceManyBody())\r\n"'))
		fwrite(outputmap, sprintf(`"\t.force("center", d3.forceCenter(width / 2, height / 2));\r\n"'))
		fwrite(outputmap, sprintf(`"d3.json("miserables.json", function(error, graph) {\r\n"'))
		fwrite(outputmap, sprintf(`"\tif (error) throw error;\r\n"'))
		fwrite(outputmap, sprintf(`"\tvar link = svg.append("g")\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t.attr("class", "links")\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t.selectAll("line")\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t.data(graph.links)\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t.enter().append("line")\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t.attr("stroke-width", function(d) { return Math.sqrt(d.value); });\r\n"'))
		fwrite(outputmap, sprintf(`"\tvar node = svg.append("g")\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t.attr("class", "nodes")\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t.selectAll("circle")\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t.data(graph.nodes)\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t.enter().append("circle")\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t.attr("r", 5)\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t.attr("fill", function(d) { return color(d.group); })\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t.call(d3.drag()\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t.on("start", dragstarted)\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t.on("drag", dragged)\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t.on("end", dragended));\r\n"'))
		fwrite(outputmap, sprintf(`"\tnode.append("title")\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t.text(function(d) { return d.id; });\r\n"'))
		fwrite(outputmap, sprintf(`"\tsimulation\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t.nodes(graph.nodes)\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t.on("tick", ticked);\r\n"'))
		fwrite(outputmap, sprintf(`"\tsimulation.force("link")\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t.links(graph.links);\r\n"'))
		fwrite(outputmap, sprintf(`"\tfunction ticked() {\r\n"'))
		fwrite(outputmap, sprintf(`"\t\tlink\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t.attr("x1", function(d) { return d.source.x; })\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t.attr("y1", function(d) { return d.source.y; })\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t.attr("x2", function(d) { return d.target.x; })\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t.attr("y2", function(d) { return d.target.y; });\r\n"'))
		fwrite(outputmap, sprintf(`"\t\tnode\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t.attr("cx", function(d) { return d.x; })\r\n"'))
		fwrite(outputmap, sprintf(`"\t\t\t.attr("cy", function(d) { return d.y; });\r\n"'))
		fwrite(outputmap, sprintf(`"\t}\r\n"'))
		fwrite(outputmap, sprintf(`"});\r\n"'))
		fwrite(outputmap, sprintf(`"function dragstarted(d) {\r\n"'))
		fwrite(outputmap, sprintf(`"\tif (!d3.event.active) simulation.alphaTarget(0.3).restart();\r\n"'))
		fwrite(outputmap, sprintf(`"\td.fx = d.x;\r\n"'))
		fwrite(outputmap, sprintf(`"\td.fy = d.y;\r\n"'))
		fwrite(outputmap, sprintf(`"}\r\n"'))
		fwrite(outputmap, sprintf(`"function dragged(d) {\r\n"'))
		fwrite(outputmap, sprintf(`"\td.fx = d3.event.x;\r\n"'))
		fwrite(outputmap, sprintf(`"\td.fy = d3.event.y;\r\n"'))
		fwrite(outputmap, sprintf(`"}\r\n"'))
		fwrite(outputmap, sprintf(`"function dragended(d) {\r\n"'))
		fwrite(outputmap, sprintf(`"\tif (!d3.event.active) simulation.alphaTarget(0);\r\n"'))
		fwrite(outputmap, sprintf(`"\td.fx = null;\r\n"'))
		fwrite(outputmap, sprintf(`"\td.fy = null;\r\n"'))
		fwrite(outputmap, sprintf(`"}\r\n"'))
		fwrite(outputmap, sprintf(`"</script>\r\n"'))
		fclose(outputmap)
	}
end



