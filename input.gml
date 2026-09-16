function input_mapping(){
	
	#macro INPUT_CTRL {control: true}
	#macro INPUT_SHIFT {shift: true}
	#macro INPUT_CTRL_SHIFT {control: true, shift: true}
	#macro INPUT_ALT {alt: true}
	#macro INPUT_CTRL_ALT {control: true, alt: true}
	
	G Input;
	Input = {};
	Input.Bind = {};
	
	// Map
	Input.GetMap = function(){
		return {
			up		: (keyboard_check(ord("W"))),
			left	: (keyboard_check(ord("A"))),
			down	: (keyboard_check(ord("S"))),
			right	: (keyboard_check(ord("D"))),
		}
	}
	
	Input.map = Input.GetMap();
	
	// Bindings
	Input.Bind.bindings = ds_map_create();
	Input.Bind.Set = function(key, flags={}, ignoreBusy=false, fn=function(){}) {
		var bind = {
			control: false,
			alt: false,
			shift: false,
			fn: fn,
			ignoreBusy: ignoreBusy,
		}
		struct_merge(bind, flags);
		Input.Bind.bindings[? key] = bind;
	}
	Input.Bind.Find = function(key) {
		var b = Input.Bind.bindings[? key];
		if (b == undefined) return;
		return b;
	}
	
	Input.Bind.Run = function() {
		var ctrl	= keyboard_check(vk_control);
		var shift	= keyboard_check(vk_shift);
		var alt		= keyboard_check(vk_alt);
		
		if (keyboard_check_pressed(vk_anykey)) {
			var key = keyboard_lastkey;
			var bind = Input.Bind.Find(key);
			if (bind && (!KeyboardBusy || bind.ignoreBusy)) {
				if (bind.control == ctrl && bind.alt == alt && bind.shift == shift) {
					bind.fn();
				}
			}
		}
	}
		
	Input.Bind.Set(192, {}, true, function(){
		keyboard_string = "";
		if (Debug.console) {
			KeyboardBusy = false;
		}
		Debug.console = !Debug.console;
	});
	
	Input.Bind.Set(vk_f3, {}, , function(){
		Debug.showDebugUI = !Debug.showDebugUI;
	});
	
	Input.Bind.Set(vk_f2, {}, , function(){
		screenshot();
	});
	
	Input.Bind.Set(ord("T"), {}, , function(){
		if (CHAT.open) return;
		keyboard_string = "";
		CHAT.open = true;
	});
}
