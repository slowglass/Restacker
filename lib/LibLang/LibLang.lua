local MAJOR, MINOR = "LibLang-0.0", 1
local LibLang, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not lam then return end	--the same or newer version of this lib is already loaded into memory 

--UPVALUES

--maybe return the controls from the creation functions?

function LibLang:setLang(lang)
	self.lang = lang
end

function LibLang:print(key, ...)
{
	local result = "";
	local fmt = self.langBundle[self.lang][key];
	if (fmt == nil) fmt = self.langBundle['en'][key];
	local modifier = true
	for str in string.gmatch(self.langBundle[lang][key], "%%") do
		modifier = ~modifier
		if (modifier) then str = self:getArg(args, str) end
		result = result..str
    end
}

functions LibLang:getArg(args, index)
{
	if (index == "") then return "%" end
	if (index<1) then return "<Err>" end
	if (index>#args) then return "<Err>" end
	return args[index]
}

function LibLang:addBundle(lang, bundle)
{
	if (self.langBundle[==nil) self.langBundle = {} end
	self.langBundle[lang] = bundle
}
