-- commented out due to crashing on use cuz i don't think change_ante_scaling exists and idk how to fix it :sob: - glitch
--[[ SMODS.Voucher {
    key = "reduction",
    atlas = "crp_placeholder",
    pos = { x = 5, y = 2 },
    config = { extra = { ante_scaling = 0.8 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { lenient_bignum(card.ability.extra.ante_scaling) } }
    end,
    redeem = function(self, card)
        G.E_MANAGER:add_event(Event({
            func = function()
                change_ante_scaling(card.ability.extra.ante_scaling)
                return true
            end
        }))
    end
} ]]--


SMODS.Voucher {
    key = "reduction",
    atlas = "crp_placeholder",
    pos = { x = 5, y = 2 },
    config = { extra = { ante_scaling = 0.8 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { lenient_bignum(card.ability.extra.ante_scaling) } }
    end,
    redeem = function(self, card)
        G.GAME.starting_params.ante_scaling = lenient_bignum(card.ability.extra.ante_scaling)
    end
}

SMODS.Voucher {
    key = "pacification",
    atlas = "crp_placeholder",
    pos = { x = 6, y = 2 },
    config = { extra = { ante_scaling = 0.6 } },
	requires = { "v_crp_reduction" },
    loc_vars = function(self, info_queue, card)
        return { vars = { lenient_bignum(card.ability.extra.ante_scaling) } }
    end,
    redeem = function(self, card)
        G.GAME.starting_params.ante_scaling = lenient_bignum(card.ability.extra.ante_scaling)
    end
}

SMODS.Voucher {
    key = "domination",
    atlas = "crp_placeholder",
    pos = { x = 7, y = 2 },
    config = { extra = { ante_scaling = 0.4 } },
	requires = { "v_crp_pacification" },
    loc_vars = function(self, info_queue, card)
        return { vars = { lenient_bignum(card.ability.extra.ante_scaling) } }
    end,
    redeem = function(self, card)
        G.GAME.starting_params.ante_scaling = lenient_bignum(card.ability.extra.ante_scaling)
    end
}

SMODS.Voucher {
    key = "reign",
    atlas = "crp_placeholder",
    pos = { x = 7, y = 2 },
    config = { extra = { ante_scaling = 0.2 } },
	requires = { "v_crp_domination" },
    loc_vars = function(self, info_queue, card)
        return { vars = { lenient_bignum(card.ability.extra.ante_scaling) } }
    end,
    redeem = function(self, card)
        G.GAME.starting_params.ante_scaling = lenient_bignum(card.ability.extra.ante_scaling)
    end
}

SMODS.Voucher {
    key = "supremacy",
    atlas = "crp_placeholder",
    pos = { x = 7, y = 2 },
    config = { extra = { } },
	requires = { "v_crp_reign" },
    loc_vars = function(self, info_queue, card)
        return { vars = {  } }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and context.cardarea == G.hand then
				update_hand_text(
					{ sound = "button", volume = 0.7, pitch = 0.8, delay = 0.3 },
					{ handname = localize("k_all_hands"), chips = "...", mult = "...", level = "" }
				)
				G.E_MANAGER:add_event(Event({
					trigger = "after",
					delay = 0.2,
					func = function()
						play_sound("tarot1")
						return true
					end,
				}))
				update_hand_text({ delay = 0 }, { mult = "+", StatusText = true })
				G.E_MANAGER:add_event(Event({
					trigger = "after",
					delay = 0.9,
					func = function()
						play_sound("tarot1")
						return true
					end,
				}))
				update_hand_text({ delay = 0 }, { chips = "+", StatusText = true })
				G.E_MANAGER:add_event(Event({
					trigger = "after",
					delay = 0.9,
					func = function()
						play_sound("tarot1")
						return true
					end,
				}))
				update_hand_text({ sound = "button", volume = 0.7, pitch = 0.9, delay = 0 }, { level = "+" .. math.ceil(math.log(G.GAME.blind.chips, 64)) })
				delay(1.3)
				for k, v in pairs(G.GAME.hands) do
					G.GAME.hands[k].level = G.GAME.hands[k].level + math.ceil(math.log(G.GAME.blind.chips, 64))
				end
				update_hand_text(
					{ sound = "button", volume = 0.7, pitch = 1.1, delay = 0 },
					{ mult = 0, chips = 0, handname = "", level = "" }
				)
        end
    end
}

SMODS.Voucher {
    key = "godhood",
    atlas = "crp_placeholder",
    pos = { x = 7, y = 2 },
    config = { extra = {  } },
	requires = { "v_crp_supremacy" },
    loc_vars = function(self, info_queue, card)
        return { vars = {  } }
    end,
    redeem = function(self, card)
    end
}

SMODS.Voucher {
    key = "ascension",
    atlas = "crp_placeholder",
    pos = { x = 7, y = 2 },
    config = { extra = {  } },
	requires = { "v_crp_godhood" },
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
    calculate = function(self, card, context)
		if context.setting_blind then
            G.GAME.blind.chips = 1
			G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
            G.GAME.blind:disable()
            play_sound('timpani')
            card_eval_status_text(card, 'extra', nil, nil, nil, { message = localize('ph_boss_disabled') })
		end
    end
}

SMODS.Voucher {
    key = "patience",
    name = "Patience",
    atlas = "crp_placeholder",
    pos = { x = 5, y = 2 },
    config = { extra = {  } },
    loc_vars = function(self, info_queue, card)
        return { vars = {  } }
    end,
    redeem = function(self, card)
    end,
	crp_credits = {
		idea = { "PurplePickle" },
		code = { "Rainstar" }
	}
}

SMODS.Voucher {
    key = "patience_2",
    name = "More Patience",
    atlas = "crp_placeholder",
    pos = { x = 5, y = 2 },
    config = { extra = {  } },
    loc_vars = function(self, info_queue, card)
        return { vars = {  } }
    end,
	requires = { "v_crp_patience" },
    redeem = function(self, card)
    end,
    crp_credits = {
		idea = { "PurplePickle" },
		code = { "Rainstar" }
	}
}

SMODS.Voucher {
    key = "patience_3",
    name = "Even More Patience",
    atlas = "crp_placeholder",
    pos = { x = 5, y = 2 },
    config = { extra = {  } },
    loc_vars = function(self, info_queue, card)
        return { vars = {  } }
    end,
	requires = { "v_crp_patience_2" },
    redeem = function(self, card)
    end,
    crp_credits = {
		idea = { "PurplePickle" },
		code = { "Rainstar" }
	}
}

SMODS.Voucher {
    key = "patience_4",
    name = "Even More Patience Again",
    atlas = "crp_placeholder",
    pos = { x = 5, y = 2 },
    config = { extra = {  } },
    loc_vars = function(self, info_queue, card)
        return { vars = {  } }
    end,
	requires = { "v_crp_patience_3" },
    redeem = function(self, card)
    end,
    crp_credits = {
		idea = { "PurplePickle" },
		code = { "Rainstar" }
	}
}

SMODS.Voucher {
    key = "patience_5",
    name = "So Much Patience",
    atlas = "crp_placeholder",
    pos = { x = 5, y = 2 },
    config = { extra = {  } },
    loc_vars = function(self, info_queue, card)
        return { vars = {  } }
    end,
	requires = { "v_crp_patience_4" },
    redeem = function(self, card)
    end,
    crp_credits = {
		idea = { "PurplePickle" },
		code = { "Rainstar" }
	}
}

SMODS.Voucher {
    key = "payoff",
    name = "Payoff", -- +4 chips!!1!1!!!
    atlas = "crp_placeholder",
    pos = { x = 5, y = 2 },
    config = { extra = {  } },
    loc_vars = function(self, info_queue, card)
        return { vars = {  } }
    end,
	requires = { "v_crp_patience_5" },
    redeem = function(self, card)
    end,
    crp_credits = {
		idea = { "PurplePickle" },
		code = { "Rainstar" }
	}
}

SMODS.Voucher {
    key = "just_kidding",
    name = "Just Kidding, This Is the Real Payoff", -- oh
    atlas = "crp_placeholder",
    pos = { x = 7, y = 2 },
    config = { extra = { all_count = 1 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { lenient_bignum(card.ability.extra.all_count) } }
    end,
	requires = { "v_crp_payoff" },
    redeem = function(self, card)
        for i = 1, lenient_bignum(card.ability.extra.all_count) do
			local card = create_card("Joker", G.jokers, nil, "crp_all", nil, nil, nil, "just_kidding")
			card:set_edition({ negative = true }, true)
			card:add_to_deck()
			G.jokers:emplace(card)
        end
    end,
    crp_credits = {
		idea = { "PurplePickle" },
		code = { "Rainstar" }
	}
}