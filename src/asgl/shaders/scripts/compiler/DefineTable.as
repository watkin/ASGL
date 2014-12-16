package asgl.shaders.scripts.compiler {
	public class DefineTable {
		private var _defineTable:Object;
		private var _customTable:Object;
		private var _replaceTable:Object;
		
		public function DefineTable() {
			_defineTable = {};
			_customTable = {};
			_replaceTable = {};
		}
		public function clear():void {
			for each (var value:* in _customTable) {
				var data:FunctionData = value;
				delete _defineTable[data.name];
			}
			_customTable = {};
			_replaceTable = {};
		}
		public function setDefine(data:FunctionData, isInternal:Boolean):void {
			_defineTable[data.name] = data;
			if (!isInternal) _customTable[data.name] = data;
			
			if (data.name in _replaceTable) data.code = _replaceTable[data.name];
		}
		public function setReplace(name:String, code:String):void {
			_replaceTable[name] = code;
			
			var fd:FunctionData = _defineTable[name];
			if (fd != null) fd.code = code;
			
			fd = _customTable[name];
			if (fd != null) fd.code = code;
		}
		public function staticBranch(code:String):String {
			var ifdefIndex:int = code.indexOf('#ifdef ');
			
			if (ifdefIndex != -1) {
				var sb:StaticBranch = new StaticBranch();
				sb.beforeCode = code.substr(0, ifdefIndex);
				
				var seg:String = code.substr(ifdefIndex + 7);
				var nameIndex:int = seg.indexOf(';');
				
				var ifName:String = seg.substr(0, nameIndex);
				seg = seg.substr(nameIndex + 1);
				sb.defineName = ifName.substring(0, ifName.indexOf(' '));
				
				var endifIndex:int = seg.indexOf('#endif ' + sb.defineName);
				if (endifIndex == -1) throw new Error('not found #endif ' + sb.defineName);
				
				var ifCode:String;
				
				while (true) {
					var elseifIndex:int = seg.indexOf('#elseif ' + sb.defineName);
					
					if (elseifIndex == -1 || elseifIndex > endifIndex) {
						break;
					} else {
						sb.addIfCode(ifName, seg.substr(0, elseifIndex));
						
						seg = seg.substr(elseifIndex + 8);
						
						nameIndex = seg.indexOf(';');
						ifName = seg.substr(0, nameIndex);
						seg = seg.substr(nameIndex + 1);
					}
				}
				
				var elseIndex:int = seg.indexOf('#else ' + sb.defineName);
				if (elseIndex != -1 && elseIndex < endifIndex) {
					sb.addIfCode(ifName, seg.substr(0, elseIndex));
					
					seg = seg.substr(elseIndex + 5);
					
					ifName = null;
				}
				
				endifIndex = seg.indexOf('#endif ' + sb.defineName);
				if (ifName == null) {
					sb.elseCode = seg.substr(0, endifIndex);
				} else {
					sb.addIfCode(ifName, seg.substr(0, endifIndex));
				}
				
				sb.afterCode = seg = seg.substr(endifIndex + 6);
				
				code = sb.beforeCode;
				
				var isFind:Boolean = false;
				
				var len:uint = sb.ifCodes.length;
				for (var i:uint = 0; i < len; i++) {
					var ic:IfCode = sb.ifCodes[i];
					var fd:FunctionData = _defineTable[ic.name];
					
					if (fd == null || fd.code == null) continue;
					
					var fdCode:String = Util.formatSpace(fd.code);
					
					if (ic.equal == null) {
						if (fdCode == 'false' || fdCode == '0') continue;
					} else {
						if (ic.equal != fdCode) continue;
					}
					
					code += ic.code;
					
					isFind = true;
				}
				
				if (!isFind && sb.elseCode != null) code += sb.elseCode;
				
				code += sb.afterCode;
				
				code = staticBranch(code);
			}
			
			return code;
		}
		public function expand(code:String):String {
			var isFind:Boolean = false;
			
			for (var name:String in _defineTable) {
				if (name in _replaceTable) continue;
				var data:FunctionData = _defineTable[name];
				
				var reg:RegExp = new RegExp('\\b' + name + '\\b');
				var index:int = code.search(reg);
				var rightIndex:uint = index + name.length;
				
				//if (index != -1 && code.charAt(index - 1) != '.' && code.charAt(rightIndex) != '.') {
				if (index != -1) {
					isFind = true;
					
					var len:uint = code.length;
					var params:Vector.<String> = new Vector.<String>();
					var paramName:String;
					var count:uint = 0;
					
					if (code.charAt(rightIndex) == '(') {
						for (var i:uint = rightIndex; i < len; i++) {
							var s:String = code.charAt(i);
							if (s == '(') {
								if (count > 0) {
									throw new Error('define error');
								} else {
									paramName = '';
								}
								count++;
							} else if (s == ')') {
								if (count == 0) {
									throw new Error('define error');
								} else {
									rightIndex = i + 1;
									if (paramName != '') params.push(paramName);
									break;
								}
								count--;
							} else if (s.search(/\s/) != 0) {
								if (count == 0) {
									break;
								} else if (s == ',') {
									params.push(paramName);
									paramName = '';
								} else {
									paramName += s;
								}
							}
						}
					}
					
					if (params.length != data.params.length) {
						throw new Error('define error');
					} else {
						var repCode:String = data.code;
						len = params.length;
						for (i = 0; i < len; i++) {
							repCode = repCode.replace(new RegExp('\\b' + data.params[i].name + '\\b', 'g'), params[i]);
						}
						
						code = code.substr(0, index) + repCode + code.substr(rightIndex);
					}
				}
			}
			
			if (isFind) code = expand(code);
			
			return code;
		}
		private function _getBranchDefineName(code:String):Array {
			var name:String = '';
			
			var len:uint = code.length;
			for (var i:uint = 0; i < len; i++) {
				var c:String = code.charAt(i);
				if (c == '\n' || c == '\r') break;
				
				var isSpace:Boolean = c == ' ' || c == '	';
				
				if (name == '') {
					if (isSpace) {
						continue;
					} else {
						name += c;
					}
				} else {
					if (isSpace) {
						break;
					} else {
						name += c;
					}
				}
			}
			
			return [name, i];
		}
	}
}
import asgl.shaders.scripts.compiler.Util;

class IfCode {
	public var name:String;
	public var equal:String;
	public var code:String;
}

class StaticBranch {
	public var defineName:String;
	public var beforeCode:String;
	public var ifCodes:Vector.<IfCode> = new Vector.<IfCode>();
	public var elseCode:String;
	public var afterCode:String;
	
	public function addIfCode(name:String, code:String):void {
		var ic:IfCode = new IfCode();
		ic.name = name;
		ic.code = code;
		
		name = Util.formatSpace(name);
		var index:int = name.indexOf(' ');
		if (index == -1) {
			ic.name = name;
		} else {
			ic.name = name.substr(0, index);
			ic.equal = name.substr(index + 1);
		}
		
		ifCodes.push(ic);
	}
}