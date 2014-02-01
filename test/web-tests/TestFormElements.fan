
internal class TestFormInputs : WebTest {
	
	Void testExerciseElementMethods() {
		client.get(`/formTest`)
		
		// don't so much care for the results - just want to check the code doesn't throw any errors!
		
		verifyEq(Element("h1").id, "head1")
		verifyEq(Element("form").id, null)
		verifyEq(Element("h1").classs, "very")
		verify(Element("#p").hasClass("good"))
		verify(Element("#p").hasClass("see"))
		verifyFalse(Element("#p").hasClass("wotever"))
		
		verify(Element("p")[0].exists)
		verify(Element("p")[1].exists)
		verifyFalse(Element("p")[2].exists)

		verifyEq(Element("#p").text, "Hello!")
		verifyEq(Element("#p")["id"], "p")
		verifyEq(Element("#p")["class"], "good see")
		verifyEq(Element("p").size, 2)
		verifyEq(Element("p").list.size, 2)
		verifyEq(Element("p").xelems.size, 2)

		verifyEq(Element("body").find("[name=textbox]").id, "textbox")
	}

	Void testSubmitButton() {
		client.get(`/formTest`)
		
		submit := Button("#submit")
		
		verifyEq(submit.name, "submit")
		verifyEq(submit.value, "Desoxypipradrol")
		verifyEq(submit.enabled, true)
		verifyEq(submit.disabled, false)
		
		res := submit.click
		map := (Map) res.asStr.in.readObj
		verifyEq(map["submit"], "Desoxypipradrol")
		
		client.get(`/formTest`)
		submit.value = "All change!"
		map = submit.click.asStr.in.readObj
		verifyEq(map["submit"], "All change!")

		client.get(`/formTest`)
		submit.disabled = true
		map = (Map) submit.click.asStr.in.readObj
		verifyFalse(map.containsKey("submit"))
	}

	Void testCheckbox() {
		client.get(`/formTest`)
		
		checkbox := CheckBox("#checkbox")
		
		verifyEq(checkbox.name, "checkbox")
		verifyEq(checkbox.checked, true)
		verifyEq(checkbox.enabled, true)
		verifyEq(checkbox.disabled, false)
		checkbox.verifyChecked
		
		res := checkbox.submitForm
		map := (Map) res.asStr.in.readObj
		verifyEq(map["checkbox"], "on")
		
		client.get(`/formTest`)
		checkbox.checked = false
		checkbox.verifyNotChecked
		map = checkbox.submitForm.asStr.in.readObj
		verifyFalse(map.containsKey("checkbox"))

		client.get(`/formTest`)
		checkbox.disabled = true
		map = (Map) checkbox.submitForm.asStr.in.readObj
		verifyFalse(map.containsKey("checkbox"))
	}
	
	Void testHidden() {
		client.get(`/formTest`)
		
		hidden := Hidden("#hidden")
		
		verifyEq(hidden.name, "hidden")
		verifyEq(hidden.value, "Gabapentin")
		hidden.verifyValueEq("Gabapentin")
		
		res := hidden.submitForm
		map := (Map) res.asStr.in.readObj
		verifyEq(map["hidden"], "Gabapentin")
		
		client.get(`/formTest`)
		hidden.value = "I've just upset Emma. :("
		hidden.verifyValueEq("I've just upset Emma. :(")
		map = hidden.submitForm.asStr.in.readObj
		verifyEq(map["hidden"], "I've just upset Emma. :(")
	}

	Void testLink() {
		client.get(`/formTest`)
		
		link := Link("p a")
		
		verifyEq(link.href, "/bounce")
		
		res := link.click
		Element("h1").verifyTextEq("Bounce")
	}

	Void testTextBox() {
		client.get(`/formTest`)
		
		textbox := TextBox("#textbox")
		
		verifyEq(textbox.name, "textbox")
		verifyEq(textbox.value, "Dimethyltryptamine")
		verifyEq(textbox.enabled, true)
		verifyEq(textbox.disabled, false)
		textbox.verifyValueEq("Dimethyltryptamine")
		
		res := textbox.submitForm
		map := (Map) res.asStr.in.readObj
		verifyEq(map["textbox"], "Dimethyltryptamine")
		
		client.get(`/formTest`)
		textbox.value = "Emma happy again!"
		textbox.verifyValueEq("Emma happy again!")
		map = textbox.submitForm.asStr.in.readObj
		verifyEq(map["textbox"], "Emma happy again!")

		client.get(`/formTest`)
		textbox.disabled = true
		map = (Map) textbox.submitForm.asStr.in.readObj
		verifyFalse(map.containsKey("textbox"))
	}

	Void testTextArea() {
		client.get(`/formTest`)
		
		textbox := TextBox("#textarea")
		
		verifyEq(textbox.name, "textarea")
		verifyEq(textbox.value.trim, "Piperazines")
		verifyEq(textbox.enabled, true)
		verifyEq(textbox.disabled, false)
		textbox.verifyValueEq("Piperazines")
		
		res := textbox.submitForm
		map := (Map) res.asStr.in.readObj
		verifyEq(map["textarea"].toStr.trim, "Piperazines")
		
		client.get(`/formTest`)
		textbox.value = "Emma happy again!"
		textbox.verifyValueEq("Emma happy again!")
		map = textbox.submitForm.asStr.in.readObj
		verifyEq(map["textarea"], "Emma happy again!")

		client.get(`/formTest`)
		textbox.disabled = true
		map = (Map) textbox.submitForm.asStr.in.readObj
		verifyFalse(map.containsKey("textarea"))
	}
}
