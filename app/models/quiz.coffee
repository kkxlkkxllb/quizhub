QuizItem = require("models/quiz_item")
class Quiz extends Spine.Model
	@configure 'Quiz', "id", "title", "start_at", "end_at", "subject", "c_at", "private", "pwd", "items_size"
	removeFB: ->
		@destroy()
		teachers_fb.child(current_member.uid + "/" + @id).remove()
	@currentFB: ->
		teachers_fb.child(current_tid + "/" + current_qid)
	@getData: (success) ->
		@currentFB().once "value", (r) ->
			if r.val()
				success(r.val())
			else
				$(".loaderlayer").html require("views/error")(msg: "无法找到该页面")
	@updateUserData: (uid, data) ->
		@currentFB().child("users/" + uid).update data
	itemFB: ->
		teachers_fb.child(current_member.uid + "/" + @id  + "/items")
	@getEditData: (id, then_do) ->
		teachers_fb.child(current_member.uid + "/" + id).once "value", (snap) ->
			if snap.val()
				data = $.extend {}, snap.val(), id: snap.key()
				then_do(data)
			else
				$(".loaderlayer").html require("views/error")(msg: "无法找到该页面")
	addOneItem: (data, then_do) ->
		ref = @itemFB().push data
		then_do ref.key()
	removeItem: (id) ->
		@itemFB().child(id).remove()
	updateItemData: (id, data) ->
		QuizItem.findByAttribute("qid", id).updateAttributes data
		@itemFB().child(id).update data
	updateData: (data) ->
		@updateAttributes data
		teachers_fb.child(current_member.uid + "/" + @id).update data
	@addOne: (data, then_do) ->
		ref = teachers_fb.child(current_member.uid).push data
		addtion =
			id: ref.key()
			c_at: moment(new Date(data.c_at)).format("YYYY/MM/DD HH:mm")
		data = $.extend {}, data, addtion
		@create data
		then_do(ref.key()) if then_do

module.exports = Quiz
