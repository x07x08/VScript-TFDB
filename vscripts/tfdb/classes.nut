// This script file is meant for adding rocket and spawner types
// You can also have a "<mapname>.nut" file for map specific types
// Read tfdb_inc/defines.nut for flags and constructors documentation

delete TFDB.RocketTypes;
delete TFDB.SpawnerTypes;

TFDB.RocketTypes <- [];
TFDB.SpawnerTypes <- {};

TFDB.RocketTypes.append(
	TFDB.RocketType({
		Name = "Homing rocket",
		Model = "",
		Flags = (TFDB.RocketFlags.PlaySpawnSound |
			TFDB.RocketFlags.PlayBeepSound |
			TFDB.RocketFlags.PlayAlertSound |
			TFDB.RocketFlags.PlayDelaySound |
			TFDB.RocketFlags.OnKillCmd |
			TFDB.RocketFlags.KeepDirection |
			TFDB.RocketFlags.ResetBounces |
			TFDB.RocketFlags.StealTeamCheck), // Double check this if something is wrong
		BeepInterval = 0.0,
		SpawnSound = "",
		BeepSound = "",
		AlertSound = "",
		DelaySound = "",
		CritChance = 100.0, // Multiplies the dealt damage by 3. Also useful for visibility
		Damage = 50.0,
		DamageIncrement = 25.0,
		Speed = 875.0, // Rocket curve limit is sv_maxvelocity * sqrt(2)
		SpeedIncrement = 160.0,
		SpeedLimit = 0.0,
		Turnrate = 0.260,
		TurnrateIncrement = 0.0180,
		TurnrateLimit = 0,
		ElevationRate = 0,
		ElevationLimit = 0,
		RocketsModifier = 0, // Increases damage, turn rate and speed for each fired rocket since round start
		PlayerModifier = 0, // Same as rockets modifier but for players
		ControlDelay = 0, // Delay before the rocket actually starts homing / thinking
		DragTimeMin = 0.04, // Delay before you can drag / control the rocket
		DragTimeMax = 0.04, // Maximum drag time. Should be equal to min time
		TargetWeight = 100, // Affects how much aiming matters for target selection
		CmdsOnSpawn = [

		], // VScript functions array
		CmdsOnDeflect = [

		], // VScript functions array
		CmdsOnKill = [
			function (hCmdTable)
			{
				local hRocket = hCmdTable.RocketEntity.GetScriptScope().TFDB.Rocket;

				CPrintToChat(null, "{darkorange}%s{default} died to a rocket travelling %.2f HU (%d deflections)", GetClientName(hCmdTable.Performer), hRocket.Speed, hRocket.Deflections);
			}
		], // VScript functions array
		CmdsOnExplode = [

		], // VScript functions array
		CmdsOnNoTarget = [

		], // VScript functions array
		MaxBounces = 100,
		BounceScale = 1.0 // Speed multiplier after the rocket touches the ground
	})
);
TFDB.RocketTypes.append(
	TFDB.RocketType({
		Name = "Nuke",
		Model = "models/custom/dodgeball/nuke/nuke.mdl",
		Flags = (TFDB.RocketFlags.CustomModel |
			TFDB.RocketFlags.PlaySpawnSound |
			TFDB.RocketFlags.PlayBeepSound |
			TFDB.RocketFlags.PlayAlertSound |
			TFDB.RocketFlags.PlayDelaySound |
			TFDB.RocketFlags.OnKillCmd |
			TFDB.RocketFlags.OnExplodeCmd |
			TFDB.RocketFlags.KeepDirection), // Double check this if something is wrong
		BeepInterval = 0.2,
		SpawnSound = "",
		BeepSound = "",
		AlertSound = "",
		DelaySound = "",
		CritChance = 100.0, // Multiplies the dealt damage by 3. Also useful for visibility
		Damage = 200.0,
		DamageIncrement = 200.0,
		Speed = 550.0, // Rocket curve limit is sv_maxvelocity * sqrt(2)
		SpeedIncrement = 100.0,
		SpeedLimit = 0.0,
		Turnrate = 0.233,
		TurnrateIncrement = 0.0275,
		TurnrateLimit = 0,
		ElevationRate = 0.1237,
		ElevationLimit = 0.1237,
		RocketsModifier = 0, // Increases damage, turn rate and speed for each fired rocket since round start
		PlayerModifier = 0, // Same as rockets modifier but for players
		ControlDelay = 0, // Delay before the rocket actually starts homing / thinking
		DragTimeMin = 0.03, // Delay before you can drag / control the rocket
		DragTimeMax = 0.03, // Maximum drag time. Should be equal to min time
		TargetWeight = 100, // Affects how much aiming matters for target selection
		CmdsOnSpawn = [

		], // VScript functions array
		CmdsOnDeflect = [

		], // VScript functions array
		CmdsOnKill = [
			function (hCmdTable)
			{
				local hRocket = hCmdTable.RocketEntity.GetScriptScope().TFDB.Rocket;

				CPrintToChat(null, "{darkorange}%s{default} died to a rocket travelling %.2f HU (%d deflections)", GetClientName(hCmdTable.Performer), hRocket.Speed, hRocket.Deflections);
			}
		], // VScript functions array
		CmdsOnExplode = [
			TFDB.Explosion,
			function (hCmdTable)
			{
				TFDB.Shockwave(hCmdTable, 200, 1000, 1000, 600);
			}
		], // VScript functions array
		CmdsOnNoTarget = [

		], // VScript functions array
		MaxBounces = 0,
		BounceScale = 1.0 // Speed multiplier after the rocket touches the ground
	})
);

// Spawner entities can be toggled using the "m_iHealth" netprop.
// The "m_iTeamNum" netprop is the team of the spawner.
// The parent name ("m_iParent" netprop) will be the spawner type (defaults to "default_<team>" if empty)

TFDB.SpawnerTypes["default_red"] <- TFDB.SpawnerType
({
	Name = "default_red", // Can match the key value
	MaxRockets = 1,
	Interval = 2.0,
	ChancesTables = [
		TFDB.ChancesTable({
			RocketTypeIndex = 0, // Index of rocket type from the TFDB.RocketTypes array
			Chances = 90 // Spawn percentage rate
		}),
		TFDB.ChancesTable({
			RocketTypeIndex = 1, // Index of rocket type from the TFDB.RocketTypes array
			Chances = 10 // Spawn percentage rate
		})
	]
});

TFDB.SpawnerTypes["default_blu"] <- TFDB.SpawnerType
({
	Name = "default_blu", // Can match the key value
	MaxRockets = 1,
	Interval = 2.0,
	ChancesTables = [
		TFDB.ChancesTable({
			RocketTypeIndex = 0, // Index of rocket type from the TFDB.RocketTypes array
			Chances = 90 // Spawn percentage rate
		}),
		TFDB.ChancesTable({
			RocketTypeIndex = 1, // Index of rocket type from the TFDB.RocketTypes array
			Chances = 10 // Spawn percentage rate
		})
	]
});

// Precaching and refreshing

foreach (iIndex, hRocketType in TFDB.RocketTypes)
{
	if (hRocketType.Flags & TFDB.RocketFlags.CustomModel)      PrecacheModel(hRocketType.Model);
	if (hRocketType.Flags & TFDB.RocketFlags.CustomSpawnSound) PrecacheSound(hRocketType.SpawnSound);
	if (hRocketType.Flags & TFDB.RocketFlags.CustomBeepSound)  PrecacheSound(hRocketType.BeepSound);
	if (hRocketType.Flags & TFDB.RocketFlags.CustomAlertSound) PrecacheSound(hRocketType.AlertSound);
	if (hRocketType.Flags & TFDB.RocketFlags.CustomDelaySound) PrecacheSound(hRocketType.DelaySound);
}

TFDB.RefreshSpawnPoints();
