/**
	Credit:
		AMXX Dev Team: Restrict Weapons
		hoboman313: Hobo Nade Management (offsets, etc.)
		OT: Flashbang Remote Control (gravity check)

	Description:
		Limit the number of grenades a player can buy/use
		Block limited action before they can be performed instead of taking away
		hp from players afterward

	Compatibility:
		Tested to work with all known weapon drop plugins:
		Real Nade Drops, Real Weapon Drop, Weapons Drop Ability, etc.

	CVars:
		nl_limit_buy 1:
		nl_limit_use 0:
			0: no limit
			1: enabled

		nl_buy_flash 3:
		nl_buy_hegren 2:
		nl_buy_sgren 2:
		nl_buy_all 5:
		nl_use_flash 3:
		nl_use_hegren 2:
		nl_use_sgren 2:
		nl_use_all 5:
			0: no limit
			positive values: limit amount

		nl_early_msg 1:
			0: message when exceeding limit
			1: message when reaching limit

	Command:
		nl_reset:
			Reset count for all players

	Client commands:
		say /nl:
		say_team /nl:
			Display limits in chat

	Changelog:
		0.5.2:
			Minor optimization: no longer uses add string native

		0.5.1:
			Minor code optimization
			Reorganized some code; added comments

		0.5:
			Improved compatibility of grenade throw detection
			Improved behavior when switching to last weapon
			Added primary attack check (optional)
			Added ML support
			Added say /nl command, report limits set by the server
			Removed many loops; uses trie in some part
			Removed dependency on csx module
			CVar changes:
				Changed nbl prefix to nl
				Removed nbl_limit_type, now always per respawn
				Renamed nbl_limit_msg to nl_early_msg
				Removed nade-specific limit cvars
				Added nade-specific limit cvars for each action type
				Added nl_limit_buy, works similarly to nl_limit_use
				Negative values no longer have any effect
				Changed some default values (see CVars section for details)

		0.4:
			Added nbl_limit_use cvar
			Added nbl_limit_msg cvar
			Added nbl_all cvar
			Setting a limit to 0 now disables that specific limit
			Various bug fixes
			Reorganized some code
			Fixed tag mismatch compiler warnings

		0.3:
			Bug fix for rebuy/autobuy

		0.2:
			Bug fix
			Added nbl_reset command

		0.1:
			Initial release
**/

// In case something was missed by the CurWeapon hook
// Will be called every frame when the attack button is held down
// #define USE_CHECK_PRIMARY_ATTACK

// Affect:
	// buy command (rebuy/autobuy)
	// class name (last weapon switch)
	// model (grenade throw)
// Not really necessary as far as I can tell
// #define CASE_INSENSITIVE_TRIE

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>

/// Constants & globals ///
// Constants
const player_id_max = 33
enum action_id { action_buy, action_use, action_id_max }
const nade_id_max = 3
new action_cmd[][] = {"buy", "use"}
new nade_cmd[][] = {"flash", "hegren", "sgren", "all"}
new nade_wid[] = {CSW_FLASHBANG, CSW_HEGRENADE, CSW_SMOKEGRENADE}
new nade_wname[][] = {"weapon_flashbang", "weapon_hegrenade", "weapon_smokegrenade"}
new nade_wname_i = 7 // "weapon_" prefix length
new nade_model[][] = {"w_flashbang.mdl", "w_hegrenade.mdl", "w_smokegrenade.mdl"}
new nade_model_i = 7 // "models/" prefix length
new nade_menu_name[] = "BuyItem" // Old-style menu
new nade_menu_id = -34 // VGUI menu
new nade_menu_key[] = {MENU_KEY_3, MENU_KEY_4, MENU_KEY_5}
new nade_ammo_max[] = {2, 1, 1}
new nade_ammo_offset[] = {387, 388, 389}
new last_item_offset = 375
new last_item_alt[] = "weapon_knife"
// These will be initialized in plugin_init
new Trie:nade_cmd_trie
new Trie:nade_wname_trie
new Trie:nade_model_trie

// CVars
// Initial values will be replaced by cvar pointers by register_cvar_num
new action_limit[] = {1, 0}
new nade_limit[][] = {{3, 2, 2, 5}, {3, 2, 2, 5}}
new early_msg = 1

// Other globals
new nade_count[player_id_max][_:action_id_max][nade_id_max + 1]

/// Utilities ///
// String
// Length constants for temporary buffers
const str_len = 128
const str_len2 = 32
const str_len3 = 16

// As a convention, the last parameter is always the output string
#define concat(%1,%2,%3) concat_l(%1,%2,%3,sizeof %3)
#define concat_sd(%1,%2,%3) concat_l_sd(%1,%2,%3,sizeof %3)
#define concat_s_s(%1,%2,%3) concat_l_s_s(%1,%2,%3,sizeof %3)
#define str_copy(%1,%2) str_l_copy(%1,%2,sizeof %2)
#define str_upper(%1,%2) str_l_upper(%1,%2,sizeof %2)
#define num_str(%1,%2) num_l_str(%1,%2,sizeof %2)
#define mls_str(%1,%2,%3,%4) (mls_l_str_l(%1,%2,%3,%4,sizeof %4),%4)
// With explicit length as the last parameter
#define concat_l(%1,%2,%3,%4) (formatex(%3,%4-1,"%s%s",%1,%2),%3)
#define concat_l_sd(%1,%2,%3,%4) (formatex(%3,%4-1,"%s%d",%1,%2),%3)
#define concat_l_s_s(%1,%2,%3,%4) (formatex(%3,%4-1,"%s_%s",%1,%2),%3)
#define str_l_copy(%1,%2,%3) (copy(%2,%3-1,%1),%2)
#define str_l_upper(%1,%2,%3) (strtoupper(str_l_copy(%1,%2,%3)),%2)
#define num_l_str(%1,%2,%3) (num_to_str(%1,%2,%3-1),%2)
#define mls_l_str_l(%1,%2,%3,%4,%5) formatex(%4,%5-1,"%L",%1,%2,%3)

// Message
const Float:welcome_msg_delay = 25.0
#define action_ml(%1,%2) action_l_ml(%1,%2,sizeof %2)
#define nade_ml(%1,%2) nade_l_ml(%1,%2,sizeof %2)
#define action_l_ml(%1,%2,%3) str_l_upper(action_cmd[%1],%2,%3)
#define nade_l_ml(%1,%2,%3) str_l_upper(nade_cmd[%1],%2,%3)

// CVar/command
register_cvar_num(&p, const c[])
{
	new s[str_len3]
	p = register_cvar(c, num_str(p, s))
}
register_saycmd(const cmd[], const func[], flag, const info[])
{
	new say_prefix[][] = {"say ", "say_team "}, s[str_len2]
	for(new i; i < sizeof say_prefix; i++)
		register_clcmd(concat(say_prefix[i], cmd, s), func, flag, info)
}

// CVar access
cvar_enabled(c, n = 0, &v = 0)
	return (v = get_pcvar_num(c)) > n
limiting_nade(j, i, &l = 0)
	return cvar_enabled(nade_limit[j][i], 0, l)
limiting_action(actn)
	return cvar_enabled(action_limit[actn])
limiting_id_action(id, actn)
	return is_user_alive(id) && limiting_action(actn)

// Trie access
#if defined CASE_INSENSITIVE_TRIE
trie_name_nid(Trie:t, const n[], &i)
{
	new s[str_len2]
	return trie_name_str_nid(t, str_copy(n, s), i)
}
trie_name_str_nid(Trie:t, s[], &i) return TrieGetCell(t, (strtolower(s), s), i)
#else
trie_name_nid(Trie:t, const n[], &i) return TrieGetCell(t, n, i)
trie_name_str_nid(Trie:t, s[], &i) return trie_name_nid(t, s, i)
#endif

/// Main ///
public plugin_init()
{
	register_plugin("Nade Limit", "0.5", "K.Nk")
	register_dictionary("nadelimit.txt")

	register_concmd("nl_reset", "reset_count_all", ADMIN_LEVEL_A)
	register_cvar_num(early_msg, "nl_early_msg")

	new s[str_len2], s2[str_len2]
	// Action-specific cvars
	for(new j; j < _:action_id_max; j++)
	{
		register_cvar_num(action_limit[j],
			concat_s_s("nl_limit", action_cmd[j], s))
		// Nade-specific cvars
		for(new i; i <= nade_id_max; i++)
			register_cvar_num(nade_limit[j][i],
				concat_s_s(concat_s_s("nl", action_cmd[j], s), nade_cmd[i], s2))
	}
	// Initialize tries
	nade_cmd_trie = TrieCreate()
	nade_wname_trie = TrieCreate()
	nade_model_trie = TrieCreate()
	// Other nade-specific stuff
	for(new i; i < nade_id_max; i++)
	{
		// Buy menu/command hook
		register_menucmd(register_menuid(nade_menu_name, 1),
			nade_menu_key[i], concat_sd("buy_command", i, s))
		register_menucmd(nade_menu_id,
			nade_menu_key[i], concat_sd("buy_command", i, s))
		register_clcmd(nade_cmd[i], concat_sd("buy_command", i, s))
#if defined USE_CHECK_PRIMARY_ATTACK
		// Primary attack hook
		RegisterHam(Ham_Weapon_PrimaryAttack,
			nade_wname[i], concat_sd("primary_attack", i, s))
#endif
		// CurWeapon hook
		register_event("CurWeapon", concat_sd("cur_weapon", i, s), "be",
			"1=1", concat_sd("2=", nade_wid[i], s2))
		// Populate tries
		TrieSetCell(nade_cmd_trie, nade_cmd[i], i)
		TrieSetCell(nade_wname_trie, nade_wname[i][nade_wname_i], i)
		TrieSetCell(nade_model_trie, nade_model[i], i)
	}
	// SetModel hook
	register_forward(FM_SetModel, "set_model_post", 1)
	// Reset condition hook
	RegisterHam(Ham_Spawn, "player", "reset_count", 1)
	// Say command
	register_saycmd("/nl", "say_nl", 0, "- display nade limit info.")
}

/// Misc. ///
// Count reset
public reset_count(pid)
{
	// Can't assign multidimensional array directly, so loop
	new zeros[nade_id_max]
	for(new j; j < _:action_id_max; j++)
		nade_count[pid][j] = zeros
}
public reset_count_all()
	for(new i; i < player_id_max; i++)
		reset_count(i)

// Welcome message
public client_putinserver(pid)
	is_user_bot(pid) ||
		set_task(welcome_msg_delay, "show_welcome_msg", pid)
public show_welcome_msg(id)
	// Don't display welcome message if no limit is set
	// Check if any action limit is set
	for(new j; j < _:action_id_max; j++)
		if(limiting_action(j))
			// Check if any nade limit for action j is set
			for(new i; i <= nade_id_max; i++)
				if(limiting_nade(j, i))
				{
					// Now display welcome message
					client_print(id, print_chat, "%L", id, "WELCOME")
					return
				}

// Say command, report limits
public say_nl(id)
{
	new j, s2[str_len2], s3[str_len3]
	// For each action type
	for(; j < _:action_id_max; j++)
	{
		new s[str_len]
		// Get limit info in s
		say_action(id, j, s, s2, s3)
		// Print s
		client_print(id, print_chat, "%L",
			id, concat_s_s("REPORT", action_ml(j, s2), s3), s)
	}
	return PLUGIN_HANDLED
}

say_action(id, j, s[], s2[], s3[],
	s_len = sizeof s, s2_len = sizeof s2, s3_len = sizeof s3)
	limiting_action(j) &&
		// Get nade limits for action j, starting at nid = 0
		say_nade(id, j, 0, 0, s, s2, s3, s_len, s2_len, s3_len) ||
			// Report disabled if no nade limit
			mls_l_str_l(id, "REPORT_DISABLED", "", s, s_len)

say_nade(id, j, i, k, s[], s2[], s3[], s_len, s2_len, s3_len)
{
	if(i <= nade_id_max)
	{
		new l, r
		if(limiting_nade(j, i, l))
		{
			r = mls_l_str_l(id, \
				concat_l_s_s("REPORT_NADE", nade_l_ml(i, s, s_len), s2, s2_len), \
				num_l_str(l, s3, s3_len), s, s_len)
			k++ && (r = mls_l_str_l(id, "REPORT_NADE_SEPARATOR", s, s2, s2_len),
				str_l_copy(s2, s, s_len))
		}
		// Get next nade limit
		return say_nade(id, j, i + 1, k, s[r], s2, s3, s_len - r, s2_len, s3_len)
	}
	return k
}

/// Check helpers ///
print_limit_msg(pid, actn, nid)
{
	new s[str_len2], s2[str_len2], s3[str_len2], s4[str_len2]
	client_print(pid, print_center, "%L", pid,
		// "NOTIFY_*"
		concat_s_s("NOTIFY", action_ml(actn, s), s2),
		// "NOTIFY_NADE_*"
		mls_str(pid, concat_s_s("NOTIFY_NADE", nade_ml(nid, s3), s4), "", s3))
	return true
}

limit_check_and_notify(pid, actn, nid)
	return \
		limit_reached(pid, actn, nade_id_max) &&
			print_limit_msg(pid, actn, nade_id_max) ||
		limit_reached(pid, actn, nid) &&
			print_limit_msg(pid, actn, nid)

limit_reached(id, j, i, &l = 0)
	return limiting_nade(j, i, l) && nade_count[id][j][i] >= l
limit_reached_any(id, j, i)
	return limit_reached(id, j, i) || limit_reached(id, j, nade_id_max)
nade_count_inc(id, actn, i)
{
	nade_count[id][actn][i]++
	nade_count[id][actn][nade_id_max]++
}

/// Buy check ///
buy_limit_check(pid, nid)
{
	if(limit_check_and_notify(pid, action_buy, nid))
		return PLUGIN_HANDLED
	else
		// Ammo check
		get_pdata_int(pid, nade_ammo_offset[nid]) < nade_ammo_max[nid] && (
			// Nade will be bought, increase counter
			nade_count_inc(pid, action_buy, nid),
			// Early message
			cvar_enabled(early_msg) &&
				limit_check_and_notify(pid, action_buy, nid))
	return PLUGIN_CONTINUE
}

// Forward from cstrike module for rebuy/autobuy
public CS_InternalCommand(id, const cmd[])
{
	if(limiting_id_action(id, action_buy))
	{
		new i
		if(trie_name_nid(nade_cmd_trie, cmd, i))
			return buy_limit_check(id, i)
	}
	return PLUGIN_CONTINUE
}

public buy_command0(id) return buy_command(id, 0)
public buy_command1(id) return buy_command(id, 1)
public buy_command2(id) return buy_command(id, 2)
buy_command(id, i)
	return \
		limiting_id_action(id, action_buy) ?
			buy_limit_check(id, i) :
			PLUGIN_CONTINUE

/// Use check ///
use_weapon_switch(id)
{
	// Switch to last weapon,
	// unless that weapon is a nade and the limit for that nade is reached,
	// then we use the default alternative
	new ent = get_pdata_cbase(id, last_item_offset)
	if(pev_valid(ent))
	{
		new s[str_len2], i
		pev(ent, pev_classname, s, str_len2 - 1)
		// Check entity class name, is it a nade?
		// If so, has its limit been reached?
		if(!trie_name_str_nid(nade_wname_trie, s[nade_wname_i], i) ||
			!limit_reached_any(id, action_use, i))
		{
			// Switch to last weapon
			client_cmd(id, "lastinv")
			return
		}
	}
	// Switch to default alternative
	client_cmd(id, last_item_alt)
}

// Grenade throw detection
// Similar to the grenade_throw forward from csx module, but more reliable
public set_model_post(ent, const mdl[])
{
	if(pev_valid(ent))
	{
		new Float:f
		pev(ent, pev_gravity, f)
		// Thrown grenade has gravity
		if(f != 0.0)
		{
			// Now get the owner
			new id = pev(ent, pev_owner)
			if(limiting_id_action(id, action_use))
			{
				new i
				// Is this actually a nade?
				if(trie_name_nid(nade_model_trie, mdl[nade_model_i], i))
				{
					// So a nade's been thrown, increase counter
					// Check the limit before that however so early message
					// would work correctly
					new b = limit_check_and_notify(id, action_use, i)
					// Now increase counter
					nade_count_inc(id, action_use, i)
					// Early message
					b || cvar_enabled(early_msg) &&
						limit_check_and_notify(id, action_use, i)
				}
			}
		}
	}
	return FMRES_IGNORED
}

#if defined USE_CHECK_PRIMARY_ATTACK
public primary_attack0(ent) primary_attack(ent, 0)
public primary_attack1(ent) primary_attack(ent, 1)
public primary_attack2(ent) primary_attack(ent, 2)
primary_attack(ent, i)
	pev_valid(ent) &&
		cur_weapon(pev(ent, pev_owner), i)
#endif

public cur_weapon0(id) cur_weapon(id, 0)
public cur_weapon1(id) cur_weapon(id, 1)
public cur_weapon2(id) cur_weapon(id, 2)
cur_weapon(id, i)
	limiting_id_action(id, action_use) &&
		limit_check_and_notify(id, action_use, i) &&
			use_weapon_switch(id)
