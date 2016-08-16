-- function curry (func, num_args)
--   num_args = num_args or debug.getinfo(func, "u").nparams
--   if num_args < 2 then return func end
--   local function helper (argtrace, n)
--     if n < 1 then
--       return func (table.unpack (flatten (argtrace)))
--     else
--       return function (...)
--         return helper ({argtrace, ...}, n - select("#", ...))
--       end
--     end
--   end
--   return helper ({}, num_args)
-- end

-- function flatten (t)
--   local result = {}
--   for _, v in ipairs(t) do
--     if type(v) == 'table' then
--       for _, fv in ipairs(flatten(v)) do
--         result[#result + 1] = fv
--       end
--     else
--       result[#result + 1] = v
--     end
--   end
--   return result
-- end

function curry (func, num_args)
   num_args = num_args or debug.getinfo(func, "u").nparams
   if num_args < 2 then return func end
   local function helper (argtrace, n)
      if n < 1 then
         return func (table.unpack (flatten(argtrace)))
      else
         return function (...)
            return helper ({argtrace, ...}, n - select("#", ...))
         end
      end
   end
   return helper ({}, num_args)
end

function flatten (t)
   local result = {}
   for i, v in ipairs(t) do
      if type(v) == "table" and i == 1 then
         for _, fv in ipairs(flatten(v)) do
            result[#result + 1] = fv
         end
      else
         result[#result + 1] = v
      end
   end
   return result
end

function add (a,b)
   return a + b
end

function subtract (a,b)
   return a - b
end

function negate (a)
   return -a
end

function map (g, t)
   -- assert(type(t) == "table", "expected table in position 2")
   return foldl(
      function (a, acc)
         acc[#acc + 1] = g(a)
         return acc
      end,
      {}, t)
end

function filter (g, t)
   -- assert(type(t) == "table", "expected table in position 2")
   return foldl(
      function (a, acc)
         if g(a) then
            acc[#acc + 1] = a
            return acc
         else
            return acc
         end
      end,
      {}, t)
end

function append (x, xs)
   assert(type(xs) == "table", "expected table in position 2")
   xs[#xs + 1] = x
   return xs
end

function foldl (g, acc, t)
   for _, v in ipairs(t) do
      acc = g (v, acc)
   end
   return acc
end

function all (cmp, t)
   return foldl (
      function (a, acc)
         if cmp(a) then
            return acc
         else
            return false
         end
      end,
      true, t)
end

function concat(t)
   local result = {}
   for _, row in ipairs(t) do
      for _, item in ipairs(row) do
         result[#result + 1] = item
      end
   end
   return result
end

function range (low, high, step)
   local result = {}
   for i=low, high, (step or 1) do
      result[#result + 1] = i
   end
   return result
end

function transpose (t)
   local result = {}
   for y=1,#t do
      result[#result + 1] = {}
      for x=1,#t do
         result[y][x] = t[x][y]
      end
   end
   return result
end

function compose(...)
   if #{...} == 2 then
      return compose2(...)
   else
      return compose(
         compose2( ({...})[#{...}], ({...})[#{...} - 1] ),
         table.unpack( delete( delete( {...}, #{...} ), #{...} - 1 ))
      )
   end
end

-- compose2 : (b -> c) -> (a -> b) -> (a -> c)
function compose2 (g, f)
   return function (a)
      return g (f (a))
   end
end

function clone (t)
   local result = {}
   for k,v in pairs(t) do
      if type(v) == "table" then
         result[k] = clone (v)
      else
         result[k] = v
      end
   end
   return result
end

function delete (t, i)
   local result = clone(t)
   table.remove(result, i)
   return result
end

return {
   curry = curry,
   foldl = curry(foldl),
   map = curry(map),
   all = curry(all),
   filter = curry(filter),
   enumFromTo = range,
   compose = compose,
   compose2 = compose2,
   add = curry(add),
   subtract = curry(subtract)
}
