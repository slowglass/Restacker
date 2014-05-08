local MAJOR, MINOR = "LibLang-0.1", 1
local LibLang, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
local ll_lang = "en"
local ll_langBundle = {}
if not LibLang then return end	 

local function getMsg(self, lang, key)
	local bundle = self.langBundle[lang]
	if (bundle == nil) then return nil end
	return bundle[key]
end

local function ll_translate(self, key, ...)
	local msg = getMsg(self, key)
	if (msg == nil) then msg = getMsg(self, "en", key) end
	if (msg == nil) then msg = "Lang Error:"..key..": <<1>> <<2>> <<3>> <<4>> <<5>>" end
	return LocalizeString(msg, ...)
end

local function ll_print(self, key, ...)
	d(ll_translate(self, key, ...))
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
		translate = ll_translate,
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
