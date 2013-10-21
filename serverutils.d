bool inRoot(char[] path) {
  auto level = 0;
  if (path[0] == '/') return false; 
  while (path.length > 0) {
    if (path[0] == '/') {
      level++;
      path = path[1..$];
    } else if (path[0] == '.' && path[1] == '.' && path[2] == '/') {
      level--;
      path = path[3..$];
    } else {
      path = path[1..$];
    }
    if (level < 0) return false;
  }
  return true;
}
