/// 64-bit FNV-1a hash generator.
/// Used to generate deterministic fast `Id` integers for objectbox databases out of String UUIDs.
/// Source: Developer Bible Architecture Guidelines.
int fastHash(String string) {
  var hash = 0xcbf29ce484222325;
  for (var i = 0; i < string.length; i++) {
    hash ^= string.codeUnitAt(i);
    hash = (hash * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF;
  }
  return hash;
}
