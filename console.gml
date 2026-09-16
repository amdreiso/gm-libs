
function console_init() 
{
	#macro log CONSOLE.Log
	#macro err CONSOLE.Err
	
	enum eLogType {
		ERROR,
		LOG,
		LINK
	}
	
	globalvar CONSOLE;
	CONSOLE = {
		commands		: [],
		logs			: [],
		maxlogs			: 30,
		logRewind		: -1,
		scroll			: 0,
		scrollSpeed		: 8,
		pos				: {x:1,y:1},
	};
	
	CONSOLE.Run = function(input, showHistory = false) {
		if (input == "") return;
	
		var args = string_split(input, " ", true);
		var command = string_lower(args[0]);
		array_delete(args, 0, 1);
	
		var found = false;
	
		if (showHistory)
			CONSOLE.Log("- "+input);
		
		if (string_starts_with(command, "#")) {
			CONSOLE.Run("color "+input);
			return;
		}
		
		// Run command from COMMAND registry
		var cmd = COMMAND.Get(command);
		if (cmd != undefined) {
			var argc = cmd.argc;
			var fn = cmd.fn;
		
			if (argc != array_length(args) && argc != -1) {
				CONSOLE.Err($"Missing {argc} arguments.");
				return;
			}
		
			fn(args);
			found = true;
		}
		
		// Instance lookup
		for (var obj = 0; obj < instance_count; obj++) {
			if (string_starts_with(command, object_get_name(obj))) {
				var str = command;
				var slices = string_split(str, ".");
				var arguments = string_split(str, "=");
				
				if (array_length(slices) < 2) {
					CONSOLE.Err("Usage is 'Object.variable=value'");
					found = true;
					break;
				}
			
				var arglen = array_length(arguments);
				if (arglen < 2) {
					var asset = asset_get_index(slices[0]);
			
					var sliceofslice = string_split(slices[1], "=");
					var name = sliceofslice[0];
				
					if (object_exists(asset)) CONSOLE.Log( struct_get(asset, name) );
				
					found = true;
					break;
				}
			
				var value = arguments[1];
				var asset = asset_get_index(slices[0]);
			
				var sliceofslice = string_split(slices[1], "=");
				var name = sliceofslice[0];
			
				CONSOLE.Log($"{asset}.{name} set to {value}");
			
				var variable = variable_struct_get(asset, name);
				var type = typeof(variable);
				CONSOLE.Log(type);
			
				switch (type) {
					case "number":
						variable_struct_set(asset, name, real(value));
						break;
						
					case "int64":
						variable_struct_set(asset, name, real(value));
						break;
				
					case "string":
						variable_struct_set(asset, name, value);
						break;
				
					case "bool":
						var b = false;
						if (value == "true" || value == "1") b = true;
						if (value == "false" || value == "0") b = false;

						variable_struct_set(asset, name, b);
						break;
				
					case "struct":
						// too annoying to do.
						break;
				}
			
				found = true;
			}
		}
	
		if (!found) {
			CONSOLE.Err($"Command '{command}' doesn't exist.");
		}
	}
	
	CONSOLE.Clear = function() {
		CONSOLE.scroll = 0;
		CONSOLE.commands = [];
		CONSOLE.logs = [];
	}
	
	CONSOLE.Log = function(str, color = c_ltgray, font = fnt_console) {
		var slices = string_split(str, "\n");
	
		for (var i = 0; i < array_length(slices); i++) {
			array_insert(CONSOLE.logs, 0, {
				str: slices[i],
				color: color,
				font: font,
				type: eLogType.LOG,
			});
		}
	}

	CONSOLE.Err = function(str) {
		array_insert(CONSOLE.logs, 0, {
			str: "Err: "+str,
			color: c_red,
			font: fnt_console_bold,
			type: eLogType.ERROR,
		});
	}

	CONSOLE.Link = function(str, url="") {
		array_insert(CONSOLE.logs, 0, {
			str: str,
			color: #4444ff,
			font: fnt_console_bold,
			type: eLogType.LINK,
		});
	}
	
	CONSOLE.Update = function() {
		var input = keyboard_string;
		static pastCommand = 0;
	
		if (keyboard_check_pressed(vk_enter)) {
			CONSOLE.Run(input, true);
			array_push(CONSOLE.commands, input);
			keyboard_string = "";
			pastCommand = 0;
		}
	
		if (keyboard_check(vk_control) && keyboard_check_pressed(ord("V")) && clipboard_has_text()) {
			keyboard_string += clipboard_get_text();
		}
	
		if (keyboard_check(vk_control) && keyboard_check_pressed(ord("C")) && keyboard_string != "") {
			clipboard_set_text(keyboard_string);
		}
	
		if (keyboard_check(vk_control) && keyboard_check_pressed(vk_backspace)) {
			var s = keyboard_string;
		    var specials = ".=/ ";
		    var found = false;
		
		    for (var i = string_length(s); i > 0; --i) {
			    var ch = string_char_at(s, i);
			    if (string_pos(ch, specials) > 0) {
				    keyboard_string = string_copy(s, 1, i);
				    found = true;
				    break;
			    }
		    }
			if (!found) keyboard_string = "";
		}
	
		if (keyboard_check_pressed(vk_tab)) {
			var partial = string_lower(input);
			var matches = [];
			var keys = ds_map_keys_to_array(COMMAND.map);
			
			for (var i = 0; i < array_length(keys); i++) {
				var cmd_name = string_lower(keys[i]);
				if (string_pos(partial, cmd_name) == 1) {
					array_push(matches, keys[i]);
				}
			}
		
			if (array_length(matches) == 1) {
				keyboard_string = matches[0] + " ";
			}
		
			else if (array_length(matches) > 1) {
				for (var i = 0; i < array_length(matches); i++) {
					CONSOLE.Log(matches[i], c_ltgray);
				}
				CONSOLE.Log("");
			}
		}
		
		var len = array_length(CONSOLE.commands);
		
		if (keyboard_check_pressed(vk_up) && pastCommand < len) {
			pastCommand += 1;
			keyboard_string = CONSOLE.commands[len - pastCommand];
		}
		
		if (keyboard_check_pressed(vk_down) && pastCommand > 1) {
			pastCommand -= 1;
			keyboard_string = CONSOLE.commands[len - pastCommand];
		}
	}
	
	CONSOLE.Draw = function() {
		var consoleCondition = Debug.console;		// change it.
		if (!consoleCondition) return;
		
		KeyboardBusy = true;
		
		CONSOLE.Update();
		
		var input = keyboard_string;
		var defaultFont = fnt_console;
		
		draw_set_halign(fa_left);
		draw_set_valign(fa_middle);
		
		// Draw the actual console
		var width = display_get_gui_width();
		var height = 500;
		var xx = CONSOLE.pos.x;
		var yy = CONSOLE.pos.y;
		var c0 = #141414;
		var c1 = c_white;
		
		draw_set_alpha(0.95);
		
		draw_rectangle_color(
			xx, yy, xx + width, yy + height, 
			c0, c0, c0, c0, false
		);
		
		draw_set_alpha(1);
		
		draw_rectangle_color(
			xx, yy, xx + width, yy + height, 
			c1, c1, c1, c1, true
		);
		
		// Draw logs
		var count = array_length(CONSOLE.logs);
		var maxcount = CONSOLE.maxlogs;
		if (array_length(CONSOLE.logs) > maxcount) {
			count = maxcount;
		}
		
		CONSOLE.scroll += (mouse_wheel_up() && CONSOLE.scroll < array_length(CONSOLE.logs) - maxcount - CONSOLE.scrollSpeed) ? CONSOLE.scrollSpeed : 0;
		CONSOLE.scroll -= (mouse_wheel_down() && CONSOLE.scroll > 0) ? CONSOLE.scrollSpeed : 0;
	
		for (var i = CONSOLE.scroll; i < count + CONSOLE.scroll; i++) {
			var sep = 18;
	
			draw_set_font(CONSOLE.logs[i].font);
		
			var yo = 50;
			
			draw_text_color(
				xx + 5, 
				(yy - yo + height) - (i - CONSOLE.scroll) * sep, 
			
				CONSOLE.logs[i].str, 
				CONSOLE.logs[i].color, CONSOLE.logs[i].color, CONSOLE.logs[i].color, CONSOLE.logs[i].color, 1
			);
		}
	
		draw_set_font(fnt_console);
		
		var bar = "|";
		draw_text(xx + 5, yy - 20 + height, "> " + input + bar);
	
		draw_set_font(defaultFont);
	
		var scale = 0.5;
		var yyy = yy + 5;
		draw_sprite_ext(sCats, 0, xx + width - 10 * scale, yyy + height, scale, scale, 0, c_white, 1);
		
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
	}
}

function command_data(){
	#macro _log CONSOLE.Log
	#macro _err CONSOLE.Err
	
	function CMD_Token(argc, fn) constructor {
		self.argc = argc;
		self.fn = fn;
	}
	
	function CMD_Registry() constructor {
		self.map = ds_map_create();
		
		static Register = function(name, argc, fn){
			self.map[? name] = new CMD_Token(argc, fn);
		}
		
		static Get = function(name) {
			return self.map[? name];
		}
	}
	
	globalvar COMMAND;
	COMMAND = new CMD_Registry();
	
	COMMAND.Register("start", 0, function(args) {
		_log("	     .->    (`-')  _                             <-. (`-')   (`-')  _    (`-')               ", make_color_hsv(0, 255, 255));
		_log(" (`(`-')/`) ( OO).-/  <-.    _             .->      \\(OO )_  ( OO).-/    ( OO).->       .->   ", make_color_hsv(16, 255, 255));
		_log(",-`( OO).',(,------.,--. )   \\-,-----.(`-')----. ,--./  ,-.)(,------.    /    '._  (`-')----. ", make_color_hsv(32, 255, 255));
		_log("|  |\\  |  | |  .---'|  (`-')  |  .--./( OO).-.  '|   `.'   | |  .---'    |'--...__)( OO).-.  '", make_color_hsv(48, 255, 255));
		_log("|  | '.|  |(|  '--. |  |OO ) /_) (`-')( _) | |  ||  |'.'|  |(|  '--.     `--.  .--'( _) | |  |", make_color_hsv(64, 255, 255));
		_log("|  |.'.|  | |  .--'(|  '__ | ||  |OO ) \\|  |)|  ||  |   |  | |  .--'        |  |    \\|  |)|  |", make_color_hsv(80, 255, 255));
		_log("|   ,'.   | |  `---.|     |'(_'  '--'\\  '  '-'  '|  |   |  | |  `---.       |  |     '  '-'  '", make_color_hsv(96, 255, 255));
		_log("`--'   '--' `------'`-----'    `-----'   `-----' `--'   `--' `------'       `--'      `-----' ", make_color_hsv(112, 255, 255));
		_log("                                 <-. (`-')_  (`-').->                    (`-')  _             ", make_color_hsv(128, 255, 255), fnt_console_bold);
		_log("             _             .->      \\( OO) ) ( OO)_      .->      <-.    ( OO).-/             ", make_color_hsv(144, 255, 255), fnt_console_bold);
		_log("             \\-,-----.(`-')----. ,--./ ,--/ (_)--\\_)(`-')----.  ,--. )  (,------.             ", make_color_hsv(160, 255, 255), fnt_console_bold);
		_log("              |  .--./( OO).-.  '|   \\ |  | /    _ /( OO).-.  ' |  (`-') |  .---'             ", make_color_hsv(176, 255, 255), fnt_console_bold);
		_log("             /_) (`-')( _) | |  ||  . '|  |)\\_..`--.( _) | |  | |  |OO )(|  '--.              ", make_color_hsv(192, 255, 255), fnt_console_bold);
		_log("             ||  |OO ) \\|  |)|  ||  |\\    | .-._)   \\\\|  |)|  |(|  '__ | |  .--'              ", make_color_hsv(208, 255, 255), fnt_console_bold);
		_log("            (_'  '--'\\  '  '-'  '|  | \\   | \\       / '  '-'  ' |     |' |  `---.             ", make_color_hsv(224, 255, 255), fnt_console_bold);
		_log("               `-----'   `-----' `--'  `--'  `-----'   `-----'  `-----'  `------'             ", make_color_hsv(240, 255, 255), fnt_console_bold);
		_log("ascii art from: https://patorjk.com/software/taag/", c_gray);
		_log("");
	});

	COMMAND.Register("exit", 0, function(args) {
		game_end();
	});

	COMMAND.Register("credits", 0, function(args) {
		_log("-------------------------------",	c_red);
		_log("Programming by Andrei Scatolin",	c_aqua);
		_log("Art by Andrei Scatolin",			c_aqua);
		_log("Audio Design by Andrei Scatolin",	c_aqua);
		_log("Special thank to the chud: Logan aka So_Damn_Close",	c_aqua);
		_log("-------------------------------",	c_red);
	});

	COMMAND.Register("restart", 0, function(args) {
		game_restart();
	});

	COMMAND.Register("clear", 0, function(args) {
		CONSOLE.Clear();
	});

	COMMAND.Register("zoom", 1, function(args) {
		try {
			var value = real(args[0]);
			Camera.zoom = value;
		} catch (e){}
	});

	COMMAND.Register("spawn", 3, function(args) {
		var enemy = args[0];
		var x0 = real(args[1]) ?? 0;
		var y0 = real(args[2]) ?? 0;
	
		var obj = asset_get_index(enemy);
	
		if (!object_exists(obj)) {
			CONSOLE.Err("Object doesn't exist");
			return;
		};
	
		instance_create_depth(Player.x + x0, Player.y + y0, Player.depth, obj);
	});
	
	COMMAND.Register("instance_value", 2, function(args) {
		var obj = asset_get_index(args[0]);
		if (!instance_exists(obj)) {
			CONSOLE.Err($"There are no instances of {object_get_name(obj)} on this level");
			return;
		}
		var value = args[1];
	
		var r = variable_instance_get(obj, value);
	
		if (is_struct(r)) {
			r = json_stringify(r, true);
		}
	
		CONSOLE.Log(r);
	});
	
	COMMAND.Register("color", 1, function(args) {
		var str = args[0];
		var _hex = string_replace_all(str, "#", "");
		
		var r,g,b;
		r=0; g=0; b=0;
		
		try {
			r = real("0x" + string_copy(_hex, 1, 2));
			g = real("0x" + string_copy(_hex, 3, 2));
			b = real("0x" + string_copy(_hex, 5, 2));
			
			var color = make_colour_rgb(r, g, b);
			log("████████████████████", color);
		} catch (e) {
			err("Use real hexadecimal numbers");
		}
		
	});

}



