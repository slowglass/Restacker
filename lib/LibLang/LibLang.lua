local MAJOR, MINOR = "LibLang-0.1", 1
local LibLang, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
local ll_lang = "en"
local ll_langBundle = {}
if not LibLang then return end	 

local function ll_print(self, key, ...)
  if (self.langBundle[self.lang][key] == nil) then
    d(key)
  else
	 d(LocalizeString(self.langBundle[self.lang][key], ...))
  end
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

function LibLang.getBundleHandler()
	local obj = {}
	setmetatable(obj, metaTable)
	return obj
end
