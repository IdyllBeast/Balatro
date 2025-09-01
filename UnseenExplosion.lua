-- Unseen Explosion
SMODS.Joker({
    key = "unseen_explosion",
    loc_txt = {
        name = "Unseen Explosion",
        text = {
            "Retriggers the {C:attention}leftmost{} Joker, then the Joker to the {C:attention}right{}, then applies {X:mult,C:white}X2{} Mult.",
        },
    },
    atlas = "unseen",
    pos = { x = 0, y = 0 },
    order = 32,
    cost = 8,
    rarity = 3,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    config = { extra = { Xmult = 2 } },

    loc_vars = function(self, info_queue, card)
        if card.area and card.area == G.jokers then
            local nodes = {}
            -- Leftmost Joker compatibility
            local compatible_left = G.jokers.cards[1] and G.jokers.cards[1] ~= card and G.jokers.cards[1].config.center.blueprint_compat
            nodes[#nodes + 1] = {
                n = G.UIT.C,
                config = { ref_table = card, align = "l", colour = compatible_left and mix_colours(G.C.GREEN, G.C.JOKER_GREY, 0.8) or mix_colours(G.C.RED, G.C.JOKER_GREY, 0.8), r = 0.05, padding = 0.06 },
                nodes = {
                    { n = G.UIT.T, config = { text = ' ' .. localize('k_' .. (compatible_left and 'compatible' or 'incompatible')) .. ' (Left) ', colour = G.C.UI.TEXT_LIGHT, scale = 0.32 * 0.8 } },
                }
            }
            -- Rightmost Joker compatibility
            local other_joker
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then other_joker = G.jokers.cards[i + 1] end
            end
            local compatible_right = other_joker and other_joker ~= card and other_joker.config.center.blueprint_compat
            nodes[#nodes + 1] = {
                n = G.UIT.C,
                config = { ref_table = card, align = "r", colour = compatible_right and mix_colours(G.C.GREEN, G.C.JOKER_GREY, 0.8) or mix_colours(G.C.RED, G.C.JOKER_GREY, 0.8), r = 0.05, padding = 0.06 },
                nodes = {
                    { n = G.UIT.T, config = { text = ' ' .. localize('k_' .. (compatible_right and 'compatible' or 'incompatible')) .. ' (Right) ', colour = G.C.UI.TEXT_LIGHT, scale = 0.32 * 0.8 } },
                }
            }
            local main_end = {
                { n = G.UIT.C, config = { align = "bl", minh = 0.4 }, nodes = nodes }
            }
            return { main_end = main_end }
        end
    end,

    calculate = function(self, card, context)
        context = context or {}
        if context.unseen_explosion_active then
            return nil
        end
        local new_context = {}
        for k, v in pairs(context) do new_context[k] = v end
        new_context.unseen_explosion_active = true

        -- Retrigger the leftmost Joker (if not self)
        local left_joker = G.jokers.cards[1]
        if left_joker and left_joker ~= card and left_joker.config.center and left_joker.config.center.blueprint_compat and left_joker.calculate then
            G.E_MANAGER:add_event(Event({
                func = function()
                    left_joker:calculate(left_joker, new_context)
                    return true
                end
            }))
        end

        -- Retrigger the Joker to the right (if not self)
        local right_joker = nil
        for i = 1, #G.jokers.cards do
            if G.jokers.cards[i] == card then right_joker = G.jokers.cards[i + 1] end
        end
        if right_joker and right_joker ~= card and right_joker.config.center and right_joker.config.center.blueprint_compat and right_joker.calculate then
            G.E_MANAGER:add_event(Event({
                func = function()
                    right_joker:calculate(right_joker, new_context)
                    return true
                end
            }))
        end

        -- Only apply x2 mult to this Joker's own result
        local result = { Xmult = 2, repetitions = 1 }
        return result
    end,
})