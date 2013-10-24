import
	std.socket,
	std.file,
	std.string,
	std.format,
	std.path;

enum ClientState {
	START,
	REQUEST_LINE,
	END_REQUEST,
	DONE,
	ERROR
};

enum ResponseCode {
	OKAY = 200,
	NOTFOUND = 404,
	NOTIMPLEMENTED = 501
};

class Request {
	string method;
	string path;
	string vers;
	string[] header_lines;
	auto this(char[] line) {
		line = strip(line);
		string tpath;
		formattedRead(line, "%s %s %s", &method, &tpath, &vers);
		if (tpath[0] == '/')
			path = buildNormalizedPath(getcwd() ~ tpath);
		else
			path = buildNormalizedPath(getcwd() ~ "/" ~ tpath);
	}
	ResponseCode check() {
		try {
			bool isfile = path.isFile();
			if (!isfile)
				return ResponseCode.NOTFOUND;
		}
		catch (FileException e) {
			return ResponseCode.NOTFOUND;
		}
		return ResponseCode.OKAY;
	}
}

class ClientContext {
	ClientState state;
	Socket pair;
	Request request;
	auto this(Socket p) {
		pair = p;
		state = ClientState.START;
	}
	void handle() {
		while(true) {
			switch(state) {
				case ClientState.START:
					char[255] line;
					auto len = pair.receive(line);
					auto request_line = line[0 .. len];
					request = new Request(request_line);
					state = ClientState.REQUEST_LINE;
					break;
				case ClientState.REQUEST_LINE:
					char[255] line;
					auto len = pair.receive(line);
					if (len < 3) //FIXME: A better test needed for newline
						state = ClientState.END_REQUEST;
					else {
						auto header_line = line[0 .. len];
						header_line = strip(line);
						request.header_lines ~= cast(string) header_line;
					}
					break;
				case ClientState.END_REQUEST:
					switch (request.check()) {
						case ResponseCode.OKAY:
							pair.send(readText(request.path));
							break;
						case ResponseCode.NOTFOUND:
							pair.send("404 File Not Found");
							break;
						case ResponseCode.NOTIMPLEMENTED:
							pair.send("501 Method Not Implemented");
							break;
						default:
							pair.send("500 Internal Server Error");
							break;
					}
					state = ClientState.DONE;
					break;
				case ClientState.DONE:
					return;
					break;
				default:
					break;
			}
		}
	}
}
