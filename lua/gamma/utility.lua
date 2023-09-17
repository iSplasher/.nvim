require('compat')

---A helper function to print a table's contents.
---@param tbl table @The table to print.
---@param depth number @The depth of sub-tables to traverse through and print.
---@param n number @Do NOT manually set this. This controls formatting through recursion.
local function print_table(tbl, depth, n)
  n = n or 0;
  depth = depth or 5;

  if (depth == 0) then
    print(string.rep(' ', n) .. "...");
    return;
  end

  if (n == 0) then
    print(" ");
  end

  for key, value in pairs(tbl) do
    if (key and type(key) == "number" or type(key) == "string") then
      key = string.format("[\"%s\"]", key);

      if (type(value) == "table") then
        if (next(value)) then
          print(string.rep(' ', n) .. key .. " = {");
          print_table(value, depth - 1, n + 4);
          print(string.rep(' ', n) .. "},");
        else
          print(string.rep(' ', n) .. key .. " = {},");
        end
      else
        if (type(value) == "string") then
          value = string.format("\"%s\"", value);
        else
          value = tostring(value);
        end

        print(string.rep(' ', n) .. key .. " = " .. value .. ",");
      end
    end
  end

  if (n == 0) then
    print(" ");
  end
end

---A helper function to merge two tables.
---@param a table @The first table to merge.
---@param b table @The second table to merge. (overwrites)
---@return table @The merged table.
local function merge_table(a, b)
  if type(a) == 'table' and type(b) == 'table' then
    for k, v in pairs(b) do if type(v) == 'table' and type(a[k] or false) == 'table' then merge(a[k], v) else a[k] = v end end
  end
  return a
end

---Set a keymap.
---@param mode string @The mode to set the keymap for.
---@param keys string @The keys to set the keymap for.
---@param func string | function @The function to set the keymap for.
---@param desc string | nil @The description to set the keymap for.
---@param opts table | nil @The options to set the keymap for.
local kmap = function(mode, keys, func, desc, opts)
  opts = opts or {}
  if desc then
    desc = '' .. desc
  end

  vim.keymap.set(mode, keys, func, { desc = desc, table.unpack(opts) })
end



return {
  print_table = print_table,
  merge_table = merge_table,
  kmap = kmap,
}
