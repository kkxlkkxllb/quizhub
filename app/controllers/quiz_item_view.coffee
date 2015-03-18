Quiz = require("models/quiz")
class QuizItemView extends Spine.Controller
	className: "quiz_item col-sm-4"
	events:
		"click .edit": "handleEdit"
		"click .delete": "handleDelete"
	constructor: ->
		super
		@item.bind "destroy",@release
		@item.bind "update", @render
	render: =>
		@html require("views/items/quiz_item")(item: @item, uid: @uid)
	handleEdit: (e) ->
		e.preventDefault()
		e.stopPropagation()
		@navigate("/edit/" + @item.id)
	handleDelete: (e) ->
		e.preventDefault()
		e.stopPropagation()
		if confirm "确定删除该试卷?"
			Quiz.trigger "delete", @item.id

module.exports = QuizItemView
