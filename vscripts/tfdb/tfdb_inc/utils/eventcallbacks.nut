local strEventsArray = "EventHooks";
local strGameEvent = "OnGameEvent_";

function HookEvent(strEvent, funcCallback, hScope = getroottable())
{
	if (!(strEventsArray in hScope)) hScope.EventHooks <- {};

	if (!(strEvent in hScope.EventHooks)) hScope.EventHooks[strEvent] <- [];

	if (hScope.EventHooks[strEvent].find(funcCallback) != null) { printl("Event callback already added"); return; }

	hScope.EventHooks[strEvent].append(funcCallback);

	if ((strGameEvent + strEvent) in hScope) return;

	hScope[strGameEvent + strEvent] <- function(hParams)
	{
		if (!(strEvent in this.EventHooks)) return;

		foreach (iIndex, funcEventCb in this.EventHooks[strEvent])
		{
			funcEventCb(hParams);
		}
	}
}

function UnhookEvent(strEvent, funcCallback, hScope = getroottable())
{
	if (!(strEventsArray in hScope)) { printl("No events hooked"); return; }

	if (!(strEvent in hScope.EventHooks)) { printl("Event not hooked"); return; }

	local iFuncIndex = hScope.EventHooks[strEvent].find(funcCallback);

	if (iFuncIndex == null) { printl("Event callback not found"); return; }

	hScope.EventHooks[strEvent].remove(iFuncIndex);

	if (hScope.EventHooks[strEvent].len() == 0) delete hScope.EventHooks[strEvent];
}
