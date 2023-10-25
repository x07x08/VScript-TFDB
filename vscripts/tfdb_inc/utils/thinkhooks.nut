function HookCustomThink(hEntity, strThinkFunc, funcCallback, fDelay = 0.1)
{
	if ((hEntity.GetScriptThinkFunc() != "") && (hEntity.GetScriptThinkFunc() != "CustomThink_"+strThinkFunc))
	{
		printl("Another think hook is active");

		return;
	}

	local hEntityScope = hEntity.GetScriptScope();

	if (!("ThinkHooks" in hEntityScope)) hEntityScope.ThinkHooks <- [];

	if (hEntityScope.ThinkHooks.find(funcCallback) != null) { printl("Think callback already added"); return; }

	hEntityScope.ThinkHooks.append(funcCallback);

	if (!("CustomThink_"+strThinkFunc in hEntityScope)) hEntityScope["CustomThink_"+strThinkFunc] <- function()
	{
		foreach (iIndex, funcThinkCb in this.ThinkHooks)
		{
			funcThinkCb();
		}

		return fDelay;
	}

	AddThinkToEnt(hEntity, "CustomThink_"+strThinkFunc);
}

function UnhookCustomThink(hEntity, strThinkFunc, funcCallback)
{
	if (hEntity.GetScriptThinkFunc() != "CustomThink_"+strThinkFunc)
	{
		printl("Think not hooked");

		return;
	}

	local hEntityScope = hEntity.GetScriptScope();
	local iFuncIndex = hEntityScope.ThinkHooks.find(funcCallback);

	if (iFuncIndex == null) { printl("Think callback not found"); return; }

	hEntityScope.ThinkHooks.remove(iFuncIndex);
}
