Member = require("models/member")
HeaderNav = require("controllers/header_nav")
Quiz = require("models/quiz")
QuizJoined = require("models/quiz_joined")
QuizItem = require("models/quiz_item")
QuizItemView = require("controllers/quiz_item_view")
NewQuizLayer = require("controllers/new_quiz_layer")
EditQuizLayer = require("controllers/edit_quiz_layer")
QuizShow = require("controllers/quiz_show")
Utils = require("lib/utils")

class QuizController extends Spine.Controller
	el: "article"
	className: "quiz_view"
	events:
		"click a[href='#joined']": "handleJoinedQuiz"
	constructor: ->
		super
		@routes
			"": ->
				@navigate("/", replace: true)
			"/": ->
				$("title").text "QuizHub"
				if @qs
					@qs.release()
					$("html").css "overflow", "auto"
				unless @head
					Quiz.one "refresh", @renderQuizContainer
					@head = new HeaderNav()
					@html require("views/main")()
					current_member.getData (data) =>
						quiz_data = []
						if data
							quiz_data =  $.map data, (e,k) ->
								c_at = moment(new Date(e.c_at)).format("YYYY/MM/DD HH:mm")
								addtion =
									id: k
									c_at: c_at
								$.extend {}, e,addtion
						Quiz.refresh quiz_data, clear: true
				$("body").removeClass "loading"
			"/edit/:qid": @handleEditQuiz
			"/:tid/:qid": @active_quiz
			"/new": @handleNewQuiz

		Member.one 'refresh', @renderMemberView
		Quiz.bind "create", @addOneQuiz
		Quiz.bind "delete", @handleQuizDestroy
		$(window).resize =>
			@adjustUserlistH()
		$("body").on "submit", ".pwd-required-form", @handlePwdCheck
		$("body").on "keydown", ".pwd-required-form", @triggerPwdCheck
	adjustUserlistH: =>
		h_cw = $(window).height() - 61
		if  window.innerWidth > 640
			$(".joined_users").height h_cw
		else
			$(".joined_users").css "height": "auto"
		$(".overflow-body").height h_cw
	commonLayer: (el) ->
		$(".datetime",el).datetimepicker
			language: "zh-CN"
			icons:
				time: "fa fa-clock-o"
				up: "fa fa-arrow-up"
				down: "fa fa-arrow-down"
				date: "fa fa-calendar"
			format: "YYYY/MM/DD HH:mm"
		$(window).trigger "resize"
		$("input[type='text']:visible, textarea:visible",el).first().focus()

	handleNewQuiz: =>
		@qs.release() if @qs
		$("title").text "新建试卷"
		@qs = new NewQuizLayer()
		@commonLayer @qs.$el
		$("body").removeClass "loading"
	handleEditQuiz: (params) =>
		@qs.release() if @qs
		$("body").addClass "loading"
		Quiz.getEditData params.qid, (data) =>
			QuizItem.destroyAll()
			@qs = new EditQuizLayer(item: data)
			@commonLayer @qs.$el
			$("body").removeClass "loading"
	renderQuizContainer: =>
		if Quiz.count() is 0
			@renderEmptyView $("#owner",@$el), userrole: 0
		else
			$("#owner",@$el).empty()
			for item in Quiz.all()
				@addOneQuiz item
	addOneQuiz: (item) =>
		$(".empty_quiz_view",@$el).remove()
		view = new QuizItemView
			item: item
			uid: current_member.uid
		$("#owner",@$el).prepend view.render()
	renderMemberView: =>
		window.current_member = Member.first()
		Spine.Route.setup()

	active_quiz: (params) ->
		@qs.release() if @qs
		window.current_tid = params.tid
		window.current_qid = params.qid
		$("body").addClass "loading"
		$(".loaderlayer .tips").removeClass "hide"
		Quiz.getData (data) =>
			$(".loaderlayer").html require("views/loading")()
			q_name = data.title || "未命名"
			$("title").text q_name
			current_member.existCurrentQuizUser (tof) =>
				if tof # 已登记用户
					@setupQuiz()
				else if data.private is "1" and current_member.uid isnt current_tid
					@popPwdRequired(data.pwd)
				else # 公开
					@setupQuiz()

	popPwdRequired: (@pwd) ->
		$modal = $(".pwd-required-modal")
		$modal.html require("views/modal/pwd")()
		$modal.modal "show"
	setupQuiz: ->
		# logon RoomUser
		unless current_member.uid is current_tid
			current_member.setCurrentQuizUserData()
		Quiz.getData (data) =>
			all_score = 0
			if data.items
				$.map data.items, (i) ->
					all_score += i.score
			@qs = new QuizShow()
			$("body").append @qs.render($.extend {},data, all_score: all_score)
			$("body").removeClass "loading"
			$(window).trigger "resize"

	handlePwdCheck: (e) =>
		e.preventDefault()
		$form = $(e.currentTarget)
		$pwd = $("input[name='pwd']",$form)
		if $pwd.val() is @pwd
			$(".pwd-required-modal").modal "hide"
			@setupQuiz()
		else
			$pwd.focus()
	triggerPwdCheck: (e) ->
		if e.keyCode is 13
			e.preventDefault()
			$(".pwd-required-form").submit()
	renderEmptyView: ($el, options)->
		$el.html require("views/quiz_empty")(options)
	handleQuizDestroy: (id) =>
		Quiz.find(id).removeFB()
		if Quiz.count() is 0
			@renderEmptyView $("#owner",@$el), userrole: 0
	handleJoinedQuiz: (e) ->
		e.preventDefault()
		unless $(e.currentTarget).hasClass "loaded"
			$(e.currentTarget).addClass "loaded"
			current_member.getCommonData (data) =>
				quiz_data = []
				if data
					quiz_data = $.map data, (e,k) ->
						submit_at = moment(new Date(e.submit_at)).format("YYYY/MM/DD HH:mm")
						addtion =
							id: k
							submit_at: submit_at
						$.extend {}, e,addtion
				if quiz_data.length is 0
					@renderEmptyView $("#joined",@$el), userrole: 1
				else
					$("#joined",@$el).empty()
					for item in quiz_data
						$("#joined",@$el).prepend require("views/items/quiz_joined_item")(item: item)

module.exports = QuizController
