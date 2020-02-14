#include <amxmodx>
#include <celltrie>
#define PLUGIN "floodban" // 
#define VERSION "0.1"
#define AUTHOR "5ardica"

new Trie:g_u_ip_warn
new Trie:g_u_time

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	g_u_ip_warn=TrieCreate();
	g_u_time=TrieCreate();
	set_task(360.0,"arrclear",_,_,_,"b")
}

public arrclear()
{
	TrieClear(g_u_ip_warn)
	TrieClear(g_u_time)
}
public client_connect(id) 
{ 
	if(is_user_bot(id)) return;
	new ip[32]
	new ltime
	get_user_ip(id,ip,31,0)
	if(!ip[0]) return;
	if (!TrieKeyExists(g_u_ip_warn, ip))
	{
		TrieSetCell(g_u_ip_warn,ip,1);
	}
	else
	{
		TrieGetCell(g_u_time,ip,ltime);
		if(!(get_systime()-ltime))
		{
			new warn
			TrieGetCell(g_u_ip_warn,ip,warn)
			if(++warn>4)
			{
				new uip[32]
				get_user_ip(id,uip,31,1)
				server_cmd("addip 600.0 %s",uip)
				TrieDeleteKey(g_u_ip_warn, ip);
			}
			else
				TrieSetCell(g_u_ip_warn,ip,warn)
		}
	}
	TrieSetCell(g_u_time,ip,get_systime());
}
