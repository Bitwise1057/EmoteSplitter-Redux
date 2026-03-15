-------------------------------------------------------------------------------
-- Gopher -- by Tammya-MoonGuard (Copyright 2018) -- All Rights Reserved.
-- Redux by VfX
-------------------------------------------------------------------------------
local Me = LibGopher.Internal
if not Me.load then return end

-- Called one frame after PLAYER_LOGIN so other addons are initialised.
function Me.AddCompatibilityLayers()
	Me.UCMCompatibility()
	Me.MisspelledCompatibility()
	Me.TonguesCompatibility()
end

-- UnlimitedChatMessage: remove its SendChatMessage hook, keep its editbox work.
function Me.UCMCompatibility()
	if Me.compatibility_ucm then return end
	if not UCM then return end
	if UCM.core.hooks.SendChatMessage then
		Me.compatibility_ucm = true
		UCM.core:Unhook( "SendChatMessage" )
	end
end

-- Misspelled: unhook its SendChatMessage and run its highlight removal via
-- CHAT_NEW instead, so it doesn't shrink already-split chunks.
function Me.MisspelledCompatibility()
	if Me.compatibility_misspelled then return end
	if not Misspelled then return end
	if not Misspelled.hooks or not Misspelled.hooks.SendChatMessage then return end

	Me.compatibility_misspelled = true
	Misspelled:Unhook( "SendChatMessage" )
	Me.Listen( "CHAT_NEW", function( event, text, ... )
		text = Misspelled:RemoveHighlighting( text )
		return text, ...
	end)
end

-- Tongues: intercept its send pipeline via CHAT_NEW so split messages work.
-- Note: Tongues' protocol does not natively support split messages.
function Me.TonguesCompatibility()
	if Me.compatibility_tongues then return end
	if not Tongues then return end

	Me.compatibility_tongues = true

	local stolen_handle_send = Tongues.HandleSend
	local tongues_hook = Tongues.Hooks.Send

	-- Replace HandleSend so we can detect organic calls.
	Tongues.HandleSend = function( self, msg, type, langid, lang, channel )
		tongues_hook( msg, type, langid, channel )
	end

	local tongues_is_calling_send = false
	local outside_send_function = function( ... )
		tongues_is_calling_send = true
		local a,b,c,d = ...
		pcall( SendChatMessage, a, b, c, d )
		tongues_is_calling_send = false
	end

	local inside_send_function = function( ... )
		Me.AddChatFromStartEvent( ... )
	end

	local tongues_accepted_types = {
		SAY=true; EMOTE=true; YELL=true; PARTY=true; GUILD=true;
		OFFICER=true; RAID=true; RAID_WARNING=true; INSTANCE_CHAT=true;
		BATTLEGROUND=true; WHISPER=true; CHANNEL=true;
	}

	Tongues.Hooks.Send = outside_send_function

	Me.Listen( "CHAT_NEW", function( event, msg, type, _, target )
		if not tongues_accepted_types[type:upper()] then return end
		if tongues_is_calling_send then return end

		Tongues.Hooks.Send = inside_send_function
		local langID, lang = GetSpeaking()
		pcall( stolen_handle_send, Tongues, msg, type, langID, lang, target )
		Tongues.Hooks.Send = outside_send_function
		return false
	end)
end
