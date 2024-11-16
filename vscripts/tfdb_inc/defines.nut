::TFDB <- {};

TFDB.SOUND_DEFAULT_SPAWN          <- "weapons/sentry_rocket.wav";
TFDB.SOUND_DEFAULT_BEEP           <- "weapons/sentry_scan.wav";
TFDB.SOUND_DEFAULT_ALERT          <- "weapons/sentry_spot.wav";
TFDB.SOUND_DEFAULT_DELAY          <- "misc/doomsday_lift_warning.wav";
TFDB.PARTICLE_NUKE_1              <- "fireSmokeExplosion";
TFDB.PARTICLE_NUKE_2              <- "fireSmokeExplosion_track";
TFDB.PARTICLE_NUKE_3              <- "fireSmokeExplosion2";
TFDB.PARTICLE_NUKE_4              <- "fireSmokeExplosion3";
TFDB.PARTICLE_NUKE_5              <- "fireSmokeExplosion4";
TFDB.PARTICLE_NUKE_COLLUMN        <- "fireSmoke_collumnP";
TFDB.PARTICLE_NUKE_1_ANGLES       <- QAngle(270.0, 0.0, 0.0);
TFDB.PARTICLE_NUKE_2_ANGLES       <- TFDB.PARTICLE_NUKE_1_ANGLES;
TFDB.PARTICLE_NUKE_3_ANGLES       <- TFDB.PARTICLE_NUKE_1_ANGLES;
TFDB.PARTICLE_NUKE_4_ANGLES       <- TFDB.PARTICLE_NUKE_1_ANGLES;
TFDB.PARTICLE_NUKE_5_ANGLES       <- TFDB.PARTICLE_NUKE_1_ANGLES;
TFDB.PARTICLE_NUKE_COLLUMN_ANGLES <- TFDB.PARTICLE_NUKE_1_ANGLES;
TFDB.ROCKET_MODEL                 <- "models/weapons/w_models/w_rocket.mdl";

class TFDB.RocketFlags
{
	None             = 0;
	PlaySpawnSound   = 1 << 0; // Self-explanatory
	PlayBeepSound    = 1 << 1; // Self-explanatory
	PlayAlertSound   = 1 << 2; // Self-explanatory
	PlayDelaySound   = 1 << 3; // Self-explanatory
	ElevateOnDeflect = 1 << 4; // Makes the rocket go upwards after a deflect
	IsNeutral        = 1 << 5; // The target's team will be completely ignored (no need for mp_friendlyfire)
	OnSpawnCmd       = 1 << 6; // Self-explanatory
	OnDeflectCmd     = 1 << 7; // Self-explanatory
	OnKillCmd        = 1 << 8; // Self-explanatory
	OnExplodeCmd     = 1 << 9; // Onkillcmd but triggered only once (useful for AOE effects)
	CustomModel      = 1 << 10; // Self-explanatory
	CustomSpawnSound = 1 << 11; // Self-explanatory
	CustomBeepSound  = 1 << 12; // Self-explanatory
	CustomAlertSound = 1 << 13; // Self-explanatory
	IsTRLimited      = 1 << 14; // Turn rate limit
	IsSpeedLimited   = 1 << 15; // Self-explanatory
	KeepDirection    = 1 << 16; // When touching the ground, the rocket will try to go down again (a.k.a downspike)
	TeamlessHits     = 1 << 17; // The owner of the rocket can deflect again instead of only once
	ResetBounces     = 1 << 18; // Resets the internal bounces count on deflect
	NoBounceDrags    = 1 << 19; // Disables rocket dragging (direction change) when touching the ground
	OnNoTargetCmd    = 1 << 20; // Command to execute when the rocket's target becomes invalid
	CanBeStolen      = 1 << 21; // Checks if the last deflector is the right one
	StealTeamCheck   = 1 << 22; // Checks if the stealer is on the target's team
	CustomDelaySound = 1 << 23; // Self-explanatory
	LegacyElevation  = 1 << 24; // Does elevation checks once every 0.1 seconds
}

class TFDB.RocketStates
{
	None          = 0;
	Bouncing      = 1 << 0;
	Stolen        = 1 << 1;
	Delayed       = 1 << 2;
	CanDrag       = 1 << 3;
	Exploded      = 1 << 4;
	Elevating     = 1 << 5;
	Deflected     = 1 << 6;
}

class TFDB.CommandsTable
{
	RocketEntity = null;
	Performer    = null; // Who caused the event
	Target       = null;

	constructor(a, b, c)
	{
		this.RocketEntity = a;
		this.Performer    = b;
		this.Target       = c;
	}
}

class TFDB.Rocket
{
	Type               = null;
	Target             = null;
	Particle           = null;
	Flags              = TFDB.RocketFlags.None;
	State              = TFDB.RocketStates.None;
	Speed              = 0.0;
	Direction          = null;
	Deflections        = 0;
	LastDeflectionTime = 0.0;
	LastBeepTime       = 0.0;
	SpawnTime          = 0.0;
	Bounces            = 0;

	constructor(a)
	{
		this.Type               = a;
		this.Target             = null;
		this.Flags              = a.Flags;
		this.State              = TFDB.RocketStates.None;
		this.Speed              = 0.0;
		this.Direction          = null;
		this.Deflections        = 0;
		this.LastDeflectionTime = 0.0;
		this.LastBeepTime       = 0.0;
		this.SpawnTime          = 0.0;
		this.Bounces            = 0;
	}

	function EmitSpawnSound(hRocketEntity)
	{
		if (!(this.Flags & TFDB.RocketFlags.PlaySpawnSound)) return;

		EmitSoundEx(
		{
			sound_name = (this.Flags & TFDB.RocketFlags.CustomSpawnSound) ? this.Type.SpawnSound : TFDB.SOUND_DEFAULT_SPAWN,
			sound_level = 75,
			entity = hRocketEntity
		});
	}

	function EmitBeepSound(hRocketEntity)
	{
		if (!(this.Flags & TFDB.RocketFlags.PlayBeepSound)) return;

		EmitSoundEx(
		{
			sound_name = (this.Flags & TFDB.RocketFlags.CustomBeepSound) ? this.Type.BeepSound : TFDB.SOUND_DEFAULT_BEEP,
			sound_level = 75,
			entity = hRocketEntity
		});
	}

	function EmitAlertSound(hClient)
	{
		if (!(this.Flags & TFDB.RocketFlags.PlayAlertSound)) return;

		EmitSoundEx(
		{
			sound_name = (this.Flags & TFDB.RocketFlags.CustomAlertSound) ? this.Type.AlertSound : TFDB.SOUND_DEFAULT_ALERT,
			sound_level = 75,
			entity = hClient,
			filter_type = RECIPIENT_FILTER_SINGLE_PLAYER
		});
	}

	function EmitDelaySound(hRocketEntity)
	{
		if (!(this.Flags & TFDB.RocketFlags.PlayDelaySound)) return;

		EmitSoundEx(
		{
			sound_name = (this.Flags & TFDB.RocketFlags.CustomDelaySound) ? this.Type.DelaySound : TFDB.SOUND_DEFAULT_DELAY,
			sound_level = 75,
			entity = hRocketEntity
		});
	}

	function UpdateSkin(hRocketEntity, iTeam)
	{
		if (this.Flags & TFDB.RocketFlags.IsNeutral)
		{
			DoEntFire("!self", "Skin", "2", 0, null, hRocketEntity);

			return;
		}

		DoEntFire("!self", "Skin", (iTeam == TF_TEAM_BLUE) ? "0" : "1", 0, null, hRocketEntity);
	}

	function CalculateDirectionToClient(hRocketEntity)
	{
		local vTemp = this.Target.EyePosition() - hRocketEntity.GetOrigin();
		vTemp.Norm();

		return vTemp;
	}

	function ApplyParameters(hRocketEntity)
	{
		hRocketEntity.SetAbsVelocity(this.Direction.Scale(this.Speed));
		hRocketEntity.SetForwardVector(this.Direction);
	}

	function ExecuteCommands(hFuncs, hCommandTable)
	{
		foreach (iIndex, funcCommand in hFuncs)
		{
			funcCommand(hCommandTable);
		}
	}

	function CheckSteal(hRocketEntity, hDeflector)
	{
		if (!(this.Target != hDeflector &&
		    ((this.Target.GetOrigin() - hDeflector.GetOrigin()).Length() > TFDB.StealDistance) &&
		    (!(this.Flags & TFDB.RocketFlags.StealTeamCheck) || (this.Target.GetTeam() == hDeflector.GetTeam())) &&
		    !(this.State & TFDB.RocketStates.Delayed)))
		{
			return;
		}

		this.State = this.State | TFDB.RocketStates.Stolen;

		if (TFDB.NoDamageOnSteal) SetPropFloat(hRocketEntity, "m_flDamage", 0);

		if (this.Flags & TFDB.RocketFlags.CanBeStolen)
		{
			return;
		}

		local hStealer = hDeflector.GetScriptScope().TFDB;

		if (hStealer.StolenRockets < TFDB.MaxSteals)
		{
			hStealer.StolenRockets++;
			CPrintToChat(hDeflector, "{default}Do not steal rockets. [Warning {darkorange}%i{default} / {darkorange}%i{default}]", hStealer.StolenRockets, TFDB.MaxSteals);
		}
		else
		{
			hDeflector.TakeDamage(hDeflector.GetHealth(), 0, null);
			CPrintToChat(hDeflector, "You have been slain for stealing rockets.");
		}
	}

	function CheckDelay(hRocketEntity)
	{
		local fTimeToCheck = (this.Deflections == 0) ? this.SpawnTime : this.LastDeflectionTime;

		if (((Time() - fTimeToCheck) < TFDB.DelayTimeLimit) ||
		    ((hRocketEntity.GetOrigin() - this.Target.GetOrigin()).Length() > TFDB.DelayDistance))
		{
			return;
		}

		if (!(this.State & TFDB.RocketStates.Delayed))
		{
			CPrintToChat(null, "{darkorange}%s{default} is delaying, the rocket will now speed up.", GetClientName(this.Target));
			this.EmitDelaySound(hRocketEntity);
			this.State = this.State | TFDB.RocketStates.Delayed;
		}
		else
		{
			this.Speed += TFDB.DelaySpeed;
		}
	}

	function HomingThink(hRocketEntity)
	{
		if (!TFDB.IsEnabled || !TFDB.RoundStarted)
		{
			hRocketEntity.Kill();

			return;
		}

		local iTargetTeam = (this.Flags & TFDB.RocketFlags.IsNeutral) ? TF_TEAM_UNASSIGNED : GetAnalogueTeam(GetPropInt(hRocketEntity, "m_iTeamNum"));
		local hOwner = GetPropEntity(hRocketEntity, "m_hThrower");

		if ((Time() - this.LastDeflectionTime) <= (this.Type.DragTimeMax + FrameTime()))
		{
			if ((this.Type.DragTimeMin <= (Time() - this.LastDeflectionTime)) && (this.State & TFDB.RocketStates.CanDrag))
			{
				this.Direction = hOwner.EyeAngles().Forward();
			}
		}
		else
		{
			if (!IsValidClient(this.Target, true))
			{
				local hOldTarget = this.Target;
				this.Target = TFDB.SelectTarget(iTargetTeam, hRocketEntity);

				if (this.Target == null)
				{
					hRocketEntity.Kill();

					return;
				}

				this.EmitAlertSound(this.Target);

				if (TFDB.NoDamageOnNoTarget) SetPropFloat(hRocketEntity, "m_flDamage", 0);

				if (this.Flags & TFDB.RocketFlags.OnNoTargetCmd)
				{
					hRocket.ExecuteCommands(hRocket.Type.CmdsOnNoTarget, TFDB.CommandsTable(hRocketEntity, hOldTarget, this.Target));
				}
			}
			else if (this.State & TFDB.RocketStates.Deflected)
			{
				this.State = this.State & ~(TFDB.RocketStates.CanDrag | TFDB.RocketStates.Deflected);
				this.Target = TFDB.SelectTarget(iTargetTeam, hRocketEntity);

				if (this.Target == null)
				{
					hRocketEntity.Kill();

					return;
				}

				if (this.Flags & TFDB.RocketFlags.ElevateOnDeflect)
				{
					this.State = this.State | TFDB.RocketStates.Elevating;
				}

				if (this.Flags & TFDB.RocketFlags.TeamlessHits)
				{
					SetPropInt(hRocketEntity, "m_iTeamNum", TF_TEAM_SPECTATOR);
				}

				this.EmitAlertSound(this.Target);

				if (this.Flags & TFDB.RocketFlags.OnDeflectCmd)
				{
					hRocket.ExecuteCommands(hRocket.Type.CmdsOnDeflect, TFDB.CommandsTable(hRocketEntity, hOwner, this.Target));
				}
			}
			else
			{
				if ((Time() - this.LastDeflectionTime) >= this.Type.ControlDelay)
				{
					local fTurnrate = this.Type.CalculateTurnrate(this.Type.CalculateModifier(this.Deflections)) / TFDB.TickModifier;
					local vDirectionToTarget = this.CalculateDirectionToClient(hRocketEntity);

					if (this.State & TFDB.RocketStates.Elevating)
					{
						if (this.Flags & TFDB.RocketFlags.LegacyElevation)
						{
							vDirectionToTarget.z = this.Direction.z;
						}
						else
						{
							if (this.Direction.z < this.Type.ElevationLimit)
							{
								vDirectionToTarget.z = this.Direction.z;
							}
							else
							{
								this.State = this.State & ~(TFDB.RocketStates.Elevating);
							}
						}
					}

					if ((this.Flags & TFDB.RocketFlags.IsTRLimited) && (fTurnrate >= this.Type.TurnrateLimit / TFDB.TickModifier))
					{
						fTurnrate = this.Type.TurnrateLimit / TFDB.TickModifier;
					}

					this.Direction = LerpVectors(this.Direction, vDirectionToTarget, fTurnrate);
				}
			}
		}

		if (!(this.State & TFDB.RocketStates.Bouncing))
		{
			this.ApplyParameters(hRocketEntity);
		}

		this.HandleCollision(hRocketEntity);
	}

	function OtherThink(hRocketEntity)
	{
		this.State = this.State & ~(TFDB.RocketStates.Bouncing);

		if (this.State & TFDB.RocketStates.Deflected) return;

		if (((Time() - this.LastDeflectionTime) >= this.Type.ControlDelay) &&
		    (this.State & TFDB.RocketStates.Elevating))
		{
			if (this.Direction.z < this.Type.ElevationLimit)
			{
				this.Direction.z = Min(this.Direction.z + this.Type.ElevationRate, this.Type.ElevationLimit);
			}
			else if (this.Flags & TFDB.RocketFlags.LegacyElevation)
			{
				this.State = this.State & ~(TFDB.RocketStates.Elevating);
			}
		}

		if ((Time() - this.LastBeepTime) >= this.Type.BeepInterval)
		{
			this.EmitBeepSound(hRocketEntity);
			this.LastBeepTime = Time();
		}

		if (TFDB.CheckForDelay) this.CheckDelay(hRocketEntity);
	}

	function HandleCollision(hRocketEntity)
	{
		local vRocketPosition = hRocketEntity.GetOrigin();

		local hTraceOutput =
		{
			start = vRocketPosition,
			end = vRocketPosition + this.Direction * TFDB.TraceLength,
			mask = (CONTENTS_SOLID|CONTENTS_MOVEABLE|CONTENTS_MONSTER|CONTENTS_WINDOW|CONTENTS_DEBRIS|CONTENTS_GRATE),
			ignore = hRocketEntity
		}

		if (!TraceLineEx(hTraceOutput) ||
		    !hTraceOutput.hit ||
		    (("enthit" in hTraceOutput) && hTraceOutput.enthit.IsPlayer()))
		{
			return;
		}

		if (this.Bounces >= this.Type.MaxBounces)
		{
			hRocketEntity.Kill();

			return;
		}

		this.Bounce(hTraceOutput.plane_normal, hRocketEntity);
	}

	function Bounce(vNormal, hRocketEntity)
	{
		local vRocketVelocity = hRocketEntity.GetAbsVelocity();
		local vBounceDirection = vRocketVelocity - vNormal * vNormal.Dot(vRocketVelocity) * 2 * this.Type.BounceScale;

		hRocketEntity.SetForwardVector(vBounceDirection);
		hRocketEntity.SetAbsVelocity(vBounceDirection);

		this.Bounces++;

		if (this.Flags & TFDB.RocketFlags.NoBounceDrags)
		{
			this.State = this.State & ~(TFDB.RocketStates.CanDrag);
		}

		if ((this.State & TFDB.RocketStates.Delayed) || (this.Flags & TFDB.RocketFlags.KeepDirection))
		{
			this.State = this.State | TFDB.RocketStates.Bouncing;
		}
		else
		{
			vBounceDirection.Norm();
			this.Direction = vBounceDirection;
		}
	}

	function UpdateParticles(hRocketEntity, iTeam)
	{
		if ((this.Deflections - 1) < TFDB.MaxTrails)
		{
			CreateAttachedParticle(hRocketEntity, "rockettrail", PATTACH_ABSORIGIN_FOLLOW, "");
		}

		if (this.Particle != null)
		{
			if (this.Particle.IsValid())
			{
				this.Particle.Kill();
			}
			else
			{
				this.Particle = null;

				return;
			}

			this.Particle = null;
		}

		if (GetPropInt(hRocketEntity, "m_bCritical") != 1)
		{
			return;
		}

		local strEffect = "eyeboss_projectile";

		switch (iTeam)
		{
			case TF_TEAM_BLUE:
				strEffect = "critical_rocket_blue";

				break;
			case TF_TEAM_RED:
				strEffect = "critical_rocket_red";

				break;
		}

		local hParticleEntity = SpawnEntityFromTable("info_particle_system", {
			start_active = true,
			effect_name = strEffect
		});

		if (hParticleEntity == null)
		{
			return;
		}

		hParticleEntity.Teleport(
			true, hRocketEntity.GetOrigin(),
			true, hRocketEntity.GetAbsAngles(),
			false, Vector()
		);

		// EntFire doesn't seem to work? I wasted too much time on this
		hParticleEntity.AcceptInput("SetParent", "!activator", hRocketEntity, hParticleEntity);

		if (hRocketEntity.LookupAttachment("trail") != 0)
		{
			hParticleEntity.AcceptInput("SetParentAttachment", "trail", null, hParticleEntity);
		}

		this.Particle = hParticleEntity;
	}
}

class TFDB.RocketType
{
	Name              = "";
	Model             = "";
	Flags             = TFDB.RocketFlags.None;
	BeepInterval      = 0;
	SpawnSound        = "";
	BeepSound         = "";
	AlertSound        = "";
	DelaySound        = "";
	CritChance        = 0.0;
	Damage            = 0.0;
	DamageIncrement   = 0.0;
	Speed             = 0.0;
	SpeedIncrement    = 0.0;
	SpeedLimit        = 0.0;
	Turnrate          = 0.0;
	TurnrateIncrement = 0.0;
	TurnrateLimit     = 0.0;
	ElevationRate     = 0.0;
	ElevationLimit    = 0.0;
	RocketsModifier   = 0.0;
	PlayerModifier    = 0.0;
	ControlDelay      = 0.0;
	DragTimeMin       = 0.0;
	DragTimeMax       = 0.0;
	TargetWeight      = 0.0;
	CmdsOnSpawn       = "";
	CmdsOnDeflect     = "";
	CmdsOnKill        = "";
	CmdsOnExplode     = "";
	CmdsOnNoTarget    = "";
	MaxBounces        = 0;
	BounceScale       = 0.0;

	constructor(...)
	{
		this.Name              = vargv[0];
		this.Model             = vargv[1];
		this.Flags             = vargv[2];
		this.BeepInterval      = vargv[3];
		this.SpawnSound        = vargv[4];
		this.BeepSound         = vargv[5];
		this.AlertSound        = vargv[6];
		this.DelaySound        = vargv[7];
		this.CritChance        = vargv[8];
		this.Damage            = vargv[9];
		this.DamageIncrement   = vargv[10];
		this.Speed             = vargv[11];
		this.SpeedIncrement    = vargv[12];
		this.SpeedLimit        = vargv[13];
		this.Turnrate          = vargv[14];
		this.TurnrateIncrement = vargv[15];
		this.TurnrateLimit     = vargv[16];
		this.ElevationRate     = vargv[17];
		this.ElevationLimit    = vargv[18];
		this.RocketsModifier   = vargv[19];
		this.PlayerModifier    = vargv[20];
		this.ControlDelay      = vargv[21];
		this.DragTimeMin       = vargv[22];
		this.DragTimeMax       = vargv[23];
		this.TargetWeight      = vargv[24];
		this.CmdsOnSpawn       = vargv[25];
		this.CmdsOnDeflect     = vargv[26];
		this.CmdsOnKill        = vargv[27];
		this.CmdsOnExplode     = vargv[28];
		this.CmdsOnNoTarget    = vargv[29];
		this.MaxBounces        = vargv[30];
		this.BounceScale       = vargv[31];
	}

	function CalculateModifier(iDeflections)
	{
		return iDeflections +
		(TFDB.RocketsFired * this.RocketsModifier) +
		(TFDB.PlayerCount * this.PlayerModifier);
	}

	function CalculateDamage(fModifier)
	{
		return this.Damage + this.DamageIncrement * fModifier;
	}

	function CalculateSpeed(fModifier)
	{
		return this.Speed + this.SpeedIncrement * fModifier;
	}

	function CalculateTurnrate(fModifier)
	{
		return this.Turnrate + this.TurnrateIncrement * fModifier;
	}
}

class TFDB.ChancesTable
{
	RocketTypeIndex = 0;
	Chances         = 0;

	constructor(a, b)
	{
		this.RocketTypeIndex = a;
		this.Chances         = b;
	}
}

class TFDB.Spawner
{
	Type          = null;
	NextSpawnTime = 0.0;
	FiredRockets  = [];

	constructor(a)
	{
		this.Type          = a;
		this.NextSpawnTime = 0.0;
		this.FiredRockets  = [];
	}

	function CreateRocket(hSpawnerEntity, iType = -1)
	{
		iType = (iType == -1) ? this.Type.GetRandomRocketType() : iType;

		local iFlags = TFDB.RocketTypes[iType].Flags;
		local hRocketEntity = Entities.CreateByClassname("tf_projectile_pipe");

		if (hRocketEntity == null) return;

		if (!hRocketEntity.ValidateScriptScope())
		{
			hRocketEntity.Kill();

			return;
		}

		local hSpawnerTeam = GetPropInt(hSpawnerEntity, "m_iTeamNum");
		local hRocketScope = hRocketEntity.GetScriptScope();
		hRocketScope.TFDB <- {};
		hRocketScope.TFDB.Rocket <- TFDB.Rocket(TFDB.RocketTypes[iType]);

		local hRocket = hRocketScope.TFDB.Rocket;
		local vAngles = hSpawnerEntity.GetAbsAngles();

		hRocketEntity.Teleport(
			true, hSpawnerEntity.GetOrigin(),
			true, vAngles,
			false, Vector()
		);

		SetPropInt(hRocketEntity, "m_bCritical", (RandomFloat(0.0, 100.0) <= hRocket.Type.CritChance) ? 1 : 0);
		SetPropInt(hRocketEntity, "m_iTeamNum", ((iFlags & TFDB.RocketFlags.IsNeutral) ? TF_TEAM_SPECTATOR : hSpawnerTeam));
		SetPropInt(hRocketEntity, "m_iDeflected", 0);

		local hTarget = TFDB.SelectTarget(((iFlags & TFDB.RocketFlags.IsNeutral) ? TF_TEAM_UNASSIGNED : GetAnalogueTeam(hSpawnerTeam)));
		local hRocketOwner = TFDB.SelectTarget(GetAnalogueTeam(hTarget.GetTeam()));
		SetPropEntity(hRocketEntity, "m_hThrower", hRocketOwner);

		SetPropEntity(hRocketEntity, "m_hOriginalLauncher", hRocketEntity);
		SetPropEntity(hRocketEntity, "m_hLauncher", hRocketEntity);

		local fModifier = hRocket.Type.CalculateModifier(0);
		hRocket.LastDeflectionTime = Time();
		hRocket.SpawnTime = Time();
		hRocket.LastBeepTime = Time();
		hRocket.Speed = hRocket.Type.CalculateSpeed(fModifier);
		hRocket.Direction = vAngles.Forward();
		hRocket.Target = hTarget;
		Entities.DispatchSpawn(hRocketEntity);

		SetPropInt(hRocketEntity, "m_MoveType", MOVETYPE_FLY);
		SetPropInt(hRocketEntity, "m_nNextThinkTick", -1);
		SetPropFloat(hRocketEntity, "m_flDamage", hRocket.Type.CalculateDamage(fModifier));

		SetPropInt(hRocketEntity, "m_nModelIndexOverrides", GetModelIndex((iFlags & TFDB.RocketFlags.CustomModel) ? hRocket.Type.Model : TFDB.ROCKET_MODEL));
		hRocket.UpdateSkin(hRocketEntity, hSpawnerTeam);
		hRocket.UpdateParticles(hRocketEntity, hSpawnerTeam);

		if (iFlags & TFDB.RocketFlags.OnSpawnCmd)
		{
			hRocket.ExecuteCommands(hRocket.Type.CmdsOnSpawn, TFDB.CommandsTable(hRocketEntity, hRocketOwner, hRocket.Target));
		}

		hRocket.EmitSpawnSound(hRocketEntity);
		hRocket.EmitAlertSound(hRocket.Target);

		TFDB.RocketsFired++;

		local hSpawnerScope = hSpawnerEntity.GetScriptScope().TFDB.Spawner;

		hSpawnerScope.FiredRockets.append(hRocketEntity);
		hSpawnerScope.NextSpawnTime = Time() + this.Type.Interval;

		HookCustomThink(hRocketEntity, "TFDB_RocketThink", function ()
		{
			this.TFDB.Rocket.HomingThink(self);
		}, -1);
	}
}

class TFDB.SpawnerType
{
	Name          = "";
	MaxRockets    = 0;
	Interval      = 0;
	ChancesTables = null;

	constructor(a, b, c, d)
	{
		this.Name          = a;
		this.MaxRockets    = b;
		this.Interval      = c;
		this.ChancesTables = d;
	}

	function GetRandomRocketType()
	{
		local iRandom = RandomInt(1, 100);
		local iLowerChances = 0;
		local iUpperChances = 0;

		foreach (iIndex, hChancesTable in this.ChancesTables)
		{
			iLowerChances += iUpperChances;
			iUpperChances  = iLowerChances + hChancesTable.Chances;

			if ((iRandom >= iLowerChances) && (iRandom <= iUpperChances))
			{
				return hChancesTable.RocketTypeIndex;
			}
		}

		return 0;
	}
}
