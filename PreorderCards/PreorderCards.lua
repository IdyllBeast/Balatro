--- STEAMODDED HEADER
--- MOD_NAME: Preorder Cards
--- MOD_ID: preorder_cards
--- MOD_AUTHOR: [asd123cqp]
--- MOD_DESCRIPTION: Preorder cards by selecting them in your collection.
----------------------------------------------
------------MOD CODE -------------------------
local _PREORDERED_CARDS = {}
local _FREE_PREORDER = true
local _FREE_REROLL = true

-- Returns the index of the next preorder card to offer in shop.
local function _get_preorder_idx()
    if not G.GAME then return 1 end
    G.GAME.preorder_idx = math.min(math.max(G.GAME.preorder_idx or 1, 1), #_PREORDERED_CARDS + 1)
    return G.GAME.preorder_idx
end

-- `preorder_idx` persists for saved runs, but `_PREORDERED_CARDS` resets on game restart, so
-- `preorder_idx` needs to be reset for saved runs.
local Original_Game_start_run = Game.start_run
function Game:start_run(args)
    local ret = Original_Game_start_run(self, args)
    _get_preorder_idx()
    return ret
end

-- Grants a free reroll if any preorders remain unoffered.
local Original_calculate_reroll_cost = calculate_reroll_cost
local function _grant_free_reroll()
    G.GAME.current_round.free_rerolls = math.max(G.GAME.current_round.free_rerolls, 0) + 1
    return Original_calculate_reroll_cost(true)
end
function calculate_reroll_cost(skip_increment)
    if _FREE_REROLL and G.GAME.shop.joker_max < #_PREORDERED_CARDS - _get_preorder_idx() + 1 then
        return _grant_free_reroll()
    end
    return Original_calculate_reroll_cost(skip_increment)
end

local Original_create_card_for_shop = create_card_for_shop
function create_card_for_shop(area)
    if area ~= G.shop_jokers or (
            G.SETTINGS.tutorial_progress and
            G.SETTINGS.tutorial_progress.forced_shop and
            G.SETTINGS.tutorial_progress.forced_shop[
            #G.SETTINGS.tutorial_progress.forced_shop]) then
        return Original_create_card_for_shop(area)
    end

    local preorder_idx = _get_preorder_idx()
    if preorder_idx > #_PREORDERED_CARDS then
        return Original_create_card_for_shop(area)
    end

    local selected_card = _PREORDERED_CARDS[preorder_idx]
    local card = create_card(G.P_CENTERS[selected_card.name].set, area, nil,
        nil, nil, nil, selected_card.name, 'sho')
    create_shop_card_ui(card, G.P_CENTERS[selected_card.name].set, area)
    G.E_MANAGER:add_event(Event({
        func = (function()
            card.ability.couponed = _FREE_PREORDER
            card.ability.perishable = nil
            card.ability.eternal = nil
            card.ability.rental = nil
            card:set_edition(selected_card.edition and
                { [selected_card.edition] = true } or
                {}, true, false)
            card:set_cost()
            card:set_debuff(false)
            return true
        end)
    }))

    G.GAME.preorder_idx = preorder_idx + 1
    return card
end

-- Grants a free reroll for new preorders.
local Original_G_FUNCS_exit_overlay_menu = G.FUNCS.exit_overlay_menu
G.FUNCS.exit_overlay_menu = function()
    local ret = Original_G_FUNCS_exit_overlay_menu()
    if (_FREE_REROLL and G.STAGE == G.STAGES.RUN and G.STATE == G.STATES.SHOP and G.shop
            and G.GAME.current_round and _get_preorder_idx() <= #_PREORDERED_CARDS) then
        G.E_MANAGER:add_event(Event({
            func = (function()
                _grant_free_reroll()
                return true
            end)
        }))
    end
    return ret
end

-- Highligh `card` based on given `edition` (or add a Gold seal if `nil`).
local function _highlight_card(card, edition)
    if edition == nil then
        card:set_edition(nil, true, false)
        card:set_seal('Gold', false, true)
    else
        card:set_seal(nil, false, true)
        card:set_edition({ [edition] = true }, true, false)
    end
end

local function _toggle_card(card, edition)
    local card_name = card.config.center.key
    local selected_index = #_PREORDERED_CARDS + 1
    for i = 1, #_PREORDERED_CARDS do
        if _PREORDERED_CARDS[i].name == card_name then
            if _PREORDERED_CARDS[i].edition == edition then
                table.remove(_PREORDERED_CARDS, i)
                card:set_edition(nil, true, false)
                card:set_seal(nil, false, true)
                if G.GAME and G.GAME.preorder_idx then
                    card:set_debuff(false)
                    G.GAME.preorder_idx = math.max(G.GAME.preorder_idx - 1, 1)
                end
                return
            else
                selected_index = i
                break
            end
        end
    end

    _PREORDERED_CARDS[selected_index] = { name = card_name, edition = edition }
    _highlight_card(card, edition)
end

local function _is_your_collection(area)
    if not G.your_collection then return false end
    for i = 1, #G.your_collection do
        if area == G.your_collection[i] then return true end
    end
    return false
end

local Original_Controller_key_press_update = Controller.key_press_update
function Controller:key_press_update(key, dt)
    Original_Controller_key_press_update(self, key, dt)
    local card = self.hovering.target
    if card and card:is(Card) and G.SETTINGS.paused and _is_your_collection(card.area) then
        local card_name = card.config.center.key
        if string.find(card_name, 'j_') then
            if key == 'f4' then
                _toggle_card(card, 'negative')
            elseif key == 'f5' then
                _toggle_card(card, 'polychrome')
            elseif key == 'f6' then
                _toggle_card(card, 'holo')
            elseif key == 'f7' then
                _toggle_card(card, 'foil')
            elseif key == 'f8' then
                _toggle_card(card, nil)
            elseif key == 'f9' then
                unlock_card(card.config.center)
                discover_card(card.config.center)
            end
        elseif string.find(card_name, 'c_') then
            if key == 'f4' then
                _toggle_card(card, 'negative')
            elseif key == 'f8' then
                _toggle_card(card, nil)
            elseif key == 'f9' then
                unlock_card(card.config.center)
                discover_card(card.config.center)
            end
        end
    end
    if key == 'f3' then
        _PREORDERED_CARDS = {}
        _get_preorder_idx()
        if G.SETTINGS.paused and G.your_collection then
            for i = 1, #G.your_collection do
                for j = 1, G.your_collection[i].cards and #G.your_collection[i].cards or 0 do
                    G.your_collection[i].cards[j]:set_edition(nil, true, false)
                    G.your_collection[i].cards[j]:set_seal(nil, false, true)
                    G.your_collection[i].cards[j]:set_debuff(false)
                end
            end
        end
    end
end

local function _maybe_highlight_card(card)
    for i = 1, #_PREORDERED_CARDS do
        if card.config.center.name == G.P_CENTERS[_PREORDERED_CARDS[i].name].name then
            _highlight_card(card, _PREORDERED_CARDS[i].edition)
            if G.STAGE == G.STAGES.RUN and G.GAME and i < _get_preorder_idx() then
                card:set_debuff(true)
            end
        end
    end
end

local Original_CardArea_emplace = CardArea.emplace
function CardArea:emplace(card, location, stay_flipped)
    local ret = Original_CardArea_emplace(self, card, location, stay_flipped)
    if G.SETTINGS.paused and _is_your_collection(self) and card.area then
        _maybe_highlight_card(card)
    end
    return ret
end

----------------------------------------------
------------MOD CODE END----------------------
