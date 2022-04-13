void main(List<String> args) {
  Map m = {1: "one", 2: "two", 3: "three"};
  print(m);
  List l = [1, 2, 3, 4, 5, 6];
  print(l);
  List l2 = [100, ...l];
  print(l2);
  Map m2 = {100: "hundred", ...m};
  print(m2);
}
