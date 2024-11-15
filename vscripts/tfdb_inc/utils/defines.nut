local ROOT = getroottable();

if (!("ConstantNamingConvention" in ROOT))
{
	foreach (a,b in Constants)
	{
		foreach (k,v in b)
		{
			if (v == null)
			{
				ROOT[k] <- 0;
			}
			else
			{
				ROOT[k] <- v;
			}
		}
	}
}

foreach (k, v in ::NetProps.getclass())
{
	if (k == "IsValid") continue;

	ROOT[k] <- ::NetProps[k].bindenv(::NetProps);
}

::MAX_PLAYERS <- MaxClients().tointeger();

::TF_TEAM_UNASSIGNED <- TEAM_UNASSIGNED;
::TF_TEAM_SPECTATOR  <- TEAM_SPECTATOR;

::LIFE_ALIVE       <- 0;
::LIFE_DYING       <- LIFE_ALIVE + 1;
::LIFE_DEAD        <- LIFE_DYING + 1;
::LIFE_RESPAWNABLE <- LIFE_DEAD + 1;
::LIFE_DISCARDBODY <- LIFE_RESPAWNABLE + 1;

::TFCOLLISIONGROUP_GRENADES                           <- LAST_SHARED_COLLISION_GROUP;
::TFCOLLISION_GROUP_OBJECT                            <- TFCOLLISIONGROUP_GRENADES + 1;
::TFCOLLISION_GROUP_OBJECT_SOLIDTOPLAYERMOVEMENT      <- TFCOLLISION_GROUP_OBJECT + 1;
::TFCOLLISION_GROUP_COMBATOBJECT                      <- TFCOLLISION_GROUP_OBJECT_SOLIDTOPLAYERMOVEMENT + 1;
::TFCOLLISION_GROUP_ROCKETS                           <- TFCOLLISION_GROUP_COMBATOBJECT + 1;
::TFCOLLISION_GROUP_RESPAWNROOMS                      <- TFCOLLISION_GROUP_ROCKETS + 1;
::TFCOLLISION_GROUP_TANK                              <- TFCOLLISION_GROUP_RESPAWNROOMS + 1;
::TFCOLLISION_GROUP_ROCKET_BUT_NOT_WITH_OTHER_ROCKETS <- TFCOLLISION_GROUP_TANK + 1;

::PATTACH_ABSORIGIN        <- 0;
::PATTACH_ABSORIGIN_FOLLOW <- PATTACH_ABSORIGIN + 1;
::PATTACH_CUSTOMORIGIN     <- PATTACH_ABSORIGIN_FOLLOW + 1;
::PATTACH_POINT            <- PATTACH_CUSTOMORIGIN + 1;
::PATTACH_POINT_FOLLOW     <- PATTACH_POINT + 1;
::PATTACH_WORLDORIGIN      <- PATTACH_POINT_FOLLOW + 1;
::PATTACH_ROOTBONE_FOLLOW  <- PATTACH_WORLDORIGIN + 1;
