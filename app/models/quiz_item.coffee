class QuizItem extends Spine.Model
	@configure 'QuizItem', "qid", "content", "data", "senior", "score", "type", "attach_data", "mass"
	@factory: (obj) ->
		data = $.map obj, (d,k) ->
			$.extend {}, d, qid: k
		@refresh data, clear: true
	calCorrectNum: ->
		d = $.grep @data, (e) -> e.key
		d.length
	checkCorrect: (answer) ->
		f = 0
		t = 0
		for idx in answer
			if @data[idx - 1].key
				t += 1
			else
				f += 1
		result = false
		switch @type
			when 1
				if f is 0
					result = true
			when 2
				if t is @calCorrectNum()
					result = true
		ext =
			answer: answer
			result: result
		@trigger "append:anwser", ext
		result



module.exports = QuizItem
