package;

import buddy.*;

using buddy.Should;
using moji.Moji;
using tink.CoreApi;

class TestConditional extends BuddySuite {
	public function new() {
		describe("Conditional", {
			it("should evaluate sync conditionals correctly", {
				var trueCond:Condition = true;
				var falseCond:Condition = false;
				
				(1:Conditional<Int>).resolve().handle(function(v) v.should.be(1));
				trueCond.then(1, 2).resolve().handle(function(v) v.should.be(1));
				falseCond.then(1, 2).resolve().handle(function(v) v.should.be(2));
				trueCond.then(trueCond.then(1, 2), falseCond.then(3, 4)).resolve().handle(function(v) v.should.be(1));
				trueCond.then(falseCond.then(1, 2), falseCond.then(3, 4)).resolve().handle(function(v) v.should.be(2));
				falseCond.then(trueCond.then(1, 2), trueCond.then(3, 4)).resolve().handle(function(v) v.should.be(3));
				falseCond.then(trueCond.then(1, 2), falseCond.then(3, 4)).resolve().handle(function(v) v.should.be(4));
			});
			
			it("should evaluate async conditionals correctly", function(done) {
				var trueTrigger:FutureTrigger<Bool> = Future.trigger();
				var falseTrigger:FutureTrigger<Bool> = Future.trigger();
				var trueCond:Condition = trueTrigger.asFuture();
				var falseCond:Condition = falseTrigger.asFuture();
				
				var count = 0;
				var errors = [];
				
				function retain() count ++;
				function release() if(--count == 0) {
					if(errors.length == 0) done();
					else fail(errors.join('\n'));
				}
				
				function assert(e:Int, cond:Conditional<Int>, ?pos:haxe.PosInfos) {
					retain();
					cond.resolve().handle(function(v) {
						if(e != v) errors.push(new Error('Expected $e but got $v', pos));
						release();
					});
				}
				
				assert(1, trueCond.then(1, 2));
				assert(2, falseCond.then(1, 2));
				assert(1, trueCond.then(trueCond.then(1, 2), falseCond.then(3, 4)));
				assert(2, trueCond.then(falseCond.then(1, 2), falseCond.then(3, 4)));
				assert(3, falseCond.then(trueCond.then(1, 2), trueCond.then(3, 4)));
				assert(4, falseCond.then(trueCond.then(1, 2), falseCond.then(3, 4)));
				assert(1, 1);
				
				trueTrigger.trigger(true);
				falseTrigger.trigger(false);
			});
		});
	}
}