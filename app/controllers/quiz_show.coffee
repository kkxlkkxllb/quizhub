Overflow = require("controllers/overflow")
Quiz = require("models/quiz")
QuizItem = require("models/quiz_item")
Member = require("models/member")
QuizPieceItemView = require("controllers/quiz_piece_item_view")
Utils = require("lib/utils")

class QuizShow extends Overflow
	className: "quiz-show overflow-layer active"
	events:
		"click .q_item .choice_item": "handleChoiceSelect"
		"click .submit": "handleSubmit"
		"click .check_answer": "handleCheckAnswer"
		"click .q_user a": "handleCheckUserAnswer"
		"click .share input": "handleSelectShareUrl"
		"click .get_qrcode": "handleShowQrcode"
		"blur .confirm_score input": "confirmScore"
		"click .choice_img img": "scaleImg"
		"click .remove .btn": "removeAnswer"
		"click .get_analytics": "getAnalytics"
	correctDict: {}
	constructor: ->
		super
		QuizItem.bind "refresh", @handleQuizItemAy
		$("html").css "overflow", "hidden"
		@answerData = {}
	render: (data) ->
		if current_member.uid is current_tid
			users_arr = []
			if data.users
				$.map data.users, (user) ->
					if user.has_answer
						users_arr.push user
			data.users = users_arr
			@data = data
			@html require("views/layer/quiz_teacher")(data)
			$(".qrcode_container",@$el).qrcode
				width: 160
				height: 160
				text: window.location.href
			QuizItem.factory data.items
		else if data.users[current_member.uid].has_answer
			@html require("views/layer/quiz_answer")(data)
			@renderAnswer()
		else
			time_s = new Date(data.start_at)
			time_e = new Date(data.end_at)
			current_time = new Date()
			@valid = false
			if current_time < time_e and current_time > time_s
				@valid = true
			ext =
				valid: @valid
				$shuffle: Utils.shuffle
			@data = $.extend {},data, ext
			@html require("views/layer/quiz_show")(@data)
		$(".aslatex",@$el).each ->
			MathJax.Hub.Queue(["Typeset",MathJax.Hub,$(@)[0]])
		$(".asmd", @$el).each ->
			Utils.renderMD $(@).text(),$(@)
		@$el
	handleChoiceSelect: (e) ->
		e.preventDefault()
		if @valid
			$target = $(e.currentTarget)
			qitem_id = $target.closest(".q_item").data().id
			$group = $target.closest(".list-group")
			if $group.data().type is 1
				$target.addClass("list-group-item-info").siblings().removeClass "list-group-item-info"
				@answerData[qitem_id] = [$target.data().idx]
			else
				$target.toggleClass "list-group-item-info"
				a = $.map $group.find(".list-group-item-info"), (el) ->
					$(el).data().idx
				if a.length > 0
					@answerData[qitem_id] = a
				else
					delete @answerData[qitem_id]
			len = Object.keys(@answerData).length
			$(".tool-bar .answered",@$el).text len
			if len is @data.items_size
				$(".submit",@$el).removeClass "disabled"
			else
				$(".submit",@$el).addClass "disabled"
	handleSubmit: (e) ->
		$target = $(e.currentTarget)
		current_time = new Date()
		time_end = new Date(@data.end_at)
		timeout = false
		if current_time > time_end
			Utils.flash "遗憾！已超出交卷截止时间，试卷将提交并标记为超时"
			timeout = true
		if Object.keys(@answerData).length is @data.items_size
			@data.users[current_member.uid].has_answer = true
			Quiz.updateUserData current_member.uid, has_answer: true
			current_member.setCurrentAnswerData
				submit_at: Firebase.ServerValue.TIMESTAMP
				title: @data.title
				teacher: current_tid
				answerData: @answerData
				timeout: timeout
			$target.text("已提交").addClass "disabled"
			$btnAnswer = $target.parent().next()
			$btnAnswer.removeClass "hide"
			$(".overflow-body",@$el).scrollTo($btnAnswer)
	handleCheckAnswer: (e) ->
		@valid = false
		@render(@data)
		$(window).trigger "resize"
	resetAnswer: ->
		@score = 0
		@correct = 0
		$(".q_item .list-group .choice_item",@$el).removeClass "list-group-item-danger selected"
		$(".q_item", @$el).removeClass "panel-success panel-danger"
	renderAnswer: (opt = {}) ->
		@resetAnswer()
		@answerFb.once "value", (f) =>
			$quInfo = $(".quiz_user_info",@$el)
			c_score = f.val().score
			$.each f.val().answerData, (k,d) =>
				qz = QuizItem.findByAttribute("qid", k)
				if qz.checkCorrect d
					@score += qz.score
					@correct += 1
				true
			if $quInfo.length > 0
				unless c_score
					@answerFb.update score: @score
				data =
					timeout: f.val().timeout
					submit_at: moment(new Date(f.val().submit_at)).format("YYYY/MM/DD HH:mm")
					score: c_score || @score
				data = $.extend {}, data, opt
				$quInfo.html require("views/items/quiz_user_info")(data)
				$(".overflow-body",@$el).scrollTo $quInfo
			$(".tool-bar .u_score .num",@$el).text @score
			$(".tool-bar .status .correct",@$el).text @correct
	handleCheckUserAnswer: (e) ->
		e.preventDefault()
		$target = $(e.currentTarget).parent()
		unless $target.hasClass "active"
			$target.addClass("active").siblings().removeClass "active"
			@answerFb = Member.currentQuizAnswerFB $target.data().id
			opt =
				email:  $target.data().mail
				name: $target.text()
			@renderAnswer(opt)
			$(".tool-bar",@$el).removeClass "hide"
	handleSelectShareUrl: (e) ->
		e.preventDefault()
		e.stopPropagation()
		$(e.currentTarget).select()
	handleShowQrcode: (e) ->
		$(".qrcode-modal",@$el).modal "show"
	confirmScore: (e) ->
		@answerFb.update score: $(e.currentTarget).val()
	scaleImg:(e) ->
		e.preventDefault()
		e.stopPropagation()
		$(e.currentTarget).toggleClass "auto"

	removeAnswer: (e) ->
		if confirm "确定移除答卷?不可恢复！"
			$target_user = $(".joined_users .q_user.active")
			uid = $target_user.data().id
			Quiz.updateUserData uid, has_answer: false
			@data.users = $.grep @data.users, (user) ->
				user.uid isnt uid
			@render(@data)
			$(window).trigger "resize"
	handleQuizItemAy: =>
		for item,idx in QuizItem.all()
			view = new QuizPieceItemView(item: item, idx)
			$(".items_container",@$el).append view.renderForAnalytics(idx + 1)
	getAnalytics: (e) ->
		self = this
		q = async.queue (task,cb) ->
			task.fb.once "value", (f) ->
				$.each f.val().answerData, (k,d) ->
					qz = QuizItem.findByAttribute("qid", k)
					result = qz.checkCorrect d, false
					self.correctDict[qz.id] ?= {}
					self.correctDict[qz.id][task.uid] = result
					true
				cb()
		q.drain = ->
			console.log self.correctDict
		if Object.keys(@correctDict).length is 0
			$.each $(".joined_users .q_user"), (i,el) ->
				uid = $(el).data().id
				answerFb = Member.currentQuizAnswerFB uid
				q.push
					fb: answerFb
					uid: uid
		else
			console.log self.correctDict

module.exports = QuizShow
