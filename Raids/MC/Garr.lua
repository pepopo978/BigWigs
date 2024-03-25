
local module, L = BigWigs:ModuleDeclaration("Garr", "Molten Core")

module.revision = 30074
module.enabletrigger = module.translatedName
module.toggleoptions = {"bosskill"}
module.wipemobs = {"Firesworn"}

local timer = {}
local icon = {}
local color = {}
local syncName = {
	}

L:RegisterTranslations("enUS", function() return {
	cmd = "Garr",
} end)

function module:OnEnable()
end

function module:OnSetup()
	self.started    = nil
end

function module:OnEngage()
end

function module:OnDisengage()
end

function module:Event(msg)

end

function module:BigWigs_RecvSync(sync, rest, nick)

end
