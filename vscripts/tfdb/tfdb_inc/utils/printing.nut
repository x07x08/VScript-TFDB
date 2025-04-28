// https://github.com/DoctorMcKay/sourcemod-plugins/blob/master/scripting/include/morecolors.inc

local hColors =
{
	"{aliceblue}" : "\x07F0F8FF",
	"{allies}" : "\x074D7942", // same as Allies team in DoD:S
	"{ancient}" : "\x07EB4B4B", // same as Ancient item rarity in Dota 2
	"{antiquewhite}" : "\x07FAEBD7",
	"{aqua}" : "\x0700FFFF",
	"{aquamarine}" : "\x077FFFD4",
	"{arcana}" : "\x07ADE55C", // same as Arcana item rarity in Dota 2
	"{axis}" : "\x07FF4040", // same as Axis team in DoD:S
	"{azure}" : "\x07007FFF",
	"{beige}" : "\x07F5F5DC",
	"{bisque}" : "\x07FFE4C4",
	"{black}" : "\x07000000",
	"{blanchedalmond}" : "\x07FFEBCD",
	"{blue}" : "\x0799CCFF", // same as BLU/Counter-Terrorist team color
	"{blueviolet}" : "\x078A2BE2",
	"{brown}" : "\x07A52A2A",
	"{burlywood}" : "\x07DEB887",
	"{cadetblue}" : "\x075F9EA0",
	"{chartreuse}" : "\x077FFF00",
	"{chocolate}" : "\x07D2691E",
	"{collectors}" : "\x07AA0000", // same as Collector's item quality in TF2
	"{common}" : "\x07B0C3D9", // same as Common item rarity in Dota 2
	"{community}" : "\x0770B04A", // same as Community item quality in TF2
	"{coral}" : "\x07FF7F50",
	"{cornflowerblue}" : "\x076495ED",
	"{cornsilk}" : "\x07FFF8DC",
	"{corrupted}" : "\x07A32C2E", // same as Corrupted item quality in Dota 2
	"{crimson}" : "\x07DC143C",
	"{cyan}" : "\x0700FFFF",
	"{darkblue}" : "\x0700008B",
	"{darkcyan}" : "\x07008B8B",
	"{darkgoldenrod}" : "\x07B8860B",
	"{darkgray}" : "\x07A9A9A9",
	"{darkgrey}" : "\x07A9A9A9",
	"{darkgreen}" : "\x07006400",
	"{darkkhaki}" : "\x07BDB76B",
	"{darkmagenta}" : "\x078B008B",
	"{darkolivegreen}" : "\x07556B2F",
	"{darkorange}" : "\x07FF8C00",
	"{darkorchid}" : "\x079932CC",
	"{darkred}" : "\x078B0000",
	"{darksalmon}" : "\x07E9967A",
	"{darkseagreen}" : "\x078FBC8F",
	"{darkslateblue}" : "\x07483D8B",
	"{darkslategray}" : "\x072F4F4F",
	"{darkslategrey}" : "\x072F4F4F",
	"{darkturquoise}" : "\x0700CED1",
	"{darkviolet}" : "\x079400D3",
	"{deeppink}" : "\x07FF1493",
	"{deepskyblue}" : "\x0700BFFF",
	"{dimgray}" : "\x07696969",
	"{dimgrey}" : "\x07696969",
	"{dodgerblue}" : "\x071E90FF",
	"{exalted}" : "\x07CCCCCD", // same as Exalted item quality in Dota 2
	"{firebrick}" : "\x07B22222",
	"{floralwhite}" : "\x07FFFAF0",
	"{forestgreen}" : "\x07228B22",
	"{frozen}" : "\x074983B3", // same as Frozen item quality in Dota 2
	"{fuchsia}" : "\x07FF00FF",
	"{fullblue}" : "\x070000FF",
	"{fullred}" : "\x07FF0000",
	"{gainsboro}" : "\x07DCDCDC",
	"{genuine}" : "\x074D7455", // same as Genuine item quality in TF2
	"{ghostwhite}" : "\x07F8F8FF",
	"{gold}" : "\x07FFD700",
	"{goldenrod}" : "\x07DAA520",
	"{gray}" : "\x07CCCCCC", // same as spectator team color
	"{grey}" : "\x07CCCCCC",
	"{green}" : "\x073EFF3E",
	"{greenyellow}" : "\x07ADFF2F",
	"{haunted}" : "\x0738F3AB", // same as Haunted item quality in TF2
	"{honeydew}" : "\x07F0FFF0",
	"{hotpink}" : "\x07FF69B4",
	"{immortal}" : "\x07E4AE33", // same as Immortal item rarity in Dota 2
	"{indianred}" : "\x07CD5C5C",
	"{indigo}" : "\x074B0082",
	"{ivory}" : "\x07FFFFF0",
	"{khaki}" : "\x07F0E68C",
	"{lavender}" : "\x07E6E6FA",
	"{lavenderblush}" : "\x07FFF0F5",
	"{lawngreen}" : "\x077CFC00",
	"{legendary}" : "\x07D32CE6", // same as Legendary item rarity in Dota 2
	"{lemonchiffon}" : "\x07FFFACD",
	"{lightblue}" : "\x07ADD8E6",
	"{lightcoral}" : "\x07F08080",
	"{lightcyan}" : "\x07E0FFFF",
	"{lightgoldenrodyellow}" : "\x07FAFAD2",
	"{lightgray}" : "\x07D3D3D3",
	"{lightgrey}" : "\x07D3D3D3",
	"{lightgreen}" : "\x0799FF99",
	"{lightpink}" : "\x07FFB6C1",
	"{lightsalmon}" : "\x07FFA07A",
	"{lightseagreen}" : "\x0720B2AA",
	"{lightskyblue}" : "\x0787CEFA",
	"{lightslategray}" : "\x07778899",
	"{lightslategrey}" : "\x07778899",
	"{lightsteelblue}" : "\x07B0C4DE",
	"{lightyellow}" : "\x07FFFFE0",
	"{lime}" : "\x0700FF00",
	"{limegreen}" : "\x0732CD32",
	"{linen}" : "\x07FAF0E6",
	"{magenta}" : "\x07FF00FF",
	"{maroon}" : "\x07800000",
	"{mediumaquamarine}" : "\x0766CDAA",
	"{mediumblue}" : "\x070000CD",
	"{mediumorchid}" : "\x07BA55D3",
	"{mediumpurple}" : "\x079370D8",
	"{mediumseagreen}" : "\x073CB371",
	"{mediumslateblue}" : "\x077B68EE",
	"{mediumspringgreen}" : "\x0700FA9A",
	"{mediumturquoise}" : "\x0748D1CC",
	"{mediumvioletred}" : "\x07C71585",
	"{midnightblue}" : "\x07191970",
	"{mintcream}" : "\x07F5FFFA",
	"{mistyrose}" : "\x07FFE4E1",
	"{moccasin}" : "\x07FFE4B5",
	"{mythical}" : "\x078847FF", // same as Mythical item rarity in Dota 2
	"{navajowhite}" : "\x07FFDEAD",
	"{navy}" : "\x07000080",
	"{normal}" : "\x07B2B2B2", // same as Normal item quality in TF2
	"{oldlace}" : "\x07FDF5E6",
	"{olive}" : "\x079EC34F",
	"{olivedrab}" : "\x076B8E23",
	"{orange}" : "\x07FFA500",
	"{orangered}" : "\x07FF4500",
	"{orchid}" : "\x07DA70D6",
	"{palegoldenrod}" : "\x07EEE8AA",
	"{palegreen}" : "\x0798FB98",
	"{paleturquoise}" : "\x07AFEEEE",
	"{palevioletred}" : "\x07D87093",
	"{papayawhip}" : "\x07FFEFD5",
	"{peachpuff}" : "\x07FFDAB9",
	"{peru}" : "\x07CD853F",
	"{pink}" : "\x07FFC0CB",
	"{plum}" : "\x07DDA0DD",
	"{powderblue}" : "\x07B0E0E6",
	"{purple}" : "\x07800080",
	"{rare}" : "\x074B69FF", // same as Rare item rarity in Dota 2
	"{red}" : "\x07FF4040", // same as RED/Terrorist team color
	"{rosybrown}" : "\x07BC8F8F",
	"{royalblue}" : "\x074169E1",
	"{saddlebrown}" : "\x078B4513",
	"{salmon}" : "\x07FA8072",
	"{sandybrown}" : "\x07F4A460",
	"{seagreen}" : "\x072E8B57",
	"{seashell}" : "\x07FFF5EE",
	"{selfmade}" : "\x0770B04A", // same as Self-Made item quality in TF2
	"{sienna}" : "\x07A0522D",
	"{silver}" : "\x07C0C0C0",
	"{skyblue}" : "\x0787CEEB",
	"{slateblue}" : "\x076A5ACD",
	"{slategray}" : "\x07708090",
	"{slategrey}" : "\x07708090",
	"{snow}" : "\x07FFFAFA",
	"{springgreen}" : "\x0700FF7F",
	"{steelblue}" : "\x074682B4",
	"{strange}" : "\x07CF6A32", // same as Strange item quality in TF2
	"{tan}" : "\x07D2B48C",
	"{teal}" : "\x07008080",
	"{thistle}" : "\x07D8BFD8",
	"{tomato}" : "\x07FF6347",
	"{turquoise}" : "\x0740E0D0",
	"{uncommon}" : "\x07B0C3D9", // same as Uncommon item rarity in Dota 2
	"{unique}" : "\x07FFD700", // same as Unique item quality in TF2
	"{unusual}" : "\x078650AC", // same as Unusual item quality in TF2
	"{valve}" : "\x07A50F79", // same as Valve item quality in TF2
	"{vintage}" : "\x07476291", // same as Vintage item quality in TF2
	"{violet}" : "\x07EE82EE",
	"{wheat}" : "\x07F5DEB3",
	"{white}" : "\x07FFFFFF",
	"{whitesmoke}" : "\x07F5F5F5",
	"{yellow}" : "\x07FFFF00",
	"{yellowgreen}" : "\x079ACD32",
	"{default}" : "\x01"
}

function CReplaceColorCodes(strMessage)
{
	local strBuiltString = strMessage;
	local iIndex = 0;

	foreach (strKey, strValue in hColors)
	{
		iIndex = 0;

		while ((iIndex = strBuiltString.find(strKey)) != null)
		{
			strBuiltString = strBuiltString.slice(0, iIndex) + strValue + strBuiltString.slice(iIndex + strKey.len());
		}
	}

	return strBuiltString;
}

function CPrintToChat(hClient, strMessage, ...)
{
	ClientPrint(hClient, HUD_PRINTTALK, format.pacall(vargv.insert(0, CReplaceColorCodes(strMessage)).insert(0, this)));
}
