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
	
	public function prompt(content:Prompt) {
		return Future.async(function(cb) {
			var message = null;
			var answers = [];
			
			var fetchMessage = content.message.get().map(function(v) {
				message = v;
				return Noise;
			});
			
			var fetchAnswers = [for(i in 0...content.answers.length)
				content.answers[i].get().map(function(v) {
					answers[i] = v;
					return Noise;
				})
			];
			
			Future.ofMany([fetchMessage].concat(fetchAnswers)).handle(function() {
				var element = document.createElement('div');
				element.appendChild(document.createTextNode(message));
				div.appendChild(element);
				
				for(i in 0...answers.length) {
					switch answers[i] {
						case None:
							// skip
						case Some(v):
							var element = document.createElement('button');
							element.appendChild(document.createTextNode(v));
							element.onclick = function() {
								cb(i);
								clear();
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