-------------------------------------------------------------------------------
-- Gopher -- by Tammya-MoonGuard (Copyright 2018) -- All Rights Reserved.
-- Redux by VfX
-------------------------------------------------------------------------------
local Internal = LibGopher.Internal
if not Internal.load then return end
local Gopher = LibGopher

function Gopher.GetVersion()
	return Internal.Version
end

-- Register a callback for a Gopher event. Returns true on success, false if
-- already registered. See Gopher.lua for the full event list.
-- Chat event callbacks receive: (event, text, chat_type, arg3, target)
-- Return false to discard, nil to pass through, or new values to modify.
Gopher.Listen         = Internal.Listen
Gopher.StopListening  = Internal.StopListening
Gopher.GetEventListeners = Internal.GetEventHooks

-- Send a new message from within a CHAT_NEW listener, resuming the filter
-- chain after the current listener rather than restarting it.
Gopher.AddChatFromNewEvent = Internal.AddChatFromStartEvent

-- Skip Gopher's filters for the next message. It still goes through the
-- queue system; CHAT_NEW is skipped but QUEUE/POSTQUEUE still fire.
Gopher.Suppress = Internal.Suppress

-- Pause the queue so you can enqueue multiple messages before sending.
-- Call StartQueue() when done. Resets automatically per message.
Gopher.PauseQueue = Internal.PauseQueue

-- Set/get traffic priority for the next message. Lower = sent sooner.
-- Resets automatically after each message.
Gopher.SetTrafficPriority = Internal.SetTrafficPriority
Gopher.GetTrafficPriority = Internal.GetTrafficPriority

-- Insert a queue break. Messages across a break are never sent together.
-- Useful for ensuring ordered delivery across channel types.
Gopher.QueueBreak = Internal.QueueBreak

-- Override the chunk size for a given chat type. Pass nil to remove.
-- Use "OTHER" to override the default for all types.
-- Resolution order: overrides[type] > defaults[type] > overrides.OTHER > defaults.OTHER
Gopher.SetChunkSizeOverride = Internal.SetChunkSizeOverride

-- Override chunk size for the next message only.
Gopher.SetTempChunkSize = Internal.SetTempChunkSize

-- Set the split markers added at the end/start of continued message chunks.
-- sticky=true persists for all future messages; false applies once only.
-- Pass nil to leave a value unchanged, false to clear it.
Gopher.SetSplitmarks = Internal.SetSplitmarks
Gopher.GetSplitmarks = Internal.GetSplitmarks

-- Set a prefix/suffix applied to every chunk. Applies to next message only.
-- Pass false to clear, nil to ignore.
Gopher.SetPadding = Internal.SetPadding
Gopher.GetPadding = Internal.GetPadding

-- Start the queue after using PauseQueue.
Gopher.StartQueue = Internal.StartQueue

-- Queue state queries.
Gopher.AnyChannelsBusy = Internal.AnyChannelsBusy
Gopher.AllChannelsBusy = Internal.AllChannelsBusy
Gopher.SendingActive   = Internal.SendingActive

-- Returns Gopher's measured latency in seconds.
Gopher.GetLatency = Internal.GetLatency

-- Returns available bandwidth as a percentage (max 50 during combat lockdown).
Gopher.ThrottlerHealth = Internal.ThrottlerHealth

-- Returns true if the throttler is currently waiting through a delay.
Gopher.ThrottlerActive = Internal.ThrottlerActive

-- Hide/show the system throttle error message in chat.
Gopher.HideFailureMessages = Internal.HideFailureMessages

-- Attach addon message metadata to the next non-queued chat message.
-- prefix/text are passed to SendAddonMessage; perchunk repeats per chunk.
-- A function may be passed instead of prefix; it should return bytes sent.
Gopher.AddMetadata = Internal.AddMetadata

-- Timer helpers with slot-based management.
-- mode: "push" (reset), "ignore" (skip if running), "duplicate", "cooldown"
Gopher.Timer_Start  = Internal.Timer_Start
Gopher.Timer_Cancel = Internal.Timer_Cancel

-- Enable or disable debug logging to chat.
function Gopher.Debug( setting )
	if setting == nil then setting = true end
	if setting == false then setting = nil end
	Gopher.Internal.debug_mode = true
end
