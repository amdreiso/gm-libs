function vela(){
	enum eNodeType {
		TEXT,
		BUTTON,
		PANEL,
		SURFACE,
		METER,
		INPUT_BOX,
	}
	
	enum eNodeAnchor {
		TOPLEFT,
		TOPCENTER,
		TOPRIGHT,
		MIDDLELEFT,
		MIDDLECENTER,
		MIDDLERIGHT,
		BOTTOMLEFT,
		BOTTOMCENTER,
		BOTTOMRIGHT,
	}
	
	enum eNodeDirection {
		ROW,
		COLUMN,
	}
	
	G Vela_Theme;
	Vela_Theme = {};
	
	#macro TRANSPARENT -1
	
	// Vela theme
	var themefile = "theme.tolin";
	fopen(themefile);
	if (file_exists(themefile)) {
		var tolinState = new TolinState();
		tolin_load_builtin_functions(tolinState, Tolin_BuiltInFunctions);
		tolin_load_constants(tolinState);
		tolin_load_file(tolinState, themefile);
		tolin_run(tolinState);
	}
}

function v_GetDefaultStyle() {
	var defaults =  {
		anchor: eNodeAnchor.MIDDLECENTER,
		padding: 0,
		margin: new Dim(),
		direction: eNodeDirection.ROW,
		
		opacity: 1,
		backgroundColor: #181818,
		color: c_white,
		
		border: true,
		borderSize: 1,
		borderColor: c_dkgray,
		borderColorSelected: c_white,
		
		buttonHoverColor: c_white,
		buttonClickColor: c_black,
		
		draggable: false,
	}
	
	struct_merge_recursive(defaults, Vela_Theme);
	return defaults;
}

function v_GetNodeAnchorPosition(node, xx, yy) {
	var left   = xx + node.textWidth / 2;
	var center = xx + node.width / 2;
	var right  = xx + node.width - node.textWidth / 2;
	
	var top    = yy + node.textHeight / 2;
	var middle = yy + node.height / 2;
	var bottom = yy + node.height - node.textHeight / 2;
	
	switch (node.style.anchor) {
		case eNodeAnchor.TOPLEFT:			return new Vec2(left,	top);
		case eNodeAnchor.TOPCENTER:			return new Vec2(center, top);
		case eNodeAnchor.TOPRIGHT:			return new Vec2(right,	top);
		case eNodeAnchor.MIDDLELEFT:		return new Vec2(left,	middle);
		case eNodeAnchor.MIDDLECENTER:		return new Vec2(center, middle);
		case eNodeAnchor.MIDDLERIGHT:		return new Vec2(right,	middle);
		case eNodeAnchor.BOTTOMLEFT:		return new Vec2(left,	bottom);
		case eNodeAnchor.BOTTOMCENTER:		return new Vec2(center, bottom);
		case eNodeAnchor.BOTTOMRIGHT:		return new Vec2(right,	bottom);
	}
}

function v_NodeDrawBorder(node) {
}

function v_Separator() {
	var sep = new v_Panel(0, 0, {
		direction: eNodeDirection.COLUMN,
		border: false,
		margin: new Dim(0, 10),
	});
	return sep;
}

function v_Panel(x=0, y=0, styleComponents={}) constructor {
	self.type = eNodeType.PANEL;
	self.children = [];
	self.length = 0;
	self.nodeClasses = {};
	
	self.x = x;
	self.y = y;
	self.initPos = new Vec2(x, y);
	
	self.width	= 0;
	self.height = 0;
	self.style = v_GetDefaultStyle();
	struct_merge_recursive(self.style, styleComponents);
	
	self.maximum = {
		width: 0,
		height: 0,
		marginWidth: 0,
		marginHeight: 0,
	}
	
	self.defaultChildrenStyle = {};
	
	static SetDefaultChildrenStyle = function(styleComponents={}) {
		self.defaultChildrenStyle = styleComponents;
	}
	
	static PushDefaultChildrenStyle = function(styleComponents={}) {
		struct_merge_recursive(self.defaultChildrenStyle, styleComponents);
	}
	
	static Destroy = function() {
		self.children = [];
		self.length = 0;
	}
	
	static ApplyStyle = function(style={}) {
		struct_merge_recursive(self.style, style);
	}
	
	static UpdateLayout = function() {
		self.Recalculate();
	}
	
	static Recalculate = function() {
	    self.width = 0;
	    self.height = 0;
	    self.maximum.width = 0;
	    self.maximum.height = 0;
		self.maximum.marginWidth	= 0;
		self.maximum.marginHeight	= 0;
	    self.length = array_length(self.children);
    
	    for (var i = 0; i < self.length; i++) {
	        var node = self.children[i];
	        if (node == undefined) continue;
			
			self.maximum.marginWidth	= max(self.maximum.marginWidth, node.style.margin.width);
			self.maximum.marginHeight	= max(self.maximum.marginHeight, node.style.margin.height);
			
	        self.maximum.width = max(
	            self.maximum.width,
	            node.width
	        );
        
	        self.maximum.height = max(
	            self.maximum.height,
	            node.height
	        );
			
			var isLast = (i == self.length - 1);
			var marginW = isLast ? 0 : node.style.margin.width;
			var marginH = isLast ? 0 : node.style.margin.height;
			
	        if (self.style.direction == eNodeDirection.ROW) {
	            self.width += node.width + marginW;
	            self.height = max(
	                self.height,
	                node.height + node.style.margin.height
	            );
	        } else {
	            self.width = max(
	                self.width,
	                node.width + node.style.margin.width
	            );
	            self.height += node.height + marginH;
	        }
	    }
		
		if (self.length > 0) {
			var firstMargin = self.children[0].style.margin;
			
			if (self.style.direction == eNodeDirection.ROW) {
				self.width += firstMargin.width / 2;
			}
			else {
				self.height += firstMargin.height / 2;
			}
		}
	}
	
	static Get = function(index) {
		return self.children[index];
	}
	
	static Insert = function(index, node) {
		array_insert(self.children, index, node);
		self.Recalculate();
	}
	
	static Push = function(node, class=undefined) {
		node.ApplyStyle(self.defaultChildrenStyle);
		node.UpdateLayout();
		array_push(self.children, node);
		self.nodeClasses[$ class] = array_length(self.children)-1;
		self.Recalculate();
	}
	
	static Find = function(class) {
		var index = self.nodeClasses[$ class];
		if (index) {
			return self.children[index];
		}
		return false;
	}
	
	static Edit = function(class, fn=function(e){}) {
		var index = self.nodeClasses[$ class];
		if (index) {
			fn(self.children[index]);
		}
		return false;
	}
	
	static Remove = function(node) {
		var index = array_get_index(self.children, node);
		if (index == -1) return;
		self.RemoveAt(index);
	}
	
	static RemoveAt = function(index) {
		array_delete(self.children, index, 1);
		self.Recalculate();
	}
	
	static Reverse = function() {
		self.children = array_reverse(self.children);
	}
	
	static Draw = function() {
		if (self.length == 0) {
			print("Trying to draw panel with no length!");
			return;
		}
		
		if (self.style.backgroundColor != TRANSPARENT) {
			draw_set_alpha(self.style.opacity);
			draw_rectangle_color(initPos.x, initPos.y, initPos.x + self.width, initPos.y + self.height, self.style.backgroundColor, self.style.backgroundColor, self.style.backgroundColor, self.style.backgroundColor, false);
			draw_set_alpha(1);
		}
		
		if (self.style.borderColor != TRANSPARENT && self.style.border) {
			draw_set_alpha(self.style.opacity);
			draw_rectangle_color(initPos.x, initPos.y, initPos.x + self.width, initPos.y + self.height, self.style.borderColor, self.style.borderColor, self.style.borderColor, self.style.borderColor, true);
			draw_set_alpha(1);
		}
		
		var xoff = 0;
		var yoff = 0;
		var mx = window_mouse_get_x();
		var my = window_mouse_get_y();
		
		var firstMargin = array_first(self.children).style.margin;
		
		self.x = self.initPos.x + firstMargin.width / 2;
		self.y = self.initPos.y + firstMargin.height / 2;
		
		self.Drag(mx, my);
		
		for (var i = 0; i < self.length; i++) {
			var node = self.children[i];
			
			if (node == undefined) continue;
			if (node.type == -1) continue;
			
			var xmargin = node.style.margin.width;
			var ymargin = node.style.margin.height;
			
			var xx = self.x + xoff;
			var yy = self.y + yoff;
			var textpos;
			
			if (self.style.direction == eNodeDirection.ROW) {
				yy += (self.maximum.height - node.height) / 2;
			}

			if (self.style.direction == eNodeDirection.COLUMN) {
				xx += (self.maximum.width - node.width) / 2;
			}
			
			switch (node.type) {
				case eNodeType.TEXT: {
					
					ALIGN_MIDDLE_CENTER;
					textpos = v_GetNodeAnchorPosition(node, xx, yy);
					
					draw_text_color(textpos.x, textpos.y, node.text, node.style.color, node.style.color, node.style.color, node.style.color, node.style.opacity);
					
					break;
				}
				case eNodeType.BUTTON: {
					
					if (string_length(node.text) > 0) {
						ALIGN_MIDDLE_CENTER;
						textpos = v_GetNodeAnchorPosition(node, xx, yy);
						draw_text_color(textpos.x, textpos.y, node.text, node.style.color, node.style.color, node.style.color, node.style.color, node.style.opacity);
					}
					
					if (sprite_exists(node.sprite)) {
						draw_sprite(node.sprite, node.spriteIndex, xx + node.width / 2, yy + node.height / 2);
					}
					
					node.hovered = node.OnMouse(xx, yy);
					
					if (node.hovered) {
						var bc = node.style.buttonHoverColor;
						var alpha = 0.25;
						
						if (mouse_check_button(mb_left)) {
							bc = node.style.buttonClickColor;
							alpha = 0.10;
						}
						
						draw_set_alpha(alpha);
						draw_rectangle_color(xx, yy, xx + node.width - 1, yy + node.height - 1, bc, bc, bc, bc, false);
						draw_set_alpha(1);
						
						if (mouse_check_button_released(mb_left)) {
							window_set_cursor(cr_default);
							node.callback.Call([node]);
						}
						
						CursorBusy = true;
						window_set_cursor(cr_handpoint);
						node.selected = true;
					}
					
					if (node.selected && !node.hovered) {
						CursorBusy = false;
						node.selected = false;
						window_set_cursor(cr_default);
					}
					
					break;
				}
				case eNodeType.PANEL: {
					
					node.SetPosition(xx, yy);
					node.Draw();
					
					break;
				}
				case eNodeType.SURFACE: {
					
					var pos = v_GetNodeAnchorPosition(node, xx, yy);
					node.callback.Call([pos.x, pos.y, node.width, node.height]);
					
					break;
				}
				case eNodeType.METER: {
					
					var pos = v_GetNodeAnchorPosition(node, xx, yy);
					var value = node.meter.get();
					var bg = node.style.backgroundColor;
					
					rect(pos.x, pos.y, node.width, node.height, node.style.borderColor, true);
					
					var part = (value / node.meter.maxvalue);
					var pw = (node.width * part);
					
					if (value > 0) then draw_rectangle_color(
						pos.x - node.width / 2, pos.y - node.height / 2, 
						(pos.x - node.width / 2) + (node.width * part), pos.y + node.height / 2, 
						
						bg, bg, bg, bg, false
					);
					
					
					break;
				}
				case eNodeType.INPUT_BOX: {
					
					var pos = v_GetNodeAnchorPosition(node, xx, yy);
					var bc = node.style.borderColor;
					
					var str = node.text;
					
					var close = function(node) {
						node.editing = false;
						KeyboardBusy = false;
					}
					
					var was_hovered = node.hovered;
					node.hovered = node.OnMouse(xx, yy);
					
					if (was_hovered && !node.hovered) {
						window_set_cursor(cr_default);
						CursorBusy = false;
					}
					
					if (node.hovered) {
						CursorBusy = true;
						window_set_cursor(cr_beam);
						
						if (mouse_check_button_released(mb_left)) {
							node.editing = true;
							keyboard_string = node.text;
						}
					}
					
					if (node.editing) {
						bc = node.style.borderColorSelected;
						str = keyboard_string;
						KeyboardBusy = true;
						
						node.text = keyboard_string;
						if (keyboard_check_pressed(vk_enter)) {
							close(node);
						}
					}
					
					if (node.editing && !node.hovered) {
						CursorBusy = false;
						window_set_cursor(cr_default);
						
						if (mouse_check_button_pressed(mb_left)) {
							close(node);
						}
					}
					
					// Draw
					draw_rectangle_color(xx, yy, xx + node.width - 1, yy + node.height - 1, bc, bc, bc, bc, true);
					
					var textWidth = (round(node.width / 9));
					
					var len = string_length(str);
					var final = str;
					
					if (len > textWidth) {
						if (node.editing) {
							final = string_copy(str, len - textWidth, textWidth + 1);
						} else {
							var maxOffset = len - textWidth;
							
							var spd = 100; 
							var pause = 1000;
							var cycle = pause + maxOffset * spd + pause + maxOffset * spd;
							var t = current_time % cycle;
							var offset = 0;
							
							if (t < pause) {
							    offset = 0;
							} else if (t < pause + maxOffset * spd) {
							    offset = floor((t - pause) / spd);
							} else if (t < pause + maxOffset * spd + pause) {
							    offset = maxOffset;
							} else {
							    offset = maxOffset - floor(
							        (t - pause - maxOffset * spd - pause) / spd
							    );
							}
							
							final = string_copy(str, offset + 1, textWidth);
						}
					}
					
					ALIGN_MIDDLE_CENTER;
					draw_text_color(pos.x, pos.y, final, node.style.color, node.style.color, node.style.color, node.style.color, node.style.opacity);
					
					break;
				}
			}
			
			if (keyboard_check_pressed(vk_escape)) {
				node.editing = false;
			}
			
			if (Debug.velaUI) then draw_rectangle_color(
				self.x + xoff, self.y + yoff,
				self.x + xoff + node.width - 1, self.y + yoff + node.height - 1,
				c_aqua, c_aqua, c_aqua, c_aqua, true
			);
			
			if (self.style.direction == eNodeDirection.ROW)		then xoff += node.width  + (xmargin);
			if (self.style.direction == eNodeDirection.COLUMN)	then yoff += node.height + (ymargin);
		}
	}
	
	static SetPosition = function(x, y) {
		self.x = x;
		self.y = y;
		self.initPos = new Vec2(x, y);
	};
	
	self.dragging = false;
	self.dragOffset = new Vec2();
	
	static Drag = function(mx, my) {
		if (!self.style.draggable) return;
		
		var range = (mx > self.initPos.x && mx < self.initPos.x + self.width && 
					 my > self.initPos.y && my < self.initPos.y + self.height);
		
		if (range && !CursorBusy) {
			if (mouse_check_button_pressed(mb_left)) {
				self.dragOffset = new Vec2(self.initPos.x - mx, self.initPos.y - my);
				self.dragging = true;
			}
		}
		
		if (self.dragging) {
			self.initPos = new Vec2(mx + self.dragOffset.x, my + self.dragOffset.y);
			
			if (mouse_check_button_released(mb_left)) {
				self.dragging = false;
			}
		}
	}
}

function v_Node() constructor {
	self.type = -1;
	self.text = "";
	
	self.sprite = -1;
	self.spriteIndex = 0;
	
	self.width = 0;
	self.height = 0;
	
	self.hovered = false;
	self.selected = false;
	self.editing = false;
	self.style = v_GetDefaultStyle();
	
	self.callback = new Callback();
	
	static ApplyStyle = function(style={}) {
		struct_merge_recursive(self.style, style);
	}
	
	static CalculateSize = function() {
		self.width		= max(string_width(self.text),  (self.sprite != -1) ? sprite_get_width(self.sprite)  : 0, self.width);
		self.height		= max(string_height(self.text), (self.sprite != -1) ? sprite_get_height(self.sprite) : 0, self.height);
	}
	
	static UpdateLayout = function() {
		self.textWidth  = string_width(self.text);
		self.textHeight = string_height(self.text);
		
		self.CalculateSize();
		
		var padding = self.style.padding;
		
		if (is_struct(padding)) {
		    self.width  += padding.width;
		    self.height += padding.height;
		} else {
		    self.width  += padding;
		    self.height += padding;
		}
	}
	
	static OnMouse = function(xx, yy) {
		var mx = window_mouse_get_x();
		var my = window_mouse_get_y();
		return (mx > xx && mx < xx + self.width && my > yy && my < yy + self.height);
	}
}

function v_Text(text, styleComponents={}) : v_Node() constructor {
	self.type = eNodeType.TEXT;
	self.text = text;
	
	self.ApplyStyle(styleComponents);
	self.UpdateLayout();
	
	print($"TEXT NODE: '{text}' dim: {self.width}x{self.height}  with style: '{self.style}'");
}

function v_Button(textOrSprite, func=function(){}, styleComponents={}) : v_Node() constructor {
	self.type = eNodeType.BUTTON;
	self.callback.Register(func);
	
	if (is_string(textOrSprite)) {
		self.text = textOrSprite;
	} else if (sprite_exists(textOrSprite)) {
		self.sprite = textOrSprite;
	}
	
	self.ApplyStyle(styleComponents);
	self.UpdateLayout();
	
	print($"BUTTON NODE: '{textOrSprite}' dim: {self.width}x{self.height}  with style: '{self.style}'");
}

function v_Surface(width, height, func=function(x, y, width, height){}, styleComponents={}) : v_Node() constructor {
	self.type = eNodeType.SURFACE;
	self.callback.Register(func);
	
	self.width = width;
	self.height = height;
	
	self.ApplyStyle(styleComponents);
	self.UpdateLayout();
	
	print($"SURFACE NODE: dim: {self.width}x{self.height} with style: '{self.style}'");
}

function v_Meter(width, height, maxvalue, get=function(){}, styleComponents={}) : v_Node() constructor {
	self.type = eNodeType.METER;
	//self.callback.Register(func);
	
	self.width = width;
	self.height = height;
	self.meter = {
		get: get,
		maxvalue: maxvalue,
	};
	
	self.ApplyStyle({
		margin: new Dim(0, 10),
		borderColor: c_lime,
		backgroundColor: c_lime,
	});
	self.ApplyStyle(styleComponents);
	self.UpdateLayout();
	
	print($"METER NODE: dim: {self.width}x{self.height} with style: '{self.style}'");
}

function v_InputBox(str="text here...", styleComponents={}) : v_Node() constructor {
	self.type = eNodeType.INPUT_BOX;
	self.text = str;
	
	self.ApplyStyle({
		padding: new Dim(20, 0),
	});
	self.ApplyStyle(styleComponents);
	self.UpdateLayout();
	
	print($"INPUT_BOX NODE: dim: {self.width}x{self.height} with style: '{self.style}'");
}
