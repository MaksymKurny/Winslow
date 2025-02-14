local assets =
{
	Asset( "ANIM", "anim/winslow.zip" ),
	Asset( "ANIM", "anim/ghost_winslow_build.zip" ),
}

local skins =
{
	normal_skin = "winslow",
	ghost_skin = "ghost_winslow_build",
}

return CreatePrefabSkin("winslow_none",
{
	base_prefab = "winslow",
	type = "base",
	assets = assets,
	skins = skins,
	skin_tags = {"WINSLOW", "CHARACTER", "BASE"},
	build_name_override = "winslow",
	rarity = "Character",
})
