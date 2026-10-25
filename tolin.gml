
function tolin_init(){
}

enum eOperation {
	PUSH, POP,
	ADD, SUB, MUL, DIV,
	LT, LE, GT, GE,
	AND, OR, NOT, 
	STORE, LOAD,
	NEG, CALL, GET_MEMBER, SET_MEMBER
}

enum eToken {
	NUMBER,
	IDENTIFIER,
	STRING,
	OPEN_PAR,
	CLOSE_PAR,
	LE, LT,
	GE, GT,
	PLUS, MINUS, DIV, MUL,
	ASSIGN,
	AND, NOT, OR,
	DOT, COMMA,
}

function tolin_get_token_name(type) {
	switch (type) {
		case eToken.IDENTIFIER: return "IDENTIFIER";
		case eToken.STRING: 	return "STRING";
		case eToken.OPEN_PAR:	return "OPEN_PAR";
		case eToken.CLOSE_PAR: 	return "CLOSE_PAR";
		case eToken.ASSIGN: 	return "ASSIGN";
		case eToken.NUMBER: 	return "NUMBER";
		case eToken.LE: 		return "LE";
		case eToken.LT: 		return "LT";
		case eToken.GE: 		return "GE";
		case eToken.GT: 		return "GT";
		case eToken.PLUS: 		return "PLUS";
		case eToken.MINUS: 		return "MINUS";
		case eToken.DIV: 		return "DIV";
		case eToken.MUL: 		return "MUL";
		case eToken.AND: 		return "AND";
		case eToken.NOT: 		return "NOT";
		case eToken.OR: 		return "OR";
	}
}

function T_TOKEN(type, line, value=undefined) {
	return {
		type: type,
		line: line,
		name: tolin_get_token_name(type),
		value: value,
	}
}

function T_OP(type, value=undefined) {
	var op = {
		type: type,
	}
	if (value != undefined) op.value = value;
	return op;
}

function OP_PUSH(value) {
	return T_OP(eOperation.PUSH, value);
}

function tolin_state() {
	var state = {};
	state.code = "";
	state.program = [];
	state.stack = [];
	state.tokens = [];
	state.env = {};
	state.funcs = {};
	state.pos = 0;
	return state;
}

function tolin_register(state, name, fn) {
	state.funcs[$ name] = fn;
}

function tolin_add_code(state, str) {
	state.code += str;
}

function tolin_assert(con, msg="no message") {
	if (!con) {
		show_error("TOLIN ERR: "+msg, false);
	}
}

#region TOKENIZER

// return code tokens
function tolin_tokenizer(state) {
	var code = state.code;
	var tokens = [];

	var i = 1;
	var line = 1;
	var len = string_length(code);

	while (i <= len) {
		var char = string_char_at(code, i);

		// NL
		if (char == "\n") {
			i++;
			line++;
			continue;
		}

		// Whitespace
		if (char == " " || char == "\r" || char == "\t") {
			i++;
			continue;
		}

		// Identifier
		if (string_letters(char) != "" || char == "_") {
			var start = i;

			while (i <= len) {
				var next = string_char_at(code, i);

				if (string_lettersdigits(next) != "" || next == "_") {
					i++;
				} else {
					break;
				}
			}

			var word = string_copy(code, start, i - start);
			array_push(tokens, T_TOKEN(eToken.IDENTIFIER, line, word));
			continue;
		}

		if (char == "\"") {
			var value = "";
			i++;

			while (i <= len) {
				char = string_char_at(code, i);

				if (char == "\"") {
					i++;
					break;
				}

				value += char;
				i++;

				tolin_assert((i <= len), $"Unterminated string at line {line}.");
			}

			array_push(tokens, T_TOKEN(eToken.STRING, line, value));
			continue;
		}

		// Numbers
		if (
			string_digits(char) != ""
			|| (char == "-" && i < len && string_digits(string_char_at(code, i + 1)) != "")
		) {
			var start = i;
			var negative = false;

			if (char == "-") {
				negative = true;
				i++;
			}

			while (i <= len) {
				var next = string_char_at(code, i);

				if (string_digits(next) != "" || next == ".") {
					i++;
				} else {
					break;
				}
			}

			var n = string_copy(code, start, i - start);
			array_push(tokens, T_TOKEN(eToken.NUMBER, line, real(n)));
			continue;
		}


		if (char == "(") {
			i++;
			array_push(tokens, T_TOKEN(eToken.OPEN_PAR, line));
			continue;
		}

		if (char == ")") {
			i++;
			array_push(tokens, T_TOKEN(eToken.CLOSE_PAR, line));
			continue;
		}

		if (char == "/") {
			var start = i;
			i++;

			array_push(tokens, T_TOKEN(eToken.DIV, line));
			continue;
		}

		if (char == "+") {
			i++;
			array_push(tokens, T_TOKEN(eToken.PLUS, line));
			continue;
		}

		if (char == "-") {
			i++;
			array_push(tokens, T_TOKEN(eToken.MINUS, line));
			continue;
		}
		
		if (char == "*") {
			i++;
			array_push(tokens, T_TOKEN(eToken.MUL, line));
			continue;
		}

		if (char == "=") {
			i++;
			array_push(tokens, T_TOKEN(eToken.ASSIGN, line));
			continue;
		}

		if (char == "!") {
			array_push(tokens, T_TOKEN(eToken.NOT, line));
			i++;
			continue;
		}

		if (char == "|") {
			i++;

			if (string_char_at(code, i) == "|") {
				array_push(tokens, T_TOKEN(eToken.OR, line));
				i++;
			}

			continue;
		}

		if (char == "&") {
			i++;

			if (string_char_at(code, i) == "&") {
				array_push(tokens, T_TOKEN(eToken.AND, line));
				i++;
			}

			continue;
		}

		if (char == ">") {
			i++;

			if (string_char_at(code, i) == "=") {
				array_push(tokens, T_TOKEN(eToken.GE, line));
				i++;
			} else {
				array_push(tokens, T_TOKEN(eToken.GT, line));
			}

			continue;
		}

		if (char == "<") {
			i++;

			if (string_char_at(code, i) == "=") {
				array_push(tokens, T_TOKEN(eToken.LE, line));
				i++;
			} else {
				array_push(tokens, T_TOKEN(eToken.LT, line));
			}

			continue;
		}

		if (char == ".") { i++; array_push(tokens, T_TOKEN(eToken.DOT, line)); continue; }
		if (char == ",") { i++; array_push(tokens, T_TOKEN(eToken.COMMA, line)); continue; }

		i++;
	}

	state.tokens = tokens;
}

#endregion

// precedence: higher binds tighter. 0 = not an infix operator
function tolin_infix_power(type) {
	switch (type) {
		case eToken.OR:    return 2;
		case eToken.AND:   return 3;

		case eToken.LT: case eToken.LE:
		case eToken.GT: case eToken.GE: return 4;

		case eToken.PLUS: case eToken.MINUS: return 5;
		case eToken.MUL:  case eToken.DIV:   return 6;
	}
	return 0;
}

function tolin_binary_op(type) {
	switch (type) {
		case eToken.PLUS:  return eOperation.ADD;
		case eToken.MINUS: return eOperation.SUB;
		case eToken.MUL:   return eOperation.MUL;
		case eToken.DIV:   return eOperation.DIV;
		case eToken.LT:    return eOperation.LT;
		case eToken.LE:    return eOperation.LE;
		case eToken.GT:    return eOperation.GT;
		case eToken.GE:    return eOperation.GE;
		case eToken.AND:   return eOperation.AND;
		case eToken.OR:    return eOperation.OR;
	}
}

function tolin_peek(state) {
	if (state.pos >= array_length(state.tokens)) return undefined;
	return state.tokens[state.pos];
}

function tolin_next(state) {
	var t = tolin_peek(state);
	tolin_assert(t != undefined, "Unexpected end of code.");
	state.pos++;
	return t;
}

function tolin_emit(state, op) {
	array_push(state.program, op);
}

function tolin_resolve(state, name) {
	if (variable_struct_exists(state.env, name)) return state.env[$ name];

	var asset = asset_get_index(name);
	tolin_assert(asset != -1, $"Unknown name '{name}'.");
	return asset;
}

function tolin_get_member(target, member) {
	if (is_struct(target)) {
		tolin_assert(variable_struct_exists(target, member), $"No member '{member}'.");
		return target[$ member];
	}

	tolin_assert(instance_exists(target), $"Can't read '{member}': no such instance.");
	with (target) {
		tolin_assert(variable_instance_exists(id, member), $"No variable '{member}'.");
		return variable_instance_get(id, member);
	}
}

function tolin_set_member(target, member, value) {
	if (is_struct(target)) {
		target[$ member] = value;
		return;
	}

	tolin_assert(instance_exists(target), $"Can't set '{member}': no such instance.");
	with (target) variable_instance_set(id, member, value);
}

function tolin_call(state, name, args) {
	var fn = state.funcs[$ name];

	if (fn == undefined) {
		var idx = asset_get_index(name);
		if (idx != -1 && script_exists(idx)) fn = idx;
	}

	tolin_assert(fn != undefined, $"Unknown function '{name}'.");
	return script_execute_ext(fn, args);
}

function tolin_parse_expr(state, min_power) {
	var t = tolin_next(state);

	// ---- prefix part ----
	switch (t.type) {
		case eToken.NUMBER:
		case eToken.STRING:
			tolin_emit(state, OP_PUSH(t.value));
			break;

		case eToken.IDENTIFIER:
			tolin_parse_identifier(state, t);
			break;

		case eToken.OPEN_PAR:
			tolin_parse_expr(state, 0);
			var close = tolin_next(state);
			tolin_assert(close.type == eToken.CLOSE_PAR, $"Expected ')' at line {close.line}.");
			break;

		case eToken.MINUS:
			tolin_parse_expr(state, 7);                        // unary binds tighter than any binary op
			tolin_emit(state, T_OP(eOperation.NEG));
			break;

		case eToken.NOT:
			tolin_parse_expr(state, 7);
			tolin_emit(state, T_OP(eOperation.NOT));
			break;

		default:
			tolin_assert(false, $"Unexpected token {t.name} at line {t.line}.");
	}

	// ---- postfix part: a.b.c, a.b.c = value ----
	while (true) {
		var p = tolin_peek(state);
		if (p == undefined || p.type != eToken.DOT) break;
		state.pos++;

		var member = tolin_next(state);
		tolin_assert(member.type == eToken.IDENTIFIER, $"Expected name after '.' at line {member.line}.");

		var after = tolin_peek(state);
		if (after != undefined && after.type == eToken.ASSIGN) {
			state.pos++;
			tolin_parse_expr(state, 0);
			tolin_emit(state, T_OP(eOperation.SET_MEMBER, member.value));
			break;   // assignment ends the chain
		}

		tolin_emit(state, T_OP(eOperation.GET_MEMBER, member.value));
	}

	// ---- infix part ----
	while (true) {
		var next = tolin_peek(state);
		if (next == undefined) break;

		var p = tolin_infix_power(next.type);
		if (p == 0 || p <= min_power) break;           // '<=' makes operators left-associative

		state.pos++;
		tolin_parse_expr(state, p);                        // right-hand side
		tolin_emit(state, T_OP(tolin_binary_op(next.type)));
	}
}

function tolin_parse_identifier(state, tok) {
	var nxt = tolin_peek(state);

	// assignment: x = ...
	if (nxt != undefined && nxt.type == eToken.ASSIGN) {
		state.pos++;
		tolin_parse_expr(state, 0);
		tolin_emit(state, T_OP(eOperation.STORE, tok.value));
		return;
	}

	// call: name(a, b, c)
	if (nxt != undefined && nxt.type == eToken.OPEN_PAR) {
		state.pos++;
		var argc = 0;

		if (tolin_peek(state).type == eToken.CLOSE_PAR) {
			state.pos++;
		} else {
			while (true) {
				tolin_parse_expr(state, 0);
				argc++;
				var t = tolin_next(state);
				if (t.type == eToken.CLOSE_PAR) break;
				tolin_assert(t.type == eToken.COMMA, $"Expected ',' or ')' at line {t.line}.");
			}
		}

		var op = T_OP(eOperation.CALL, tok.value);
		op.argc = argc;
		tolin_emit(state, op);
		return;
	}

	tolin_emit(state, T_OP(eOperation.LOAD, tok.value));
}

function tolin_parser(state) {
	state.pos = 0;
	while (state.pos < array_length(state.tokens)) {
		tolin_parse_expr(state, 0);
		tolin_emit(state, T_OP(eOperation.POP));
	}
}

function tolin_binary(stack, fn) {
	var b = array_pop(stack);
	var a = array_pop(stack);
	array_push(stack, fn(a, b));
}

function tolin_run(state) {
	tolin_tokenizer(state);
	tolin_parser(state);

	var program = state.program;
	var stack = state.stack;

	for (var i = 0; i < array_length(program); i++) {
		var op = program[i];

		switch (op.type) {
			case eOperation.PUSH: array_push(stack, op.value); break;
			case eOperation.POP:  array_pop(stack); break;

			case eOperation.LOAD:
				array_push(stack, tolin_resolve(state, op.value));
				break;

			case eOperation.GET_MEMBER:
				array_push(stack, tolin_get_member(array_pop(stack), op.value));
				break;

			case eOperation.SET_MEMBER: {
				var value = array_pop(stack);
				var target = array_pop(stack);
				tolin_set_member(target, op.value, value);
				array_push(stack, value);
				break;
			}

			case eOperation.CALL: {
				var args = array_create(op.argc);
				for (var j = op.argc - 1; j >= 0; j--) args[j] = array_pop(stack);
				array_push(stack, tolin_call(state, op.value, args));
				break;
			}

			case eOperation.STORE:
				state.env[$ op.value] = stack[array_length(stack) - 1];  // peek, leave value
				break;

			case eOperation.ADD: tolin_binary(stack, function(a, b) { return a + b; }); break;
			case eOperation.SUB: tolin_binary(stack, function(a, b) { return a - b; }); break;
			case eOperation.MUL: tolin_binary(stack, function(a, b) { return a * b; }); break;
			case eOperation.DIV: tolin_binary(stack, function(a, b) { return a / b; }); break;
			case eOperation.LT:  tolin_binary(stack, function(a, b) { return a <  b; }); break;
			case eOperation.LE:  tolin_binary(stack, function(a, b) { return a <= b; }); break;
			case eOperation.GT:  tolin_binary(stack, function(a, b) { return a >  b; }); break;
			case eOperation.GE:  tolin_binary(stack, function(a, b) { return a >= b; }); break;
			case eOperation.AND: tolin_binary(stack, function(a, b) { return a && b; }); break;
			case eOperation.OR:  tolin_binary(stack, function(a, b) { return a || b; }); break;

			case eOperation.NEG: array_push(stack, -array_pop(stack)); break;
			case eOperation.NOT: array_push(stack, !array_pop(stack)); break;
		}
	}
}
