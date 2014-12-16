package asgl.shaders.scripts.compiler {
	public class CodeSegmentParser implements ICodeSegmentParser {
		private var _hasOperatorReg:RegExp;
		
		public function CodeSegmentParser() {
			_hasOperatorReg = /[\+\-\*\/\,\)\＝\≠\<\>\≤\≥\＆\｜\!]/;
		}
		public function parse(code:String, scope:String, functionTable:FunctionTable, isParams:Boolean=false):Vector.<CodeSegment> {
			var css:Vector.<CodeSegment> = new Vector.<CodeSegment>();
			
			var curCss:Vector.<CodeSegment>;
			if (isParams) {
				var tmpCs:CodeSegment = new CodeSegment();
				curCss = new Vector.<CodeSegment>();
				tmpCs.bodies = curCss;
				css.push(tmpCs);
			} else {
				curCss = css;
			}
			
			var cs:CodeSegment;
			
			var len:uint = code.length;
			var count:int = 0;
			var start:int = 0;
			var index:int = -1;
			var prev:String = null;
			
			for (var i:uint = 0; i < len; i++) {
				var s:String = code.charAt(i);
				
				if (isParams && count == 0 && prev == ',' && curCss.length > 0) {
					tmpCs = new CodeSegment();
					curCss = new Vector.<CodeSegment>();
					tmpCs.bodies = curCss;
					css.push(tmpCs);
				}
				
				if (s == '(') {
					count++;
					if (count == 1) index = i;
				} else if (i + 1 == len || s.search(_hasOperatorReg) == 0) {
					if (s == OperatorSymbol.SUB) {
						if (prev == null || prev.search(/[\+\-\*\/]/) == 0) {
							continue;
						}
					} else if (s == OperatorSymbol.IS_NOT) {
						if (prev == null || prev.search(/[\+\-\*\/]/) == 0) {
							continue;
						}
					}
					
					if (s.search(_hasOperatorReg) == 0 && prev == ')' && count == 0) {
						start++;
						index++;
						
						continue;
					}
					
					var isBracket:Boolean = s == ')';
					if (isBracket) {
						count--;
					}
					
					if (count == 0) {
						var offset:int = isBracket ? 1 : 0;
						
						cs = new CodeSegment();
						cs.name = code.substring(start, index);
						
						if (cs.name.charAt(0) == ',') {
							cs.name = cs.name.substr(1);
						}
						
						if (cs.name.search(_hasOperatorReg) == 0) {
							cs.operator = cs.name.charAt(0);
							cs.name = cs.name.substr(1);
						}
						
						var endIndex:int = i;
						if (!isBracket && i + 1 == len) {
							endIndex++;
						}
						
						var body:String = code.substring(index + offset, endIndex);
						
						var isBreakBody:Boolean = false;
						if (!isBracket) {
							switch (body.charAt(0)) {
								case OperatorSymbol.SUB :
									if (!Util.isNumber(body, null)) {
										isBreakBody = true;
										cs.name = BaseFunctionType._NEG;
									}
									break;
								case OperatorSymbol.IS_NOT :
									isBreakBody = true;
									cs.name = BaseFunctionType._IS_NOT;
									break;
							}
							
							if (isBreakBody) {
								body = body.substr(1);
								cs.bodies = parse(body, scope, functionTable, true);
							}
						}
						
						if (!isBreakBody) {
							if (isBracket) {
								cs.bodies = parse(body, scope, functionTable, cs.name.length > 0);
							} else {
								var variable:Variable = new Variable();
								cs.body = variable;
								
								index = body.search(/\./);
								if (index != -1) {
									cs.component = body.substr(index + 1);
									body = body.substr(0, index);
								}
								
								variable.setValue(body);
								variable.setName(scope, variable.name);
							}
						}
						
						if (isBracket) {
							i++;
							
							var next:String = code.charAt(i);
							if (next == OperatorSymbol.POINT) {
								index = code.substr(i + 1).search(_hasOperatorReg);
								if (index == -1) index = int.MAX_VALUE;
								cs.component = code.substr(i+1, index);
								
								if (index == int.MAX_VALUE) {
									i = index - 1;
								} else {
									i += 1 + index;
								}
							}
							
							s = code.charAt(i);
						}
						
						start = i;
						index = start + 1;
						
						curCss.push(cs);
					}
				}
				
				prev = s;
			}
			
			if (css.length > 0) {
				if (css[0].operator == OperatorSymbol.SUB) {
					cs = new CodeSegment();
					cs.name = BaseFunctionType._NEG;
					cs.bodies = new Vector.<CodeSegment>();
					cs.bodies[0] = css[0];
					css[0].operator = null;
					css[0] = cs;
				}
			}
			
			return css;
		}
	}
}