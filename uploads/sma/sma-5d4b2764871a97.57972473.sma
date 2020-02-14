/*================================================================================
=
=					Plugin: Time Bonus
=					Version: 1.0
=					Version mod: Public
=
=
=		Description:
=			- This is plugin add in game presents.
=			Presents are given every 3 min, 5 min, 10 min, 20 min, 30 min, 1 hour.
=
=		Defaults:
=			3 min - 3000 $
=			5 min - 5000 $
=			10 min - 3000 $
=			20 min - 5000 $
=			30 min - 10000 $
=			60 min - 16000 $
=================================================================================*/

#include <amxmodx>
#include <cstrike>

/*================================================================================
[Macros]
=================================================================================*/

#define SMALL				500
#define AVERAGE			        1000
#define LARGE				1500
#define MAX				2000
#define PRO				2500
#define HARD				3000

/*================================================================================
[Plugin Init]
=================================================================================*/

public plugin_init()
{
	register_plugin("Time Bonus", "1.1", "KneLe")
}

/*================================================================================
[Set Tasks]
=================================================================================*/

public client_putinserver(id)
{
	set_task(180.0, "small_present", id)
	set_task(300.0, "average_present", id)
	set_task(600.0, "large_present", id)
	set_task(1200.0, "max_present", id)
	set_task(1800.0, "pro_present", id)
	set_task(3600.0, "hard_present", id)
}

/*================================================================================
[Remove Task]
=================================================================================*/

public client_disconnect(id)
{
	if(task_exists(id))
		remove_task(id)
}

/*================================================================================
[Give Presents]
=================================================================================*/

public small_present(id)
{
	cs_set_user_money(id, min(cs_get_user_money(id) + SMALL, 16000), 1)
	client_printcolor(id, "^4[PH Time Bonus] ^1You got ^4%d$ ^1for playing 3 minutes on server.", SMALL)
}

public average_present(id)
{
	cs_set_user_money(id, min(cs_get_user_money(id) + AVERAGE, 16000), 1)
	client_printcolor(id, "^4[PH Time Bonus] ^1You got ^4%d$ ^1for playing 5 minutes on server.", AVERAGE)
}

public large_present(id)
{
	cs_set_user_money(id, min(cs_get_user_money(id) + LARGE, 16000), 1)
	client_printcolor(id, "^4[PH Time Bonus] ^1You got ^4%d$ ^1for playing 10 minutes on server.", LARGE)
}

public max_present(id)
{
	cs_set_user_money(id, min(cs_get_user_money(id) + MAX, 16000), 1)
	client_printcolor(id, "^4[PH Time Bonus] ^1You got ^4%d$ ^1for playing 20 minutes on server.", MAX)
}

public pro_present(id)
{
	cs_set_user_money(id, min(cs_get_user_money(id) + PRO, 16000), 1)
	client_printcolor(id, "^4[PH Time Bonus] ^1You got ^4%d$ ^1for playing 30 minutes on server.", PRO)
}

public hard_present(id)
{
	cs_set_user_money(id, min(cs_get_user_money(id) + HARD, 16000), 1)
	client_printcolor(id, "^4[PH Time Bonus] ^1You got ^4%d$ ^1for playing 60 minutes on server.", HARD)
}

/*================================================================================
[Stock]
=================================================================================*/

stock client_printcolor(const id, const input[], any:...)
{
	new iCount = 1, iPlayers[32]
	static szMsg[191]
	
	vformat(szMsg, charsmax(szMsg), input, 3)
	replace_all(szMsg, 190, "/g", "^4")
	replace_all(szMsg, 190, "/y", "^1")
	replace_all(szMsg, 190, "/ctr", "^1")
	replace_all(szMsg, 190, "/w", "^0")
	
	if(id) iPlayers[0] = id
	else get_players(iPlayers, iCount, "ch")
	for (new i = 0; i < iCount; i++)
	{
		if(is_user_connected(iPlayers[i]))
		{
			message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, iPlayers[i])
			write_byte(iPlayers[i])
			write_string(szMsg)
			message_end()
		}
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
