#include <amxmodx>
#include <cstrike>
#include <amxmisc>
#include <engine>
#include <fun>
#include <fakemeta>
#include <hamsandwich>
#include <colorchat>

#define	HOOK_LEVEL ADMIN_LEVEL_A

#define	TRAIL_LIFE		10
#define	TRAIL_WIDTH		10
#define	TRAIL_RED		255
#define	TRAIL_GREEN		0
#define	TRAIL_BLUE		0
#define	TRAIL_BRIGTHNESS	220

#define	TRAIL_LIF		10
#define	TRAIL_WIDT		10
#define	TRAIL_RE		0
#define	TRAIL_GREE		0
#define	TRAIL_BLU		255
#define	TRAIL_BRIGTHNES		220

#pragma	tabsize	0

new bool:canusehook[32]
new bool:ishooked[32]
new hookorigin[32][3]

new Enable
new Glow, GlowRandom, GlowR, GlowG, GlowB
new Fade, FadeRandom, fadeR, fadeG, fadeB
new model_gibs, model_gibs1, model_gibs2, model_gibs3, model_gibs4, model_gibs5, model_gibs6, gTrail, gTrail1;
new g_iBeamSprite, g_iBeamSprite1, g_iBeamSprite2, g_iBeamSprite3, g_iBeamSprite4, g_iBeamSprite5, g_iBeamSprite6;
new g_speed[33]
new g_izgled[33]
new g_kuglice[33] 
new g_zvuk[33]

public plugin_init() {
	register_plugin("HOOK","1.2","Lumeno Gejjjjj")
	
	register_clcmd("+hook","hook_on",HOOK_LEVEL)
	register_clcmd("-hook","hook_off",HOOK_LEVEL)
	register_clcmd("say /hookizgled","HookMeni")
	register_clcmd("say /hookzvuk", "HM")
	register_clcmd("say /hookkuglice","HookMenu")
	register_clcmd("say /hookspeed","Menu_hook")
	register_clcmd("say /hook","HMeni")
	
	Enable		=	register_cvar("hook_enable",		"1"	)
	Glow 		=	register_cvar("hook_glow",		"1"	)
	GlowRandom 	=	register_cvar("hook_glow_random",	"1"	)
	GlowR		=	register_cvar("hook_glow_r",		"255"	)
	GlowG		=	register_cvar("hook_glow_g",		"255"	)
	GlowB		=	register_cvar("hook_glow_b",		"255"	)
	Fade		=	register_cvar("hook_screenfade",	"0"	)
	FadeRandom	=	register_cvar("hook_screenfade_random",	"1"	)
	fadeR		=	register_cvar("hook_fade_r",		"255"	)
	fadeG		=	register_cvar("hook_fade_g",		"255"	)
	fadeB		=	register_cvar("hook_fade_b",		"255"	)
	
	set_task(120.0, "tet") 
}

public plugin_precache() {

	g_iBeamSprite		=	precache_model("sprites/hook/sg_0.spr");
	g_iBeamSprite1		=	precache_model("sprites/hook/sg_1.spr");
	g_iBeamSprite2		=	precache_model("sprites/hook/sg_2.spr");
	g_iBeamSprite3		=	precache_model("sprites/hook/sg_3.spr");
	g_iBeamSprite4		=	precache_model("sprites/hook/sg_4.spr");
	g_iBeamSprite5		=	precache_model("sprites/hook/sg_5.spr");
	g_iBeamSprite6		=	precache_model("sprites/hook/sg_6.spr");
	model_gibs		=	precache_model("sprites/hook/kuglica_roze.spr");
	model_gibs1		=	precache_model("sprites/hook/kuglica_plava.spr");
	model_gibs2		=	precache_model("sprites/hook/kuglica_zelena.spr");
	model_gibs3		=	precache_model("sprites/hook/kuglica_3.spr");
	model_gibs4		=	precache_model("sprites/hook/kuglica_4.spr");
	model_gibs5		=	precache_model("sprites/hook/kuglica_5.spr");
	model_gibs6		=	precache_model("sprites/hook/kuglica_6.spr");
	gTrail			=	precache_model("sprites/hook/trail.spr");
	gTrail1			=	precache_model("sprites/hook/trail_1.spr");
	precache_sound("hook/hook1.wav")
	precache_sound("hook/hook2.wav")
	precache_sound("hook/hook3.wav")
	precache_sound("hook/hook4.wav")
	precache_sound("hook/hook5.wav")
	precache_sound("hook/hook6.wav")
	precache_sound("hook/hook7.wav")
	precache_sound("hook/hook8.wav")
	precache_sound("hook/hook9.wav")
}

public HMeni(id)
{
         if(get_user_flags(id) & ADMIN_LEVEL_A || get_user_flags(id) & ADMIN_LEVEL_A) 
	{
		new menu = menu_create("\y[UJBM] \wHook Meni \y:3:","h_meni")
		menu_additem(menu,"\yIzgled \rHooka", "1", 0)
		menu_additem(menu,"\yKuglice \rHooka", "2", 0)
		menu_additem(menu,"\ySpeed \rHooka", "3", 0) 
		menu_additem(menu,"\yZvuk \rHooka", "4", 0)
		
		menu_setprop(menu, MPROP_NEXTNAME, "Sledeca")
		menu_setprop(menu, MPROP_BACKNAME, "Nazad")
		menu_setprop(menu, MPROP_EXITNAME, "\rIzlaz")
		menu_setprop(menu, MPROP_EXIT,	MEXIT_ALL)
		menu_display(id, menu)	
		
	} else {
		ColorChat(id, GREEN,"^4[UJBM] ^3Nemas pristup meniju za mjenjanje hook-a!")	
	}		
	return PLUGIN_HANDLED
}

public	h_meni(id, menu, key)
{ 
	if(key == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	new accss, clbck, data[6], name[64], itm
	menu_item_getinfo(menu, key, accss, data, 5, name, 63, clbck)
	itm = str_to_num(data)
	
	switch(itm)
	{
		case 1:	 client_cmd(id, "say /hookizgled")
		case 2:  client_cmd(id, "say /hookkuglice")
		case 3:  client_cmd(id, "say /hookspeed")
		case 4: client_cmd(id, "say /hookzvuk")
		}
	return PLUGIN_HANDLED
}
	
public Menu_hook(id)
{
	if(get_user_flags(id) & ADMIN_LEVEL_A || get_user_flags(id) & ADMIN_LEVEL_A)
	{
		new menu = menu_create("\y[UJBM]	\wBrzine Hook-a \y:3:","menu_hook")
		if(g_speed[id] == 0)
		{
			menu_additem(menu,"Spora \y[Izabrana]", "1", 0)
		} else {
			menu_additem(menu,"Spora \r[Izaberi]", "1", 0)
		}
		if(g_speed[id] == 1)
		{
			menu_additem(menu,"Normalna \y[Izabrana]", "2", 0)
		} else {
			menu_additem(menu,"Normalna \r[Izaberi]", "2", 0)
		}
		if(g_speed[id] == 2)
		{
			menu_additem(menu,"Brza \y[Izabrana]", "3", 0)
		} else {
			menu_additem(menu,"Brza \r[Izaberi]", "3", 0)
		}
		
		menu_setprop(menu, MPROP_NEXTNAME, "Sledeca")
		menu_setprop(menu, MPROP_BACKNAME, "Nazad")
		menu_setprop(menu, MPROP_EXITNAME, "\rIzlaz")
		menu_setprop(menu, MPROP_EXIT,	MEXIT_ALL)
		menu_display(id, menu)	
		
	} else {
		ColorChat(id, GREEN,"^4[UJBM] ^3Nemas pristup meniju za mjenjanje brzine hook-a!")	
	}		
	return PLUGIN_HANDLED
}

public	menu_hook(id, menu, key)
{
	if(key == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	new accss, clbck, data[6], name[64], itm
	menu_item_getinfo(menu, key, accss, data, 5, name, 63, clbck)
	itm = str_to_num(data)
	
	switch(itm)
	{
		case 1:
		{
			if(g_speed[id] == 0)
			{
					ColorChat(id, GREEN,"^4[UJBM] ^3Brzina Hook-a je vec setovana na ^4sporu^1.")
					Menu_hook(id)
			} else {
					g_speed[id] = 0
					ColorChat(id, GREEN,"^4[UJBM] ^3Brzina Hook-a je setovana na ^4sprou^1.")
			}
		}
		case 2:
		{
			if(g_speed[id] == 1)
			{
					ColorChat(id, GREEN,"^4[UJBM] ^3Brzina Hook-a je vec setovana na ^4normalnu^1.")
					Menu_hook(id)
			} else {
					g_speed[id] = 1
					ColorChat(id, GREEN,"^4[UJBM] ^3Brzina Hook-a je setovana na ^4normalnu^1.")
			}
		}
		case 3:
		{
			if(g_speed[id] == 2)
			{
					ColorChat(id, GREEN,"^4[UJBM] ^3Brzina Hook-a je vec setovana na ^4brzu^1.")
					Menu_hook(id)
			} else {
					g_speed[id] = 2
					ColorChat(id, GREEN,"^4[UJBM] ^3Brzina Hook-a je setovana na ^4brzu^1.")
			}
		}
	}
	return PLUGIN_HANDLED
}

public HookMeni(id)
{
	if(get_user_flags(id) & ADMIN_LEVEL_A)
	{
		new menu = menu_create("\y[UJBM]	\wIzgledi Hook-a \y:3:","Hook_Meni")
		if(g_izgled[id] == 0)
		{
			menu_additem(menu,"AutoPut \y[Izabrana]", "1", 0)
		} else {
			menu_additem(menu,"AutoPut \r[Izaberi]", "1", 0)
		}
		if(g_izgled[id] == 1)
		{
			menu_additem(menu,"Munja \y[Izabrana]", "2", 0)
		} else {
			menu_additem(menu,"Munja \r[Izaberi]", "2", 0)
		}
		if(g_izgled[id] == 2)
		{
			menu_additem(menu,"Put 2k18  \y[Izabrana]", "3", 0)
		} else {
			menu_additem(menu,"Put 2k18 \r[Izaberi]", "3", 0)
		}
		if(g_izgled[id] == 3)
		{
			menu_additem(menu,"Lajne  \y[Izabrana]", "4", 0)
		} else {
			menu_additem(menu,"Lajne \r[Izaberi]", "4", 0)
		}
		if(g_izgled[id] == 4)
		{
			menu_additem(menu,"3 Lajne \y[Izabrana]", "5", 0)
		} else {
			menu_additem(menu,"3 Lajne \r[Izaberi]", "5", 0)
		}
		if(g_izgled[id] == 5)
		{
			menu_additem(menu,"Mali laser  \y[Izabrana]", "6", 0)
		} else {
			menu_additem(menu,"Mali laser \r[Izaberi]", "6", 0)
		}
		if(g_izgled[id] == 6)
		{
			menu_additem(menu,"Lanci  \y[Izabrana]", "7", 0)
		} else {
			menu_additem(menu,"Lanci  \r[Izaberi]", "7", 0)
		}
		
		menu_setprop(menu, MPROP_NEXTNAME, "Sledeca")
		menu_setprop(menu, MPROP_BACKNAME, "Nazad")
		menu_setprop(menu, MPROP_EXITNAME, "\rIzlaz")
		menu_setprop(menu, MPROP_EXIT,	MEXIT_ALL)
		menu_display(id, menu)	
		
	} else {
		ColorChat(id, GREEN,"^4[UJBM] ^3Nemas pristup ovom meniju jer nemas hook!")	
	}		
	return PLUGIN_HANDLED
}

public Hook_Meni(id, menu, key)
{
	if(key == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	new accss, clbck, data[6], name[64], itm
	menu_item_getinfo(menu, key, accss, data, 5, name, 63, clbck)
	itm = str_to_num(data)
	
	switch(itm)
	{
		case 1:
		{
			if(g_izgled[id] == 0)
			{
					ColorChat(id, GREEN,"^4[UJBM] ^3Izgled Hook-a je vec setovan na ^4 AutoPut^1.")
					HookMeni(id)
			} else {
					g_izgled[id] = 0
					ColorChat(id, GREEN,"^4[UJBM] ^3Izgled Hook-a je setovana na ^4 AutoPut^1.")
			}
		}
		case 2:
		{
			if(g_izgled[id] == 1)
			{
					ColorChat(id, GREEN,"^4[UJBM] ^3Izgled Hook-a je vec setovana na ^4 Munja^1.")
					HookMeni(id)
			} else {
					g_izgled[id] = 1
					ColorChat(id, GREEN,"^4[UJBM] ^3Izgled Hook-a je setovana na ^4 Munja^1.")
			}
		}
		case 3:
		{
			if(g_izgled[id] == 2)
			{
					ColorChat(id, GREEN,"^4[UJBM] ^3Izgled Hook-a je vec setovana na ^4 Put 2k18^1.")
					HookMeni(id)
			} else {
					g_izgled[id] = 2
					ColorChat(id, GREEN,"^4[UJBM] ^3Izgled Hook-a je setovana na ^4 Put k18^1.")
			}
		}
		case 4:
		{
			if(g_izgled[id] == 3)
			{
					ColorChat(id, GREEN,"^4[UJBM] ^3Izgled Hook-a je vec setovana na ^4 Lajne^1.")
					HookMeni(id)
			} else {
					g_izgled[id] = 3
					ColorChat(id, GREEN,"^4[UJBM] ^3Izgled Hook-a je setovana na ^4 Lajne^1.")
			}
		}
		case 5:
		{
			if(g_izgled[id] == 4)
			{
					ColorChat(id, GREEN,"^4[UJBM] ^3Izgled Hook-a je vec setovana na ^4 3 Lajne^1.")
					HookMeni(id)
			} else {
					g_izgled[id] = 4
					ColorChat(id, GREEN,"^4[UJBM] ^3Izgled Hook-a je setovana na ^4 3 Lajne^1.")
			}
		}
		case 6:
		{
			if(g_izgled[id] == 5)
			{
					ColorChat(id, GREEN,"^4[UJBM] ^3Izgled Hook-a je vec setovana na ^4 Mali laser^1.")
					HookMeni(id)
			} else {
					g_izgled[id] = 5
					ColorChat(id, GREEN,"^4[UJBM] ^3Izgled Hook-a je setovana na ^4 Mali laser^1.")
			}
		}
		case 7:
		{
			if(g_izgled[id] == 6)
			{
					ColorChat(id, GREEN,"^4[UJBM] ^3Izgled Hook-a je vec setovana na ^4 Lance^1.")
					HookMeni(id)
			} else {
					g_izgled[id] = 6
					ColorChat(id, GREEN,"^4[UJBM] ^3Izgled Hook-a je setovana na ^4 Lance^1.")
			}
		}
	}
	return PLUGIN_HANDLED
}

public HookMenu(id)
{
	if(get_user_flags(id) & ADMIN_LEVEL_A)
	{
		new menu = menu_create("\y[UJBM]	\wIzgledi Hook-a \y:3:","Hook_Menu")
		if(g_kuglice[id] == 0)
		{
			menu_additem(menu,"Roze pahulje \y[Izabrana]", "1", 0)
		} else {
			menu_additem(menu,"Roze pahulje \r[Izaberi]", "1", 0)
		}
		if(g_kuglice[id] == 1)
		{
			menu_additem(menu,"Plavo sunce \y[Izabrana]", "2", 0)
		} else {
			menu_additem(menu,"Plavo sunce \r[Izaberi]", "2", 0)
		}
		if(g_kuglice[id] == 2)
		{
			menu_additem(menu,"Zelene kuglice  \y[Izabrana]", "3", 0)
		} else {
			menu_additem(menu,"Zelene kuglice \r[Izaberi]", "3", 0)
		}
		if(g_kuglice[id] == 3)
		{
			menu_additem(menu,"Infected  \y[Izabrana]", "4", 0)
		} else {
			menu_additem(menu,"Infected \r[Izaberi]", "4", 0)
		}
		if(g_kuglice[id] == 4)
		{
			menu_additem(menu,"Disko  \y[Izabrana]", "5", 0)
		} else {
			menu_additem(menu,"Disko \r[Izaberi]", "5", 0)
		}
		if(g_kuglice[id] == 5)
		{
			menu_additem(menu,"Plave pahulje  \y[Izabrana]", "6", 0)
		} else {
			menu_additem(menu,"Plave pahulje \r[Izaberi]", "6", 0)
		}
		if(g_kuglice[id] == 6)
		{
			menu_additem(menu,"Half-Life  \y[Izabrana]", "7", 0)
		} else {
			menu_additem(menu,"Half-Life \r[Izaberi]", "7", 0)
		}
		
		menu_setprop(menu, MPROP_NEXTNAME, "Sledeca")
		menu_setprop(menu, MPROP_BACKNAME, "Nazad")
		menu_setprop(menu, MPROP_EXITNAME, "\rIzlaz")
		menu_setprop(menu, MPROP_EXIT,	MEXIT_ALL)
		menu_display(id, menu)	
		
	} else {
		ColorChat(id, GREEN,"^4[UJBM] ^3Nemas pristup ovom meniju jer nemas hook!")	
	}		
	return PLUGIN_HANDLED
}

public Hook_Menu(id, menu, key)
{
	if(key == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	new accss, clbck, data[6], name[64], itm
	menu_item_getinfo(menu, key, accss, data, 5, name, 63, clbck)
	itm = str_to_num(data)
	
	switch(itm)
	{
		case 1:
		{
			if(g_kuglice[id] == 0)
			{
					ColorChat(id, GREEN,"^4[UJBM] ^3Kuglice  Hook-a su vec setovane na ^4 roze pahulje ^1.")
					HookMenu(id)
			} else {
					g_kuglice[id] = 0
					ColorChat(id, GREEN,"^4[UJBM] ^3Kuglice Hook-a su setovane na ^4 roze pahulje^1.")
			}
		}
		case 2:
		{
			if(g_kuglice[id] == 1)
			{
					ColorChat(id, GREEN,"^4[UJBM] ^3Kuglice  Hook-a su vec setovane na ^4 plavo sunce^1.")
					HookMenu(id)
			} else {
					g_kuglice[id] = 1
					ColorChat(id, GREEN,"^4[UJBM] ^3Kuglice Hook-a su setovane na ^4 plavo sunce^1.")
			}
		}
		case 3:
		{
			if(g_kuglice[id] == 2)
			{
					ColorChat(id, GREEN,"^4[UJBM] ^3Kuglice  Hook-a su vec setovane na ^4 zelene kuglice^1.")
					HookMenu(id)
			} else {
					g_kuglice[id] = 2
					ColorChat(id, GREEN,"^4[UJBM] ^3Kuglice Hook-a su setovane na ^4 zelene kuglice^1.")
			}
		}
		case 4:
		{
			if(g_kuglice[id] == 3)
			{
					ColorChat(id, GREEN,"^4[UJBM] ^3Kuglice  Hook-a su vec setovane na ^4 infected^1.")
					HookMenu(id)
			} else {
					g_kuglice[id] = 3
					ColorChat(id, GREEN,"^4[UJBM] ^3Kuglice Hook-a su setovane na ^4 infected^1.")
			}
		}
		case 5:
		{
			if(g_kuglice[id] == 4)
			{
					ColorChat(id, GREEN,"^4[UJBM] ^3Kuglice  Hook-a su vec setovane na ^4 disko^1.")
					HookMenu(id)
			} else {
					g_kuglice[id] = 4
					ColorChat(id, GREEN,"^4[UJBM] ^3Kuglice Hook-a su setovane na ^4 disko^1.")
			}
		}
		case 6:
		{
			if(g_kuglice[id] == 5)
			{
					ColorChat(id, GREEN,"^4[UJBM] ^3Kuglice  Hook-a su vec setovane na ^4 plave pahulje^1.")
					HookMenu(id)
			} else {
					g_kuglice[id] = 5
					ColorChat(id, GREEN,"^4[UJBM] ^3Kuglice Hook-a su setovane na ^4 plave pahulje^1.")
			}
		}
		case 7:
		{
			if(g_kuglice[id] == 6)
			{
					ColorChat(id, GREEN,"^4[UJBM] ^3Kuglice  Hook-a su vec setovane na ^4 half-life^1.")
					HookMenu(id)
			} else {
					g_kuglice[id] = 6
					ColorChat(id, GREEN,"^4[UJBM] ^3Kuglice Hook-a su setovane na ^4 half-life^1.")
			}
		}
	}
	return PLUGIN_HANDLED
}

public HM(id)
{
	if(get_user_flags(id) & ADMIN_LEVEL_A)
	{
		new menu = menu_create("\y[UJBM]	\wZvuk Hook-a \y:3:","H_M")
		if(g_zvuk[id] == 0)
		{
			menu_additem(menu,"Zvuk 1 \y[Izabrana]", "1", 0)
		} else {
			menu_additem(menu,"Zvuk 1 \r[Izaberi]", "1", 0)
		}
		if(g_zvuk[id] == 1)
		{
			menu_additem(menu,"Zvuk 2 \y[Izabrana]", "2", 0)
		} else {
			menu_additem(menu,"Zvuk 2 \r[Izaberi]", "2", 0)
		}
		if(g_zvuk[id] == 2)
		{
			menu_additem(menu,"Zvuk 3  \y[Izabrana]", "3", 0)
		} else {
			menu_additem(menu,"Zvuk 3 \r[Izaberi]", "3", 0)
		}
		if(g_zvuk[id] == 3)
		{
			menu_additem(menu,"Zvuk 4  \y[Izabrana]", "4", 0)
		} else {
			menu_additem(menu,"Zvuk 4 \r[Izaberi]", "4", 0)
		}
		if(g_zvuk[id] == 4)
		{
			menu_additem(menu,"Zvuk 5  \y[Izabrana]", "5", 0)
		} else {
			menu_additem(menu,"Zvuk 5 \r[Izaberi]", "5", 0)
		}
		if(g_zvuk[id] == 5)
		{
			menu_additem(menu,"Zvuk 6  \y[Izabrana]", "6", 0)
		} else {
			menu_additem(menu,"Zvuk 6 \r[Izaberi]", "6", 0)
		}
		if(g_zvuk[id] == 6)
		{
			menu_additem(menu,"Zvuk 7  \y[Izabrana]", "7", 0)
		} else {
			menu_additem(menu,"Zvuk 7 \r[Izaberi]", "7", 0)
		}
		if(g_zvuk[id] == 7)
		{
			menu_additem(menu,"Zvuk 8  \y[Izabrana]", "8", 0)
		} else {
			menu_additem(menu,"Zvuk 8 \r[Izaberi]", "8", 0)
		}
		if(g_zvuk[id] == 8)
		{
			menu_additem(menu,"Zvuk 9  \y[Izabrana]", "9", 0)
		} else {
			menu_additem(menu,"Zvuk 9 \r[Izaberi]", "9", 0)
		}		
		
		menu_setprop(menu, MPROP_NEXTNAME, "Sledeca")
		menu_setprop(menu, MPROP_BACKNAME, "Nazad")
		menu_setprop(menu, MPROP_EXITNAME, "\rIzlaz")
		menu_setprop(menu, MPROP_EXIT,	MEXIT_ALL)
		menu_display(id, menu)	
		
	} else {
		ColorChat(id, GREEN,"^4[UJBM] ^3Nemas pristup ovom meniju jer nemas hook!")	
	}		
	return PLUGIN_HANDLED
}

public H_M(id, menu, key)
{
	if(key == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	new accss, clbck, data[6], name[64], itm
	menu_item_getinfo(menu, key, accss, data, 5, name, 63, clbck)
	itm = str_to_num(data)
	
	switch(itm)
	{
		case 1:
		{
			if(g_zvuk[id] == 0)
			{
					ColorChat(id, GREEN,"^4[UJBM] ^3Zvuk Hook-a je vec setovan na ^4 zvuk 1^1.")
					HookMenu(id)
			} else {
					g_zvuk[id] = 0
					ColorChat(id, GREEN,"^4[UJBM] ^3Zvuk Hook-a je setovan na ^4 zvuk 1^1.")
			}
		}
		case 2:
		{
			if(g_zvuk[id] == 1)
			{
					ColorChat(id, GREEN,"^4[UJBM] ^3Zvuk Hook-a je vec setovan na ^4 zvuk 2^1.")
					HookMenu(id)
			} else {
					g_zvuk[id] = 1
					ColorChat(id, GREEN,"^4[UJBM] ^3Zvuk Hook-a je setovan na ^4 zvuk 2^1.")
			}
		}
		case 3:
		{
			if(g_zvuk[id] == 2)
			{
					ColorChat(id, GREEN,"^4[UJBM] ^3Zvuk Hook-a je vec setovan na ^4 zvuk 3^1.")
					HookMenu(id)
			} else {
					g_zvuk[id] = 2
					ColorChat(id, GREEN,"^4[UJBM] ^3Zvuk Hook-a je setovan na ^4 zvuk 3^1.")
			}
		}
		case 4:
		{
			if(g_zvuk[id] == 3)
			{
					ColorChat(id, GREEN,"^4[UJBM] ^3Zvuk Hook-a je vec setovan na ^4 zvuk 4^1.")
					HookMenu(id)
			} else {
					g_zvuk[id] = 3
					ColorChat(id, GREEN,"^4[UJBM] ^3Zvuk Hook-a je setovan na ^4 zvuk 4^1.")
			}
		}
		case 5:
		{
			if(g_zvuk[id] == 4)
			{
					ColorChat(id, GREEN,"^4[UJBM] ^3Zvuk Hook-a je vec setovan na ^4 zvuk 5^1.")
					HookMenu(id)
			} else {
					g_zvuk[id] = 4
					ColorChat(id, GREEN,"^4[UJBM] ^3Zvuk Hook-a je setovan na ^4 zvuk 5^1.")
			}
		}
		case 6:
		{
			if(g_zvuk[id] == 5)
			{
					ColorChat(id, GREEN,"^4[UJBM] ^3Zvuk Hook-a je vec setovan na ^4 zvuk 6^1.")
					HookMenu(id)
			} else {
					g_zvuk[id] = 5
					ColorChat(id, GREEN,"^4[UJBM] ^3Zvuk Hook-a je setovan na ^4 zvuk 6^1.")
			}
		}
		case 7:
		{
			if(g_zvuk[id] == 6)
			{
					ColorChat(id, GREEN,"^4[UJBM] ^3Zvuk Hook-a je vec setovan na ^4 zvuk 7^1.")
					HookMenu(id)
			} else {
					g_zvuk[id] = 6
					ColorChat(id, GREEN,"^4[UJBM] ^3Zvuk Hook-a je setovan na ^4 zvuk 7^1.")
			}
		}
		case 8:
		{
			if(g_zvuk[id] == 7)
			{
					ColorChat(id, GREEN,"^4[UJBM] ^3Zvuk Hook-a je vec setovan na ^4 zvuk 8^1.")
					HookMenu(id)
			} else {
					g_zvuk[id] = 7
					ColorChat(id, GREEN,"^4[UJBM] ^3Zvuk Hook-a je setovan na ^4 zvuk 8^1.")
			}
		} 
		case 9:
		{
			if(g_zvuk[id] == 8)
			{
					ColorChat(id, GREEN,"^4[UJBM] ^3Zvuk Hook-a je vec setovan na ^4 zvuk 9^1.")
					HookMenu(id)
			} else {
					g_zvuk[id] = 8
					ColorChat(id, GREEN,"^4[UJBM] ^3Zvuk Hook-a je setovan na ^4 zvuk 9^1.")
			}			
		}
	}
	return PLUGIN_HANDLED
}

public tet()
{
        ColorChat(0, TEAM_COLOR, "^4[UJBM]^1 Say ^3 /hook ^1 da otvoris ^4 hook ^1 menu")
        set_task(120.0, "erer")
        return PLUGIN_CONTINUE
}
 
public erer()
{
        ColorChat(0, TEAM_COLOR, "^4[UJBM]^1 Say ^3 /hook ^1 da otvoris ^4 hook ^1 menu")
        set_task(120.0, "tet")
        return PLUGIN_CONTINUE
}

public client_disconnect(id) {
	remove_hook(id)
	g_speed[id] = 1
}

public client_putinserver(id) {
	remove_hook(id)
	g_speed[id] = 1
}
public give_hook(id,level,cid) {
	if(!cmd_access(id,level,cid,3))
		return PLUGIN_HANDLED
			
	new name[32]
	get_user_name(id,name,32)
		
	new szarg1[32], szarg2[8], bool:mode
	read_argv(1,szarg1,32)
	read_argv(2,szarg2,32)
	if(equal(szarg2,"on"))
		mode = true
		
	if(equal(szarg1,"@ALL")) {
		for(new	i=1;i<=get_maxplayers();i++) {
			if(is_user_connected(i) && is_user_alive(i)) {
				canusehook[i-1] = mode
				if(mode) {
					client_print(i,print_chat,"[UJBM]	^1Admin ^4%s ^1 je ^3dao svim ^1igracima da koriste superhook", name)
					client_print(i,print_chat,"[UJBM]	Da koristis hook kucaj u konzoli 'bind slovo +shook' ")
				}
				else
					client_print(i,print_chat,"[UJBM]	^1Admin ^4%s ^1 je ^3dao svim ^1igracima da koriste superhook ^4%s ^1.", name)
			}
		}
	}
	else	{
		new pid	= cmd_target(id,szarg1,2)
		if(pid > 0)	{
			canusehook[pid-1] =mode
			if(mode) {
				client_print(pid,print_chat,"[UJBM]	^1Admin ^4%s ^1 je  ^3dozvolio ^1igracu da koristi superhook ^4%s ^1.", name)
				client_print(pid,print_chat,"[UJBM]	Da koristis hook kucaj u konzoli 'bind slovo +shook'")
			}
			else
				client_print(pid,print_chat,"[UJBM]	^1Admin ^4%s ^1 je  ^3dozvolio ^1igracu da koristi superhook ^4%s ^1.", name)
		}
	}
	
	return PLUGIN_HANDLED
}

public hook_on(id,level,cid)

{
	if(!is_user_alive(id))
	return FMRES_IGNORED;
	if(get_pcvar_num(Enable))
	{
		if(!canusehook[id-1] && !cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED
	
	if(get_user_flags(id) & ADMIN_BAN)
	{
		get_user_origin(id,hookorigin[id-1],3)
	
	if(callfunc_begin("detect_cheat","prokreedz.amxx") == 1) {
		callfunc_push_int(id)
		callfunc_push_str("Hook")
		callfunc_end()
	}
	
	ishooked[id-1] = true
	set_task(0.1,"hook_task",id,"",0,"ab")
	hook_task(id)
	func_break(id)
	func_zvuk(id) 
	
	}						
	if(is_user_alive(id) && get_pcvar_num(Glow))
		{
			if(is_user_alive(id) && get_pcvar_num(GlowRandom))
			{
				set_user_rendering(id, kRenderFxGlowShell, random_num(0,255), random_num(0,255),	 random_num(0,255), kRenderNormal, 16)
			}
			else
			{
				set_user_rendering(id, kRenderFxGlowShell, (get_pcvar_num(GlowR)), (get_pcvar_num(GlowG)), (get_pcvar_num(GlowB)), kRenderNormal, 16)
			}
		}
	}
	else
	{
		ColorChat(id, RED,"[UJBM] ^4 FUNKCIJA OTKLJUCANA!")
	}
	
	if( get_pcvar_num(Fade))
	{
		if(get_pcvar_num(FadeRandom))
		{
			message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenFade"), {0,0,0}, id)
			write_short(10<<12)
			write_short(10<<16)
			write_short(1<<1)
			write_byte random_num(0,255)
			write_byte random_num(0,255)
			write_byte random_num(0,255)
			write_byte(255)
			message_end()
		}
		else
		{
			message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenFade"), {0,0,0}, id)
			write_short(10<<12)
			write_short(10<<16)
			write_short(1<<1)
			write_byte(get_pcvar_num(fadeR))
			write_byte(get_pcvar_num(fadeG))
			write_byte(get_pcvar_num(fadeB))
			write_byte(255)
			message_end()
		}
	}
	
	return PLUGIN_HANDLED
}

public is_hooked(id) {
	return ishooked[id-1]
}

public hook_off(id) {
	remove_hook(id)
	if(is_user_alive(id) && get_pcvar_num(Glow))
	{
		set_user_rendering(id, kRenderFxGlowShell, random_num(0,0), random_num(0,0), random_num(0,0), kRenderNormal, 16)
	}
	
	if(get_pcvar_num(Fade))
	{
		message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenFade"), {0,0,0}, id)
		write_short(10<<12)
		write_short(10<<16)
		write_short(1<<1)
		write_byte(255)
		write_byte(255)
		write_byte(255)
		write_byte(255)
		message_end()
	}
	
	return PLUGIN_HANDLED
}

public hook_task(id) {
	if(!is_user_connected(id) || !is_user_alive(id))
		remove_hook(id)
	
	remove_beam(id)
	f(id)
	func_trail(id)
	func_trail_ct(id)
	
	new origin[3], Float:velocity[3]
	get_user_origin(id,origin)	
	new distance = get_distance(hookorigin[id-1],origin)
	
	if(distance > 25)
	{	
		if(g_speed[id] == 0)
		{
			velocity[0] = (hookorigin[id-1][0] - origin[0]) * (4.0 * 100 / distance)
			velocity[1] = (hookorigin[id-1][1] - origin[1]) * (4.0 *	100 / distance)
			velocity[2] = (hookorigin[id-1][2] - origin[2]) * (4.0 *	100 / distance)
		} else if(g_speed[id] == 1) {
			velocity[0] = (hookorigin[id-1][0] - origin[0]) * (4.0 * 200 / distance)
			velocity[1] = (hookorigin[id-1][1] - origin[1]) * (4.0 *	200 / distance)
			velocity[2] = (hookorigin[id-1][2] - origin[2]) * (4.0 *	200 / distance)
		} else if(g_speed[id] == 2) {
			velocity[0] = (hookorigin[id-1][0] - origin[0]) * (4.0 * 300 / distance)
			velocity[1] = (hookorigin[id-1][1] - origin[1]) * (4.0 *	300 / distance)
			velocity[2] = (hookorigin[id-1][2] - origin[2]) * (4.0 *	300 / distance)
		}
		
		entity_set_vector(id,EV_VEC_velocity,velocity)
	}	
	else {
		entity_set_vector(id,EV_VEC_velocity,Float:{0.0,0.0,0.0})
		remove_hook(id)
	}
}

public f(id) {
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMENTPOINT);
	write_short(id);
	write_coord(hookorigin[id-1][0]);
	write_coord(hookorigin[id-1][1]);
	write_coord(hookorigin[id-1][2]);
			
	switch(g_izgled[id])
	{
		case 0:
		{
			write_short(g_iBeamSprite);
		}
		case 1:
		{
			write_short(g_iBeamSprite1);
		}
		case 2:
		{
			write_short(g_iBeamSprite2);
		}
		case 3:
		{
			write_short(g_iBeamSprite3);
		}
		case 4:
		{
			write_short(g_iBeamSprite4);
		}
		case 5:
		{
			write_short(g_iBeamSprite5);
		}
		case 6:
		{
			write_short(g_iBeamSprite6);	
		}
	}
	
	write_byte(0);
	write_byte(1);
	write_byte(1);
	write_byte(40);
	write_byte(10);
	write_byte(random(255));
	write_byte(random(255));
	write_byte(random(255));
	write_byte(2000);												//Яркость
	write_byte(0);																//...
	message_end();
}

public func_break(id)
{
	new origin[3]
			
	get_user_origin(id,origin,3)
	
	message_begin(MSG_ALL,SVC_TEMPENTITY,{0,0,0},id)
	write_byte(TE_SPRITETRAIL)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]+20)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]+80)
	
	switch(g_kuglice[id])
	{
		case 0:
		{
			write_short(model_gibs);
		}
		case 1:
		{
			write_short(model_gibs1);
		}
		case 2:
		{
			write_short(model_gibs2);
		}
		case 3:
		{
			write_short(model_gibs3);
		}
		case 4:
		{
			write_short(model_gibs4);
		}
		case 5:
		{
			write_short(model_gibs5);
		}
		case 6:
		{
			write_short(model_gibs6);	
		}
	}
	write_byte(20)
	write_byte(20)
	write_byte(4)
	write_byte(20)
	write_byte(10)
	message_end()
}

public func_zvuk(id)
{
	switch(g_zvuk[id])
	{
		case 0:
		{
			emit_sound(id,CHAN_STATIC,"hook/hook1.wav",1.0,ATTN_NORM,0,PITCH_NORM)
		}
		case 1:
		{
			emit_sound(id,CHAN_STATIC,"hook/hook2.wav",1.0,ATTN_NORM,0,PITCH_NORM)
		}
		case 2:
		{
			emit_sound(id,CHAN_STATIC,"hook/hook3.wav",1.0,ATTN_NORM,0,PITCH_NORM)
		}
		case 3:
		{
			emit_sound(id,CHAN_STATIC,"hook/hook4.wav",1.0,ATTN_NORM,0,PITCH_NORM);
		}
		case 4:
		{
			emit_sound(id,CHAN_STATIC,"hook/hook5.wav",1.0,ATTN_NORM,0,PITCH_NORM);
		}
		case 5:
		{
			emit_sound(id,CHAN_STATIC,"hook/hook6.wav",1.0,ATTN_NORM,0,PITCH_NORM);
		}
		case 6:
		{
			emit_sound(id,CHAN_STATIC,"hook/hook7.wav",1.0,ATTN_NORM,0,PITCH_NORM);
		}
		case 7:
		{
			emit_sound(id,CHAN_STATIC,"hook/hook8.wav",1.0,ATTN_NORM,0,PITCH_NORM);
		}
		case 8:
		{
			emit_sound(id,CHAN_STATIC,"hook/hook9.wav",1.0,ATTN_NORM,0,PITCH_NORM);
		}
	}
}

public func_trail(id) {
	if(cs_get_user_team(id) == CS_TEAM_T)
	{
		{
			{
				
				message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
				write_byte(TE_BEAMFOLLOW)
				write_short(id)
				write_short(gTrail)
				write_byte(TRAIL_LIFE)
				write_byte(TRAIL_WIDTH)
				write_byte(TRAIL_RED)
				write_byte(TRAIL_GREEN)
				write_byte(TRAIL_BLUE)
				write_byte(TRAIL_BRIGTHNESS)
				message_end()
			}
		}		
	}
}

public func_trail_ct(id){
	if(cs_get_user_team(id) == CS_TEAM_CT)
	{
		{
			{
				
				message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
				write_byte(TE_BEAMFOLLOW)
				write_short(id)
				write_short(gTrail1)
				write_byte(TRAIL_LIF)
				write_byte(TRAIL_WIDT)
				write_byte(TRAIL_RE)
				write_byte(TRAIL_GREE)
				write_byte(TRAIL_BLU)
				write_byte(TRAIL_BRIGTHNES)
				message_end()
			}
		}		
	}
}

public remove_hook(id) {
	if(task_exists(id))
		remove_task(id)
		remove_beam(id)
		ishooked[id-1] = false
}

public remove_beam(id) {
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(99)	
	write_short(id)
	message_end()
}
