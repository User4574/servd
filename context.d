import
	std.socket,
	std.file,
	std.string,
	std.format,
	std.stdio;
import
  serverutils;

enum ClientState {
	START,
	REQUEST_LINE,
	HEADER_LINES,
	DONE,
	ERROR
};

class Request {
	string method;
	string path;
	string vers;
	char[][] header_lines;
	auto this(char[] line) {
		line = strip(line);
		formattedRead(line, "%s %s %s", &method, &path, &vers);
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
					state
					break;
				case ClientState.HEADER_LINES:
					if (inRoot(request.path))
						pair.send(readText(request.path));
					else
						pair.send("ERROR: Client left root!\n");
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
