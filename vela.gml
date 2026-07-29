function vela(){
	enum eNodeType {
		TEXT,
		BUTTON,
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
	
	#macro TRANSPARENT -1
}

function v_GetDefaultStyle() {
	return {
		anchor: eNodeAnchor.TOPLEFT,
		padding: 0,
		margin: new Dim(),
		direction: eNodeDirection.ROW,
		
		// stylying
		opacity: 1,
		backgroundColor: #181818,
		color: c_white,
		alpha: 1,
		
		// Border
		borderSize: 1,
		borderColor: c_dkgray,
		
		// Button
		buttonHoverColor: c_white,
		buttonClickColor: c_black,
		
		// Window
		draggable: false,
	}
}

function v_GetAnchorPosition(node, xx, yy) {
	var left	= xx + node.textWidth / 2;
	var center	= xx + node.width / 2;
	var right	= xx + node.width - node.textWidth / 2;
			
	var top		= yy + node.textHeight / 2;
	var middle	= yy + node.height / 2;
	var bottom	= yy + node.height - node.textHeight / 2;
		
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

function v_Panel(x=0, y=0, styleComponents={}) constructor {
	self.children = [];
	self.length = 0;
	
	self.x = x;
	self.y = y;
	self.initPos = new Vec2(x, y);
	
	self.width	= 0;
	self.height = 0;
	self.style = v_GetDefaultStyle();
	struct_merge_recursive(self.style, styleComponents);
	
	self.maximums = {
		width: 0,
		height: 0,
	}
	
	static Destroy = function() {
		self.children = [];
		self.length = 0;
	}
	
	static CalculateDimensions = function(node) {
		self.length = array_length(self.children);
		
		self.maximums.width		= max(self.maximums.width, node.width);
		self.maximums.height	= max(self.maximums.height, node.height);
		
		if (self.style.direction == eNodeDirection.ROW) {
			self.width += node.width + node.style.margin.width;
			self.height = max(self.height, node.height + node.style.margin.height);
		}
		
		if (self.style.direction == eNodeDirection.COLUMN) {
			self.width = max(self.width, node.width + node.style.margin.height);
			self.height += node.height + node.style.margin.height;
		}
		
		print(self.maximums);
	}
	
	static Get = function(index) {
		return self.children[index];
	}
	
	static Insert = function(index, node) {
		array_insert(self.children, index, node);
		self.CalculateDimensions(node);
	}
	
	static Push = function(node) {
		array_push(self.children, node);
		self.CalculateDimensions(node);
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
			draw_rectangle_color(x, y, x + self.width, y + self.height, self.style.backgroundColor, self.style.backgroundColor, self.style.backgroundColor, self.style.backgroundColor, false);
			draw_set_alpha(1);
		}
		
		if (self.style.borderColor != TRANSPARENT) {
			draw_set_alpha(self.style.opacity);
			draw_rectangle_color(x, y, x + self.width, y + self.height, self.style.borderColor, self.style.borderColor, self.style.borderColor, self.style.borderColor, true);
			draw_set_alpha(1);
		}
		
		var xoff = 0;
		var yoff = 0;
		var mx = display_mouse_get_x();
		var my = display_mouse_get_y();
		
		self.x = self.initPos.x + array_first(self.children).style.margin.width / 2;
		self.y = self.initPos.y + array_last(self.children).style.margin.height / 2;
		
		self.Drag(x, y, mx, my);
		
		for (var i = 0; i < self.length; i++) {
			var node = self.children[i];
			
			if (node == undefined) continue;
			if (node.type == -1) continue;
			
			var xmargin = node.style.margin.width;
			var ymargin = node.style.margin.height;
			
			var xx = self.x + xoff;
			var yy = self.y + yoff;
			var textpos;
			
			switch (node.type) {
				case eNodeType.TEXT:
					
					if (node.height < self.maximums.height) {
					}
					
					ALIGN_MIDDLE_CENTER;
					textpos = v_GetAnchorPosition(node, xx, yy);
					
					draw_text_color(textpos.x, textpos.y, node.text, node.style.color, node.style.color, node.style.color, node.style.color, node.style.alpha);
					
					break;
				
				case eNodeType.BUTTON:
					
					if (string_length(node.text) > 0) {
						ALIGN_MIDDLE_CENTER;
						textpos = v_GetAnchorPosition(node, xx, yy);
						draw_text_color(textpos.x, textpos.y, node.text, node.style.color, node.style.color, node.style.color, node.style.color, node.style.alpha);
					}
					
					if (sprite_exists(node.sprite)) {
						draw_sprite(node.sprite, node.spriteIndex, xx + node.width / 2, yy + node.height / 2);
					}
					
					var range = (mx > xx && mx < xx + node.width && my > yy && my < yy + node.height);
					
					if (range) {
						var bc = node.style.buttonHoverColor;
						var alpha = 0.25;
						
						if (mouse_check_button(mb_left)) {
							bc = node.style.buttonClickColor;
							alpha = 0.10;
						}
						
						draw_set_alpha(alpha);
						draw_rectangle_colour(xx, yy, xx + node.width - 1, yy + node.height - 1, bc, bc, bc, bc, false);
						draw_set_alpha(1);
						
						
						if (mouse_check_button_released(mb_left)) {
							node.callback.Call();
							window_set_cursor(cr_default);
						}
						
						CursorBusy = true;
						window_set_cursor(cr_handpoint);
						node.selected = true;
					}
					
					if (node.selected && !range) {
						CursorBusy = false;
						node.selected = false;
						window_set_cursor(cr_default);
					}
					
					break;
			}
			
			if (Debug.velaUI) then draw_rectangle_colour(
				x + xoff, y + yoff,
				x + xoff + node.width - 1, y + yoff + node.height - 1,
				c_aqua, c_aqua, c_aqua, c_aqua, true
			);
			
			if (self.style.direction == eNodeDirection.ROW)		then xoff += node.width  + xmargin;
			if (self.style.direction == eNodeDirection.COLUMN)	then yoff += node.height + ymargin;
		}
	}
	
	static SetPosition = function(x, y) {
		self.x = x;
		self.y = y;
		self.initPos = new Vec2(x, y);
	};
	
	self.dragging = false;
	self.dragOffset = new Vec2();
	
	static Drag = function(x, y, mx, my) {
		if (!self.style.draggable) return;
		
		var range = (mx > x && mx < x + self.width && my > y && my < y + self.height);
		
		if (range && !CursorBusy) {
			if (mouse_check_button_pressed(mb_left)) {
				self.dragOffset = new Vec2(x - mx, y - my);
				self.dragging = true;
			}
		}
		
		if (self.dragging) {
			var newpos = new Vec2(mx + self.dragOffset.x, my + self.dragOffset.y);
			var spd = 0.5;
			self.x = lerp(self.x, newpos.x,					spd);
			self.y = lerp(self.y, newpos.y,					spd);
			self.initPos.x = lerp(self.initPos.x, newpos.x, spd);
			self.initPos.y = lerp(self.initPos.y, newpos.y, spd);
			
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
	
	self.selected = false;
	self.style = v_GetDefaultStyle();
	
	self.callback = new Callback();
	
	static ApplyStyle = function(style={}) {
		struct_merge_recursive(self.style, style);
	}
	
	static CalculateWidth = function() {
		self.width		= max(string_width(self.text), (self.sprite != -1) ? sprite_get_width(self.sprite) : 0);
		self.height		= max(string_height(self.text), (self.sprite != -1) ? sprite_get_height(self.sprite) : 0);
	}
	
	static UpdateLayout = function() {
		self.textWidth  = string_width(self.text);
		self.textHeight = string_height(self.text);
		
		self.CalculateWidth();
		
		var padding = self.style.padding;
		
		if (is_struct(padding)) {
		    self.width  += padding.width;
		    self.height += padding.height;
		} else {
		    self.width  += padding;
		    self.height += padding;
		}
	}
}

function v_Text(text, styleComponents={}) : v_Node() constructor {
	self.type = eNodeType.TEXT;
	self.text = text;
	
	self.ApplyStyle(styleComponents);
	self.UpdateLayout();
	
	print($"TEXT NODE: '{text}' of width: '{self.width}' with style: {self.style}");
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
	
	print($"BUTTON NODE: '{textOrSprite}' of width: '{self.width}' with style: {self.style}");
}


