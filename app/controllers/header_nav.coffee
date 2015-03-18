Member = require("models/member")
Quiz = require("models/quiz")

class HeaderNav extends Spine.Controller
	el: "header"
	className: "inav"
	events:
		"click .checkout": "quit"
	constructor: ->
		super
		@render()
	quit: (e) ->
		e.preventDefault()
		$(".login-modal,.register-modal").remove()
		Member.logout ->
			window.location.href = "/"
	render: ->
		@html require("views/header_nav")(data: current_member)


module.exports = HeaderNav
