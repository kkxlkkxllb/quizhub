require('spine')
require('spine/lib/local')
require('spine/lib/ajax')
require('spine/lib/route')

require("lib/bootstrap.min")
require("lib/jquery/jquery.serializeObject")
require("lib/jquery/jquery.unveil")
require("lib/jquery/autolink-min")
require("lib/jquery/jquery.qrcode.min")

require("lib/uploader/jquery.ui.widget")
require("lib/uploader/jquery.iframe-transport")
require("lib/uploader/jquery.fileupload")
window.moment = require("lib/jquery/moment-with-locales.min")
require("lib/jquery/bootstrap-datetimepicker.min")

window.marked = require("lib/markdown/marked")
window.hljs = require("lib/markdown/highlight.pack")
window.async = require("lib/jquery/async")

require("lib/jquery/jquery.utils")
require("lib/md5.min")
require("lib/jquery/firebase-token-generator")

# 跨域请求带上cookie等凭证
$.ajaxSetup
	# xhrFields:
	# 	withCredentials: true
	crossDomain: true

moment.locale('zh-cn')

languageOverrides =
	js: "javascript"
	html: "xml"
marked.setOptions
	highlight: (code, lang) ->
		if languageOverrides[lang]
			lang = languageOverrides[lang]
		return if hljs.LANGUAGES[lang] then hljs.highlight(lang, code).value else code
