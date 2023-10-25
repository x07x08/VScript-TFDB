// This script file is meant for adding rocket and spawner types
// You can also have a "<mapname>.nut" file for map specific types
// Read tfdb_inc/defines.nut for flags documentation

delete TFDB.RocketTypes;
delete TFDB.SpawnerTypes;

TFDB.RocketTypes <- [];
TFDB.SpawnerTypes <- {};

TFDB.RocketTypes.append(
	TFDB.RocketType(
		"Homing rocket", // Name
		"", // Model
		(TFDB.RocketFlags.PlaySpawnSound |
		TFDB.RocketFlags.PlayBeepSound |
		TFDB.RocketFlags.PlayAlertSound |
		TFDB.RocketFlags.PlayDelaySound |
		TFDB.RocketFlags.OnKillCmd |
		TFDB.RocketFlags.KeepDirection |
		TFDB.RocketFlags.ResetBounces |
		TFDB.RocketFlags.StealTeamCheck), // Flags (double check this if something is wrong)
		0.0, // Beep interval
		"", // Spawn sound
		"", // Beep sound
		"", // Alert sound
		"", // Delay sound
		100.0, // Critical chance (multiplies the starting damage by 3, useful for visibility)
		50.0, // Damage
		25.0, // Damage increment
		875.0, // Speed (rocket curve limit is sv_maxvelocity * sqrt(2))
		160.0, // Speed increment
		0.0, // Speed limit
		0.260, // Turn rate
		0.0180, // Turn rate increment
		0, // Turn rate limit
		0, // Elevation rate
		0, // Elevation limit
		0, // Rockets modifier (increases damage, turn rate and speed for each fired rocket since round start)
		0, // Players modifier (same as rockets modifier but for players)
		0, // Control delay (delay before the rocket actually starts homing / thinking)
		0.04, // Drag time min (delay before you can drag / control the rocket)
		0.04, // Drag time max (maximum drag time; should be equal to min time)
		100, // Target weight (affects how much aiming matters for target selection)
		[

		], // Commands on spawn (vscript functions array)
		[

		], // Commands on deflect (vscript functions array)
		[
			function (hCmdTable)
			{
				local hRocket = hCmdTable.RocketEntity.GetScriptScope().TFDB.Rocket;

				CPrintToChat(null, "{darkorange}%s{default} died to a rocket travelling %.2f HU (%d deflections)", GetClientName(hCmdTable.Performer), hRocket.Speed, hRocket.Deflections);
			}
		], // Commands on kill (vscript functions array)
		[

		], // Commands on explode (vscript functions array)
		[

		], // Commands on no target (vscript functions array)
		100, // Max bounces
		1.0 // Bounce scale (speed multiplier after the rocket touches the ground)
	)
);
TFDB.RocketTypes.append(
	TFDB.RocketType(
		"Nuke", // Name
		"models/custom/dodgeball/nuke/nuke.mdl", // Model
		(TFDB.RocketFlags.CustomModel |
		TFDB.RocketFlags.PlaySpawnSound |
		TFDB.RocketFlags.PlayBeepSound |
		TFDB.RocketFlags.PlayAlertSound |
		TFDB.RocketFlags.PlayDelaySound |
		TFDB.RocketFlags.OnKillCmd |
		TFDB.RocketFlags.OnExplodeCmd |
		TFDB.RocketFlags.KeepDirection), // Flags (double check this if something is wrong)
		0.2, // Beep interval
		"", // Spawn sound
		"", // Beep sound
		"", // Alert sound
		"", // Delay sound
		100.0, // Critical chance (multiplies the starting damage by 3, useful for visibility)
		200.0, // Damage
		200.0, // Damage increment
		550.0, // Speed (rocket curve limit is sv_maxvelocity * sqrt(2))
		100.0, // Speed increment
		0.0, // Speed limit
		0.233, // Turn rate
		0.0275, // Turn rate increment
		0, // Turn rate limit
		0.1237, // Elevation rate
		0.1237, // Elevation limit
		0, // Rockets modifier (increases damage, turn rate and speed for each fired rocket since round start)
		0, // Players modifier (same as rockets modifier but for players)
		0, // Control delay (delay before the rocket actually starts homing / thinking)
		0.03, // Drag time min (delay before you can drag / control the rocket)
		0.03, // Drag time max (maximum drag time; should be equal to min time)
		100, // Target weight (affects how much aiming matters for target selection)
		[

		], // Commands on spawn (vscript functions array)
		[

		], // Commands on deflect (vscript functions array)
		[
			function (hCmdTable)
			{
				local hRocket = hCmdTable.RocketEntity.GetScriptScope().TFDB.Rocket;

				CPrintToChat(null, "{darkorange}%s{default} died to a rocket travelling %.2f HU (%d deflections)", GetClientName(hCmdTable.Performer), hRocket.Speed, hRocket.Deflections);
			}
		], // Commands on kill (vscript functions array)
		[
			TFDB.Explosion,
			function (hCmdTable)
			{
				TFDB.Shockwave(hCmdTable, 200, 1000, 1000, 600);
			}
		], // Commands on explode (vscript functions array)
		[

		], // Commands on no target (vscript functions array)
		0, // Max bounces
		1.0 // Bounce scale (speed multiplier after the rocket touches the ground)
	)
);

// Spawner entities can be toggled using the "m_iHealth" netprop.
// The "m_iTeamNum" netprop is the team of the spawner.
// The parent name ("m_iParent" netprop) will be the spawner type (defaults to "default_<team>" if empty)

TFDB.SpawnerTypes["default_red"] <- TFDB.SpawnerType
(
	"default_red", // Name (can match the key value)
	1, // Max rockets
	2.0, // Interval
	[
		TFDB.ChancesTable(
			0, // Index of rocket type from the TFDB.RocketTypes array
			90 // Spawn percentage rate
		),
		TFDB.ChancesTable(
			1, // Index of rocket type from the TFDB.RocketTypes array
			10 // Spawn percentage rate
		)
	]
);

TFDB.SpawnerTypes["default_blu"] <- TFDB.SpawnerType
(
	"default_blu", // Name (can match the key value)
	1, // Max rockets
	2.0, // Interval
	[
		TFDB.ChancesTable(
			0, // Index of rocket type from the TFDB.RocketTypes array
			90 // Spawn percentage rate
		),
		TFDB.ChancesTable(
			1, // Index of rocket type from the TFDB.RocketTypes array
			10 // Spawn percentage rate
		)
	]
);

foreach (iIndex, hRocketType in TFDB.RocketTypes)
{
	if (hRocketType.Flags & TFDB.RocketFlags.CustomModel)      PrecacheModel(hRocketType.Model);
	if (hRocketType.Flags & TFDB.RocketFlags.CustomSpawnSound) PrecacheSound(hRocketType.SpawnSound);
	if (hRocketType.Flags & TFDB.RocketFlags.CustomBeepSound)  PrecacheSound(hRocketType.BeepSound);
	if (hRocketType.Flags & TFDB.RocketFlags.CustomAlertSound) PrecacheSound(hRocketType.AlertSound);
	if (hRocketType.Flags & TFDB.RocketFlags.CustomDelaySound) PrecacheSound(hRocketType.DelaySound);
}

TFDB.RefreshSpawnPoints();
