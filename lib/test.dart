import 'dart:convert';
import 'dart:io';


class Test {
	static final gzip = GZipCodec();
	static String compress(String s) {
		return base64.encode(gzip.encode(s.codeUnits));
	}
	static List<int> compressI(String s) {
		return gzip.encode(utf8.encode(s));

	}
	static String decompressI(List<int> s) {
		return utf8.decode(gzip.decode(s));
	}
	static String decompress(String s) {
		return utf8.decode(gzip.decode(s.codeUnits));
	}
}

void main(){

	print("test");
	final t = "Hör mir Gut zu Umlaute sind: öäüÖÄÜ";
	print("t");

	print(t);

	final t2=Test.compressI(t);
	print("t2");
	print(t2);
	final t3=Test.decompressI(t2);
	print("t3");
	print(t3);
}
