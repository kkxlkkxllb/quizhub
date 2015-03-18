require('lib/setup')
Member = require("models/member")
QuizController = require("controllers/quiz_controller")
Utils = require("lib/utils")

$ ->
	Spine.Model.host = "http://api.17up.org"
	# Spine.Model.host = "http://144.214.111.189:3000"
	@fb = new Firebase("https://imagine17.firebaseio.com/")
	window.teachers_fb = @fb.child("teachers")
	new QuizController()
	showLoginModal = ->
		$("body").addClass "loading"
		$(".loaderlayer .tips").addClass "hide"
		$(".login-modal").modal
			backdrop: false
		.modal "show"

	# auth&register from 3rd
	auth = $.getParameterByName("auth")
	name = $.getParameterByName("n")
	email = $.getParameterByName("m")
	uid = $.getParameterByName("id")
	provider = $.getParameterByName("p")
	if auth isnt "" and uid isnt ""  and provider isnt ""
		token = Member.generateToken uid,provider, auth
		@fb.authWithCustomToken token, (error,data) =>
			unless error
				window.history.replaceState("","home","/")
				success = (data) ->
					if data.auth.data is auth
						Member.login data
					else
						Utils.flash "fail auth", "danger"
				failure = =>
					ext =
						name: name
						password:
							email: email
					data = $.extend {}, data, ext
					@fb.child("users").child(data.uid).set(data)
					Member.login data
				Member.getUserData data.uid, success, failure
	else
		@fb.onAuth (user) =>
			if user
				Member.getUserData user.uid, (data) ->
					Member.login data
				$(".login-modal").modal "hide"
				$(".register-modal").modal "hide"
			else
				showLoginModal()

	$(".link_register").click (e) ->
		e.preventDefault()
		$(".login-modal").modal "hide"
		$(".register-modal").modal
			backdrop: false
		.modal "show"
	$(".link_login").click (e) ->
		e.preventDefault()
		$(".register-modal").modal "hide"
		$(".login-modal").modal
			backdrop: false
		.modal "show"
	$(".login-modal").on "submit", "form", (e) =>
		e.preventDefault()
		$form = $(e.currentTarget)
		form_data = $form.serializeObject()
		$(".loaderlayer .tips").removeClass "hide"
		@fb.authWithPassword form_data, (err, authData) =>
			if err
				Utils.flash err.message, "danger"
	$(".register-modal").on "submit", "form", (e) =>
		e.preventDefault()
		$form = $(e.currentTarget)
		form_data = $form.serializeObject()
		$(".loaderlayer .tips").removeClass "hide"
		@fb.createUser form_data, (error) =>
			if error
				Utils.flash error.message, "danger"
			else
				Utils.flash "新用户注册成功", "success"
				@fb.authWithPassword form_data, (err, authData) =>
					unless err
						data = $.extend {}, authData, name: form_data.name
						@fb.child("users").child(authData.uid).set(data)





