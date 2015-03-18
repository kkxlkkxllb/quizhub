Overflow = require("controllers/overflow")
Quiz = require("models/quiz")
QuizItem = require("models/quiz_item")
QuizPieceItemView = require("controllers/quiz_piece_item_view")
Utils = require("lib/utils")
Preview = require("lib/preview")
AjaxQuiz = require("models/ajax_quiz")

class NewQuizLayer extends Overflow
	className: "new-quiz-layer overflow-layer active"
	events:
		"click .basic_info .submit": "createQuiz"
		"change input[name='private']": "setPwd"
		"blur :input:visible[required='required']": "checkFormInput"
		"change .set_cate  input[type='radio']": "handleQuizCateChange"
		"input .panel .score": "handleQuizItemsScoreChange"
		"click .q_container .add": "addMoreChoice"
		"click .q_container .remove": "removeOneChoice"
		"click .confirm": "createQuizItems"
		"click .cancel": "cancelEdit"
		"change input[type='file']": "handleQuizImageUpload"
		"click .remove_image": "handleQuizImageRemove"
		"keyup .set_content textarea": "handleUpdateContentPreview"
		"change .senior_editor input[type='checkbox']": "handleSeniorSwitch"
		"click .more_func": "handleMoreFuncShow"
		"click .tool-bar .new": "scrollToBottom"
		"focus .edit-qz-form .set_content textarea": "addActive"
		"shown.bs.modal .modal": "afterModalShow"
		"click .more-func-modal .submit": "handleMoreFuncSubmit"

	constructor: ->
		super
		$("html").css "overflow", "hidden"
		Quiz.bind "delete_item", @handleQuizItemDelete
		$("body").append @render()
	render: ->
		@html require("views/layer/quiz")()
	checkFormInput: (e) ->
		$input = $(e.currentTarget)
		if $input[0].validity.valid
			$input.parent().removeClass "has-error"
	setPwd: (e) ->
		value = $(e.currentTarget).val()
		tof = if value is "1" then true else false
		$(".set_pwd",@$el).toggleClass "hide",!tof
	createQuiz: (e) ->
		$btn = $(e.currentTarget)
		$form = $(".add-quiz-form",@$el)
		data = $form.serializeObject()
		qid = data.id
		$(":input:visible[required='required']",$form).each ->
			if $(@).prop("readonly")
				if $(@).val() is ""
					$(@).parent().addClass "has-error"
					return false
			else if !@validity.valid
				$(@).parent().addClass "has-error"
				$(@).focus()
				return false
		time_s = new Date(data["start_at"])
		time_e = new Date(data["end_at"])
		if time_s > time_e
			Utils.flash "不能早于开始时间","danger"
			return false
		if $(".has-error",$form).length is 0
			delete data["id"]
			if qid isnt ""
				Quiz.find(qid).updateData data
				$btn.addClass("disabled").text "已更新"
			else
				obj = $.extend {}, data, c_at: Firebase.ServerValue.TIMESTAMP
				Quiz.addOne obj, (id) =>
					$(".new_form",@$el).data("id", id)
				$btn.addClass("disabled").text "已提交"
				$(".new_form, .tool-bar",@$el).removeClass "hide"
				@scrollToBottom()
	handleQuizCateChange: (e) ->
		$panel = $(e.currentTarget).closest(".panel")
		value = $(e.currentTarget).val()
		$(".q_container .qc[data-id='#{value}']",$panel).removeClass("hide").siblings().addClass "hide"
	handleQuizItemsScoreChange: (e) ->
		$panel = $(e.currentTarget).closest(".panel")
		value = $(e.currentTarget).val()
		$("label .s_val",$panel).text(value)
	addMoreChoice: (e) ->
		$qc = $(e.currentTarget).closest(".qc")
		type = if $qc.data().id is 1 then "radio" else "checkbox"
		$qc.find("form").append require("views/items/qc_item")(ctype: type)
	removeOneChoice: (e) ->
		$(e.currentTarget).closest(".qc_item").remove()
	choiceValidateAndGetData: ($qc) ->
		$(":input:visible[required='required']",$qc).each ->
			if !@validity.valid
				$(@).parent().addClass "has-error"
				$(@).focus()
				return false
		if $(".has-error",$qc).length is 0
			arys = []
			$qc.find("form textarea[name='qc_desc']").each (i) ->
				$qzc = $(@).closest(".qc_item")
				arys.push
					idx: (i + 1)
					desc: $(@).val()
					key: $(@).prev().find("input[name='key']").is(':checked')
					senior: $qzc.data("senior") || null
					attach_data: $qzc.data("attach_data") || null
			return arys
		else
			return false
	createQuizItems: (e) ->
		qid = $(e.currentTarget).data().qid
		$panel = $(e.currentTarget).closest(".panel")
		$qc = $(".qc:visible",$panel)
		type = $qc.data().id
		quiz_id = $(".new_form",@$el).data().id
		quiz = Quiz.find(quiz_id)
		$ta = $panel.find(".set_content textarea")
		if $ta.val() is ""
			$ta.parent().addClass "has-error"
			$ta.focus()
			return false
		$img = $(".attach_file .attach_preview img",$panel)
		attach_data = null
		if $img.length isnt 0
			attach_data =
				url: $img.attr("src")
				id: $img.data().id
		$se = $(".senior_editor input[type='checkbox']:checked",@$el)
		senior = false
		if $se.length isnt 0
			senior = $se.data().value
		switch type
			when 1
				if $(".qc_item",$qc).length < 2
					Utils.flash "请确保至少有2个选项！","danger"
					return false
				$keys = $(".qc_item input[name='key']:checked",$qc)
				if $keys.length is 0
					Utils.flash "请选定一个选项作为答案！","danger"
					return false
				data = @choiceValidateAndGetData $qc
			when 2
				if $(".qc_item",$qc).length < 3
					Utils.flash "请确保至少有3个选项！","danger"
					return false
				$keys = $(".qc_item input[name='key']:checked",$qc)
				if $keys.length is 0
					Utils.flash "请选定至少一个选项作为答案！","danger"
					return false
				data = @choiceValidateAndGetData $qc
		if data
			objData =
				type: type
				senior: senior
				content: $ta.val()
				data: data
				score: parseInt($("input.score",$panel).val(),10)
				attach_data: attach_data
				mass: $(".options input[name='mass']",$panel).is(":checked")
			if qid
				quiz.updateItemData(qid, objData)
				@updateQuizState()
				$(".overflow-body",@$el).scrollTo $panel
			else
				quiz.addOneItem objData, (id) =>
					data = $.extend {}, objData, qid: id
					@addOneItem data, true
					@updateQuizState(quiz_id)
				$panel.html require("views/items/new_form")()
				$(".set_cate .btn:eq(0)",$panel).trigger "click"

	cancelEdit: (e) ->
		$target = $(e.currentTarget)
		qid = $target.prev().data().qid
		$item = $target.closest(".q_item")
		QuizItem.findByAttribute("qid", qid).trigger "update"
		$(".overflow-body",@$el).scrollTo($item)
	renderImageAttach: ($target, data) ->
		$target.html require("views/items/img_attach")(attach_data: data)
	handleQuizImageUpload: (e) ->
		$panel = $(e.currentTarget).closest(".attach_file")
		$img = $(".attach_preview img",$panel)
		$panel.html require("views/loading")()
		if $img.length > 0
			AjaxQuiz.delete $img.data().id
		fr = new FileReader()
		fr.readAsDataURL(e.target.files[0])
		self = this
		fr.onload = (ev) ->
			AjaxQuiz.saveB64 ev.target.result.split("base64,")[1], (data) ->
				self.renderImageAttach $panel, data
	handleQuizImageRemove: (e) ->
		$panel = $(e.currentTarget).closest(".attach_file")
		$img = $(".attach_preview img",$panel)
		if $img.length > 0
			AjaxQuiz.delete $img.data().id
		@renderImageAttach $panel
	handleQuizItemDelete: (id) =>
		quiz_id = $(".new_form",@$el).data().id
		Quiz.find(quiz_id).removeItem id
		@updateQuizState(quiz_id)
	updateQuizState: (qid) ->
		items_size = QuizItem.count()
		if qid
			Quiz.find(qid).updateData items_size: items_size
		$(".navbar .count em",@$el).text items_size
		all_score = 0
		$.map QuizItem.all(), (i) ->
			all_score += i.score
		$(".navbar .score em",@$el).text all_score
	handleSeniorSwitch: (e) ->
		$target = $(e.currentTarget)
		tof = $target.is(":checked")
		$panel = $target.closest(".senior_editor")
		if tof
			$siblings = $target.parent().siblings()
			if $siblings.hasClass "active"
				$siblings.click()
		switch $target.data().value
			when 1
				$(".latex_preview",$panel).toggleClass "hide", !tof
			when 2
				$(".md_preview",$panel).toggleClass "hide", !tof
		$ta = $panel.prev().find("textarea")
		if $ta.val() isnt "" and tof
			$ta.trigger "keyup"
	handleMoreFuncShow: (e) ->
		$target = $(e.currentTarget).closest(".qc_item")
		$target.addClass("active").siblings().removeClass "active"
		$modal = $(".more-func-modal",@$el)
		obj =
			desc: $target.find("textarea[name='qc_desc']").val()
			attach_data: $target.data().attach_data
		$modal.html require("views/modal/more_func")(obj)
		$modal.modal "show"
		if val = $target.data().senior
			$("input[data-value=#{val}]",$modal).parent().click()
	handleUpdateContentPreview: (e) ->
		$ta = $(e.currentTarget)
		$qzForm = $ta.closest(".edit-qz-form")
		if $("input[name='latex']",$qzForm).is(":checked")
			Preview.Update()
		else if $("input[name='md']",$qzForm).is(":checked")
			Utils.renderMD $ta.val(), $(".edit-qz-form.active .md_preview .qz_preview_content", @$el)
	addOneItem: (data, scrollTo) ->
		q = QuizItem.create data
		item = new QuizPieceItemView(item: q)
		$(".items_container",@$el).append item.render()
		if scrollTo
			$(".overflow-body",@$el).scrollTo item.$el
	scrollToBottom: ->
		$newForm = $(".new_form:visible", @$el)
		if $newForm.length > 0
			$(".overflow-body",@$el).scrollTo($newForm)
			$newForm.find(".set_content textarea").focus()
	afterModalShow: (e) ->
		$modal = $(e.currentTarget)
		$modal.find("input[type='text']:visible, textarea:visible").first().focus()
	addActive: (e) ->
		$qzForm = $(e.currentTarget).closest(".edit-qz-form")
		unless $qzForm.hasClass "active"
			$(".edit-qz-form",@$el).removeClass "active"
			$qzForm.addClass "active"
			Preview.Init(@$el)
	handleMoreFuncSubmit: (e) ->
		$modal = $(e.currentTarget).closest(".modal")
		$target = $(".qc_item.active",@$el)
		$img = $(".attach_file .attach_preview img",$modal)
		attach_data = null
		if $img.length isnt 0
			attach_data =
				url: $img.attr("src")
				id: $img.data().id
		$target.find("textarea[name='qc_desc']").val $("textarea", $modal).val()
		$se = $(".senior_editor input[type='checkbox']:checked",$modal)
		senior = false
		if $se.length isnt 0
			senior = $se.data().value
		$target.data("senior",senior)
		$target.data("attach_data", attach_data)
		$(".qc_item",@$el).removeClass "active"
		$modal.modal "hide"

module.exports = NewQuizLayer
