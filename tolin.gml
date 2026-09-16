function tolin(){

}

#region OPERATIONS

enum TOLIN_OP_TYPE {
	Dump,
	Push,
	Plus,
	Sub,
	Mul,
	Div,
	Dup,
	GT,
	LT,
	GE,
	LE,
	Store,
	Load,
	Equal,
	Not,
	And,
	Or,
	Label,
	Jump,
	JumpIfFalse,
	ArrayCreate,
	StructCreate,
	StructSet,
	ArrayAppend,
	Get,
	GetKey,
	Exit,
	Call,
	CallStack,
	Ret,
}

globalvar TOLIN_OP_NAME; 
TOLIN_OP_NAME = [];
TOLIN_OP_NAME[ TOLIN_OP_TYPE.Push ]					= "Push";
TOLIN_OP_NAME[ TOLIN_OP_TYPE.Plus ]					= "Plus";
TOLIN_OP_NAME[ TOLIN_OP_TYPE.Dump ]					= "Dump";
TOLIN_OP_NAME[ TOLIN_OP_TYPE.Sub ]					= "Sub";
TOLIN_OP_NAME[ TOLIN_OP_TYPE.Mul ]					= "Mul";
TOLIN_OP_NAME[ TOLIN_OP_TYPE.Div ]					= "Div";
TOLIN_OP_NAME[ TOLIN_OP_TYPE.Dup ]					= "Dup";
TOLIN_OP_NAME[ TOLIN_OP_TYPE.Store ]				= "Store";
TOLIN_OP_NAME[ TOLIN_OP_TYPE.Load ]					= "Load";
TOLIN_OP_NAME[ TOLIN_OP_TYPE.Equal ]				= "Equal";
TOLIN_OP_NAME[ TOLIN_OP_TYPE.Not ]					= "Not";
TOLIN_OP_NAME[ TOLIN_OP_TYPE.And ]					= "And";
TOLIN_OP_NAME[ TOLIN_OP_TYPE.Or ]					= "Or";
TOLIN_OP_NAME[ TOLIN_OP_TYPE.Label ]				= "Label";
TOLIN_OP_NAME[ TOLIN_OP_TYPE.Jump ]					= "Jump";
TOLIN_OP_NAME[ TOLIN_OP_TYPE.JumpIfFalse]			= "Jump If False";
TOLIN_OP_NAME[ TOLIN_OP_TYPE.Exit ]					= "Exit";
TOLIN_OP_NAME[ TOLIN_OP_TYPE.Call ]					= "Call";
TOLIN_OP_NAME[ TOLIN_OP_TYPE.CallStack ]			= "Call Stack";
TOLIN_OP_NAME[ TOLIN_OP_TYPE.Ret ]					= "Ret";
TOLIN_OP_NAME[ TOLIN_OP_TYPE.LT ]					= "Less Than";
TOLIN_OP_NAME[ TOLIN_OP_TYPE.LE ]					= "Less Than or Equal";
TOLIN_OP_NAME[ TOLIN_OP_TYPE.GT ]					= "Greater Than";
TOLIN_OP_NAME[ TOLIN_OP_TYPE.GE ]					= "Greater Than or Equal";
TOLIN_OP_NAME[ TOLIN_OP_TYPE.StructCreate ]			= "Create Struct";
TOLIN_OP_NAME[ TOLIN_OP_TYPE.StructSet ]			= "Struct Set";
TOLIN_OP_NAME[ TOLIN_OP_TYPE.ArrayAppend ]			= "Array Set";
TOLIN_OP_NAME[ TOLIN_OP_TYPE.Get ]					= "Get";
TOLIN_OP_NAME[ TOLIN_OP_TYPE.ArrayCreate ]			= "Create Array";

/**
 * Function Description
 * @param {Enum.OP_TYPE} type Operation type
 * @param {struct.Token} token The token the operation was found in
 * @param {real} pos Position of the operation in the file
 * @param {real} [value] Value the Operation holds
 */
function Tolin_Operation(type, token, pos, value=undefined) constructor {
	self.type = type;
	self.token = token;
	self.pos = pos;
	self.value = value;
}

function CALL_STACK(token, pos){
	return new Tolin_Operation(TOLIN_OP_TYPE.CallStack, token, pos);
}

function ARRAY_CREATE(token, pos){
	return new Tolin_Operation(TOLIN_OP_TYPE.ArrayCreate, token, pos);
}

function STRUCT_CREATE(token, pos){
	return new Tolin_Operation(TOLIN_OP_TYPE.StructCreate, token, pos);
}

function STRUCT_SET(token, pos){
	return new Tolin_Operation(TOLIN_OP_TYPE.StructSet, token, pos);
}

function ARRAY_APPEND(token, pos){
	return new Tolin_Operation(TOLIN_OP_TYPE.ArrayAppend, token, pos);
}

function GET(token, pos){
	return new Tolin_Operation(TOLIN_OP_TYPE.Get, token, pos);
}

function GT(token, pos){
	return new Tolin_Operation(TOLIN_OP_TYPE.GT, token, pos);
}

function GE(token, pos){
	return new Tolin_Operation(TOLIN_OP_TYPE.GE, token, pos);
}

function LT(token, pos){
	return new Tolin_Operation(TOLIN_OP_TYPE.LT, token, pos);
}

function LE(token, pos){
	return new Tolin_Operation(TOLIN_OP_TYPE.LE, token, pos);
}

function CALL(token, pos, name){
	return new Tolin_Operation(TOLIN_OP_TYPE.Call, token, pos, name);
}

function RET(token, pos){
	return new Tolin_Operation(TOLIN_OP_TYPE.Ret, token, pos);
}

function EXIT(token, pos){
	return new Tolin_Operation(TOLIN_OP_TYPE.Exit, token, pos);
}

function JUMP_IF_FALSE(token, pos, name){
	return new Tolin_Operation(TOLIN_OP_TYPE.JumpIfFalse, token, pos, name);
}

function JUMP(token, pos, name){
	return new Tolin_Operation(TOLIN_OP_TYPE.Jump, token, pos, name);
}

function LABEL(token, pos, name){
	return new Tolin_Operation(TOLIN_OP_TYPE.Label, token, pos, name);
}

// push value on stack
function PUSH(token, pos ,val){
	return new Tolin_Operation(TOLIN_OP_TYPE.Push, token, pos, val);
}

// add
function PLUS(token, pos){
	return new Tolin_Operation(TOLIN_OP_TYPE.Plus, token, pos);
}

// subtract
function SUB(token, pos){
	return new Tolin_Operation(TOLIN_OP_TYPE.Sub, token, pos);
}

// multiply
function MUL(token, pos){
	return new Tolin_Operation(TOLIN_OP_TYPE.Mul, token, pos);
}

// divide
function DIV(token, pos){
	return new Tolin_Operation(TOLIN_OP_TYPE.Div, token, pos);
}

// duplicate
function DUP(token, pos){
	return new Tolin_Operation(TOLIN_OP_TYPE.Dup, token, pos);
}

// print
function DUMP(token, pos){
	return new Tolin_Operation(TOLIN_OP_TYPE.Dump, token, pos);
}

// store variable
function STORE(token, pos, value){
	return new Tolin_Operation(TOLIN_OP_TYPE.Store, token, pos, value);
}

// load variable
function LOAD(token, pos, name){
	return new Tolin_Operation(TOLIN_OP_TYPE.Load, token, pos, name);
}

function EQUAL(token, pos){
	return new Tolin_Operation(TOLIN_OP_TYPE.Equal, token, pos);
}

function NOT(token, pos){
	return new Tolin_Operation(TOLIN_OP_TYPE.Not, token, pos);
}

function AND(token, pos){
	return new Tolin_Operation(TOLIN_OP_TYPE.And, token, pos);
}

function OR(token, pos){
	return new Tolin_Operation(TOLIN_OP_TYPE.Or, token, pos);
}

#endregion

#region LEXER

enum TOLIN_TOKEN_TYPE {
	Number,
	String,
	Keyword,
	Identifier,
	Plus,
	Sub,
	Mul,
	Div,
	GT,
	GE,
	LT,
	LE,
	Equal,
	OpenParen,
	CloseParen,
	And,
	Or,
	Not,
	EOF,
	Arrow,
}

globalvar TOLIN_TOKEN_NAME;

TOLIN_TOKEN_NAME[TOLIN_TOKEN_TYPE.Number]		= "Number"
TOLIN_TOKEN_NAME[TOLIN_TOKEN_TYPE.String]		= "String"
TOLIN_TOKEN_NAME[TOLIN_TOKEN_TYPE.Keyword]		= "Keyword"
TOLIN_TOKEN_NAME[TOLIN_TOKEN_TYPE.Identifier]	= "Identifier"
TOLIN_TOKEN_NAME[TOLIN_TOKEN_TYPE.Plus]			= "Plus"
TOLIN_TOKEN_NAME[TOLIN_TOKEN_TYPE.Sub]			= "Sub"
TOLIN_TOKEN_NAME[TOLIN_TOKEN_TYPE.Mul]			= "Mul"
TOLIN_TOKEN_NAME[TOLIN_TOKEN_TYPE.Div]			= "Div"
TOLIN_TOKEN_NAME[TOLIN_TOKEN_TYPE.OpenParen]	= "OpenParen"
TOLIN_TOKEN_NAME[TOLIN_TOKEN_TYPE.CloseParen]	= "CloseParen"
TOLIN_TOKEN_NAME[TOLIN_TOKEN_TYPE.GT]			= "GT"
TOLIN_TOKEN_NAME[TOLIN_TOKEN_TYPE.GE]			= "GE"
TOLIN_TOKEN_NAME[TOLIN_TOKEN_TYPE.LT]			= "LT"
TOLIN_TOKEN_NAME[TOLIN_TOKEN_TYPE.LE]			= "LE"
TOLIN_TOKEN_NAME[TOLIN_TOKEN_TYPE.And]			= "And"
TOLIN_TOKEN_NAME[TOLIN_TOKEN_TYPE.Not]			= "Not"
TOLIN_TOKEN_NAME[TOLIN_TOKEN_TYPE.Or]			= "Or"
TOLIN_TOKEN_NAME[TOLIN_TOKEN_TYPE.Equal]		= "Equal"
TOLIN_TOKEN_NAME[TOLIN_TOKEN_TYPE.EOF]			= "EOF"
TOLIN_TOKEN_NAME[TOLIN_TOKEN_TYPE.Arrow]		= "Arrow"

/**
 * Function Description
 * @param {Enum.TOKEN_TYPE} type Type of token
 * @param {real} line Line number
 * @param {any*} [value] Value of token
 */
function Tolin_Token(type, line, value=undefined) constructor {
	self.type = type;
	self.line = line;
	self.value = value;
	self.name = TOLIN_TOKEN_NAME[type];
}

function tolin_lexer(state, source) {
	var tokens = [];
	var line = 1;
	var index = 1;
	var len = string_length(source);

	while (index < len) {
		var char = string_char_at(source, index);

		// new lines
		if (char == "\n") {
			index ++;
			line ++;
			continue;
		}

		if (char == " " || char == "\r" || char == "\t") {
			index ++;
			continue;
		}

		// Identifiers
		if (string_letters(char) != "" || char == "_") {
			var start = index;

			while (index <= len) {
				var next = string_char_at(source, index);

				if (string_lettersdigits(next) != "" || next == "_") {
					index ++;
				} else {
					break;
				}
			}

			var word = string_copy(source, start, index - start);

			if (word == "include") {
				index ++;

				var file = "";

				while (index <= len) {
					var next = string_char_at(source, index);

					if (string_lettersdigits(next) != "" || next == "_") {
						file += next;
						index ++;
					} else {
						break;
					}
				}

				source = string_delete(source, start, index - start);

				var FILENAME = file + ".tolin";

				if (file_exists(FILENAME)) {
					var FILE = file_text_open_read(FILENAME);
					var content = "";

					while (!file_text_eof(FILE)) {
						content += file_text_readln(FILE);
					}

					file_text_close(FILE);

					source = string_join(source, " ", content);

					index = 1;
					len = string_length(source);
				}

				continue;
			}

			var t = new Tolin_Token(TOLIN_TOKEN_TYPE.Identifier, line, word);
			array_push(tokens, t);
			continue;
		}

		// Numbers
		//if ((string_digits(char) != "" || (char == "-" && index < len && string_digits(string_char_at(source, index + 1)) != "")) && char != "") {
		//	var start = index;

		//	if (char == "-") {
		//		index ++;
		//	}

		//	while (index <= len) {
		//		var next = string_char_at(source, index);

		//		if (string_digits(next) != "" || next == ".") {
		//			index ++;
		//		} else {
		//			break;
		//		}
		//	}

		//	var n = string_copy(source, start, index - start);
		//	var t = new Tolin_Token(TOLIN_TOKEN_TYPE.Number, line, real(n));
		//	array_push(tokens, t);
		//	continue;
		//}
		
		// Numbers
		if (
			string_digits(char) != ""
			|| (char == "-" && index < len && string_digits(string_char_at(source, index + 1)) != "")
			|| char == "#"
		) {
			var start = index;
			var negative = false;

			if (char == "-") {
				negative = true;
				index++;
			}

			// hex
			if (string_char_at(source, index) == "#") {
				index++;

				var hex = "";

				while (index <= len) {
					var h = string_char_at(source, index);
			
					if (
						string_digits(h) != ""
						|| string_pos(string_lower(h), "abcdef") > 0
					) {
						hex += h;
						index++;
					} else {
						break;
					}
				}

				var value = 0;

				for (var i = 1; i <= string_length(hex); i++) {
					var h = string_lower(string_char_at(hex, i));
					var digit;

					if (string_digits(h) != "") {
						digit = real(h);
					} else {
						digit = 10 + string_pos(h, "abcdef") - 1;
					}

					value = value * 16 + digit;
				}

				if (!negative) {
					var r = (value >> 16) & 255;
					var g = (value >> 8) & 255;
					var b = value & 255;

					value = make_color_rgb(r, g, b);
				} else {
					value = -value;
				}

				var t = new Tolin_Token(TOLIN_TOKEN_TYPE.Number, line, value);
				array_push(tokens, t);
				continue;
			}

			// Normal decimal number
			while (index <= len) {
				var next = string_char_at(source, index);

				if (string_digits(next) != "" || next == ".") {
					index++;
				} else {
					break;
				}
			}

			var n = string_copy(source, start, index - start);
			var t = new Tolin_Token(TOLIN_TOKEN_TYPE.Number, line, real(n));
			array_push(tokens, t);
			continue;
		}
		
		if (char == "\"") {
			var lineStart = line;
			var str = "";

			index ++;

			while (index <= len) {
				var next = string_char_at(source, index);

				if (next == "\"") {
					index ++;
					break;
				}

				if (next == "\n") {
					line ++;
				}

				str += next;
				index ++;

				if (index > len) {
					show_error("Tolin ERR: Unterminated string starting at line " + string(lineStart), true);
				}
			}

			var t = new Tolin_Token(TOLIN_TOKEN_TYPE.String, lineStart, str);
			array_push(tokens, t);
			continue;
		}

		if (char == "+") {
			index ++;
			var t = new Tolin_Token(TOLIN_TOKEN_TYPE.Plus, line);
			array_push(tokens, t);
			continue;
		}

		if (char == "-") {
			index ++;

			if (string_char_at(source, index) == ">") {
				var t = new Tolin_Token(TOLIN_TOKEN_TYPE.Arrow, line);
				array_push(tokens, t);
				
				index ++;
			} else {
				var t = new Tolin_Token(TOLIN_TOKEN_TYPE.Sub, line);
				array_push(tokens, t);
				
			}

			continue;
		}
		
		if (char == "*") {
			index ++;
			var t = new Tolin_Token(TOLIN_TOKEN_TYPE.Mul, line);
			array_push(tokens, t);
			continue;
		}

		if (char == "=") {
			index ++;
			var t = new Tolin_Token(TOLIN_TOKEN_TYPE.Equal, line);
			array_push(tokens, t);
			continue;
		}

		if (char == "!") {
			var t = new Tolin_Token(TOLIN_TOKEN_TYPE.Not, line);
			array_push(tokens, t);
			index ++;
			continue;
		}

		if (char == "|") {
			index ++;

			if (string_char_at(source, index) == "|") {
				var t = new Tolin_Token(TOLIN_TOKEN_TYPE.Or, line);

				array_push(tokens, t);

				index ++;
			}

			continue;
		}

		if (char == "&") {
			index ++;

			if (string_char_at(source, index) == "&") {
				var t = new Tolin_Token(TOLIN_TOKEN_TYPE.And, line);

				array_push(tokens, t);

				index ++;
			}

			continue;
		}

		if (char == ">") {
			index ++;

			if (string_char_at(source, index) == "=") {
				var t = new Tolin_Token(TOLIN_TOKEN_TYPE.GE, line);
				array_push(tokens, t);
				index ++;
			} else {
				var t = new Tolin_Token(TOLIN_TOKEN_TYPE.GT, line);

				array_push(tokens, t);
			}

			continue;
		}

		if (char == "<") {
			index ++;

			if (string_char_at(source, index) == "=") {
				var t = new Tolin_Token(TOLIN_TOKEN_TYPE.LE, line);
				array_push(tokens, t);

				index ++;
			} else {
				var t = new Tolin_Token(TOLIN_TOKEN_TYPE.LT, line);
				array_push(tokens, t);
			}

			continue;
		}

		if (char == "/") {
			var start = index;
			index ++;

			if (string_char_at(source, index) == "/") {
				while (string_char_at(source, index) != "\n") {
					index ++;
				}

				string_delete(source, start, index);
				continue;
			}

			var t = new Tolin_Token(TOLIN_TOKEN_TYPE.Div, line);
			array_push(tokens, t);
			continue;
		}

		if (char == "(") {
			index ++;
			var t = new Tolin_Token(TOLIN_TOKEN_TYPE.OpenParen, line);
			array_push(tokens, t);
			continue;
		}

		if (char == ")") {
			index ++;
			var t = new Tolin_Token(TOLIN_TOKEN_TYPE.CloseParen, line);
			array_push(tokens, t);
			continue;
		}

		index ++;
	}

	return tokens;
}

#endregion

#region PARSER

function tolin_parse_identifier(tokens, index, program, BLOCK_Stack) {
    var len = array_length(tokens);
    var t = tokens[index];
	
	// Function call
    if (index + 1 < len && tokens[index + 1].type == TOLIN_TOKEN_TYPE.OpenParen) {
        array_push(program, CALL(t, index, t.value));
        index += 1;
        return index;
    }

    // Normal identifier
    array_push(program, LOAD(t, index, t.value));

    if (
        array_length(BLOCK_Stack) > 0 &&
        BLOCK_Stack[array_length(BLOCK_Stack) - 1].type == "array"
    ) {
        array_push(program, ARRAY_APPEND(t, index));
    }
	
    while (
        index + 2 < len &&
        tokens[index + 1].type == TOLIN_TOKEN_TYPE.Arrow &&
        tokens[index + 2].type == TOLIN_TOKEN_TYPE.Identifier
    ) {
        index += 2;

        var key = tokens[index];

        array_push(program, PUSH(key, index, key.value));

        // Only GET if another -> follows this property
        if (
            index + 2 < len &&
            tokens[index + 1].type == TOLIN_TOKEN_TYPE.Arrow &&
            tokens[index + 2].type == TOLIN_TOKEN_TYPE.Identifier
        ) {
            array_push(program, GET(key, index));
        }
    }

    return index;
}

function tolin_parser(state, tokens) {
	var len = array_length(tokens);
	var BLOCK_Stack = [];
	var program = state.program;
	
	for (var i = 0; i < len; i++) {
		var t = tokens[i];
		
		switch (t.type) {

			case TOLIN_TOKEN_TYPE.Number:
				array_push(program, PUSH(t, i, t.value));

				if (array_length(BLOCK_Stack) > 0 && BLOCK_Stack[array_length(BLOCK_Stack) - 1].type == "array") {
				    array_push(program, ARRAY_APPEND(t, i));
				}
				    break;

			case TOLIN_TOKEN_TYPE.String:
				array_push(program, PUSH(t, i, t.value));

				if (array_length(BLOCK_Stack) > 0 && BLOCK_Stack[array_length(BLOCK_Stack) - 1].type == "array") {
				    array_push(program, ARRAY_APPEND(t, i));
				}
				    break;

			case TOLIN_TOKEN_TYPE.Identifier:

			    var stacklen = array_length(BLOCK_Stack);

			    // struct literal handling
			    if (stacklen > 0 &&
			        BLOCK_Stack[stacklen - 1].type == "struct" &&
			        t.value != "end")
			    {
			        // your existing struct code...
			        continue;
			    }

			    switch (t.value) {
					case "print":
					    array_push(program, DUMP(t, i));
					    break;

				    case "dup":
					    array_push(program, DUP(t, i));
					    break;


				    case "exit":
					    array_push(program, EXIT(t, i));
					    break;

				    case "get":
					    array_push(program, GET(t, i));
					    break;

				    case ".":
						i++;
						var next = tokens[i];
			
						array_push(program, PUSH(next, i, next.value));
						array_push(program, GET(next, i));
			
						break;

				    case "assign":
					    array_push(program, STRUCT_SET(t, i));
					    break;

				    case "true":
					    array_push(program, PUSH(t, i, true));

					    if (array_length(BLOCK_Stack) > 0 && BLOCK_Stack[array_length(BLOCK_Stack) - 1].type == "array") {
					        array_push(program, ARRAY_APPEND(t, i));
					    }
					    break;

				    case "false":
					    array_push(program, PUSH(t, i, false));

					    if (array_length(BLOCK_Stack) > 0 && BLOCK_Stack[array_length(BLOCK_Stack) - 1].type == "array") {
					        array_push(program, ARRAY_APPEND(t, i));
					    }
					    break;

				    case "NULL":
					    array_push(program, PUSH(t, i, undefined));

					    if (array_length(BLOCK_Stack) > 0 && BLOCK_Stack[array_length(BLOCK_Stack) - 1].type == "array") {
					        array_push(program, ARRAY_APPEND(t, i));
					    }
					    break;

				    case "call":
					    array_push(program, CALL_STACK(t, i));
					    break;

				    case "set":
					    i++;
					    var next = tokens[i];
					    array_push(program, STORE(t, i, next.value));
					    break;

				    case "func":
					    i++;
					    var name = tokens[i].value;

					    var skip_index = array_length(program);
					    array_push(program, JUMP(t, i, -1));

					    state.functions[$ name] = array_length(program);

					    array_push(BLOCK_Stack, {
					        type: "func",
					        jump: skip_index
					    });
						break;

				    case "if":
					    var jump_index = array_length(program);
					    array_push(program, JUMP_IF_FALSE(t, i, -1));

					    array_push(BLOCK_Stack, {
					        type: "if",
					        jump: jump_index
					    });
					    break;

				    case "while":
						var start = array_length(program);
					    array_push(BLOCK_Stack, {
					        type: "while",
					        start: start,
					        jump: -1
					    });
					    break;
					
					case "do":
						var stack_depth = array_length(BLOCK_Stack);
						if (stack_depth > 0 && BLOCK_Stack[stack_depth - 1].type == "while") {
							var block = BLOCK_Stack[stack_depth - 1];
							
							block.jump = array_length(program);
							array_push(program, JUMP_IF_FALSE(t, i, -1));
						}
						break;
						
				    case "struct":
					    array_push(program, STRUCT_CREATE(t, i));

					    array_push(BLOCK_Stack, {
					        type: "struct"
					    });
					    break;

				    case "array":
					    array_push(program, ARRAY_CREATE(t, i));

					    array_push(BLOCK_Stack, {
					        type: "array"
					    });
					    break;

				    case "end":
						var block = array_pop(BLOCK_Stack);

						switch (block.type) {
							case "func":
								array_push(program, RET(t, i));
								program[block.jump].value = array_length(program);
								break;

							case "if":
								program[block.jump].value = array_length(program);
								break;

							case "while":
								array_push(program, JUMP(t, i, block.start));
    
								if (block.jump != -1) {
									program[block.jump].value = array_length(program);
								}
								break;

							case "struct":
							break;

							case "array":
							break;
					    }
						
					    break;

			        default:
						i = tolin_parse_identifier(tokens, i, program, BLOCK_Stack);
			            //var name = t.value;

			            //// Load the first identifier
			            //array_push(program, LOAD(t, i, name));

			            //// Follow -> chains
			            //while (
			            //    i + 2 < len &&
			            //    tokens[i + 1].type == TOLIN_TOKEN_TYPE.Arrow &&
			            //    tokens[i + 2].type == TOLIN_TOKEN_TYPE.Identifier
			            //) {
			            //    i += 2;

			            //    var key = tokens[i];

			            //    array_push(program, PUSH(key, i, key.value));
			            //    array_push(program, GET(key, i));
			            //}

			            //break;
			    }

			    break;

			    //default:
				//    var name = t.value;

				//	if (i + 1 < len && tokens[i + 1].type == TOLIN_TOKEN_TYPE.OpenParen) {
				//	    array_push(program, CALL(t, i, name));
				//	    i += 1;
				//	} else {
				//	    array_push(program, LOAD(t, i, name));

				//	    if (array_length(BLOCK_Stack) > 0 && BLOCK_Stack[array_length(BLOCK_Stack) - 1].type == "array") {
				//	    array_push(program, ARRAY_APPEND(t, i));
				//	    }
				//	}
				//    break;

			case TOLIN_TOKEN_TYPE.Plus:		array_push(program, PLUS(t, i));	break;
			case TOLIN_TOKEN_TYPE.Sub:		array_push(program, SUB(t, i));		break;
			case TOLIN_TOKEN_TYPE.Mul:		array_push(program, MUL(t, i));		break;
			case TOLIN_TOKEN_TYPE.Div:		array_push(program, DIV(t, i));		break;
			case TOLIN_TOKEN_TYPE.GT:		array_push(program, GT(t, i));		break;
			case TOLIN_TOKEN_TYPE.GE:		array_push(program, GE(t, i));		break;
			case TOLIN_TOKEN_TYPE.LT:		array_push(program, LT(t, i));		break;
			case TOLIN_TOKEN_TYPE.LE:		array_push(program, LE(t, i));		break;
			case TOLIN_TOKEN_TYPE.Equal:	array_push(program, EQUAL(t, i));	break;
			case TOLIN_TOKEN_TYPE.And:		array_push(program, AND(t, i));		break;
			case TOLIN_TOKEN_TYPE.Not:		array_push(program, NOT(t, i));		break;
			case TOLIN_TOKEN_TYPE.Or:		array_push(program, OR(t, i));		break;
		}
	}
}

#endregion



function tolin_init() {
	tolin_builtin();
}

/// @typedef {struct} TolinState
/// @property {struct} env
/// @property {struct} labels
/// @property {array} program
/// @property {array} patches
/// @property {struct} functions
/// @constructor
/// @returns {TolinState}
function TolinState() constructor {
	self.env			= {};
	self.code			= "";
	self.labels			= {};
	self.program		= [];
	self.patches		= [];
	self.functions		= {};
}

/**
 * Returns tolin error
 * @param {struct.Operation} op Current operation
 * @param {string} cause Cause of error
 */
function tolin_error(op, cause) {
	var line = op.token.line, pos = op.pos;
	
	var str = $"TOLIN ERR: {line}:{pos} | {cause}";
	show_error(str, true);
}

/**
 * Check if state exists
 * @param {struct.TolinState} state TolinState
 */
function tolin_state_exists(state) {
	if (!is_struct(state)) return false;
	if (struct_get(state, "functions")	== undefined) return false;
	if (struct_get(state, "env")		== undefined) return false;
	if (struct_get(state, "patches")	== undefined) return false;
	if (struct_get(state, "labels")		== undefined) return false;
	
	return true;
}

/**
 * Executes program in state, step by step
 * @param {struct.TolinState} state TolinState
 * @param {Real} start Where to begin reading the program
 */
function program_execute(state, start) {
	var program    = state.program;
	var env        = state.env;
	var labels     = state.labels;
	
	var stack      = [];
	var callStack  = [];
	var len        = array_length(program);

	for (var i = start; i >= 0 && i < len; i++) {
		var op = program[i];
		
		switch (op.type) {
		    case TOLIN_OP_TYPE.Push:
			    array_push(stack, op.value);
				break;
				
			case TOLIN_OP_TYPE.Equal:
			    var a = array_pop(stack);
			    var b = array_pop(stack);
				
				if (a == undefined || b == undefined) {
					tolin_error(op, "comparison requires two values");
					break;
				}
				
				array_push(stack, (b == a) ? 1 : 0);
				break;

		    case TOLIN_OP_TYPE.Plus:
			    var a = array_pop(stack);
			    var b = array_pop(stack);
				
				if (a == undefined || b == undefined) {
					tolin_error(op, "addition requires two values");
					break;
				}
				
				array_push(stack, b + a);
				break;

		    case TOLIN_OP_TYPE.Sub:
			    var a = array_pop(stack);
			    var b = array_pop(stack);
				
				if (a == undefined || b == undefined) {
					tolin_error(op, "subtraction requires two values");
					break;
				}
				
				array_push(stack, b - a);
				break;

		    case TOLIN_OP_TYPE.Mul:
				var a = array_pop(stack);
				var b = array_pop(stack);
				
				if (a == undefined || b == undefined) {
					tolin_error(op, "multiplication requires two values");
					break;
				}
				
				array_push(stack, b * a);
				break;

		    case TOLIN_OP_TYPE.Div:
			    var a = array_pop(stack);
			    var b = array_pop(stack);
				
				if (a == undefined || b == undefined) {
					tolin_error(op, "division requires two values");
					break;
				}
				
			    if (a == 0) {
			        tolin_error(op, "division by zero");
			        break;
			    }
				
				array_push(stack, b / a);
				break;

		    case TOLIN_OP_TYPE.Dup:
				var val = stack[array_length(stack) - 1];
				if (val == undefined) {
					tolin_error(op, $"stack is empty");
				}
				array_push(stack, val);
				break;

		    case TOLIN_OP_TYPE.GT:
				var a = array_pop(stack);
				var b = array_pop(stack);
				
				if (a == undefined || b == undefined) {
					tolin_error(op, "greater than requires two values");
					break;
				}
				
				array_push(stack, (b > a));
				break;

		    case TOLIN_OP_TYPE.GE:
			    var a = array_pop(stack);
			    var b = array_pop(stack);
				
				if (a == undefined || b == undefined) {
					tolin_error(op, "greater or equal requires two values");
					break;
				}
				
				array_push(stack, (b >= a));
				break;

		    case TOLIN_OP_TYPE.LT:
				var a = array_pop(stack);
				var b = array_pop(stack);
				
				if (a == undefined || b == undefined) {
					tolin_error(op, "less than requires two values");
					break;
				}
				
				array_push(stack, (b < a));
				break;

		    case TOLIN_OP_TYPE.LE:
				var a = array_pop(stack);
				var b = array_pop(stack);
				
				if (a == undefined || b == undefined) {
					tolin_error(op, "less or equal requires two values");
					break;
				}
				
				array_push(stack, (b <= a));
				break;

		    case TOLIN_OP_TYPE.StructCreate:
				array_push(stack, {});
				break;
			
			case TOLIN_OP_TYPE.StructSet:
			    var value = array_pop(stack);
			    var key   = array_pop(stack);
			    var obj   = array_pop(stack);

			    if (!is_string(key)) {
			        key = string(key);
			    }

			    switch (typeof(obj)) {
			        case "struct":
			            obj[$ key] = value;
			            array_push(stack, obj);
			            break;

			        case "ref":
			            variable_instance_set(obj, key, value);
			            array_push(stack, obj);
			            break;

			        default:
			            tolin_error(
			                op,
			                $"{obj} is not a struct or reference"
			            );
			            break;
			    }

			    break;
			
		    //case TOLIN_OP_TYPE.StructSet:
			//	var value = array_pop(stack);
			//	var key   = array_pop(stack);
			//	var obj   = array_pop(stack);
			
			//	if (!is_string(key)) key = string(key);
			
			//	switch (typeof(obj)) {
			//		case "struct":
			//			obj[$ key] = value;
			//			array_push(stack, obj);
					
			//			break;
				
			//		case "ref":
			//			variable_instance_set(obj, key, value);
			//			array_push(stack, obj);
					
			//			break;
				
			//		default:
			//			tolin_error(op, $"{obj} is not a struct or reference"); 
			//			break;
			//	}
			
			//	break;
				
		    case TOLIN_OP_TYPE.ArrayCreate:
				array_push(stack, []);
				break;

		    case TOLIN_OP_TYPE.ArrayAppend:
				var value = array_pop(stack);
				var arr   = stack[array_length(stack) - 1];
				
				array_push(arr, value);
				break;
		
			case TOLIN_OP_TYPE.GetKey:
				break;
		
			case TOLIN_OP_TYPE.Get:
				var key = array_pop(stack);
				var obj = array_pop(stack);
			
				switch (typeof(obj)) {
					case "struct":
						var value = obj[$ key];
						array_push(stack, value);
						
						break;
					
					case "array":
						var value = obj[key];
						array_push(stack, value);
						
						break;
				
					case "ref":
						var value = variable_instance_get(obj, key);
						array_push(stack, value);
					
						break;
					
					default:
						tolin_error(op, "trying to get impossible value");
						break;
				}
				break;
			
		    case TOLIN_OP_TYPE.Dump:
				var s = array_pop(stack);
				
				if (s == undefined) {
					tolin_error(op, "stack is empty");
					break;
				}
				
				s = string(s);
			    s = string_replace_all(s, "\n", "");
			    s = string_replace_all(s, "\r", "");
				print(s);
				break;

		    case TOLIN_OP_TYPE.Store:
				var val = array_pop(stack);
				if (val == undefined) {
					tolin_error(op, $"stack is empty");
					break;
				}
				struct_set(env, op.value, val);
				break;

		    //case TOLIN_OP_TYPE.Load:
			//    var val = struct_get(env, op.value);
			//    if (val != undefined) {
			//        array_push(stack, val);
			//    } else {
			//		tolin_error(op, $"variable '{op.value}' does not exist.");
			//	}
			//	break;
			
			case TOLIN_OP_TYPE.Load:
			    var val = struct_get(env, op.value);

			    if (val != undefined) {
			        array_push(stack, val);
			        break;
			    }

			    // NEW: fall back to functions table so bare identifiers
			    // referring to functions resolve to a callable value.
			    if (struct_exists(state.functions, op.value)) {
			        var fn = state.functions[$ op.value];

			        if (is_struct(fn)) {
			            // builtin function -> push the real GML function reference
			            array_push(stack, fn.func);
			        } else {
			            // user-defined tolin function (bytecode entry point)
			            // -> wrap it so it's callable like a normal function
			            var callable = method(
			                { _state: state, _entry: fn },
			                function() { return program_execute(_state, _entry); }
			            );
			            array_push(stack, callable);
			        }
			        break;
			    }

			    tolin_error(op, $"variable '{op.value}' does not exist.");
			    break;

		    case TOLIN_OP_TYPE.And:
			    var a = array_pop(stack);
			    var b = array_pop(stack);
				
				if (a == undefined || b == undefined) {
					tolin_error(op, "AND comparison requires two values");
					break;
				}
				
			    array_push(stack, (b && a));
				break;

		    case TOLIN_OP_TYPE.Or:
			    var a = array_pop(stack);
			    var b = array_pop(stack);
				
				if (a == undefined || b == undefined) {
					tolin_error(op, "OR comparison requires two values");
					break;
				}
				
				array_push(stack, (b || a));
				break;

		    case TOLIN_OP_TYPE.Not:
			    var a = array_pop(stack);
				
				if (a == undefined) {
					tolin_error(op, "NOT comparison requires two values");
					break;
				}
				
				array_push(stack, (a == 0) ? 1 : 0);
				break;
			
			case TOLIN_OP_TYPE.Jump:
				i = op.value - 1;
				break;

			case TOLIN_OP_TYPE.JumpIfFalse:
				var condition = array_pop(stack);
				
				if (!condition) {
				i = op.value - 1;
				}
				break;
			
			case TOLIN_OP_TYPE.CallStack:
				var fn = array_pop(stack);
				
				if (is_callable(fn)) {
					fn();
				} else {
					tolin_error(op, "function is undefined");
				}
				break;
			
			case TOLIN_OP_TYPE.Call:
				var target = op.value;
				var fn;
				
				if (is_string(target)) {
					if (!struct_exists(state.functions, target)) {
						tolin_error(op, "unknown function: " + target);
					}
					fn = state.functions[$ target];
				}
				
				// builtin
				if (is_struct(fn)) {
					var argc = fn.argc;
					var args = array_create(argc);
						
					for (var a = argc - 1; a >= 0; a--) {
						args[a] = array_pop(stack);
					}

					var ret = method_call(fn.func, args);

					if (ret != undefined) {
						array_push(stack, ret);
					}
				} else {
					// bytecode function
					array_push(callStack, i);
					i = fn - 1;
				}
				break;
			
			case TOLIN_OP_TYPE.Ret:
				if (array_length(callStack) == 0) {
					return;
				}

				var ret = array_pop(callStack);
				if (ret < 0 || ret >= len) {
					return;
				}

				i = ret;
				break;
			
		    case TOLIN_OP_TYPE.Exit:
			    if (array_length(stack) > 0) {
			        return array_pop(stack);
			    }
			    return undefined;

		}
	}
}

/**
 * Runs entire state code
 * @param {struct.TolinState} state TolinState
 */
function program_run(state) {
	program_execute(state, 0);
}

/**
 * Calls for a specific function in state
 * @param {struct.TolinState} state TolinState
 * @param {string} name Function name
 */
function program_call(state, entry) {
	if (!struct_exists(state.functions, entry)) {
		show_error("Tolin ERR: Function '" + string(entry) + "' does not exist!", true);
		return;
	}
	return program_execute(state, state.functions[$ entry]);
}

/**
 * Reads a .tolin file and translates it into the states program, making it executable
 * @param {struct.TolinState} state TolinState
 * @param {string} path Path to file
 * @param {bool} verbose prints interpretation process to the console
 * @return {string} Returns content of the file as a string
 */
function tolin_load_file(state, path) {
	if (state == undefined) {
		show_error("Tolin ERR: state is undefined", true);
		return;
	}
	
	if (!file_exists(path)) {
		show_error($"Tolin ERR: path ./{path} doesn't exist", true);
		return;
	}
	
	var FILE = file_text_open_read(path);
	var content = "";
	
	while (!file_text_eof(FILE)) {
		content += file_text_readln(FILE);
	}
	
	file_text_close(FILE);
	state.code += "\n"+content+"\n";
}

function tolin_add_code(state, str) {
	if (state == undefined) {
		show_error("Tolin ERR: state is undefined", true);
		return;
	}
  
	state.code += "\n"+str+"\n";
}

/**
 * Reads a .tolin file and translates it into the states program, making it executable
 * @param {struct.TolinState} state TolinState
 * @param {string} path Path to file
 * @param {bool} verbose prints interpretation process to the console
 * @returns {string} Returns content of the file as a string
 */
function tolin_interpret(state, verbose = false) {
	if (state == undefined) {
		show_error("Tolin ERR: state is undefined", true);
		return;
	}
  
	var content = state.code;
  
	var tokens = tolin_lexer(state, content);
	tolin_parser(state, tokens);

	if (verbose) {
		var col = function(str, w) {
			str = string(str);
			var len = string_length(str);
			if (len < w) {
				str += string_repeat(" ", w - len);
			}
			return str;
		}
		
		print("");
		print("=========== TOKENS =============");
	
		for (var i = 0; i < array_length(tokens); i++) {
			var t = tokens[i];
			
			var line =
	        col("Tolin_Token " + string(i), 8) + " | " +
	        col("name: " + t.name, 20) + " | " +
	        col("value: " + string(t.value), 30) + " | " +
	        col("line: " + string(t.line), 6);
			
			print(line);
		}
	
		print("");
		print("=========== PROGRAM ============");
	
		for (var i = 0; i < array_length(state.program); i++) {
			var ins = state.program[i];
		    var name = TOLIN_OP_NAME[ins.type];

		    var value = "";
		    if (variable_struct_exists(ins, "value")) {
				value = string(ins.value);
		    }
			
			var line =
	        col("Instr. " + string(i), 8) + " | " +
	        col(name, 20) + " | " +
	        col(value, 30);

		    print(line);
		}
		print("");
		print("============ print ============");
	}
}

/**
 * Runs entire state code
 * @param {struct.TolinState} state TolinState
 */
function tolin_run(state, verbose=false) {
	tolin_interpret(state, verbose);
	program_run(state);
}

/**
 * Calls for a specific function in state
 * @param {struct.TolinState} state TolinState
 * @param {string} name Function name
 */
function tolin_call(state, name) {
	program_call(state, name);
}

/**
 * Loads the built-in functions from Tolin_BuiltInFunctions to the states default functions
 * @param {struct.TolinState} state TolinState
 * @param {id.dsmap} map Function map
 */
function tolin_load_builtin_functions(state, map) {
	var keys = ds_map_keys_to_array(map);

	for (var i = 0; i < array_length(keys); i++) {
		var name = keys[i];
		var builtin = map[? name];

		state.functions[$ name] = {
		    type: "builtin",
		    func: builtin.func,
		    argc: builtin.argc
		};
	}
}

function tolin_load_constants(state) {
	tolin_set_variable(state, "Main", Main);
	tolin_set_variable(state, "Spaceship", Spaceship);
	tolin_set_variable(state, "Camera", Camera);
	tolin_set_variable(state, "World", World);
	
	tolin_set_variable(state, "INPUT_ALT", INPUT_ALT);
	tolin_set_variable(state, "INPUT_CTRL", INPUT_CTRL);
	tolin_set_variable(state, "INPUT_CTRL_ALT", INPUT_CTRL_ALT);
	tolin_set_variable(state, "INPUT_CTRL_SHIFT", INPUT_CTRL_SHIFT);
	tolin_set_variable(state, "INPUT_SHIFT", INPUT_SHIFT);
	
	tolin_set_variable(state, "Vela_Theme", Vela_Theme);
}

function tolin_builtin(){

	globalvar Tolin_BuiltInFunctions;
	Tolin_BuiltInFunctions = ds_map_create();
	
	function tolin_register_function(name, argc, func=function(){}) {
		Tolin_BuiltInFunctions[? name] = {
			func : func,
			argc : argc,
		};
	}

	function tolin_get_function(name) {
		if (!ds_map_exists(Tolin_BuiltInFunctions, name)) {
			return false;
		}
		return Tolin_BuiltInFunctions[? name];
	}

	function tolin_run_function(func, args=[]) {
		return method_call(func, args, 0, array_length(args));
	}
	
	/**
	 * Set global function in tolin state
	 * @param {struct.TolinState} state Tolin state
	 * @param {string} name function name
	 * @param {real} argc argument count
	 * @param {function} func function
	 */
	function tolin_set_function(state, name, argc, func) {
		if (!tolin_state_exists(state)) return;
		state.functions[$ name] = {
			type : "builtin",
			func : func,
			argc : argc,
		};
	}
	
	/**
	 * Set global function in tolin state
	 * @param {struct.TolinState} state Tolin state
	 * @param {string} name varaible name
	 * @param {any*} val variable value
	 */
	function tolin_set_variable(state, name, val) {
		if (!tolin_state_exists(state)) return;
		struct_set(state.env, name, val);
	}
	
	#region All built-in functions
	
	// general
	tolin_register_function("game_end", 0, game_end);
	tolin_register_function("game_restart", 0, game_restart);
	
	// Arrays
	tolin_register_function("length", 1,	array_length);
	tolin_register_function("push",	2,		array_push);
	tolin_register_function("insert", 3,	array_insert);
	
	tolin_register_function("typeof", 1, typeof);
	
	// Mouse
	tolin_register_function("mouse_check", 1, mouse_check_button);
	tolin_register_function("mouse_check_pressed", 1, mouse_check_button_pressed);
	tolin_register_function("mouse_check_released", 1, mouse_check_button_released);
	
	// Keyboard
	tolin_register_function("keyboard_check_pressed", 1, function(key){
		if (is_string(key)) {
			key = string_upper(key);
			key = ord(key);
		}
		return keyboard_check_pressed(key);
	});
	
	tolin_register_function("keyboard_check_released", 1, function(key){
		if (is_string(key)) {
			key = string_upper(key);
			key = ord(key);
		}
		return keyboard_check_released(key);
	});
	
	tolin_register_function("keyboard_check", 1, function(key){
		if (is_string(key)) {
			key = string_upper(key);
			key = ord(key);
		}
		return keyboard_check(key);
	});
	
	// String
	tolin_register_function("to_string", 1, string);
	
	// Math
	tolin_register_function("abs", 1, abs);
	tolin_register_function("sign", 1, sign);
	tolin_register_function("sqrt", 1, sqrt);
	tolin_register_function("sqr", 1, sqr);
	tolin_register_function("exp", 1, exp);
	tolin_register_function("ln", 1, ln);
	tolin_register_function("log10", 1, log10);
	tolin_register_function("sin", 1, sin);
	tolin_register_function("cos", 1, cos);
	tolin_register_function("tan", 1, tan);
	tolin_register_function("arcsin", 1, arcsin);
	tolin_register_function("arccos", 1, arccos);
	tolin_register_function("arctan", 1, arctan);
	tolin_register_function("arctan2", 2, arctan2);
	tolin_register_function("degtorad", 1, degtorad);
	tolin_register_function("radtodeg", 1, radtodeg);
	tolin_register_function("power", 2, power);
	tolin_register_function("min", 2, min);
	tolin_register_function("max", 2, max);
	tolin_register_function("clamp", 3, clamp);
	tolin_register_function("lerp", 3, lerp);
	tolin_register_function("floor", 1, floor);
	tolin_register_function("ceil", 1, ceil);
	tolin_register_function("round", 1, round);
	tolin_register_function("frac", 1, frac);
	tolin_register_function("random", 1, random);
	tolin_register_function("random_range", 2, random_range);
	tolin_register_function("irandom", 1, irandom);
	tolin_register_function("irandom_range", 2, irandom_range);
	tolin_register_function("randomise", 0, randomise);
	
	//tolin_register_function("", );
	
	#endregion
	
	tolin_register_function("ord", 1, ord);
	
	#region Project Specific
	
	tolin_register_function("log", 1, log);
	
	tolin_register_function("input_set", 4, Input.Bind.Set);
	
	#endregion
	
}
