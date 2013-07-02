$ () ->
	socket = io.connect("/mobileinput" + instanceInputId)

	$(document).on("keyup", "textarea", (e) -> 
		socket.emit "input:set", this.value
	)
