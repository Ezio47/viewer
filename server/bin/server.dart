import 'dart:core';
import 'package:watcher/watcher.dart';
import 'proxy.dart';
import 'dart:io';


DirectoryWatcher watcher;

void main() {
    String srcDir = "/Users/mgerlek/work/data";

}


void runWatcher(String srcDir)
{
    final String testfile = srcDir + "/foo";

    if (FileSystemEntity.isFileSync(testfile)) {
        new File(testfile).deleteSync(recursive: false);
        sleep(new Duration(seconds: 1));
    }
    assert(FileSystemEntity.isFileSync(testfile) == false);

    var fs = new ProxyFileSystem.build(srcDir);
    fs.dump();

    // BUG: a file could be added between the initial crawl and the watching becoming ready

    watcher = new DirectoryWatcher(srcDir);

    watcher.events.listen(fs.handleWatchEvent);

    watcher.ready.then((onValue) {
        new File(testfile).createSync(recursive: false);
        print("*3");
        fs.dump();
    });

    print("*4");
}
