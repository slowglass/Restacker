local MAJOR, MINOR = "LibLang-0.1", 1
local LibLang, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not LibLang then return end	 


local function ll_setLang(lang)
	self.lang = lang
end

local function ll_print(key, ...)
	local args={...}
	local result = ""
	local fmt = self.langBundle[self.lang][key]
	if (fmt == nil) then fmt = self.langBundle['en'][key] end
	if (fmt == nil) then fmt = key end
	local modifier = true

	result = fmt
	local idx
	for idx = 1, #args do
		local arg = args[idx]
		if (arg==nil) then arg = "" end
		result = result:gsub("%%"..idx, arg)
    end
    return result
end

local function ll_addBundle(lang, bundle)
	d ("Lang is "..lang)
	if (self.langBundle==nil) then self.langBundle = {} end
	self.langBundle[lang] = bundle
	d(lang)
	d(bundle["CMD_ERR"])
	d(self.langBundle[lang]["CMD_ERR"])
end

local metaTable = {
	__index = {
		setLang = ll_setLang,
		print = ll_print,
		addBundle = ll_addBundle
	}
}


function LibLang:getBundleHandler()
	local obj = {}
	setmetatable(obj, metaTable)
	return obj
end
