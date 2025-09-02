SMODS.Joker {
    key = "stranger_than_fiction",
    order = 121,
    generate_ui = Kino.generate_info_ui,
    config = {
        extra = {
            next_card = nil,
            stacked_chips = 0,
            a_chips = 25,
            next_card_name = "2 of Hearts"
        }
    },
    rarity = 2,
    atlas = "kino_atlas_4",
    pos = { x = 0, y = 2},
    cost = 4,
    blueprint_compat = true,
    perishable_compat = true,
    kino_joker = {
        id = 1262,
        budget = 0,
        box_office = 0,
        release_date = "1900-01-01",
        runtime = 90,
        country_of_origin = "US",
        original_language = "en",
        critic_score = 100,
        audience_score = 100,
        directors = {},
        cast = {},
    },
    pools, k_genre = {"Comedy", "Drama", "Romance"},

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.stacked_chips,
                card.ability.extra.a_chips,
                card.ability.extra.next_card,
                card.ability.extra.next_card_name
            }
        }
    end,
    calculate = function(self, card, context)
        -- Gain 10 chips when you play the narrated card. When you do not, set chips back to 0.
        if context.hand_drawn and not context.blueprint and not context.repetition then
            card.ability.extra.next_card = pseudorandom_element(context.hand_drawn, pseudoseed('stf'))
            card.ability.extra.next_card_name = G.P_CARDS[card.ability.extra.next_card.config.card_key].name
        end

        if context.before and context.cardarea == G.jokers and not context.blueprint then
            local _has_card = false
            for i = 1, #context.scoring_hand do
                if context.scoring_hand[i] == card.ability.extra.next_card then
                    _has_card = true
                    -- Page Turn Sound plays.
                    card.ability.extra.stacked_chips = card.ability.extra.stacked_chips + card.ability.extra.a_chips
                end
            end

            if not _has_card then
                card.ability.extra.stacked_chips = 0
            end
        end

        if context.joker_main then
            return {
                chips = card.ability.extra.stacked_chips
            }
        end
    end
}