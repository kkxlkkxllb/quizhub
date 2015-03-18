Preview =
	delay: 150
	preview: null
	buffer: null
	timeout: null
	mjRunning: false
	oldtext: null
	Init: (el) ->
		@preview = $(".edit-qz-form.active .latex_preview .qz_preview_content", el)[0]
		@buffer = $(".edit-qz-form.active .latex_preview .qz_buffer_content", el)[0]
		@$ta = $(".edit-qz-form.active textarea",el)
	SwapBuffers: ->
		buffer = @preview
		preview = @buffer
		@buffer = buffer
		@preview = preview
		buffer.style.visibility = "hidden"
		buffer.style.position = "absolute"
		preview.style.position = ""
		preview.style.visibility = ""

	Update: ->
		if @timeout
			clearTimeout(@timeout)
		@timeout = setTimeout(@callback,@delay)

	CreatePreview: ->
		Preview.timeout = null
		if @mjRunning
			return
		text = @$ta.val()
		if text is @oldtext
			return
		@buffer.innerHTML = @oldtext = text
		@mjRunning = true
		MathJax.Hub.Queue(["Typeset",MathJax.Hub, @buffer],["PreviewDone",@])
	PreviewDone: ->
		@mjRunning = false
		@SwapBuffers()

Preview.callback = MathJax.Callback(["CreatePreview",Preview])
Preview.callback.autoReset = true

module?.exports = Preview
