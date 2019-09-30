/*
	Global API - Jumpstats Module Include File

	Author: 	Chuckles, Sikari & Zach47
	Source: 	""
	
*/

// ======================= DOUBLE INCLUDE ====================== //

#if defined _GlobalAPI_Jumpstats_included_
#endinput
#endif
#define _GlobalAPI_Jumpstats_included_

#define GlobalAPI_Jumpstats_Version "1.2.1"

// ======================= CALLBACKS ====================== //

//Get
typedef GetJumpstatTopCallback = function int(bool bFailure, const char[] top, any data);

//Post
typedef PostJumpstatCallback = function int(bool bFailure, int id, int place, any data);

// ======================= ENUMS ====================== //

enum APIJumptype
{
	APIJumptype_None = 0,
	APIJumptype_Longjump,
	APIJumptype_Bhop,
	APIJumptype_Multihop,
	APIJumptype_Weirdjump,
	APIJumptype_Drophop,
	APIJumptype_Countjump,
	APIJumptype_Ladderjump,
	APIJumptype_Count
};

enum position
{
	Float:x, 
	Float:y,
	Float:z
}

enum vector
{
	Float:x[2056], 
	Float:y[2056], 
	Float:z[2056]
}

enum jump
{	
	//JSON
	eye_ang[vector], 
	player_pos[vector],
	player_vel[vector],
	player_buttons[2056],
	
	//MSL
	msl_count,
	Float:eye_diff[2056],
	
	//Is Bind
	ticks_holding_both_c_j,
	bool:still_holding_bind,
	bool:is_cj_boost,
	bool:is_cj_bind,
	
	//Strafe Counts
	strafe_count,
	
	bool:recording_jump, 
	start_tick, 
	end_tick, 
	total_ticks, 
	start_pos[vector], 
	end_pos[vector], 

	speed[2056]
}

// ======================= STOCKS ====================== //

stock bool IsValidClient(int client)
{
	return client >= 1 && client <= MaxClients && IsClientInGame(client) && !IsClientSourceTV(client);
}

// ======================= NATIVES ====================== //

/**
 * Sends a jumpstat to the GlobalAPI
 *
 * @param client		Client index of the player who jumped
 * @param jumptype		Jumptype of the jump
 * @param distance		Distance of the jump
 * @param callback		Callback function when API call finishes
 * @param data			Optional data to pass to the callback
 * @noreturn
 */
native int GlobalAPI_SendJumpstat(int client, APIJumptype jumptype, int jumpcolor, float distance, bool is_pb, PostJumpstatCallback onComplete, any data = 0);

/**
 * Gets the jumpstats top for given jumptype
 *
 * @param jumptype		Jumptype we want records from
 * @param callback		Callback function when API call finishes
 * @param data			Optional data to pass to the callback
 * @noreturn
 */
native int GlobalAPI_GetJumpstatTop(APIJumptype jumptype, GetJumpstatTopCallback onComplete, any data = 0);

/**
 * Gets the binded/nonbinded jumpstats top for given jumptype
 *
 * @param jumptype		Jumptype we want records from
 * @param bool			Do we want jumps to be binded or not?
 * @param callback		Callback function when API call finishes
 * @param data			Optional data to pass to the callback
 * @noreturn
 */
native int GlobalAPI_GetJumpstatTopEx(APIJumptype jumptype, bool bind, GetJumpstatTopCallback onComplete, any data = 0);

// ======================= FORWARDS ====================== //

/**
 * Called when a valid API Jump is done
 *
 * @param client		Client index
 * @param jumptype		Type of the jump (See APIJumptype)
 * @param jumpcolor		Color tier of the jump INT
 * @param distance		Distance of the jump
 * @param personalbest	Was the jump personal best?
 * @noreturn
 */
forward void GlobalAPI_JS_ValidJump(int client, APIJumptype jumptype, int jumpcolor, float distance, bool personalbest);

// ======================= METHODMAPS ====================== //

methodmap APIJumpRecordList < Handle
{
	public APIJumpRecordList(const char[] records)
	{
		return view_as<APIJumpRecordList>(json_load(records));
	}

	public native int Count();

	public native void GetByIndex(int index, char[] buffer, int maxlength);
}

methodmap APIJumpRecord < Handle
{
	public APIJumpRecord(const char[] record)
	{
		return view_as<APIJumpRecord>(json_load(record));
	}

	public native int ID();
	
	public native int ServerID();

	public native int SteamID(char[] buffer, int maxlength);
	
	public native int SteamID64();

	public native int PlayerName(char[] buffer, int maxlength);
	
	public native int JumpType();
	
	public native int Tickrate();

	public native float Distance();

	public native int Strafes();
	
	public native int CreatedOn(char[] buffer, int maxlength);
}

// ======================= PLUGIN INFO ====================== //

public SharedPlugin __pl_GlobalAPI_Jumpstats = 
{
	name = "GlobalAPI-Jumpstats", 
	file = "GlobalAPI-Jumpstats.smx", 
	#if defined REQUIRE_PLUGIN
	required = 1, 
	#else
	required = 0, 
	#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_GlobalAPI_Jumpstats_SetNTVOptional()
{
	MarkNativeAsOptional("GlobalAPI_SendJumpstat");
	MarkNativeAsOptional("GlobalAPI_GetJumpstatTop");
	MarkNativeAsOptional("GlobalAPI_GetJumpstatTopEx");

	MarkNativeAsOptional("APIJumpRecordList.Count");
	MarkNativeAsOptional("APIJumpRecordList.GetByIndex");
	MarkNativeAsOptional("APIJumpRecord.ID");
	MarkNativeAsOptional("APIJumpRecord.ServerID");
	MarkNativeAsOptional("APIJumpRecord.SteamID");
	MarkNativeAsOptional("APIJumpRecord.SteamID64");
	MarkNativeAsOptional("APIJumpRecord.PlayerName");
	MarkNativeAsOptional("APIJumpRecord.JumpType");
	MarkNativeAsOptional("APIJumpRecord.Tickrate");
	MarkNativeAsOptional("APIJumpRecord.Distance");
	MarkNativeAsOptional("APIJumpRecord.Strafes");
	MarkNativeAsOptional("APIJumpRecord.CreatedOn");
}
#endif