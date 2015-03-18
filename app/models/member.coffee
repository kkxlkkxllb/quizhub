class Member extends Spine.Model
	@configure 'Member', "id", "uid", "password", "token", "provider", 'userrole', 'devicetype', "name", "webrtc", "avatar"
	@logout: (then_do) ->
		teachers_fb.unauth()
		then_do() if then_do
	@login: (data) ->
		avatar = if data.avatar? then data.avatar.thumb else '/favicon.png'
		obj = $.extend {}, data, avatar: avatar
		@create obj
		@refresh(obj, clear: true)
	quiz_users: (qid) ->
		teachers_fb.child(@uid).child(qid + "/users")
	get_quiz_users: (qid, callback) ->
		@quiz_users(qid).once "value" , (d) ->
			callback(d.val())
	@generateToken: (uid, provider, token) ->
		tokenGenerator = new FirebaseTokenGenerator("I1a1lkUUuLWyTAFOIg3wHf0ZZaY9HUU4ofjNtErp")
		tokenGenerator.createToken uid: "#{provider}:#{uid}", provider: provider, data: token
	@getUserData: (uid, success, fail) ->
		teachers_fb.parent().child("users/" + uid).once "value", (d) ->
			if d.val()
				success(d.val())
			else
				fail() if fail
	getData: (then_do) ->
		teachers_fb.child(@uid).once "value", (f) ->
			then_do(f.val())
	getCommonData: (then_do) ->
		teachers_fb.parent().child("common/" + @uid).once "value", (f) ->
			then_do(f.val())
	currentQuizUserFB: ->
		teachers_fb.child(current_tid + "/" + current_qid + "/users/" + @uid)
	@currentQuizAnswerFB: (uid) ->
		teachers_fb.parent().child("common/" + uid + "/" + current_qid)
	currentQuizAnswerFB: ->
		Member.currentQuizAnswerFB @uid
	existCurrentQuizUser: (then_do) ->
		@currentQuizUserFB().once "value", (d) ->
			then_do d.val()
	setCurrentQuizUserData: ->
		@currentQuizUserFB().update
			uid: @uid
			name: @name
			email: @password.email
	setCurrentAnswerData: (data) ->
		@currentQuizAnswerFB().set data

module.exports = Member
