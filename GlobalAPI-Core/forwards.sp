/*
	Global API ~ Forwards

	Author: 	Chuckles, Sikari & Zach47
	Source:		""

*/

static Handle H_OnAPIKeyReloaded;
static Handle H_OnKickIfBanned_Changed;
static Handle H_OnDevelopmentMode_Changed;
static Handle H_OnPlayer_Joined;

static Handle H_OnVariablesReset;

void CreateForwards()
{
	H_OnAPIKeyReloaded = CreateGlobalForward("GlobalAPI_OnAPIKeyReloaded", ET_Ignore);
	H_OnKickIfBanned_Changed = CreateGlobalForward("GlobalAPI_OnKickIfBanned_Changed", ET_Ignore, Param_Cell);
	H_OnDevelopmentMode_Changed = CreateGlobalForward("GlobalAPI_OnDevelopmentMode_Changed", ET_Ignore, Param_Cell);
	H_OnPlayer_Joined = CreateGlobalForward("GlobalAPI_OnPlayer_Joined", ET_Ignore, Param_Cell, Param_Cell);

	H_OnVariablesReset = CreateForward(ET_Ignore);

	AddToForward(H_OnVariablesReset, g_ThisPlugin, API_OnVariablesReset);
}

void Call_API_OnAPIKeyReloaded()
{
	Call_StartForward(H_OnAPIKeyReloaded);
	Call_Finish();
}

void Call_API_OnKickIfBanned_Changed(bool KickIfBanned)
{
	Call_StartForward(H_OnKickIfBanned_Changed);
	Call_PushCell(KickIfBanned);
	Call_Finish();
}

void Call_API_OnDevelopmentMode_Changed(bool developmentmode)
{
	Call_StartForward(H_OnDevelopmentMode_Changed);
	Call_PushCell(developmentmode);
	Call_Finish();
}

void Call_API_OnPlayer_Joined(int client, bool banned)
{
	Call_StartForward(H_OnPlayer_Joined);
	Call_PushCell(client);
	Call_PushCell(banned);
	Call_Finish();
}
