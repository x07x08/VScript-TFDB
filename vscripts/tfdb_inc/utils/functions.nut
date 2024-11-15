function IsPlayerAlive(hClient)
{
	return GetPropInt(hClient, "m_lifeState") == LIFE_ALIVE;
}

function CreateAttachedParticle(hEntity, strParticleName, iAttachmentType, strBone)
{
	local hParticle = SpawnEntityFromTable("trigger_particle", {
		particle_name = strParticleName,
		attachment_type = iAttachmentType,
		spawnflags = 64,
		attachment_name = strBone
	});

	hParticle.AcceptInput("StartTouch", "!activator", hEntity, hEntity);
	hParticle.Kill();
}

function IsValidClient(hClient, bAlive = false)
{
	try
	{
		return hClient != null && hClient.IsValid() && hClient.IsPlayer() && (!bAlive || IsPlayerAlive(hClient));
	}
	catch(e)
	{
		return false;
	}
}

function IsValidClientEx(hClient, bAlive = false)
{
	try
	{
		return hClient != null && (!bAlive || IsPlayerAlive(hClient));
	}
	catch(e)
	{
		return false;
	}
}

function BothTeamsPlaying()
{
	local bRedFound, bBluFound;

	for (local iIndex = 1; iIndex <= MAX_PLAYERS; iIndex++)
	{
		local hClient = PlayerInstanceFromIndex(iIndex);

		if (!IsValidClientEx(hClient, true)) continue;

		local iTeam = hClient.GetTeam();

		if (iTeam == TF_TEAM_RED)
		{
			bRedFound = true;
		}
		else if (iTeam == TF_TEAM_BLUE)
		{
			bBluFound = true;
		}
	}

	return bRedFound && bBluFound;
}

function CountPlayers(bAliveOnly = true)
{
	local iCount = 0;

	for (local iIndex = 1; iIndex <= MAX_PLAYERS; iIndex++)
	{
		if (IsValidClientEx(PlayerInstanceFromIndex(iIndex), bAliveOnly)) iCount++;
	}

	return iCount;
}

function GetClientName(hClient)
{
	return GetPropString(hClient, "m_szNetname");
}

function GetAnalogueTeam(iTeam)
{
	if (iTeam == TF_TEAM_RED) return TF_TEAM_BLUE;

	return TF_TEAM_RED;
}

function Min(a, b)
{
	return (a < b) ? a : b;
}

function Max(a, b)
{
	return (a > b) ? a : b;
}

function CalculateTickModifier()
{
	return 0.1 / FrameTime();
}

function LerpVectors(vA, vB, t)
{
	(t < 0.0) ? 0.0 : (t > 1.0) ? 1.0 : t;

	return vA + (vB - vA) * t;
}

function PrecacheParticle(strParticle)
{
	PrecacheEntityFromTable({ classname = "info_particle_system", effect_name = strParticle });
}

// https://tf2maps.net/downloads/vs-saxton-hale-vscript.15067/
// /vssaxtonhale/__lizardlib/player_util.nut

function PushClient(hClient, vForce)
{
	SetPropEntity(hClient, "m_hGroundEntity", null);
	hClient.ApplyAbsVelocityImpulse(vForce);
	hClient.RemoveFlag(FL_ONGROUND);
}

function PlayParticle(strParticle, vPosition, vAngles, fStopTime = 5.0, fKillTime = 9.0)
{
	local hParticleEntity = SpawnEntityFromTable("info_particle_system",
	{
		effect_name = strParticle,
		start_active = 1
	});

	if (hParticleEntity == null) return;

	hParticleEntity.Teleport(true, vPosition, true, vAngles, false, Vector());
	DoEntFire("!self", "Stop", "", fStopTime, null, hParticleEntity);
	DoEntFire("!self", "Kill", "", fKillTime, null, hParticleEntity);
}

// https://github.com/samisalreadytaken/vs_library/blob/master/src/vs_math.nut

const RAD2DEG = 57.295779513; // 180 / PI = 57.29577951308232087679

//-----------------------------------------------------------------------
// Forward direction vector -> Euler QAngle
//-----------------------------------------------------------------------
function VectorAngles(forward)
{
	local yaw = 0.0;
	local pitch = yaw;

	if (!forward.y && !forward.x)
	{
		if (forward.z > 0.0)
			pitch = 270.0;
		else
			pitch = 90.0;
	}
	else
	{
		yaw = atan2(forward.y, forward.x) * RAD2DEG;
		if (yaw < 0.0)
			yaw += 360.0;

		pitch = atan2(-forward.z, forward.Length2D()) * RAD2DEG;
		if (pitch < 0.0)
			pitch += 360.0;
	};

	return QAngle(pitch, yaw, 0.0);
}
