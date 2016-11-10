package renderer;

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
		appendElement('h1', 'Game Over');
	}
	
	public function prompt(content:Prompt) {
		return Future.async(function(cb) {
			content.resolve().handle(function(v) {
				appendElement('div', v.message);
				
				for(i in 0...v.answers.length) {
					switch v.answers[i] {
						case Hidden:
							// skip
						case Disabled(v):
							var element = appendElement('button', v);
							element.setAttribute('disabled', 'true');
						case Normal(v):
							var element = appendElement('button', v);
							element.onclick = function() {
								clear();
								cb(i);
							}
					}
				}
			});
		});
	}
	
	function clear() {
		while(div.firstChild != null) div.removeChild(div.firstChild);
	}
	
	function appendElement(name:String, content:String) {
		var element = document.createElement(name);
		element.appendChild(document.createTextNode(content));
		div.appendChild(element);
		return element;
	}
}