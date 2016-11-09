package moji;

using tink.CoreApi;

class Prompt {
	var message:Conditional<String>;
	var answers:Array<Conditional<Option<String>>>;
	
	public function new(message, answers) {
		this.message = message;
		this.answers = answers;
	}
	
	public function resolve() {
		var ret = {
			message: null,
			answers: [],
		}
		var fetchMessage = message.get().map(function(v) {
			ret.message = v;
			return Noise;
		});
		
		var fetchAnswers = [for(i in 0...answers.length)
			answers[i].get().map(function(v) {
				ret.answers[i] = v;
				return Noise;
			})
		];
		
		return Future.ofMany([fetchMessage].concat(fetchAnswers)).map(function(_) return ret);
	}
}