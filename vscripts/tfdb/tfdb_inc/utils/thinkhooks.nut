local strThinkArray = "ThinkHooks";
local strCustomThink = "CustomThink_";

function HookCustomThink(hEntity, strThinkFunc, funcCallback, fDelay = 0.1)
{
	if ((hEntity.GetScriptThinkFunc() != "") && (hEntity.GetScriptThinkFunc() != strCustomThink + strThinkFunc))
	{
		printl("Another think hook is active");

		return;
	}

	local hEntityScope = hEntity.GetScriptScope();

	if (!(strThinkArray in hEntityScope)) hEntityScope.ThinkHooks <- [];

	if (hEntityScope.ThinkHooks.find(funcCallback) != null) { printl("Think callback already added"); return; }

	hEntityScope.ThinkHooks.append(funcCallback);

	if (!(strCustomThink + strThinkFunc in hEntityScope)) hEntityScope[strCustomThink + strThinkFunc] <- function()
	{
		foreach (iIndex, funcThinkCb in this.ThinkHooks)
		{
			funcThinkCb();
		}

		return fDelay;
	}

	AddThinkToEnt(hEntity, strCustomThink + strThinkFunc);
}

function UnhookCustomThink(hEntity, strThinkFunc, funcCallback)
{
	if (hEntity.GetScriptThinkFunc() != strCustomThink + strThinkFunc)
	{
		printl("Think not hooked");

		return;
	}

	local hEntityScope = hEntity.GetScriptScope();
	local iFuncIndex = hEntityScope.ThinkHooks.find(funcCallback);

	if (iFuncIndex == null) { printl("Think callback not found"); return; }

	hEntityScope.ThinkHooks.remove(iFuncIndex);
}
