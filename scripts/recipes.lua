
local atlas = "images/inventoryimages/winslow.xml"
local AddCharacterRecipe = AddCharacterRecipe

GLOBAL.setfenv(1, GLOBAL)
RegisterInventoryItemAtlas(atlas, "baton.tex")
AddCharacterRecipe("baton", { Ingredient("log", 1), Ingredient("nightmarefuel", 1) }, TECH.NONE,
    {
        builder_tag = "conductor",
        atlas = atlas,
    })
AddCharacterRecipe("violin", { Ingredient("nightmarefuel", 1) }, TECH.NONE,
    {
        builder_tag = "conductor",
        atlas = atlas,
        image = "violin.tex",
        product = "winslow_orchestraproxy_violin",
        sg_state = "spawn_mutated_creature",
        no_deconstruction = true,
        dropitem = true,
        canbuild = function(
            inst, builder)
            return builder:HasTag("readytoperform"),
                "NOTREDY" or (builder.components.petleash and not builder.components.petleash:IsFullForTag("orchestra")),
                "FULLORCHESTRA"
        end
    })
AddCharacterRecipe("drum", { Ingredient("nightmarefuel", 1), Ingredient("pigskin", 1) }, TECH.NONE,
    {
        builder_tag = "conductor",
        atlas = atlas,
        image = "drum.tex",
        product = "winslow_orchestraproxy_drum",
        sg_state = "spawn_mutated_creature",
        no_deconstruction = true,
        dropitem = true,
        canbuild = function(
            inst, builder)
            return builder:HasTag("readytoperform"),
                "NOTREDY" or (builder.components.petleash and not builder.components.petleash:IsFullForTag("orchestra")),
                "FULLORCHESTRA"
        end
    })
AddCharacterRecipe("clarinet", { Ingredient("nightmarefuel", 2), Ingredient("transistor", 1) }, TECH.NONE,
    {
        builder_tag = "conductor",
        atlas = atlas,
        image = "clarinet.tex",
        product = "winslow_orchestraproxy_clarinet",
        sg_state = "spawn_mutated_creature",
        no_deconstruction = true,
        dropitem = true,
        canbuild = function(
            inst, builder)
            return builder:HasTag("readytoperform"),
                "NOTREDY" or (builder.components.petleash and not builder.components.petleash:IsFullForTag("orchestra")),
                "FULLORCHESTRA"
        end
    })
AddCharacterRecipe("bass", { Ingredient("nightmarefuel", 2), Ingredient("livinglog", 1) }, TECH.NONE,
    {
        builder_tag = "conductor",
        atlas = atlas,
        image = "clarinet.tex",
        product = "winslow_orchestraproxy_bass",
        sg_state = "spawn_mutated_creature",
        no_deconstruction = true,
        dropitem = true,
        canbuild = function(
            inst, builder)
            return builder:HasTag("readytoperform"),
                "NOTREDY" or (builder.components.petleash and not builder.components.petleash:IsFullForTag("orchestra")),
                "FULLORCHESTRA"
        end
    })
AddCharacterRecipe("trombone", { Ingredient("nightmarefuel", 2), Ingredient("goldnugget", 1) }, TECH.NONE,
    {
        builder_tag = "conductor",
        atlas = atlas,
        image = "trombone.tex",
        product = "winslow_orchestraproxy_trombone",
        sg_state = "spawn_mutated_creature",
        no_deconstruction = true,
        dropitem = true,
        canbuild = function(
            inst, builder)
            return builder:HasTag("readytoperform"),
                "NOTREDY" or (builder.components.petleash and not builder.components.petleash:IsFullForTag("orchestra")),
                "FULLORCHESTRA"
        end
    })
AddCharacterRecipe("guitar", { Ingredient("nightmarefuel", 2), Ingredient("log", 4) }, TECH.NONE,
    {
        builder_tag = "conductor",
        atlas = atlas,
        image = "guitar.tex",
        product = "winslow_orchestraproxy_guitar",
        sg_state = "spawn_mutated_creature",
        no_deconstruction = true,
        dropitem = true,
        canbuild = function(
            inst, builder)
            return builder:HasTag("readytoperform"),
                "NOTREDY" or (builder.components.petleash and not builder.components.petleash:IsFullForTag("orchestra")),
                "FULLORCHESTRA"
        end
    })

AddCharacterRecipe("piano", { Ingredient("nightmarefuel", 3), Ingredient("marble", 2) }, TECH.NONE,
    {
        builder_tag = "conductor_allegiance_shadow",
        atlas = atlas,
        image = "piano.tex",
        product = "winslow_orchestraproxy_piano",
        sg_state = "spawn_mutated_creature",
        no_deconstruction = true,
        dropitem = true,
        canbuild = function(
            inst, builder)
            return builder:HasTag("readytoperform"),
                "NOTREDY" or (builder.components.petleash and not builder.components.petleash:IsFullForTag("orchestra")),
                "FULLORCHESTRA"
        end
    })
AddCharacterRecipe("saxophone", { Ingredient("nightmarefuel", 3), Ingredient("goldnugget", 5) }, TECH.NONE,
    {
        builder_tag = "conductor_allegiance_shadow",
        atlas = atlas,
        image = "saxophone.tex",
        product = "winslow_orchestraproxy_saxophone",
        sg_state = "spawn_mutated_creature",
        no_deconstruction = true,
        dropitem = true,
        canbuild = function(
            inst, builder)
            return builder:HasTag("readytoperform"),
                "NOTREDY" or (builder.components.petleash and not builder.components.petleash:IsFullForTag("orchestra")),
                "FULLORCHESTRA"
        end
    })

AddCharacterRecipe("shamisen", { Ingredient("moonglass", 2), Ingredient("goldnugget", 2) }, TECH.NONE,
    {
        builder_tag = "conductor_allegiance_lunar",
        atlas = atlas,
        image = "shamisen.tex",
        product = "winslow_orchestraproxy_shamisen",
        sg_state = "spawn_mutated_creature",
        no_deconstruction = true,
        dropitem = true,
        canbuild = function(
            inst, builder)
            return builder:HasTag("readytoperform"),
                "NOTREDY" or (builder.components.petleash and not builder.components.petleash:IsFullForTag("orchestra")),
                "FULLORCHESTRA"
        end
    })
