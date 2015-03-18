class AjaxQuiz extends Spine.Model
	@configure 'AjaxQuiz', "id", "url"
	@extend Spine.Model.Ajax
	@delete: (id) ->
		if id?
			request_url = Spine.Model.host + "/api/images"
			@ajax().ajaxQueue
				type: "DELETE"
				url: request_url
				processData: true
				data:
					id: id
	@saveB64: (bg, then_do) ->
		request_url = Spine.Model.host + "/api/images"
		@ajax().ajaxQueue
			url: request_url
			data:
				type: "bg"
				data: bg
			processData: true
			type: 'POST'
		.done(then_do)

module.exports = AjaxQuiz
