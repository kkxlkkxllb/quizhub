Utils =
	flash: (msg,type = "warning",$container) ->
		$container = $container || $("#flash_message")
		$container.prepend require('views/items/flash')(msg: msg)
		$alert = $(".alert:eq(0)",$container)
		$alert.addClass "alert-#{type}"
		fuc = ->
			$alert.remove()
		setTimeout fuc,5000
		false
	renderMD: (content, $target) ->
		val = content.replace /<equation>((.*?\n)*?.*?)<\/equation>/ig, (a, b) ->
			'<img src="http://latex.codecogs.com/png.latex?' + encodeURIComponent(b) + '" />'
		$target.html marked(val)
	shuffle: (arr) ->
		for i in [arr.length-1..1]
			j = Math.floor Math.random() * (i + 1)
			[arr[i], arr[j]] = [arr[j], arr[i]]
		arr


module?.exports = Utils
