local LIB, VERSION = "LibLang-0.1", 2
local LibLang, VERSION = LibStub:NewLibrary(LIB, VERSION)

-- Early exit if this is same or older version of existing library
if not LibLang then return end	 
LibLang.__index = LibLang

function LibLang.new()
	local obj = {lang="en", bundles = {}}
	return setmetatable(obj, LibLang)
end

function LibLang:addBundle(lang, bundle)
	if (self.bundles==nil) then self.bundles = {} end
	self.bundles[lang] = bundle
end

local function LibLang:setLang(lang)
	self.lang = lang
end

local function LibLang:getMsg(lang, key)
	local bundle = self.bundles[lang]
	if (bundle == nil) then return nil end
	return bundle[key]
end

local function LibLang:print(key, ...)
	CHAT_SYSTEM:AddMessage(self:translate(self, key, ...))
end

local function LibLang:translate(key, ...)
	local msg = self:getMsg(self.lang, key)
	if (msg == nil) then msg = self:getMsg(self, "en", key) end
	if (msg == nil) then msg = "Lang Error:"..key..": <<1>> <<2>> <<3>> <<4>> <<5>>" end
	return LocalizeString(msg, ...)
end


