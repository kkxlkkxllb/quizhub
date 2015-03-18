Quiz = require("models/quiz")
Preview = require("lib/preview")
Utils = require("lib/utils")

class QuizPieceItemView extends Spine.Controller
	className: "q_item panel panel-default"
	events:
		"click .q_edit": "handleEdit"
		"click .q_remove": "handleDelete"
	constructor: ->
		super
		@item.bind "destroy",@release
		@item.bind "update", @render
		@item.bind "append:anwser", @appendUserAnswer
	render: =>
		@html require("views/items/qz_item")(item: @item, isTesting: false, displayAnswer: true)
		$(".aslatex",@$el).each ->
			MathJax.Hub.Queue(["Typeset",MathJax.Hub,$(@)[0]])
		$(".asmd", @$el).each ->
			Utils.renderMD $(@).text(),$(@)
		@$el
	renderForAnalytics: (num) ->
		options =
			item: @item
			isTesting: true
			displayAnswer: true
			num: num
		@html require("views/items/qz_item")(options)
	appendUserAnswer: (d,data) =>
		for idx in data.answer
			$target = $(".list-group div[data-idx='#{idx}']",@$el)
			unless $target.hasClass "list-group-item-success"
				$target.addClass "list-group-item-danger"
			$target.addClass "selected"
		cls = if data.result then "panel-success" else "panel-danger"
		@$el.removeClass("panel-default").addClass cls
	handleEdit: (e) ->
		e.preventDefault()
		e.stopPropagation()
		@html require("views/items/form_add_quiz")(@item)
		$(".set_cate input[value=#{@item.type}]",@$el).trigger "click"
		$(".set_content textarea",@$el).focus()
		switch @item.senior
			when 1
				$("input[name='latex']",@$el).parent().trigger "click"
			when 2
				$("input[name='md']",@$el).parent().trigger "click"
		if @item.mass
			$(".options input[name='mass']",@$el).parent().trigger "click"
		$(".overflow-body",@$el.closest(".overflow-layer")).scrollTo(@$el)
	handleDelete: (e) ->
		e.preventDefault()
		e.stopPropagation()
		if confirm "确定删除该试题?"
			@item.destroy()
			Quiz.trigger "delete_item", @item.qid

module.exports = QuizPieceItemView
