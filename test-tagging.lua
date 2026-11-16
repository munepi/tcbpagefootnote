-- test-tagging.lua
-- ================
-- Check of the structure tree of a tagged PDF made by test-tagging.tex:
-- the footnote (FENote) of a footnote mark (Lbl) must be the next
-- sibling of the mark, as for \footnote in the body text (empty marked
-- content between them, as written by pdfTeX and XeTeX, is skipped).
--
--   texlua test-tagging.lua <pdf file>
--
-- Reads the output of show-pdf-tags and prints
--   TPF-TAGS: <p> paired, <u> unpaired
-- where <p> marks are directly followed by their FENote and <u> are not
-- (a \footnotemark whose \footnotetext comes later is unpaired), and a
-- "TPF-TAGS unpaired: ..." line for each unpaired mark.

local pdf = arg[1]
if not pdf then
  io.stderr:write("usage: texlua test-tagging.lua <pdf file>\n")
  os.exit(2)
end

local p = io.popen('show-pdf-tags "' .. pdf .. '" 2>&1')
local lines = {}
for l in p:lines() do lines[#lines + 1] = l end
p:close()

-- The characters of the tree drawn by show-pdf-tags
local tree = {
  [utf8.codepoint("│")] = true, [utf8.codepoint("├")] = true,
  [utf8.codepoint("└")] = true, [utf8.codepoint("─")] = true,
  [utf8.codepoint(" ")] = true,
}

-- The depth (number of tree characters before the node) and the node
-- text of a line that starts a node ("├─" or "└─"), or nil
local function node(l)
  local n, pos = 0, 1
  for i, c in utf8.codes(l) do
    if not tree[c] then pos = i; break end
    n = n + 1
    pos = nil
  end
  if not pos then return nil end
  local before = l:sub(1, pos - 1)
  if not (before:find("├─$") or before:find("└─$")) then return nil end
  return n, l:sub(pos)
end

local paired, unpaired = 0, 0
for i, l in ipairs(lines) do
  local d, text = node(l)
  if d and text:find("^footnotemark ") and text:find("/ Lbl ") then
    local ok = false
    for j = i + 1, #lines do
      local dj, tj = node(lines[j])
      if dj and dj <= d
         and not (dj == d and tj:find("^Marked content on page %d+: *$")) then
        ok = (dj == d) and tj:find("^footnote ") and tj:find("/ FENote ")
        break
      end
    end
    if ok then
      paired = paired + 1
    else
      unpaired = unpaired + 1
      -- the text of the mark, for the log
      local mark = ""
      for j = i + 1, #lines do
        local m = lines[j]:match("Marked content on page %d+: (.*)$")
        if m and m:find("%S") then mark = m; break end
      end
      print("TPF-TAGS unpaired: mark " .. mark .. " (line " .. i .. ")")
    end
  end
end
print(string.format("TPF-TAGS: %d paired, %d unpaired", paired, unpaired))
