import std.socket, std.conv;
import context;

void main(string[] args) {
	if (args.length != 2) return;
	auto sock = new TcpSocket();
	sock.bind(new InternetAddress("127.0.0.1", to!ushort(args[1])));
	sock.listen(1000);
	while (true) {
		auto pair = sock.accept();
		auto context = new ClientContext(pair);
		context.handle();
		pair.shutdown(SocketShutdown.BOTH);
		pair.close();
	}
}
