package;

import moji.*;
import js.Browser.*;
import js.html.*;

using tink.CoreApi;

class HtmlRenderer implements Renderer {
	
	var div:Element;
	
	public function new(div:Element) {
		this.div = div;
	}
	
	public function end() {
		clear();
		var element = document.createElement('h1');
		element.appendChild(document.createTextNode("Game Over"));
		div.appendChild(element);
	}
	
	public function prompt(content:Prompt) {
		return Future.async(function(cb) {
			content.resolve().handle(function(v) {
				var element = document.createElement('div');
				element.appendChild(document.createTextNode(v.message));
				div.appendChild(element);
				
				for(i in 0...v.answers.length) {
					switch v.answers[i] {
						case None:
							// skip
						case Some(v):
							var element = document.createElement('button');
							element.appendChild(document.createTextNode(v));
							element.onclick = function() {
								clear();
								cb(i);
							}
							div.appendChild(element);
					}
				}
			});
		});
	}
	
	function clear() {
		while(div.firstChild != null) div.removeChild(div.firstChild);
	}
}