ClearGameEventCallbacks();

local strScripts =
[
	"utils/defines.nut",
	"utils/functions.nut",
	"utils/eventcallbacks.nut",
	"utils/thinkhooks.nut",
	"utils/printing.nut",
	"defines.nut"
]

foreach (iIndex, strScript in strScripts)
{
	IncludeScript("tfdb_inc/" + strScript);
}

TFDB.AlreadySetUp <- (("TFDB" in this) && ("AlreadySetUp" in this.TFDB)) ? true : false;
TFDB.IsEnabled <- false;
TFDB.RoundStarted <- false;
TFDB.RoundCount <- 0;
TFDB.RocketsFired <- 0;
TFDB.LastDeadTeam <- 0;
TFDB.PlayerCount <- 0;
TFDB.TickModifier <- -1;
TFDB.MaxSteals <- 2;
TFDB.StealDistance <- 64.0;
TFDB.NoDamageOnSteal <- false;
TFDB.ResetStealsOnRound <- true;
TFDB.ResetStealsOnDeath <- false;
TFDB.CheckForDelay <- true;
TFDB.DelayDistance <- 256.0;
TFDB.DelayTimeLimit <- 5.0;
TFDB.DelaySpeed <- 500;
TFDB.NoDamageOnNoTarget <- true;
TFDB.AllowPrimaryAttack <- false;
TFDB.RemoveNonPrimaries <- true;
TFDB.DamageOnlyTarget <- false;
TFDB.TraceLength <- 16;
TFDB.BotDeflect <- true;
TFDB.BotDeflectRadius <- 198;

TFDB.RocketTypes <- [];
TFDB.SpawnerTypes <- {};

function TFDB::IsValidRocket(hScope)
{
	try
	{
		return ("TFDB" in hScope) && ("Rocket" in hScope.TFDB);
	}
	catch(e)
	{
		return false;
	}
}

function TFDB::IsValidSpawner(hScope)
{
	try
	{
		return ("TFDB" in hScope) && ("Spawner" in hScope.TFDB);
	}
	catch(e)
	{
		return false;
	}
}

function TFDB::Explosion(hCmdTable)
{
	local vClientPosition = hCmdTable.Performer.GetOrigin();

	switch(RandomInt(0, 4))
	{
		case 0 :
			PlayParticle(TFDB.PARTICLE_NUKE_1, vClientPosition, TFDB.PARTICLE_NUKE_1_ANGLES);
			break;
		case 1 :
			PlayParticle(TFDB.PARTICLE_NUKE_2, vClientPosition, TFDB.PARTICLE_NUKE_2_ANGLES);
			break;
		case 2 :
			PlayParticle(TFDB.PARTICLE_NUKE_3, vClientPosition, TFDB.PARTICLE_NUKE_3_ANGLES);
			break;
		case 3 :
			PlayParticle(TFDB.PARTICLE_NUKE_4, vClientPosition, TFDB.PARTICLE_NUKE_4_ANGLES);
			break;
		case 4 :
			PlayParticle(TFDB.PARTICLE_NUKE_5, vClientPosition, TFDB.PARTICLE_NUKE_5_ANGLES);
			break;
	}

	PlayParticle(TFDB.PARTICLE_NUKE_COLLUMN, vClientPosition, TFDB.PARTICLE_NUKE_COLLUMN_ANGLES);
}

function TFDB::Shockwave(hCmdTable, iDamage, fPushStrength, fRadius, fFalloffRadius)
{
	local iTeam = hCmdTable.Performer.GetTeam();
	local vPerformerPosition = hCmdTable.Performer.GetOrigin();
	local fDistanceToShockwave = 0.0;
	local fImpact = 0.0;
	local iFinalDamage = 0;
	local fFinalPush = 0.0;
	local vPlayerPosition = null;
	local vImpulse = null;
	local hClient = null;

	for (local iIndex = 1; iIndex <= MAX_PLAYERS; iIndex++)
	{
		hClient = PlayerInstanceFromIndex(iIndex);

		if (!IsValidClientEx(hClient, true) || (iTeam != hClient.GetTeam()))
		{
			continue;
		}

		vPlayerPosition = hClient.GetOrigin();
		fDistanceToShockwave = (vPerformerPosition - vPlayerPosition).Length();

		if (fDistanceToShockwave >= fRadius) continue;

		vImpulse = vPlayerPosition - vPerformerPosition;
		vImpulse.Norm();

		if (vImpulse.z < 0.4) { vImpulse.z = 0.4; vImpulse.Norm(); }

		if (fDistanceToShockwave < fFalloffRadius)
		{
			fFinalPush = fPushStrength;
			iFinalDamage = iDamage;
		}
		else
		{
			fImpact = (1.0 - ((fDistanceToShockwave - fFalloffRadius) / (fRadius - fFalloffRadius)));
			fFinalPush = fImpact * fPushStrength;
			iFinalDamage = floor(fImpact * iDamage);
		}

		vImpulse = vImpulse * fFinalPush;
		hClient.TakeDamage(iFinalDamage, 0, null);
		PushClient(hClient, vImpulse);
	}
}

function TFDB::SelectTarget(iTeam, hRocketEntity = null)
{
	local hTarget = null;
	local fTargetWeight = 0.0;
	local vRocketPosition = null;
	local vRocketDirection = null;
	local hRocketOwner = null;
	local hRocket = null;
	local hClient = null;

	if (hRocketEntity != null)
	{
		hRocketOwner = GetPropEntity(hRocketEntity, "m_hThrower");
		hRocket = hRocketEntity.GetScriptScope().TFDB.Rocket;
		vRocketPosition = hRocketEntity.GetOrigin();
	}

	for (local iIndex = 1; iIndex <= MAX_PLAYERS; iIndex++)
	{
		hClient = PlayerInstanceFromIndex(iIndex);

		if (!IsValidClientEx(hClient, true) ||
		    (iTeam && (hClient.GetTeam() != iTeam)) ||
		    (hClient == hRocketOwner))
		{
			continue;
		}

		local fNewWeight = RandomFloat(0.0, 100.0);

		if (hRocketEntity != null)
		{
			fNewWeight += (hRocket.Direction.Dot((hClient.EyePosition() - vRocketPosition))) * hRocket.Type.TargetWeight;
		}

		if ((hTarget == null) || fNewWeight >= fTargetWeight)
		{
			hTarget = hClient;
			fTargetWeight = fNewWeight;
		}
	}

	return hTarget;
}

function TFDB::PlayerThink()
{
	if (!::TFDB.IsEnabled) return;

	if (!::TFDB.AllowPrimaryAttack) SetPropInt(self, "m_nButtons", (GetPropInt(self, "m_nButtons") & ~IN_ATTACK));
}

function TFDB::BotThink()
{
	if (!::TFDB.IsEnabled || !::TFDB.RoundStarted || !::TFDB.BotDeflect) return;

	// https://github.com/Scags/TF2-Auto-Airblast/blob/master/tf/addons/sourcemod/scripting/autoairblast.sp

	local hProjectileEntity = null;
	local vBotEyes = self.EyePosition();
	local hWeapon = GetPropEntityArray(self, "m_hMyWeapons", 0);
	local vBotAngles = null;

	while (hProjectileEntity = Entities.FindByClassnameWithin(hProjectileEntity, "tf_projectile_*", vBotEyes, ::TFDB.BotDeflectRadius))
	{
		if (hProjectileEntity.GetClassname() == "tf_projectile_syringe" ||
		    (GetPropInt(hProjectileEntity, "m_iTeamNum") == self.GetTeam()))
		{
			continue;
		}

		if (HasProp(hProjectileEntity, "m_hOwnerEntity") && (GetPropEntity(hProjectileEntity, "m_hOwnerEntity") == self))
		{
			continue;
		}
		else if (HasProp(hProjectileEntity, "m_hThrower") && (GetPropEntity(hProjectileEntity, "m_hThrower") == self))
		{
			continue;
		}

		vBotAngles = VectorAngles(hProjectileEntity.GetOrigin() - vBotEyes);

		// https://github.com/lzardy/tf2db-advancedbot/blob/master/bot.sp#L1002

		if (vBotAngles.x >= 90.0) vBotAngles.x -= 360.0;

		self.SnapEyeAngles(vBotAngles);
		SetPropFloat(hWeapon, "m_flNextSecondaryAttack", 0);
		hWeapon.SecondaryAttack();
	}
}

function TFDB::SpawnerThink()
{
	local hSpawner = this.TFDB.Spawner;
	local hRocket = null;

	foreach (iIndex, hRocketEntity in hSpawner.FiredRockets)
	{
		if (!hRocketEntity.IsValid())
		{
			hSpawner.FiredRockets.remove(iIndex);

			continue;
		}

		hRocket = hRocketEntity.GetScriptScope().TFDB.Rocket;

		hRocket.OtherThink(hRocketEntity);
	}

	if (!::TFDB.IsEnabled ||
	    !BothTeamsPlaying() ||
	    (GetPropInt(self, "m_iHealth") != 1) ||
	    (Time() < hSpawner.NextSpawnTime) ||
	    !::TFDB.RoundStarted ||
	    (hSpawner.FiredRockets.len() >= hSpawner.Type.MaxRockets) ||
	    (GetPropInt(self, "m_iTeamNum") != ::TFDB.LastDeadTeam))
	{
		return;
	}

	hSpawner.CreateRocket(self);
}

function TFDB::PopulateSpawnPoints()
{
	local hSpawnerEntity = null;
	local strSpawnerName = "";
	local strSpawnerType = "";
	local hSpawnerScope = null;

	while (hSpawnerEntity = Entities.FindByClassname(hSpawnerEntity, "info_target"))
	{
		if (!hSpawnerEntity.ValidateScriptScope()) continue;

		hSpawnerScope = hSpawnerEntity.GetScriptScope();

		if (IsValidSpawner(hSpawnerScope)) continue;

		strSpawnerName = GetPropString(hSpawnerEntity, "m_iName");
		strSpawnerType = GetPropString(hSpawnerEntity, "m_iParent");

		if (((strSpawnerName.find("rocket_spawn_red") != null) || (strSpawnerName.find("tf_dodgeball_red") != null)))
		{
			if (strSpawnerType == "" || !(strSpawnerType in TFDB.SpawnerTypes))
			{
				strSpawnerType = "default_red";
			}

			hSpawnerScope.TFDB <- {};
			hSpawnerScope.TFDB.Spawner <- TFDB.Spawner(TFDB.SpawnerTypes[strSpawnerType]);
			HookCustomThink(hSpawnerEntity, "TFDB_SpawnerThink", TFDB.SpawnerThink);
			SetPropInt(hSpawnerEntity, "m_iTeamNum", TF_TEAM_RED);
			SetPropInt(hSpawnerEntity, "m_iHealth", 1);
		}
		else if (((strSpawnerName.find("rocket_spawn_blu") != null) || (strSpawnerName.find("tf_dodgeball_blu") != null)))
		{
			if (strSpawnerType == "" || !(strSpawnerType in TFDB.SpawnerTypes))
			{
				strSpawnerType = "default_blu";
			}

			hSpawnerScope.TFDB <- {};
			hSpawnerScope.TFDB.Spawner <- TFDB.Spawner(TFDB.SpawnerTypes[strSpawnerType]);
			HookCustomThink(hSpawnerEntity, "TFDB_SpawnerThink", TFDB.SpawnerThink);
			SetPropInt(hSpawnerEntity, "m_iTeamNum", TF_TEAM_BLUE);
			SetPropInt(hSpawnerEntity, "m_iHealth", 1);
		}
	}
}

function TFDB::RefreshSpawnPoints()
{
	local hSpawnerEntity = null;
	local strSpawnerName = "";
	local strSpawnerType = "";
	local hSpawnerScope = null;

	while (hSpawnerEntity = Entities.FindByClassname(hSpawnerEntity, "info_target"))
	{
		if (!hSpawnerEntity.ValidateScriptScope()) continue;

		hSpawnerScope = hSpawnerEntity.GetScriptScope();

		if (!IsValidSpawner(hSpawnerScope)) continue;

		strSpawnerName = GetPropString(hSpawnerEntity, "m_iName");
		strSpawnerType = GetPropString(hSpawnerEntity, "m_iParent");

		if (((strSpawnerName.find("rocket_spawn_red") != null) || (strSpawnerName.find("tf_dodgeball_red") != null)))
		{
			if (strSpawnerType == "" || !(strSpawnerType in TFDB.SpawnerTypes))
			{
				strSpawnerType = "default_red";
			}

			hSpawnerScope.TFDB.Spawner.Type = TFDB.SpawnerTypes[strSpawnerType];
		}
		else if (((strSpawnerName.find("rocket_spawn_blu") != null) || (strSpawnerName.find("tf_dodgeball_blu") != null)))
		{
			if (strSpawnerType == "" || !(strSpawnerType in TFDB.SpawnerTypes))
			{
				strSpawnerType = "default_blu";
			}

			hSpawnerScope.TFDB.Spawner.Type = TFDB.SpawnerTypes[strSpawnerType];
		}
	}
}

function TFDB::OnSetupFinished(hParams)
{
	if (!TFDB.IsEnabled || !BothTeamsPlaying() || TFDB.RoundStarted) return;

	TFDB.PopulateSpawnPoints();

	if (TFDB.LastDeadTeam == 0) TFDB.LastDeadTeam = RandomInt(TF_TEAM_RED, TF_TEAM_BLUE);

	TFDB.PlayerCount = CountPlayers();
	TFDB.RocketsFired = 0;
	TFDB.RoundStarted = true;
	TFDB.RoundCount++;
}

function TFDB::OnRoundStart(hParams)
{
	if (TFDB.TickModifier == -1)
	{
		TFDB.TickModifier = CalculateTickModifier();
	}

	if (!TFDB.IsEnabled || !TFDB.ResetStealsOnRound) return;

	local hClient = null;

	for (local iIndex = 1; iIndex <= MAX_PLAYERS; iIndex++)
	{
		hClient = PlayerInstanceFromIndex(iIndex);

		if (hClient == null) continue;

		hClient.GetScriptScope().TFDB.StolenRockets = 0;
	}
}

function TFDB::OnRoundEnd(hParams)
{
	TFDB.RoundStarted = false;

	local hClientEntity = null;

	while (hClientEntity = Entities.FindByClassname(hClientEntity, "passtime_ball"))
	{
		hClientEntity.KeyValueFromString("classname", "player");
	}
}

function TFDB::OnPlayerSpawn(hParams)
{
	if (!TFDB.IsEnabled) return;

	local hClient = GetPlayerFromUserID(hParams.userid);
	local hClientScope = null;

	if ((hParams.team == TF_TEAM_UNASSIGNED) && hClient.ValidateScriptScope())
	{
		hClientScope = hClient.GetScriptScope();

		if (!("TFDB" in hClientScope))
		{
			hClientScope.TFDB <- {};
			hClientScope.TFDB.StolenRockets <- 0;
			HookCustomThink(hClient, "TFDB_PlayerThink", TFDB.PlayerThink, -1);
		}
	}

	if (!IsPlayerAlive(hClient)) return;

	hClientScope = hClient.GetScriptScope();

	if (hParams["class"] == TF_CLASS_PYRO)
	{
		if (hClient.IsFakeClient() && !("IsFakeClient" in hClientScope.TFDB))
		{
			hClientScope.TFDB.IsFakeClient <- true;
			HookCustomThink(hClient, "TFDB_PlayerThink", TFDB.BotThink);
		}

		// https://github.com/lua9520/source-engine-2018-hl2_src/blob/master/game/shared/tf/tf_weapon_grenade_pipebomb.cpp#L746
		// Respawning on new rounds with this classname will break the player

		if ((GetRoundState() == GR_STATE_PREROUND) || TFDB.RoundStarted)
		{
			hClient.KeyValueFromString("classname", "passtime_ball");
		}

		return;
	}

	hClient.SetPlayerClass(TF_CLASS_PYRO);
	SetPropInt(hClient, "m_Shared.m_iDesiredPlayerClass", TF_CLASS_PYRO);
	hClient.ForceRegenerateAndRespawn();
}

function TFDB::OnPlayerDeath(hParams)
{
	if (!TFDB.IsEnabled || !TFDB.RoundStarted) return;

	local hAttacker = GetPlayerFromUserID(hParams.attacker);
	local hVictim = GetPlayerFromUserID(hParams.userid);

	hVictim.KeyValueFromString("classname", "player");

	if (TFDB.ResetStealsOnDeath)
	{
		hVictim.GetScriptScope().TFDB.StolenRockets = 0;
	}

	local hInflictor = EntIndexToHScript(hParams.inflictor_entindex);

	if ((hInflictor == null) || !hInflictor.ValidateScriptScope()) return;

	local hInflictorScope = hInflictor.GetScriptScope();

	if (!TFDB.IsValidRocket(hInflictorScope)) return;

	TFDB.LastDeadTeam = hVictim.GetTeam();

	local hRocket = hInflictorScope.TFDB.Rocket;

	if ((hRocket.Flags & TFDB.RocketFlags.OnExplodeCmd) && !(hRocket.State & TFDB.RocketStates.Exploded))
	{
		hRocket.ExecuteCommands(hRocket.Type.CmdsOnExplode, TFDB.CommandsTable(hInflictor, hVictim, hRocket.Target));
		hRocket.State = hRocket.State | TFDB.RocketStates.Exploded;
	}

	if (hRocket.Flags & TFDB.RocketFlags.OnKillCmd)
	{
		hRocket.ExecuteCommands(hRocket.Type.CmdsOnKill, TFDB.CommandsTable(hInflictor, hVictim, hRocket.Target));
	}
}

function TFDB::OnPlayerInventory(hParams)
{
	if (!TFDB.IsEnabled || !TFDB.RemoveNonPrimaries) return;

	local hClient = GetPlayerFromUserID(hParams.userid);
	local hWeapon = null;

	for (local iSlot = 1; iSlot < 5; iSlot++)
	{
		hWeapon = GetPropEntityArray(hClient, "m_hMyWeapons", iSlot);

		if (hWeapon != null) hWeapon.Kill();
	}

	hWeapon = GetPropEntityArray(hClient, "m_hMyWeapons", 0);
	hWeapon.AddAttribute("airblast_pushback_disabled", 1, -1);
}

function TFDB::OnObjectDeflected(hParams)
{
	if (!TFDB.IsEnabled) return;

	local hDeflected = EntIndexToHScript(hParams.object_entindex);

	if ((hDeflected == null) || !hDeflected.ValidateScriptScope()) return;

	local hDeflectedScope = hDeflected.GetScriptScope();

	if (!TFDB.IsValidRocket(hDeflectedScope)) return;

	local hRocket = hDeflectedScope.TFDB.Rocket;
	hRocket.Deflections++;

	if (hRocket.State & TFDB.RocketStates.Delayed)
	{
		hRocket.State = hRocket.State & ~TFDB.RocketStates.Delayed;
		hRocket.Speed = hRocket.Type.CalculateSpeed(hRocket.Type.CalculateModifier(hRocket.Deflections));
	}

	if (hRocket.Flags & TFDB.RocketFlags.ResetBounces)
	{
		hRocket.Bounces = 0;
	}

	if (hRocket.Flags & TFDB.RocketFlags.IsNeutral)
	{
		SetPropInt(hDeflected, "m_iTeamNum", TF_TEAM_SPECTATOR);
	}

	local hDeflector = GetPlayerFromUserID(hParams.userid);
	local fModifier = hRocket.Type.CalculateModifier(hRocket.Deflections);

	hRocket.State = (hRocket.State | (TFDB.RocketStates.CanDrag | TFDB.RocketStates.Deflected)) & ~(TFDB.RocketStates.Stolen);
	hRocket.Direction = hDeflector.EyeAngles().Forward();
	hRocket.UpdateSkin(hDeflected, GetPropInt(hDeflector, "m_iTeamNum"));
	hRocket.LastDeflectionTime = Time();
	hRocket.Speed = hRocket.Type.CalculateSpeed(fModifier);
	SetPropFloat(hDeflected, "m_flDamage", hRocket.Type.CalculateDamage(fModifier));
	SetPropInt(hRocket.Projectile, "m_iTeamNum", GetPropInt(hDeflected, "m_iTeamNum"));
	SetPropInt(hRocket.Projectile, "m_iDeflected", hRocket.Deflections % 2);
	SetPropEntity(hRocket.Projectile, "m_hOwnerEntity", hDeflector);

	if ((hRocket.Flags & TFDB.RocketFlags.IsSpeedLimited) && (hRocket.Speed >= hRocket.Type.SpeedLimit))
	{
		hRocket.Speed = hRocket.Type.SpeedLimit;
	}

	if (!(hRocket.Flags & TFDB.RocketFlags.CanBeStolen)) hRocket.CheckSteal(hDeflector);

	if (TFDB.NoDamageOnSteal && (hRocket.State & TFDB.RocketStates.Stolen))
	{
		SetPropFloat(hDeflected, "m_flDamage", 0);
	}
}

function TFDB::OnScriptHook_OnTakeDamage(hParams)
{
	local hInflictorScope = hParams.inflictor.GetScriptScope();

	if (!TFDB.IsValidRocket(hInflictorScope)) return;

	local hRocket = hInflictorScope.TFDB.Rocket;

	if ((hRocket.Flags & TFDB.RocketFlags.IsNeutral))
	{
		hParams.force_friendly_fire = true;
	}

	if (TFDB.DamageOnlyTarget && (hParams.const_entity != hRocket.Target))
	{
		hParams.damage = 0;
	}
}

function TFDB::EnableDodgeball()
{
	if (TFDB.IsEnabled) return;

	Convars.SetValue("tf_flamethrower_burstammo", "0");
	Convars.SetValue("tf_arena_use_queue", "0");
	Convars.SetValue("tf_avoidteammates_pushaway", "0");
	Convars.SetValue("sv_alltalk", "1");
	Convars.SetValue("mp_bonusroundtime", "5");
	Convars.SetValue("mp_chattime", "5");
	Convars.SetValue("mp_winlimit", "15");

	try { IncludeScript("classes.nut"); } catch(e) {}
	try { IncludeScript(GetMapName()+".nut"); } catch(e) {}

	if (TFDB.RocketTypes.len() == 0) printl("No rocket classes / types defined.");
	if (TFDB.SpawnerTypes.len() == 0) printl("No spawner classes / types defined.");

	if (!("default_red" in TFDB.SpawnerTypes)) printl("No default spawner class / type (default_red) defined for RED.");
	if (!("default_blu" in TFDB.SpawnerTypes)) printl("No default spawner class / type (default_blu) defined for BLU.");

	if (!TFDB.AlreadySetUp)
	{
		PrecacheParticle(TFDB.PARTICLE_NUKE_1);
		PrecacheParticle(TFDB.PARTICLE_NUKE_2);
		PrecacheParticle(TFDB.PARTICLE_NUKE_3);
		PrecacheParticle(TFDB.PARTICLE_NUKE_4);
		PrecacheParticle(TFDB.PARTICLE_NUKE_5);
		PrecacheParticle(TFDB.PARTICLE_NUKE_COLLUMN);

		PrecacheSound(TFDB.SOUND_DEFAULT_SPAWN);
		PrecacheSound(TFDB.SOUND_DEFAULT_BEEP);
		PrecacheSound(TFDB.SOUND_DEFAULT_ALERT);
		PrecacheSound(TFDB.SOUND_DEFAULT_DELAY);
	}

	TFDB.IsEnabled = true;
	TFDB.RoundStarted = false;
	TFDB.RoundCount = 0;

	HookEvent("teamplay_round_start", TFDB.OnRoundStart, TFDB);
	HookEvent(!IsInArenaMode() ? "teamplay_round_active" : "arena_round_start", TFDB.OnSetupFinished, TFDB);
	HookEvent("teamplay_round_win", TFDB.OnRoundEnd, TFDB);
	HookEvent("player_spawn", TFDB.OnPlayerSpawn, TFDB);
	HookEvent("player_death", TFDB.OnPlayerDeath, TFDB);
	HookEvent("post_inventory_application", TFDB.OnPlayerInventory, TFDB);
	HookEvent("object_deflected", TFDB.OnObjectDeflected, TFDB);

	if (!CountPlayers(false)) return;

	if (TFDB.TickModifier == -1)
	{
		TFDB.TickModifier = CalculateTickModifier();
	}

	local hClient = null;
	local hClientScope = null;
	local hWeapon = null;

	local iRoundRunning = !IsInArenaMode() ? GR_STATE_RND_RUNNING : GR_STATE_STALEMATE;
	local iRoundState = GetRoundState();

	for (local iIndex = 1; iIndex <= MAX_PLAYERS; iIndex++)
	{
		hClient = PlayerInstanceFromIndex(iIndex);

		if (hClient == null || !hClient.ValidateScriptScope()) continue;

		hClientScope = hClient.GetScriptScope();

		if (!("TFDB" in hClientScope))
		{
			hClientScope.TFDB <- {};
			hClientScope.TFDB.StolenRockets <- 0;
			HookCustomThink(hClient, "TFDB_PlayerThink", TFDB.PlayerThink, -1);

			if (hClient.IsFakeClient() && !("IsFakeClient" in hClientScope.TFDB))
			{
				hClientScope.TFDB.IsFakeClient <- true;
				HookCustomThink(hClient, "TFDB_PlayerThink", TFDB.BotThink);
			}
		}

		if (!IsPlayerAlive(hClient)) continue;

		if (hClient.GetPlayerClass() != TF_CLASS_PYRO)
		{
			hClient.SetPlayerClass(TF_CLASS_PYRO);
			SetPropInt(hClient, "m_Shared.m_iDesiredPlayerClass", TF_CLASS_PYRO);
			hClient.ForceRegenerateAndRespawn();

			if (!TFDB.AlreadySetUp)
			{
				hClient.Weapon_Switch(GetPropEntityArray(hClient, "m_hMyWeapons", 0));

				for (local iSlot = 1; iSlot < 5; iSlot++)
				{
					hWeapon = GetPropEntityArray(hClient, "m_hMyWeapons", iSlot);

					if (hWeapon != null) hWeapon.Kill();
				}

				hWeapon = GetPropEntityArray(hClient, "m_hMyWeapons", 0);
				hWeapon.AddAttribute("airblast_pushback_disabled", 1, -1);

				if ((iRoundState == iRoundRunning) || (iRoundState == GR_STATE_PREROUND))
				{
					hClient.KeyValueFromString("classname", "passtime_ball");
				}
			}

			continue;
		}

		hClient.Weapon_Switch(GetPropEntityArray(hClient, "m_hMyWeapons", 0));

		for (local iSlot = 1; iSlot < 5; iSlot++)
		{
			hWeapon = GetPropEntityArray(hClient, "m_hMyWeapons", iSlot);

			if (hWeapon != null) hWeapon.Kill();
		}

		hWeapon = GetPropEntityArray(hClient, "m_hMyWeapons", 0);
		hWeapon.AddAttribute("airblast_pushback_disabled", 1, -1);

		if ((iRoundState == iRoundRunning) || (iRoundState == GR_STATE_PREROUND))
		{
			hClient.KeyValueFromString("classname", "passtime_ball");
		}
	}

	if (iRoundState == iRoundRunning)
	{
		TFDB.OnSetupFinished(null);
	}
}

TFDB.EnableDodgeball();

function TFDB::DisableDodgeball()
{
	if (!TFDB.IsEnabled) return;

	local hClientEntity = null;

	while (hClientEntity = Entities.FindByClassname(hClientEntity, "passtime_ball"))
	{
		hClientEntity.KeyValueFromString("classname", "player");
	}

	Convars.SetValue("tf_flamethrower_burstammo", "20");
	Convars.SetValue("tf_arena_use_queue", "1");
	Convars.SetValue("tf_avoidteammates_pushaway", "1");
	Convars.SetValue("sv_alltalk", "0");
	Convars.SetValue("mp_bonusroundtime", "15");
	Convars.SetValue("mp_chattime", "10");
	Convars.SetValue("mp_winlimit", "0");

	TFDB.IsEnabled = false;
	TFDB.RoundStarted = false;
	TFDB.RoundCount = 0;

	UnhookEvent("teamplay_round_start", TFDB.OnRoundStart, TFDB);
	UnhookEvent(!IsInArenaMode() ? "teamplay_round_active" : "arena_round_start", TFDB.OnSetupFinished, TFDB);
	UnhookEvent("teamplay_round_win", TFDB.OnRoundEnd, TFDB);
	UnhookEvent("player_spawn", TFDB.OnPlayerSpawn, TFDB);
	UnhookEvent("player_death", TFDB.OnPlayerDeath, TFDB);
	UnhookEvent("post_inventory_application", TFDB.OnPlayerInventory, TFDB);
	UnhookEvent("object_deflected", TFDB.OnObjectDeflected, TFDB);
}

try { IncludeScript("tfdb_custom/main.nut"); } catch(e) {}
try { IncludeScript("tfdb_custom/"+GetMapName()+".nut"); } catch(e) {}

__CollectGameEventCallbacks(TFDB);

TFDB.AlreadySetUp <- true;
