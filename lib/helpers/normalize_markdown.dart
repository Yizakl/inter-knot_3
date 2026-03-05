String normalizeMarkdown(String input) {
  var out = input;
  // Remove stray selectable-region context menu divs captured from web.
  out = out.replaceAll(
    RegExp('<div class="web-selectable-region-context-menu"[^>]*></div>'),
    '',
  );
  // Unescape common markdown escapes that break image parsing.
  out = out.replaceAllMapped(
    RegExp(r'\\([\\`*_{}\[\]()#+\-.!])'),
    (m) => m[1]!,
  );
  // Fix nested link pattern: ![alt]([url](url)) (allow whitespace/newlines).
  out = out.replaceAllMapped(
    RegExp(
      r'!\[([^\]]*)\]\(\[([^\]]+)\]\s*\(([^)\s]+)\)\s*\)+(?=\s|$)',
    ),
    (m) => '![${m[1]}](${m[3]})',
  );
  // Fix malformed image markdown with an extra trailing ')', allow whitespace.
  out = out.replaceAllMapped(
    RegExp(r'!\[([^\]]*)\]\(([^)\s]+)\)\s*\)+(?=\s|$)'),
    (m) => '![${m[1]}](${m[2]})',
  );
  // Collapse excessive newlines from DeltaToMarkdown (3+ -> 2), keeping
  // standard paragraph separators (\n\n) intact.
  out = out.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  return out;
}