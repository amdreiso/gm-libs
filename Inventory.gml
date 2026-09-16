
function ItemStack(itemID = -1, quantity = 0) constructor {
	self.itemID		= itemID;
	self.quantity	= quantity;
}

function Inventory(slots = 10, capacityPerSlot = 100) constructor {
	self.slots = [];
	repeat (slots) {
		array_push(self.slots, new ItemStack());
	}
	self.length = slots;
	self.capacityPerSlot = capacityPerSlot;
	self.capacity = self.length * capacityPerSlot;
	
	static Add = function(itemID, quantity=1) {
		var found = -1;
		var free = -1;
		var amt = 0;
		
		for (var i = 0; i < self.length; i++) {
			var slot = self.slots[i];
			
			if (slot.itemID == -1 && free == -1) {
				free = i;
			}
			
			if (slot.itemID == itemID && (slot.quantity + quantity) < self.capacityPerSlot) {
				found = i;
				amt = quantity;
				break;
			}
		}
		
		if (found != -1) {
			self.slots[found].quantity += amt;
		} else {
			self.slots[free].itemID		= itemID;
			var q;
			
			if (quantity > 99) {
				q = quantity - 99;
				self.slots[free].quantity = 99;
				self.Add(itemID, q);
			} else {
				self.slots[free].quantity = quantity;
			}
		}
	}
	
	static Get = function(index) {
		return self.slots[index];
	}
	
	static RemoveItem = function(itemID, quantity) {
		var index = self.Has(itemID, quantity);
		self.slots[index].quantity -= quantity;
		if (self.slots[index].quantity <= 0) {
			self.slots[index].itemID = -1;
			self.slots[index].quantity = 0;
		}
	}
	
	static Remove = function(index, quantity) {
		self.slots[index].quantity -= quantity;
		if (self.slots[index].quantity <= 0) {
			self.slots[index].itemID = -1;
			self.slots[index].quantity = 0;
		}
	}
	
	static Has = function(itemID, quantity=1) {
		for (var i = 0; i < self.length; i++) {
			var s = self.slots[i];
			if (s.itemID == itemID && s.quantity >= quantity) {
				return i;
			}
		}
		return false;
	}
	
	static SlotPush = function(itemID = -1, quantity = 0) {
		array_push(self.slots, new ItemStack(itemID, quantity));
		self.length = array_length(self.slots);
		self.capacity = self.length * capacityPerSlot;
	}
	
	static SlotInsert = function(index, itemID = -1, quantity = 0) {
		array_insert(self.slots, index, new ItemStack(itemID, quantity));
		self.length = array_length(self.slots);
		self.capacity = self.length * capacityPerSlot;
	}
	
	static SlotRemove = function(index) {
		array_delete(self.slots, index, 1);
		self.length = array_length(self.slots);
	}
	
	static SetCapacityPerSlot = function(value) {
		self.capacityPerSlot = value;
		self.capacity = slots * value;
	}
	
	static Log = function() {
		for (var i = 0; i < self.length; i++) {
			var slot = self.slots[i];
			log($"slot '{i}' : '{slot}'");
		}
	}
}


