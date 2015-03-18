class Overflow extends Spine.Controller
	className: "overflow-layer active"
	events:
		"click .navbar .close": "handleCloseWindow"
	render: ->
		@html require("views/layer/overflow")()
	handleCloseWindow: (e) ->
		e.preventDefault()
		$(".datetime").each ->
			$(@).data("DateTimePicker").destroy()
		@release()
		$("html").css "overflow", "auto"
		@navigate("/")

module?.exports = Overflow
