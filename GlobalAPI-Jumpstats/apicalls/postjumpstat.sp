/* 
	Global API - Jumpstats Module ~ API Calls - Post Jumpstat

	Author: 	Chuckles, Sikari & Zach47
	Source:		""
	
*/

int PostAPIJumpstat(Handle plugin, PostJumpstatCallback func, int client, const char[] steam_id, APIJumptype jump_type, float distance, int msl_count_int, int is_crouch_bind, int is_forward_bind, int is_crouch_boost, int strafes, any data)
{
	char requestUrl[512];
	if (gB_Staging)
	{
		Format(requestUrl, sizeof(requestUrl), "%sstaging.%s", SECURE, API_JUMPSTATS);
	}

	else
	{
		Format(requestUrl, sizeof(requestUrl), "%s%s", SECURE, API_JUMPSTATS);
	}

	char httpPOSTRecord[80000] = "";
	Handle post_jumpstat = json_object();
	
	json_object_set_new(post_jumpstat, "steam_id" , json_string(steam_id));
	json_object_set_new(post_jumpstat, "jump_type" , json_integer(view_as<int>(jump_type)));
	json_object_set_new(post_jumpstat, "distance" , json_real(distance));
	json_object_set_new(post_jumpstat, "json_jump_info" , json_string(JumpToJSONString(client)));
	json_object_set_new(post_jumpstat, "tickrate" , json_integer(gI_tickRate));
	json_object_set_new(post_jumpstat, "msl_count" , json_integer(msl_count_int));
	json_object_set_new(post_jumpstat, "is_crouch_bind" , json_integer(is_crouch_bind));
	json_object_set_new(post_jumpstat, "is_forward_bind" , json_integer(is_forward_bind));
	json_object_set_new(post_jumpstat, "is_crouch_boost" , json_integer(is_crouch_boost));
	json_object_set_new(post_jumpstat, "strafe_count" , json_integer(strafes));
	
	json_dump(post_jumpstat, httpPOSTRecord, sizeof(httpPOSTRecord), 0);
	delete post_jumpstat;

	if (GetFeatureStatus(FeatureType_Native, "SteamWorks_CreateHTTPRequest") == FeatureStatus_Available)
	{
		DataPack dp = CreateDataPack();
		dp.WriteCell(plugin);
		dp.WriteFunction(func);
		dp.WriteCell(data);
		dp.WriteString(requestUrl);
		dp.WriteString(httpPOSTRecord);

		Handle postRecord = SteamWorks_CreateHTTPRequest(k_EHTTPMethodPOST, requestUrl);

		if (postRecord == INVALID_HANDLE) 
		{
			delete dp;
			PrintToServer("Failed to POST jumpstat because there was a problem creating the HTTP request.");
			return;
		}

		SteamWorks_SetHTTPRequestHeaderValue(postRecord, "Content-Type", "application/json");
		SteamWorks_SetHTTPRequestHeaderValue(postRecord, "X-ApiKey", gSZ_API_Key);
		SteamWorks_SetHTTPRequestRawPostBody(postRecord, "application/json", httpPOSTRecord, sizeof(httpPOSTRecord));
		SteamWorks_SetHTTPCallbacks(postRecord, OnJumpstatPostInfo);
		SteamWorks_SetHTTPRequestContextValue(postRecord, dp); // Passing datapack
		SteamWorks_SendHTTPRequest(postRecord);
	}
}

public int OnJumpstatPostInfo(Handle request, bool failure, bool requestSuccessful, EHTTPStatusCode statusCode, DataPack dp)
{
	int status = view_as<int>(statusCode);

	if (failure || !requestSuccessful || status == 404 || status == 500 || status == 503)
	{
		char requestUrl[512];
		char content[80000];

		dp.Reset();
		Handle plugin = dp.ReadCell();
		Function func = dp.ReadFunction();
		any data = dp.ReadCell();
		dp.ReadString(requestUrl, sizeof(requestUrl));
		dp.ReadString(content, sizeof(content));
		delete dp;

		if (gI_Logging >= 2)
		{
			APILog(requestUrl, "POST", status, content);
		}
		
		if (func != INVALID_FUNCTION)
		{
			Call_StartFunction(plugin, func);
			Call_PushCell(true); // failure
			Call_PushCell(0);
			Call_PushCell(0);
			Call_PushCell(data);
			Call_Finish();
		}
	}

	else
	{
		SteamWorks_GetHTTPResponseBodyCallback(request, OnJumpstatPostInfo_Data, dp);
	}
	
	delete request;
}

public int OnJumpstatPostInfo_Data(const char[] response, DataPack dp)
{
	dp.Reset();
	Handle plugin = dp.ReadCell();
	Function func = dp.ReadFunction();
	any data = dp.ReadCell();
	delete dp;

	int id = 0;
	int place = 0;

	Handle jsonData = json_load(response);

	if (jsonData != INVALID_HANDLE)
	{
		id = json_object_get_int(jsonData, "id");
		place = json_object_get_int(jsonData, "top_30");
	}

	delete jsonData;

	if (func != INVALID_FUNCTION)
	{
		Call_StartFunction(plugin, func);
		Call_PushCell(false);
		Call_PushCell(id);
		Call_PushCell(place);
		Call_PushCell(data);
		Call_Finish();
	}
}