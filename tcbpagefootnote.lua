--
-- tcbpagefootnote.lua
-- ===================
-- Page footnotes from inside a breakable tcolorbox (LuaLaTeX).
--
-- Copyright (c) 2026 Munehiro Yamamoto <munepixyz@gmail.com>
--
-- This package is licensed under the conditions of the LaTeX Project
-- Public License, either version 1.3c of this license or (at your
-- option) any later version.  The latest version of this license is in
--   https://www.latex-project.org/lppl.txt
--
-- Loaded by tcbpagefootnote.sty.
--
-- In a breakable box with "page footnote", a footnote text is a real
-- \insert at its mark.  The insertion (an ins node) stays in the box
-- of the content and, when tcolorbox splits this box with \vsplit, in
-- the part of its mark.
--   add_reserves     puts a "reserve" after each insertion: an empty
--                    box that is as high as the insertion will be on
--                    the page, so that tcolorbox counts the footnotes
--                    when it measures and splits the content;
--   update_reserves  sets the heights of the reserves again, before
--                    each part is split off: what an insertion takes
--                    from the page (\count\footins) can differ from
--                    column to column (ftnright);
--   strip            removes the reserves from a part that is about to
--                    be drawn and takes its insertions out;
--   flush            writes these insertions after the part.
--
local M = {}

local ins_id   = node.id("ins")
local hlist_id = node.id("hlist")
local vlist_id = node.id("vlist")

-- The reserves are the boxes with this attribute
local reserve_attr = luatexbase.new_attribute("tcbpagefootnote_reserve")

-- The insertions of the part that is drawn, until they are written
local pending = {}

-- What an insertion takes from the page (as the page builder of TeX
-- computes it), with the \count of its class as it is now
local function ins_height(n)
  local count = tex.count[n.subtype]
  if count == 1000 then return n.height end
  return (n.height // 1000) * count
end

local function is_reserve(n)
  return n.id == hlist_id and node.has_attribute(n, reserve_attr)
end

-- The insertions in a list, also those inside its boxes:
-- whether there are any, and what they take from the page
local function ins_inside(head)
  local found, total = false, 0
  for n in node.traverse(head) do
    local id = n.id
    if id == ins_id then
      found, total = true, total + ins_height(n)
    elseif id == hlist_id or id == vlist_id then
      local f, t = ins_inside(n.list)
      found, total = found or f, total + t
    end
  end
  return found, total
end

-- The insertions of the node n of the list of a box register: of an
-- insertion, or of a box that is not a reserve (see ins_inside)
local function ins_of(n)
  local id = n.id
  if id == ins_id then
    return true, ins_height(n)
  elseif (id == hlist_id or id == vlist_id) and not is_reserve(n) then
    return ins_inside(n.list)
  end
  return false, 0
end

-- Put a reserve after each insertion of the box register b and after
-- each box in it that has insertions inside.  A reserve is not
-- discardable and there is no breakpoint between it and its
-- insertion: they stay together when the box is split.
-- Returns true if the box is changed (it has to be packed again).
local function add_reserves(b)
  local box = tex.box[b]
  if not box or box.id ~= vlist_id then return false end
  local head, changed = box.list, false
  local n = head
  while n do
    local nxt = n.next
    local found, total = ins_of(n)
    if found then
      local r = node.new(hlist_id)
      r.height = total
      node.set_attribute(r, reserve_attr, 1)
      head = node.insert_after(head, n, r)
      changed = true
    end
    n = nxt
  end
  box.list = head
  return changed
end

-- Set the height of each reserve of the box register b again, to what
-- the insertions before it take from the page now.
-- Returns true if a height is changed (the box has to be packed again).
local function update_reserves(b)
  local box = tex.box[b]
  if not box or box.id ~= vlist_id then return false end
  local changed = false
  for n in node.traverse(box.list) do
    local r = n.next
    if r and is_reserve(r) then
      local found, total = ins_of(n)
      if found and r.height ~= total then
        r.height = total
        changed = true
      end
    end
  end
  return changed
end

-- Whether the box register b has a reserve, i.e. a footnote
local function has_reserve(b)
  local box = tex.box[b]
  if not box or box.id ~= vlist_id then return false end
  for n in node.traverse(box.list) do
    if is_reserve(n) then return true end
  end
  return false
end

local function strip_list(head, top)
  local removed, changed = 0, false
  local n = head
  while n do
    local nxt = n.next
    local id = n.id
    if id == ins_id then
      head = node.remove(head, n)
      n.prev, n.next = nil, nil
      pending[#pending + 1] = n
      changed = true
    elseif top and is_reserve(n) then
      removed = removed + n.height
      head = node.remove(head, n)
      node.free(n)
      changed = true
    elseif (id == hlist_id or id == vlist_id) and n.list then
      n.list = strip_list(n.list, false)
    end
    n = nxt
  end
  return head, removed, changed
end

-- Remove the reserves from the box register b and move its insertions
-- (also those inside its boxes) to the pending ones.
-- Returns what the reserves took, and
--   0  if the box is unchanged,
--   1  if it is changed and has to be packed again to its natural size,
--   2  if it is changed and had a given size, which is reduced here.
local function strip(b)
  local box = tex.box[b]
  if not box or box.id ~= vlist_id then return 0, 0 end
  local head, removed, changed = strip_list(box.list, true)
  box.list = head
  if not changed then return 0, 0 end
  if box.glue_sign == 0 then return removed, 1 end
  box.height = box.height - removed
  return removed, 2
end

-- -------------------------------------------------------------------
-- The interface for tcbpagefootnote.sty: the results are printed
-- -------------------------------------------------------------------
-- What the reserves removed by strip took, until it is asked for
local removed_total = 0

-- 1 if the box is changed, else 0
function M.add_reserves(b)
  tex.sprint(add_reserves(b) and 1 or 0)
end

-- 1 if the height of a reserve of the box is changed, else 0
function M.update_reserves(b)
  tex.sprint(update_reserves(b) and 1 or 0)
end

-- 1 if one of the box registers has a reserve, else 0
function M.has_reserve(...)
  for _, b in ipairs({...}) do
    if has_reserve(b) then tex.sprint(1) return end
  end
  tex.sprint(0)
end

-- 0, 1 or 2 as described at strip
function M.strip(b)
  local removed, state = strip(b)
  removed_total = removed_total + removed
  tex.sprint(state)
end

-- What the reserves removed since the last call took (a dimension)
function M.removed()
  tex.sprint(removed_total .. "sp")
  removed_total = 0
end

-- 1 if there are insertions to write, else 0
function M.has_pending()
  tex.sprint(#pending > 0 and 1 or 0)
end

-- Write the pending insertions to the current list
function M.flush()
  local list = pending
  pending = {}
  for i = 1, #list do
    node.write(list[i])
  end
end

return M
