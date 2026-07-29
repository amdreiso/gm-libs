
function fovy(){
	// macros
	#macro G globalvar
	
	// aligns
	#macro ALIGN_TOP_LEFT			draw_set_valign(fa_top)			draw_set_halign(fa_left)		
	#macro ALIGN_TOP_CENTER			draw_set_valign(fa_top)			draw_set_halign(fa_center)		
	#macro ALIGN_MIDDLE_CENTER		draw_set_valign(fa_middle)		draw_set_halign(fa_center)		
	#macro ALIGN_MIDDLE_LEFT		draw_set_valign(fa_middle)		draw_set_halign(fa_left)		
	#macro ALIGN_MIDDLE_RIGHT		draw_set_valign(fa_middle)		draw_set_halign(fa_right)		
	#macro ALIGN_BOTTOM_RIGHT		draw_set_valign(fa_bottom)		draw_set_halign(fa_right)		
	#macro ALIGN_BOTTOM_CENTER		draw_set_valign(fa_bottom)		draw_set_halign(fa_center)		
	
	#macro SPRITE_STACKED_OFFSET 0.75
	#macro print show_debug_message
	
	#macro WIDTH display_get_gui_width()
	#macro HEIGHT display_get_gui_height()
	
	enum BUTTON_ORIGIN {
		Left,
		MiddleCenter,
	}
}

function draw_game_info(){
	
	if (!Debug.showInfo) return;
	
	draw_set_font(fnt_main);
	
	content = [];
	_ = function(s, color=c_white){array_push(content,{text:s,color})}
	
	var separator = function(title="", color=c_gray){
		var size = 60;
		var len = string_length(title);
		len = (len == 0) ? 0 : len;
		
		var left  = (size / 2) - ceil( len / 2);
		var right = (size / 2) - floor(len / 2);
		
		var s = "=";
		var final = string_repeat(s, left) + string_upper(title) + string_repeat(s, right);
		
		_(final, color);
	}
	
	#region stuff
	
	// Default
	separator("MANIFEST");
	_($"{Manifest.title} {Manifest.version} by {Manifest.author} (c) {Manifest.company}");
	_($"FPS: {fps}");
	
	// Cursor
	separator("CURSOR");
	_($"busy: {bool_string(CursorBusy)}");
	
	// World
	if (instance_exists(World)) {
		separator("world");
		var w = World;
		_($"gs: {w.gameSpeed} tick: {w.getCurrentGameSpeed()}");
	}
	
	#endregion
	
	
	var scale = 1;
	var sep = 16 * scale;
	var len = array_length(content);
	var width = 90 * (sep / 2);
	
	ALIGN_TOP_LEFT;
	
	draw_set_alpha(0.75);
	draw_rectangle_colour(0, 0, width, len * sep, c_black, c_black, c_black, c_black, false);
	draw_set_alpha(1);
	
	for (var i = 0; i < len; i++) {
		var t = content[i];
		var c = t.color;
		draw_text_transformed_color(0, i * sep, t.text, scale, scale, 0, c, c, c, c, 1);
	}
	
	ALIGN_MIDDLE_CENTER;
}

function draw_on_surface(surface, func=function(){}) {
	if (!surface_exists(surface)) return;
	surface_set_target(surface);
	func();
	surface_reset_target();
}

function perlin() constructor {

    static seed = function(seed_val = 0) {
        random_set_seed(seed_val);
        self.gradients = ds_map_create();
        self.memory = ds_map_create();
    }

    static rand_vect = function() {
        var theta = random(2 * pi);
        return {
            x: cos(theta),
            y: sin(theta)
        };
    }
	
    static dot_prod_grid = function(x, y, vx, vy) {
        var key = string(vx) + "," + string(vy);

        var g_vect;
        if (ds_map_exists(self.gradients, key)) {
            g_vect = self.gradients[? key];
        } else {
            g_vect = self.rand_vect();
            self.gradients[? key] = g_vect;
        }

        var dx = x - vx;
        var dy = y - vy;

        return dx * g_vect.x + dy * g_vect.y;
    }
	
    // Proper fade function (Perlin standard)
    static fade = function(t) {
        return t * t * t * (t * (t * 6 - 15) + 10);
    }
	
    static get = function(x, y) {

        var xf = floor(x);
        var yf = floor(y);

        var tx = x - xf;
        var ty = y - yf;

        tx = clamp(tx, 0, 1);
        ty = clamp(ty, 0, 1);

        var tl = self.dot_prod_grid(x, y, xf,   yf);
        var tr = self.dot_prod_grid(x, y, xf+1, yf);
        var bl = self.dot_prod_grid(x, y, xf,   yf+1);
        var br = self.dot_prod_grid(x, y, xf+1, yf+1);

        var u = self.fade(tx);
        var v = self.fade(ty);

        var top = lerp(tl, tr, u);
        var bottom = lerp(bl, br, u);

        return lerp(top, bottom, v);
    }
}

function lerp(a, b, t) {
    return a + (b - a) * t;
}

function invlerp(a, b, v) {
    return (v - a) / (b - a);
}

function remap(i1, i2, o1, o2, v) {
    var t = invlerp(i1, i2, v);
    return lerp(o1, o2, t);
}

function smoothstep(a, b, t) {
    t = clamp(t, 0, 1);
    t = t * t * (3 - 2 * t);
    return lerp(a, b, t);
}

//function smootherstep(a, b, t) {
//    t = clamp(t, 0, 1);
//    t = t * t * t * (t * (t * 6 - 15) + 10);
//    return lerp(a, b, t);
//}

function ease_in_quad(a, b, t) {
    return lerp(a, b, t * t);
}

function ease_out_quad(a, b, t) {
    return lerp(a, b, 1 - (1 - t) * (1 - t));
}

function ease_in_out_quad(a, b, t) {
    if (t < 0.5)
        return lerp(a, b, 2 * t * t);
    else
        return lerp(a, b, 1 - power(-2 * t + 2, 2) / 2);
}

function ease_in_cubic(a, b, t) {
    return lerp(a, b, t * t * t);
}

function ease_out_cubic(a, b, t) {
    return lerp(a, b, 1 - power(1 - t, 3));
}

function ease_in_out_cubic(a, b, t) {
    if (t < 0.5)
        return lerp(a, b, 4 * t * t * t);
    else
        return lerp(a, b, 1 - power(-2 * t + 2, 3) / 2);
}

function ease_in_sine(a, b, t) {
    return lerp(a, b, 1 - cos((t * pi) / 2));
}

function ease_out_sine(a, b, t) {
    return lerp(a, b, sin((t * pi) / 2));
}

function ease_in_out_sine(a, b, t) {
    return lerp(a, b, -(cos(pi * t) - 1) / 2);
}

function Table(owner=noone) constructor {
	self.entries = [];
	self.weightMax = 0;
	self.owner = owner;
	
	static Roll = function(luck = 0) {
	    var total = 0;

	    for (var i = 0; i < array_length(self.entries); i++) {
	        var w = power(self.entries[i].weight, 1 - luck);
	        total += w;
	    }

	    var roll = random(total);
		
		print("=================================");
		
	    for (var i = 0; i < array_length(self.entries); i++) {
	        var w = power(self.entries[i].weight, 1 - luck);
			print($"{self.owner} rolled: {self.entries[i].value} with weight: {w}");
			
	        roll -= w;
	        if (roll <= 0)
	            return self.entries[i].value;
	    }
		
		print("=================================");

	    return undefined;
	}
	
	static Random = function(){
		return array_get_random(self.entries).value;
	}
	
	static Set = function(value, weight){
		array_push(self.entries, {
			value : value,
			weight : weight,
		});
		self.weightMax += weight;
	}
}

function draw_sprite_stacked(spr, x, y, offset, xscale=1, yscale=1, rot=0, color=c_white, alpha=1) {
	for ( var i = 0; i < sprite_get_number(spr); i++ ) {
		draw_sprite_ext(spr, i, x, y - i * offset, xscale, yscale, rot, color, alpha);
	}
}

function Maybe(value) constructor {
	self.value = value;
	
	static Bind = function(fn) {
		return new Maybe(fn(self.value));
	}
}

function fopen(filename) {
	if (!file_exists(filename)) {
		var buf = buffer_create(1, buffer_fixed, 1);
		buffer_save(buf, filename);
		buffer_delete(buf);
	}
	return buffer_load(filename);
}

function fwrite(buffer, content, type=buffer_string) {
	if (!buffer_exists(buffer)) return;
	buffer_write(buffer, type, content);
}

function fread(buffer, type=buffer_string) {
	if (!buffer_exists(buffer)) return;
	return buffer_read(buffer, type);
}

function fclose(buffer) {
	if (!buffer_exists(buffer)) return;
	buffer_delete(buffer);
}

function Node(value, children=[]) constructor {
	self.value = value;
	self.children = children;
	self.width = 0;
}

function tree_measure(node, spacing = 10) {
    var len = array_length(node.children);
	
	if (len == 0) {
        node.width = spacing;
        return node.width;
    }

    var total = 0;

    for (var i = 0; i < array_length(node.children); i++) {
        total += tree_measure(node.children[i], spacing);
    }

    total += spacing * (len - 1);
	
    node.width = total;

    return total;
}

/**
 * Function Description
 * @param {Struct.Node} root
 * @param {Real} x
 * @param {Real} y
 */
function draw_node_tree(node, x, y, nodeStyle=Colorscheme.node) {
	// draw self
	var size = nodeStyle.size;
	var spacingY = size * 2;
	var color = c_white;
	
	rect(x, y, size, size, c_black, false, 1);
	rect(x, y, size, size, color, true, 1, 5);
	
	var children = node.children;
	var len = array_length(children);
	
	if (len == 0) return;
	
	var childrenWidth = 0;

	for (var i = 0; i < len; i++) {
	    childrenWidth += children[i].width;
	}

	var startX = x - childrenWidth / 2;
	
	for (var i = 0; i < len; i++) {
		var c = children[i];
		
		var xx = startX + c.width / 2;
		var yy = y + spacingY;
		
        //draw_line_width(x, y, xx, yy, 0.5);
		draw_node_tree(c, xx, yy);
        startX += c.width;
	}
	
	
}

function draw_rotated_rect(_x, _y, _w, _h, _angle, _col, _alpha)
{
    var hw = _w * 0.5;
    var hh = _h * 0.5;

    var c = dcos(_angle);
    var s = dsin(_angle);

    // rotated corners
    var x1 = _x + (-hw * c - -hh * s);
    var y1 = _y + (-hw * s + -hh * c);

    var x2 = _x + ( hw * c - -hh * s);
    var y2 = _y + ( hw * s + -hh * c);

    var x3 = _x + ( hw * c -  hh * s);
    var y3 = _y + ( hw * s +  hh * c);

    var x4 = _x + (-hw * c -  hh * s);
    var y4 = _y + (-hw * s +  hh * c);

    draw_set_color(_col);
    draw_set_alpha(_alpha);

    // triangle 1
    draw_triangle(x1, y1, x2, y2, x3, y3, false);

    // triangle 2
    draw_triangle(x1, y1, x3, y3, x4, y4, false);

    draw_set_alpha(1);
}

function hsv_pulsate(h, s, v, time=0.01, value=0.90) {
	var _v = value * 2;
	var _s = (sin(current_time * time) * _v) + _v;
	return make_colour_hsv(h, s, v / _s);
}

function rgb_pulsate(r, g, b, time=0.01, value=0.90) {
	var _v = value * 2;
	var _s = (sin(current_time * time) * _v) + _v;
	return make_colour_rgb(r, g, b / _s);
}

function array_swap_values(arr, a, b) {
    for (var i = 0; i < array_length(arr); i++) {
        if (arr[i] == a) {
            arr[i] = b;
        } else if (arr[i] == b) {
            arr[i] = a;
        }
    }
    return arr;
}

function process_init() {
	globalvar Process;
	Process = {};
	Process.list = [];
	Process.Run = function() {
		for (var i = 0; i < array_length(Process.list); i++) {
			var p = Process.list[i];
			var ret = p();
			
			if (ret) {
				array_delete(Process.list, i, 1);
				print($"PROCESS: completed ID '{i}'");
			}
		}
	}
	Process.Push = function(fn) {
		if (!is_callable(fn)) return;
		array_push(Process.list, fn);
	}
}

enum MENU_BUTTON_TYPE {
	Method,
	Slider,
}

function Button(name, backgroundColor, textColor, fn, goback = false) constructor {
	self.type = MENU_BUTTON_TYPE.Method;
	self.name = name;
	self.fn = fn;
	self.backgroundColor = backgroundColor;
	self.textColor = textColor;
	self.goback = goback;
}

function ButtonSlider(name, backgroundColor, textColor, get, set, variabledefault, slope=0.1) constructor {
	self.type = MENU_BUTTON_TYPE.Slider;
	self.name = name;
	self.backgroundColor = backgroundColor;
	self.textColor = textColor;
	self.get = get;
	self.set = set;
	self.variabledefault = variabledefault;
	self.slope = slope;
}

function bool_string(val) {
	if (val == true) return "true" else return "false";
}

function Signal(signalID, time = 5 * 60) constructor {
	self.signalID = signalID;
	self.time = time;
}

function get_relative_direction(obj) {
	var side = new Vec2();
	if (obj.x < x) side.x = -1 else side.x = 1;
	if (obj.y < y) side.y = -1 else side.y = 1;
	return side;
}

function Children() constructor {
	self.list = [];
	
	static Append = function(){
		for (var i = 0; i < argument_count; i++) {
			array_push(self.list, argument[i]);
		}
	}
	
	static ForEach = function(func = function(obj){}){
		var len = array_length(self.list);
		if (len == 0) then return;
		for (var i = 0; i < len; i++) {
			var obj = self.list[i];
			if (instance_exists(obj)) then func(obj);
		}
	}
	
	static DestroyAll = function() {
		var len = array_length(self.list);
		if (len == 0) then return;
		for (var i = 0; i < len; i++) {
			var obj = self.list[i];
			if (instance_exists(obj)) then instance_destroy(obj);
		}
	}
}

function Instance(obj, x, y, components = {}) constructor {
	self.object = obj;
	self.pos = new Vec2(x, y);
	self.components = components;
	
	static Create = function() {
		var instance = instance_create_depth(self.pos.x, self.pos.y, 0, self.object);
		struct_merge(instance, self.components);
	}
}

function mouse_collision(orientation, x, y, width, height) {
	
	var mx = mouse_x;
	var my = mouse_y;
	
	switch (orientation) {
		case "top left":
			return (
				mx > x && 
				my > y &&
				mx < x + width && 
				my < y + height
			);
		
		case "center":
			return (
				mx > x - width / 2 && 
				my > y - height / 2 &&
				mx < x + width / 2 && 
				my < y + height / 2
			);
	}
}

function signabs(x) {
  return (x < 0) ? -1 : 1;
}

function DropTable() constructor {
	self.table = [];
	
	static Add = function(itemID, chance, quantity) {
		var drop = {};
		drop.itemID = itemID;
		drop.chance = chance;
		drop.quantity = random_array_argument(quantity);
		array_push(self.table, drop);
	}
	
	static Get = function() {
		for (var i = 0; i < array_length(self.table); i++) {
			var drop = self.table[i];
			var rand = random(1.00);
			if (drop.chance < rand) {
				return {
					itemID : drop.itemID,
					quantity : drop.quantity,
				}
			}
		}
		
		return undefined;
	}
	
}

function SpriteStates() constructor {
	self.states = ds_map_create();
	self.currentState = "";
	
	static Set = function(stateID, name, sprite, condition) {
		var state = {};
		state.name = name;
		state.sprite = sprite;
		state.condition = condition;
		
		self.states[? stateID] = state;
	}
	
	static Get = function() {
		var keys = ds_map_keys_to_array(self.states);
		array_sort(keys, true);
		
		var sprite = undefined;
		var name = "";
		
		for (var i = 0; i < array_length(keys); i++) {
			var state = self.states[? keys[i]];
			var con = state.condition();
			
			if (con) {
				name = state.name;
				sprite = state.sprite; 
			}
		}
		
		self.currentState = name;
		return sprite;
	}
	
}

function sleep(val) {
	Sleep = val;
}

function approach(value, target, amount) {
  if (value < target) return min(value + amount, target)
  if (value > target) return max(value - amount, target)
  return value
}

function mouse_get_direction(x, y) {
	return point_direction(x, y, mouse_x, mouse_y);
}

function interval_set(obj, time, fn, verbose=false) {
	static tick = 0;
	static alltimetick = 0;
	
	tick += 1;
	alltimetick += 1;
	
	if (verbose) then print($"interval set : {tick}");
	
	if (tick >= time) {
		fn(obj, alltimetick);
		tick = 0;
	}
}

function Registry() constructor {
	self.entries = ds_map_create();
	self.defaultComponents = {};
	self.types = ds_map_create();
	
	static SetDefaultComponents = function(components) {
		self.defaultComponents = components;
	}
	
	static Register = function(val, components = {}, onRegister = function(val){}) {
		var entry = {};
		entry.components = {};
		
		struct_merge(entry.components, self.defaultComponents);
		struct_merge(entry.components, components);
		
		self.entries[? val] = entry;
		
		print($"{val} : {components}");
		
		onRegister( val );
	}
	
	static Get = function(val) {
		return self.entries[? val] ?? undefined;
	}
	
	static GetType = function(val) {
		if (ds_map_exists(self.entries, val)) {
			if (!variable_struct_exists(self.entries[? val], "components")) return;
			return self.entries[? val].components.type;
		}
	}
}

function Callback() constructor {
	self.list = [];
	
	static Clear = function() {
		self.list = [];
	}	
	
	static Register = function(fn) {
		array_push(self.list, {fn:fn});
	}
	
	static Call = function(obj=undefined) {
		var len = array_length(self.list);
		for (var i = 0; i < len; i++) {
			var cb = self.list[i];
			
			if (obj == undefined) 
			then cb.fn();
			else cb.fn( obj );
			
			// End of callbacks
			if (i == len - 1) {
			}
		}
	}
}

function Stat(_value) constructor {
	self.value = _value;
	self.defaultValue = _value;
	
	static Sub = function(val) {
		self.value -= val;
	}
	
	static Add = function(val) {
		self.value += val;
	}
	
	static Set = function(val) {
		self.value = val;
	}
	
	static Reset = function(val) {
		self.value = self.defaultValue;
	}
	
	static GetPercentage = function() {
		return (self.value / self.defaultValue) * 100;
	}
	
	static UpdateValue = function(val) {
		self.value = val;
		self.defaultValue = val;
	}
	
}


function show_object_status() {
	if (mouse_check_button_pressed(mb_left) && mouse_box_collision()) {
		log(object_get_name(object_index) + ": " + json_stringify(self, true));
	}
}

function mouse_box_collision() {
	var on = (mouse_x > bbox_left && mouse_x < bbox_right && mouse_y > bbox_top && mouse_y < bbox_bottom);
	return on;
}

function array_get_random(arr) {
	var index = irandom(array_length(arr) - 1);
	return arr[index];
}

function save_room_screenshot() {
	var filename = room_get_name(room) + ".png";
	
	// Make camera see the entire room 1:1 ratio
	var cam = camera_create_view(0, 0, room_width, room_height);
	
	view_set_visible(CAMERA_VIEWPORT_DEFAULT, false);
	view_set_visible(1, true);
	view_set_camera(1, cam);
	
	window_set_size(room_width, room_height);
	
	CameraViewport = 1;
	
	Player.isVisible = false;
	Settings.graphics.drawUI = false;
	
	screen_save(filename);
	
	print($"Screenshot saved as {filename}");
	
	CameraViewport = 0;
}

function position_get(o) {
	return new Vec2(o.x, o.y);
}

function angle_lerp(a, b, t)
{
    var diff = angle_difference(b, a);
    return ((a + diff * t) + 360) mod 360;
}

function file_load(filename) {
	var file = filename;
	var buffer = buffer_load(file);
	var con = buffer_read(buffer, buffer_string);
	buffer_delete(buffer);
	return con;
}

function string_pad(str, val) {
	while (string_length(str) < val) str+=" ";
	return str;
}

function format_number(n) {
	if (n >= 1_000_000_000) return string_format(n / 1_000_000_000, 0, 1) + "B";
	if (n >= 1_000_000) return string_format(n / 1_000_000, 0, 1) + "M";
	if (n >= 1_000) return string_format(n / 1_000, 0, 1) + "K";
	return string(n);
}

function merge_struct_into_instance(target, struct) {
  var keys = variable_struct_get_names(struct);
	
  for (var i = 0; i < array_length(keys); i++) {
		var index = struct_get(struct, keys[i]);
		
		if (is_method(index)) {
			var value = index();
			struct_set(struct, keys[i], value);
		}
		
    variable_instance_set(target, keys[i], index);
	}
	
}

function color_invert(color) {
  var r = 255 - color_get_red(color);
  var g = 255 - color_get_green(color);
  var b = 255 - color_get_blue(color);
  return make_color_rgb(r, g, b);
}

function color_darkness(color, value) {
	var hue = color_get_hue(color);
	var sat = color_get_saturation(color);
	var val = color_get_value(color) - value;
	return make_color_hsv(hue, sat, val);
}

function position_tolerance(xx, yy, tolerance) {
	var t = tolerance;
	return (x > xx - t && x < xx + t && y > yy - t && y < yy + t);
}

function on_last_frame(fn) {
	if (ceil(image_index) == sprite_get_number(sprite_index)) {
		fn();
		return true;
	}
	return false;
}

function knockback_apply(threshold = 1) {
	var knockbackFallout = 0.1;
	
	knockback.x = max(threshold, knockback.x - knockbackFallout * GameSpeed);
	knockback.y = max(threshold, knockback.y - knockbackFallout * GameSpeed);
}

//function apply_force() {
//  var decel = FORCE_DECELERATION * GameSpeed;

//  if (abs(force.x) <= decel) {
//    force.x = 0;
//  } else {
//    force.x -= decel * sign(force.x);
//  }

//  if (abs(force.y) <= decel) {
//    force.y = 0;
//  } else {
//    force.y -= decel * sign(force.y);
//  }
//}

function collision_set(obj, subpixel = 1) {
	if (!instance_exists(obj)) return;
	
	var sp = 0.1;
	
	if (place_meeting(x + hsp, y, obj)) {
		
		var pixelCheck = subpixel * sign(hsp);
		
		// Slope up
		if (!place_meeting(x + hsp, y - abs(hsp) - 1, obj)) {
			
			while (place_meeting(x + pixelCheck, y, obj)) {
				y -= sp;
				vsp = 0;
			}
			
		} else {
 			
			var pixelCheck = subpixel * sign(hsp);
			
			while (!place_meeting(x + pixelCheck, y, obj)) {
				x += sign(hsp);
			}
			
			hsp = 0;
			knockback.x = 0;
		}
	}
	
	if (place_meeting(x, y + vsp, obj)) {
		var pixelCheck = subpixel * sign(vsp);
		
		while (!place_meeting(x, y + sign(vsp), obj)) {
			y += sign(vsp);
		}
		
		vsp = 0;
		knockback.y = 0;
	}
	
}

function isometric_position(x, y) {
	var x0, y0, xoffset = 0;
	var w = TILE_WIDTH;
	var h = TILE_HEIGHT - 4;
	
	if (y % 2 == true) then xoffset = w / 2;
			
	x0 = (x * w) + xoffset;
	y0 = (y * (h / 2));
	
	return new Vec2(x0, y0);
}

function Vec2(x=0, y=0) constructor {
	self.x = x;
	self.y = y;
}

function randvec2(x=0, y=0, range=0) {
	return new Vec2(
		x + random_range(-range, range),
		y + random_range(-range, range)
	);
}

function irandvec2(x=0, y=0, range=0) {
	return {
		x: x + irandom_range(-range, range),
		y: y + irandom_range(-range, range),
	}
}

function Dim(width=0, height=0) constructor {
	self.width = width;
	self.height = height;
}

function sound3D(emitter, x, y, snd, loop, gain, pitch, offset = 0){
	if (emitter == -1) {
		return audio_play_sound_at(snd, x, y, 0, Sound.distance, Sound.dropoff, Sound.multiplier, 
			loop, -1, random_array_argument(gain), offset, random_array_argument(pitch));
	}
	
	return audio_play_sound_on(emitter, snd, loop, 0, random_array_argument(gain), offset, random_array_argument(pitch));
}

function Color(r, g, b) constructor { self.r = r; self.g = g; self.b = b; }

function button(
	x, y, width, height, label = "",
	hasOutline = true, outlineColor = c_white, hoverColor = c_white, hoverAlpha = 0.25, hoverFunction = function(){},
	orientation = 0, cursor = true
) {
	var range;
	
	switch (orientation) {
		case BUTTON_ORIGIN.Left:
			
			range = (mouse_x > x && mouse_x < x + width && mouse_y > y && mouse_y < y + height);
			var hovered = range;
			
			// Draw outline
			if (hasOutline) {
				draw_rectangle_color(
					x, y, 
					x + width, y + height, 
					outlineColor, outlineColor, outlineColor, outlineColor, true
				);
			}
			
			if (range) {
				draw_set_alpha(hoverAlpha);
				draw_rectangle_color(
					x, y, 
					x + width, y + height, 
					hoverColor, hoverColor, hoverColor, hoverColor, false
				);
				draw_set_alpha(1);
				
				if (cursor) {
					//set_cursor(CURSOR.Pointer);
				}
				
				hoverFunction();
			}
			
			draw_text_transformed(x, y, label, 0.5, 0.5, 1);
			
			break;
		
		case BUTTON_ORIGIN.MiddleCenter:
			
			range = (
				mouse_x > x - width / 2 && 
				mouse_x < x + width / 2 && 
				mouse_y > y - height / 2 && 
				mouse_y < y + height / 2
			);
			
			// Draw outline
			if (hasOutline) {
				draw_rectangle_color(
					x - width / 2, y - height / 2, 
					x + width / 2, y + height / 2, 
					outlineColor, outlineColor, outlineColor, outlineColor, true
				);
			}
			
			if (range) {
				draw_set_alpha(hoverAlpha);
				draw_rectangle_color(
					x - width / 2, y - height / 2, 
					x + width / 2, y + height / 2, 
					hoverColor, hoverColor, hoverColor, hoverColor, false
				);
				draw_set_alpha(1);
				
				hoverFunction();
			}
			
			draw_set_halign(fa_center);
			draw_text_transformed(x, y+1, label, 0.5, 0.5, 0);
			draw_set_halign(fa_left);
			
			break;
	}
}

function button_clear(
	x, y, width, height, fn = function(){}
) {
	var range = (mouse_x > x && mouse_x < x + width && mouse_y > y && mouse_y < y + height);
	if (range) fn();
}

function button_clear_gui(
	x, y, width, height, fn = function(){}
) {
	var mx = window_mouse_get_x();
	var my = window_mouse_get_y();
	var range = (mx > x && mx < x + width && my > y && my < y + height);
	if (range) fn();
}

function button_gui(
	x, y, width, height, label = "", gamepadID = -1,
	hasOutline = true, outlineColor = c_white, hoverColor = c_white, hoverAlpha = 0.25, alpha = 1, hoverFunction = function(){},
	orientation = 0, cursor = true
) {
	var mx, my;
	mx = window_mouse_get_x();
	my = window_mouse_get_y();
	
	var range;
	
	switch (orientation) {
		case BUTTON_ORIGIN.Left:
			
			range = (mx > x && mx < x + width && my > y && my < y + height);
			
			// Draw outline
			if (hasOutline) {
				draw_set_alpha(alpha);
				
				draw_rectangle_color(
					x, y, 
					x + width, y + height, 
					outlineColor, outlineColor, outlineColor, outlineColor, true
				);
				
				draw_set_alpha(1);
			}
			
			if (range) {
				draw_set_alpha(hoverAlpha * alpha);
				draw_rectangle_color(
					x, y, 
					x + width, y + height, 
					hoverColor, hoverColor, hoverColor, hoverColor, false
				);
				draw_set_alpha(1);
				
				if (cursor) {
					window_set_cursor(cr_handpoint);
				}
				
				hoverFunction();
			}
			
			draw_set_valign(fa_middle);
			draw_text_color(x, y + height / 2, label, Style.textColor, Style.textColor, Style.textColor, Style.textColor, alpha);
			draw_set_valign(fa_top);
			
			break;
		
		case BUTTON_ORIGIN.MiddleCenter:
			
			range = (
				mx > x - width / 2 && 
				mx < x + width / 2 && 
				my > y - height / 2 && 
				my < y + height / 2
			);
			
			// Draw outline
			if (hasOutline) {
				draw_set_alpha(alpha);
				draw_rectangle_color(
					x - width / 2, y - height / 2, 
					x + width / 2, y + height / 2, 
					outlineColor, outlineColor, outlineColor, outlineColor, true
				);
				draw_set_alpha(1);
			}
			
			if (range) {
				draw_set_alpha(hoverAlpha * alpha);
				draw_rectangle_color(
					x - width / 2, y - height / 2, 
					x + width / 2, y + height / 2, 
					hoverColor, hoverColor, hoverColor, hoverColor, false
				);
				draw_set_alpha(1);
				
				if (cursor) {
				}
				
				hoverFunction();
			}
			
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			
			draw_set_alpha(alpha);
			draw_text(x, y, label);
			draw_set_alpha(1);
			
			draw_set_halign(fa_left);
			draw_set_valign(fa_top);
			
			break;
	}
}

function draw_3d(step, x, y, sprite, xscale, yscale, angle = 0, color = c_white, alpha = 1, smoothing = false, smoothOffset = 100, smoothStep = 5) {
	draw_set_alpha(alpha);
	for (var i = 0; i < sprite_get_number(sprite); i++) {
		var yy = y - (i * step);
		var c = color;
		
		if (smoothing) {
			c = make_color_rgb(
				color_get_red(color) + smoothOffset + i * smoothStep,
				color_get_green(color) + smoothOffset + i * smoothStep,
				color_get_blue(color) + smoothOffset + i * smoothStep
			);
		}
		
		draw_sprite_ext(sprite, i, x, yy, xscale, yscale, angle, c, alpha);
	}
	draw_set_alpha(1);
}

function save_id(file, save, prettify = false) {
	var str = json_stringify(save, prettify);
	var buffer = buffer_create(string_byte_length(str)+1, buffer_fixed, 1);
	
	buffer_write(buffer, buffer_text, str);
	buffer_save(buffer, file);
	buffer_delete(buffer);
}

function color_lerp(col1, col2, t) {
    var r1 = color_get_red(col1);
    var g1 = color_get_green(col1);
    var b1 = color_get_blue(col1);

    var r2 = color_get_red(col2);
    var g2 = color_get_green(col2);
    var b2 = color_get_blue(col2);

    var r = lerp(r1, r2, t);
    var g = lerp(g1, g2, t);
    var b = lerp(b1, b2, t);

    return make_color_rgb(r, g, b);
}


// Code from Arend Peter Teaches
function get_perlin_noise_1D(xx, range){
	var noise = 0;
	var chunkSize = 8;
	var chunkIndex = xx div chunkSize;
	var prog = (xx % chunkSize) / chunkSize;

	var leftRandom = random_seed(chunkIndex, range);
	var rightRandom = random_seed(chunkIndex + 1, range);

	noise = (1-prog)*leftRandom + prog*rightRandom;

	return round(noise);
}


// Code from Arend Peter Teaches
function get_perlin_noise_2D(xx, yy, range, r = false, chunksize = 1){
	var chunkSize = 64 * chunksize;
	var noise = 0;

	range = range div 2;

	while (chunkSize > 0){
	  var index_x = xx div chunkSize;
	  var index_y = yy div chunkSize;
    
	  var t_x = (xx % chunkSize) / chunkSize;
	  var t_y = (yy % chunkSize) / chunkSize;
    
	  var r_00 = random_seed(range, index_x,   index_y);
	  var r_01 = random_seed(range, index_x,   index_y + 1);
	  var r_10 = random_seed(range, index_x+1, index_y);
	  var r_11 = random_seed(range, index_x+1, index_y + 1);
    
		var r_0 = lerp(r_00, r_01, t_y);
	  var r_1 = lerp(r_10, r_11, t_y);
   
	  noise += lerp(r_0, r_1, t_x);
    
	  chunkSize = chunkSize div 2;
	  range = range div 2;
	  range = max(1, range);
	}
	
	if (r) {
		return round(noise);
	}
	
	return noise;
}

// Code from Arend Peter Teaches
function random_seed(range){
	var num = 0;
	
	switch(argument_count) {
		case 2:
			num = argument[1];
			break;
		case 3:
			num = argument[1] + argument[2] * 12409172;
			break;
	}
	
	var seed = 0;
	seed += World.seed + num;

	random_set_seed(seed);
	var rand = random_range(0, range);

	return rand;
}

function rect(x, y, width, height, color = c_white, outline = false, alpha = 1, size = 1) {
	for (var i = 0; i < size; i++) {
		var step = size * 2;
		draw_set_alpha(alpha);
		draw_rectangle_color(
			x - width / 2 + i / step, 
			y - height / 2 + i / step, 
			x + width / 2 - i / step, 
			y + height / 2 - i / step, 
			color, color, color, color, outline
		);
		draw_set_alpha(1);
	}
}

function random_array_argument(array){
	if (is_array(array)) {
		return random_range(array[0], array[1]);
	}
	
	return array;
}


//function opt(base, value) {
//	var f = 60;
	
//  if (value > f) value = f;
//  else if (value < 0) value = 0;
    
//  var factor = value / f;
//  return base * factor;
//}


function slider(val, x, y, width, height, handleWidth, color = c_white) {
	var handleX = (x + val) - width / 2;
	
	draw_line_color(x - width/2, y, x + width/2, y, color, color);
	
	button_gui(handleX, y, handleWidth, height, "", -1, true, color, c_white, 1, 1, function(){
		if (mouse_check_button(mb_left)) {
			var mx = window_mouse_get_x();
			var my = window_mouse_get_y();
	
			var pos = mx - x;
			
			return (pos);
		}
	}, BUTTON_ORIGIN.MiddleCenter);
	
}

function mkdir(path) {
	if (directory_exists(path)) {
		show_debug_message("./" + path + " already exists");
		return;
	}
	directory_create(path);
}

function struct_merge(dest, src) {
	var keys = struct_get_names(src);
	for (var i = 0; i < array_length(keys); i++) {
		var key = keys[i];
		var val = variable_struct_get(src, key);
		struct_set(dest, key, val);
	}
}

function struct_merge_recursive(default_struct, loaded_struct) {
  var names = struct_get_names(loaded_struct);
  for (var i = 0; i < array_length(names); i++) {
    var key = names[i];
    var loaded_val = struct_get(loaded_struct, key);

    if (variable_struct_exists(default_struct, key) && is_struct(struct_get(default_struct, key)) && is_struct(loaded_val)) {
      struct_merge_recursive(struct_get(default_struct, key), loaded_val);
    } else {
      struct_set(default_struct, key, loaded_val);
    }
  }
}

function raycast_to_collisions(x1, y1, x2, y2) {
  var nearest = noone;
  var nearest_dist = -1;

  var inst;
  with (Collision) {
    if (collision_line(x1, y1, x2, y2, id, false, true)) {
      var px = collision_line(x1, y1, x2, y2, id, false, true);
      var dist = point_distance(x1, y1, x, y);
      if (nearest == noone || dist < nearest_dist) {
        nearest = id;
        nearest_dist = dist;
      }
    }
  }

  return nearest;
}

function line_intersects_line(x1, y1, x2, y2, x3, y3, x4, y4) {
  var den = ((x1 - x2) * (y3 - y4)) - ((y1 - y2) * (x3 - x4));
  if (den == 0) return false;

  var t = ((x1 - x3) * (y3 - y4)) - ((y1 - y3) * (x3 - x4));
  var u = ((x1 - x3) * (y1 - y2)) - ((y1 - y3) * (x1 - x2));

  t /= den;
  u /= den;

  return (t >= 0 && t <= 1) && (u >= 0 && u <= 1);
}

function line_intersects_rect(x1, y1, x2, y2, rx1, ry1, rx2, ry2) {
  return (line_intersects_line(x1, y1, x2, y2, rx1, ry1, rx2, ry1) || // top
    line_intersects_line(x1, y1, x2, y2, rx2, ry1, rx2, ry2) || // right
    line_intersects_line(x1, y1, x2, y2, rx2, ry2, rx1, ry2) || // bottom
    line_intersects_line(x1, y1, x2, y2, rx1, ry2, rx1, ry1));   // left
}

