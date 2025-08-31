-- Unseen Explosion
SMODS.Joker({
    key = "unseen_explosion",
    loc_txt = {
        name = "Unseen Explosion",
        text = {
            "Copies ability of",
            "{C:attention}leftmost{} Joker &", -- Brainstorm-like
            "Joker to the {C:attention}right{}", -- Blueprint-like
            "{X:mult,C:white}X2{} Mult",
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

    -- Function to provide localized variables for UI display
    loc_vars = function(self, info_queue, card)
        if card.area and card.area == G.jokers then
            local nodes = {}

            -- Leftmost Joker compatibility
            local compatible_left = G.jokers.cards[1] and G.jokers.cards[1] ~= card and
                                    G.jokers.cards[1].config.center.blueprint_compat
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

    -- Main calculation logic for the Joker's effect
    calculate = function(self, card, context)
        local ret = SMODS.blueprint_effect(card, G.jokers.cards[1], context)
        if ret then
            ret.colour = G.C.RED
        end

        local other_joker = nil
        for i = 1, #G.jokers.cards do
            if G.jokers.cards[i] == card then other_joker = G.jokers.cards[i + 1] end
        end
        local ret_right = SMODS.blueprint_effect(card, other_joker, context)
        if ret_right then
            ret_right.colour = G.C.BLUE
            if ret then
                ret = SMODS.combine_calculations(ret, ret_right)
            else
                ret = ret_right
            end
        end
        return ret
    end,
})