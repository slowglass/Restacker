local MAJOR, MINOR = "LibLang-0.1", 1
local LibLang, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
local ll_lang = "en"
local ll_langBundle = {}
if not LibLang then return end	 

local function ll_print(self, key, ...)
	d(LocalizeString(self.langBundle[self.lang][key], ...))
end

local function ll_setLang(self, lang)
	self.lang = lang
end


local function ll_addBundle(self, lang, bundle)
	if (self.langBundle==nil) then self.langBundle = {} end
	self.langBundle[lang] = bundle
end


local metaTable = {
	__index = {
		setLang = ll_setLang,
		print = ll_print,
		addBundle = ll_addBundle
	}
}

function table.val_to_str ( v )
  if "string" == type( v ) then
    v = string.gsub( v, "\n", "\\n" )
    if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
      return "'" .. v .. "'"
    end
    return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
  else
    return "table" == type( v ) and table.tostring( v ) or
      tostring( v )
  end
end

function table.key_to_str ( k )
  if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
    return k
  else
    return "[" .. table.val_to_str( k ) .. "]"
  end
end

function table.tostring( tbl )
  local result, done = {}, {}
  for k, v in ipairs( tbl ) do
    table.insert( result, table.val_to_str( v ) )
    done[ k ] = true
  end
  for k, v in pairs( tbl ) do
    if not done[ k ] then
      table.insert( result,
        table.key_to_str( k ) .. "=" .. table.val_to_str( v ) )
    end
  end
  return "{" .. table.concat( result, "," ) .. "}"
end

local function ll_setLang(lang)
	d(self)
	self.lang = lang
end

function LibLang.getBundleHandler()
	local obj = {}
	setmetatable(obj, metaTable)
	return obj
end
