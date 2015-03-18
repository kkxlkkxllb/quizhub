NewQuizLayer = require("controllers/new_quiz_layer")
Member = require("models/member")
Utils = require("lib/utils")

class EditQuizLayer extends NewQuizLayer
	className: "edit-quiz-layer overflow-layer active"
	events:
		"click .remove_users": "handleRemoveAll"
	constructor: ->
		super
		$("body").append @render()
		@checkQuizUsers()
		@setupItems()
	render: ->
		@html require("views/layer/quiz")(@item)
	setupItems: ->
		if @item.items
			$.each @item.items, (k, item) =>
				data = $.extend {}, item, qid: k
				@addOneItem data
		@updateQuizState()
		@$el.find(".basic_info .category input[value='#{@item.private}']").trigger "click"
	checkQuizUsers: ->
		current_member.get_quiz_users @item.id, (data) =>
			users_arr = []
			if data
				$.map data, (user) ->
					if user.has_answer
						users_arr.push user
			num = users_arr.length
			if num > 0
				@users_arr = users_arr
				$(".basic_info",@$el).before require("views/items/tips")(num: num)
	handleRemoveAll: (e) ->
		e.preventDefault()
		if confirm "确定移除所有答卷？"
			for u in @users_arr
				current_member.quiz_users(@item.id).child(u.uid).update
					has_answer: false
			$(e.currentTarget).closest(".well").remove()

module.exports = EditQuizLayer
