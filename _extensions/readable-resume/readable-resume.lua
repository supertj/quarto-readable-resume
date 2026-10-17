-- Turns the resume markdown into calls to the functions in typst-template.typ.

local stringify = pandoc.utils.stringify

local entry_functions = { "education", "experience", "activity" }

-- Name and contact go to Typst as plain strings rather than through the
-- template: the template would hand over Typst markup, and escapes like
-- "\@" in an email address aren't valid inside a Typst string. The contact
-- line also only turns strings into links, not content.
local function typst_string(text)
  local escaped = text:gsub("\\", "\\\\"):gsub('"', '\\"')
  return '"' .. escaped .. '"'
end

-- Entry fields are read as markdown, so "--" becomes a dash and characters
-- that mean something in Typst ($, #, @) come out escaped.
local function typst_content(markdown)
  local inlines = pandoc.utils.blocks_to_inlines(pandoc.read(markdown, "markdown").blocks)
  local typst = pandoc.write(pandoc.Pandoc({ pandoc.Plain(inlines) }), "typst", { wrap_text = "none" })
  return "[" .. typst:gsub("%s+$", "") .. "]"
end

function Meta(meta)
  if meta.name then
    meta.name = pandoc.RawInline("typst", typst_string(stringify(meta.name)))
  end
  if meta.contact then
    local items = meta.contact
    if pandoc.utils.type(items) ~= "List" then
      items = { items }
    end
    local strings = {}
    for _, item in ipairs(items) do
      table.insert(strings, typst_string(stringify(item)))
    end
    -- The trailing comma keeps a single item an array in Typst.
    meta.contact = pandoc.RawInline("typst", "(" .. table.concat(strings, ", ") .. ",)")
  end
  return meta
end

-- ::: {.experience company="..." title="..."} becomes
-- #experience(company: [...], title: [...])[ bullets ]
function Div(div)
  for _, function_name in ipairs(entry_functions) do
    if div.classes:includes(function_name) then
      local arguments = {}
      for key, value in pairs(div.attributes) do
        table.insert(arguments, key .. ": " .. typst_content(value))
      end
      local call = "#" .. function_name .. "(" .. table.concat(arguments, ", ") .. ")"
      if #div.content == 0 then
        return pandoc.RawBlock("typst", call)
      end
      local blocks = pandoc.Blocks({ pandoc.RawBlock("typst", call .. "[") })
      blocks:extend(div.content)
      blocks:insert(pandoc.RawBlock("typst", "]"))
      return blocks
    end
  end
end
