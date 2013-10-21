import std.socket, std.stdio,
       std.conv, std.file,
       std.string;
import serverutils;

void main(string[] args) {
	if (args.length != 2) return;
	auto sock = new TcpSocket();
	sock.bind(new InternetAddress("127.0.0.1", to!ushort(args[1])));
	sock.listen(1000);
	while (true) {
    auto level = 0;
		auto pair = sock.accept();
		char[255] filename;
		auto len = pair.receive(filename);
    auto file = filename[0 .. len];
    file = strip(file);
    if (inRoot(file)) {
  		pair.send(readText(file));
    } else {
      pair.send("ERROR: Client left root!\n");
    }
		pair.shutdown(SocketShutdown.BOTH);
		pair.close();
	}
}
