local LibLang, VERSION = LibStub:NewLibrary("LibLang-0.2", 1)

-- Early exit if this is same or older version of existing library
if not LibLang then return end	 
LibLang.__index = LibLang

function LibLang.new(bundle)
	local obj = {bundle = bundle}
	return setmetatable(obj, LibLang)
end

function LibLang:getMsg( key)
	local bundle = self.bundle
	if (bundle == nil) then return nil end
	return bundle[key]
end

function LibLang:print(key, ...)
	CHAT_SYSTEM:AddMessage(self:translate(key, ...))
end

function LibLang:translate(key, ...)
	local msg = self:getMsg(key)
	if (msg == nil) then msg = "Lang Error:"..key..": <<1>> <<2>> <<3>> <<4>> <<5>>" end
	return LocalizeString(msg, ...)
end

function LibLang:exists(key)
	local msg = self:getMsg(key)
	return msg ~= nil
end
