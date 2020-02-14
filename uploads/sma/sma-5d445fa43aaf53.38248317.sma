
#include <amxmodx>
#include <amxmisc>
#define PLUGIN "OpenglDetektor"
#define VERSION "1.1"
#define AUTHOR "5ardica"

new g_CheckPlayer[33]		
new g_PunishPlayer[33]

new g_File[17] = "../opengl32.dll"
new g_PrecFile[32]
new g_Path[12] ="../opengl32"
new Array:g_Files

new g_Enable
new g_PunishType
new g_BanTime
new g_ShowAdmin

stock bool:file_copy(SOURCE[], TARGET[], error[], const ERRORLEN, const bool:REPLACE_TARGET = false) 
{
	if (!file_exists(SOURCE)) 
	{
		format(error, ERRORLEN, "File copy error: Source ^"%s^" doesn't exist!", SOURCE)
		return false
	}
	if (!REPLACE_TARGET && file_exists(TARGET)) 
	{
		format(error, ERRORLEN, "File copy error: Target ^"%s^" exists!", TARGET)
		return false
	}
	
	new source = fopen(SOURCE, "rb")
	if (!source) 
	{
		format(error, ERRORLEN, "File copy error: Opening source ^"%s^" failed!", SOURCE)
		return false
	}
	
	new target = fopen(TARGET, "wb")
	if (!target)
	{
		format(error, ERRORLEN, "File copy error: Opening target ^"%s^" failed!", TARGET)
		fclose(source)
		return false
	}
	
	for (new buffer, eof = feof(source); !eof; !eof && fputc(target, buffer)) 
	{
		buffer = fgetc(source)
		eof = feof(source)
	}
	
	fclose(source)
	fclose(target)

	return true
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_concmd("amx_opengl_list","opengl_list",ADMIN_BAN,"List opengl files and stats")
	register_concmd("amx_opengl_set","opengl_set",ADMIN_BAN,"'opengl_set x' 1->nr.max. Set specific opengl file for nextmap or 0 for cyclic")
	register_event("Damage", "Event_Damage", "b", "2!0", "3=0", "4!0");
	
	g_Enable = register_cvar("opengl_enable", "1") // enable?
	g_BanTime = register_cvar("opengl_bantime", "43200") // 30 Days BAN (43200 minutes)
	g_PunishType = register_cvar("opengl_punish_type", "1") // 1-ban,2-kick,3-log
	g_ShowAdmin = register_cvar("opengl_show_admin", "1") // 0-disable,1-anounce admins,2-anounce everybody
	
	if (!file_exists(g_File))
	{
		server_print("[OpenglCheck] No opengl32 ,plugin disable!!!") 
		set_pcvar_num(g_Enable,0)
		//return PLUGIN_HANDLED
	}
	
	set_task(1.0,"load")
	return PLUGIN_CONTINUE
}

public load()
{
	
	if (!dir_exists(g_Path))
         {
		server_print("[OpenglCheck] No dir opengl32 with source files!!!") 
		return PLUGIN_HANDLED
	}

	//check and copy opengl file in case of first time run plugin
	new glfile[32], glfile_path[64], err[64]
	
	if(!file_exists(g_File))
	{
		new gldir = open_dir(g_Path,glfile,31)
		
		formatex(glfile_path,63,"%s/%s",g_Path,glfile)
		file_copy(glfile_path,g_File,err,63,true)
		
		if (strlen(err)>0)
		{
			server_print("[OpenglCheck] %s",err)
			server_print("[OpenglCheck] Invalid opengl32 file,!!!")
			return PLUGIN_HANDLED
		}
		close_dir(gldir)
	}
	
	//Loop opengl dir to identify curent opengl file with md5, 
	//and store names for setting next precache file
	
	new prec_buff[34], glfile_buff[34]
	md5_file(g_File,prec_buff)
	
	g_Files = ArrayCreate(32);
	new gldir = open_dir(g_Path,glfile,31)
	new maxarr = 0
	
	do
	{
		if(strlen(glfile)>3)
		{
			if(contain(glfile,"@")!=-1) 
			{
				new renfile[64]
				
				formatex(renfile,63,"%s",glfile)
				replace(glfile,31,"@","")
				formatex(glfile_path,63,"%s/%s",g_Path,glfile)
				format(renfile,63,"%s/%s",g_Path,renfile)
				
				rename_file(renfile,glfile_path,true)
				server_print("[OpenglCheck] Invalid opengl file name: %s renamed to: %s",renfile,glfile_path)
			}
			
			formatex(glfile_path,63,"%s/%s",g_Path,glfile)
			md5_file(glfile_path,glfile_buff)
			if(equal(prec_buff,glfile_buff))
			{
				copy(g_PrecFile,31,glfile)
				server_print("[OpenglCheck] Precached opengl file is %s",g_PrecFile) 	
			}
			ArrayPushString(g_Files,glfile);
			maxarr += 1;
		}
	
	}
	while ( next_file(gldir,glfile,31))
	close_dir(gldir)		
	
	//check and update list of files
	new listfile[128]
	
	get_configsdir(listfile,127)
	format(listfile,127,"%s/openglfiles.txt",listfile)
	
	if(!file_exists(listfile))
	{
		server_print("[OpenglCheck] openglfiles.txt not exist, create file !!!")
		write_file(listfile,g_PrecFile,0)
		write_file(listfile,"0",1)
	}

	new i, chk, lstfile[36],chkfile[36],arrfile[32], maxlst, len
	
	//new maxlst = file_size(listfile,1)

	for(i = 0 ; i < maxarr ; i++)
	{
		ArrayGetString(g_Files,i,arrfile,31)
		formatex(chkfile,35,"@%s",arrfile)
		chk = 0
		
		
		/*
		new listfile_handle = fopen( listfile, "rt" );
		while(!feof(listfile_handle))
		{
			fgets(listfile_handle,lstfile,35)
			if(strlen(lstfile) >10)
			{
				if (strfind(lstfile,chkfile)!=-1)
					chk += 1
			}
		}
		*/
		
		new j
		maxlst = file_size(listfile,1)
		
		for(j = 2 ; j < maxlst-1 ; j++)
		{
			read_file(listfile,j,lstfile,31,len)
			if (strfind(lstfile,chkfile)!=-1)
				chk += 1
		}
		
		if (chk == 0)	
		{
			server_print("[OpenglCheck] write opengl file %s in list",chkfile)
			format(chkfile,35,"0%s",chkfile)
			write_file(listfile,chkfile,-1)
		}
	}
	
	//set nextopengl file
	new nextfile[32], setfile[32], pos
	
	read_file(listfile,0,nextfile,31,len)
	read_file(listfile,1,setfile,31,len)
	
	if( strlen(setfile) < 2 ) //cycle ?
	{
		
		if(maxlst > 3) 
		{
			i=0
			for( i = 0 ; i < maxarr ; i++ )
			{
				ArrayGetString(g_Files,i,chkfile,31)
				
				if ( strfind(nextfile,chkfile) != -1)
				{
					if (i == maxarr-1)
						pos = 0
					else
						pos = i+1
				}
			}
			ArrayGetString(g_Files,pos,nextfile,31)
		}
		else
		{
			copy(nextfile,31,g_PrecFile)
		}
		
		formatex(glfile_path,63,"%s/%s",g_Path,nextfile)
		write_file(listfile,nextfile,0)
	}
	else
	{
		formatex(glfile_path,63,"%s/%s",g_Path,setfile)
	}
	
	ArrayDestroy(g_Files);
	
	file_copy(glfile_path,g_File,err,63,true)
	if (strlen(err)>0)
		server_print("[OpenglCheck] %s",err)
	return PLUGIN_CONTINUE
}

public plugin_precache()
{
    force_unmodified(force_exactfile, {0,0,0},{0,0,0}, g_File)
}

public inconsistent_file(id, const filename[], reason[64])
{ 
	if (equal(filename,g_File))
	{
		g_CheckPlayer[id]=1
		g_PunishPlayer[id]=0
	}
	return PLUGIN_HANDLED 
} 

public client_connect(id)
{
	g_CheckPlayer[id]=0
	g_PunishPlayer[id]=1
	if((get_pcvar_num(g_Enable)==0)&&(file_exists (g_File)))
		set_pcvar_num(g_Enable,1)
	return PLUGIN_CONTINUE
}

public client_putinserver(id)
{
	if ( is_user_hltv(id) || is_user_bot(id) )
	{
		g_PunishPlayer[id]=0
		g_CheckPlayer[id]=1
		return PLUGIN_HANDLED
	}
	set_task(5.0, "check_file", id)
	return PLUGIN_HANDLED
}

public client_disconnect(id)
{
	g_CheckPlayer[id]=0
	g_PunishPlayer[id]=0
	if(task_exists(id))
		remove_task(id)
}  

public Event_Damage(id) 
{
	if(get_pcvar_num(g_Enable)==0)
		return PLUGIN_HANDLED
	if (id>0) {
		new attacker = get_user_attacker(id)
		if (attacker > 0 && attacker <= 32)
		{ 
			if(g_PunishPlayer[attacker]==0)
				return PLUGIN_HANDLED
			if(g_CheckPlayer[attacker]==0)
				set_task(1.0,"punish_player",attacker+33)
		}
	}
	return PLUGIN_CONTINUE;
}

public check_file(id)
{
	if(get_pcvar_num(g_Enable)==0)
		return PLUGIN_HANDLED
	
	
	if(g_CheckPlayer[id]==0)
	{   
		new name[32]
		get_user_name(id, name, sizeof(name)-1)
		
		new msg[127]
		switch(get_pcvar_num(g_PunishType))
		{
			case 1:
				formatex(msg,127,"; ce biti banovan na %d min. posle prvog napada", get_pcvar_num(g_BanTime) )
			case 2:
				formatex(msg,127,"; ce biti kikovan posle prvog napada")
			case 3:
				formatex(msg,127,"!!!")
			default:
				formatex(msg,127,"; ce biti banovan na %d min. posle prvog napada", get_pcvar_num(g_BanTime) )
		}
		format(msg,127,"[OpenglCheck] Igrac %s ima OpenGL32 hack fajl. %s",name,msg)

		switch(get_pcvar_num(g_ShowAdmin))
		{
			case 0:
				return PLUGIN_HANDLED
			case 1:
			{
				new players[32],num,i;
				get_players(players,num,"c");
				for(i=1;i<num;i++) 
				{
					if( get_user_flags(i) & ADMIN_KICK )
						client_print(i,print_chat," %s",msg);
				}
			}
			case 2:
				client_print(0,print_chat," %s",msg);
			default:
				client_print(0,print_chat," %s",msg);
		}
	}
	return PLUGIN_CONTINUE;
}

public punish_player(id)
{
	
	if(get_pcvar_num(g_Enable)==0)
		return PLUGIN_HANDLED
		
	new name[32], authid[32], ip[32]
	id -= 33
	get_user_authid(id, authid, sizeof(authid)-1)
	get_user_ip(id, ip, 31, 1)
	get_user_name(id, name, sizeof(name)-1)
	
	client_print(id,print_chat,"[OpenglCheck]OpenGL32 hak detektovan na tebi :P") //
	
	switch(get_pcvar_num(g_PunishType))
	{
		case 1:
			server_cmd("amx_ban %s %d ^"Wallhack OpenGL^"", name, get_pcvar_num(g_BanTime) )
		case 2:
			server_cmd("kick %s  Wallhack OpenGL", name) 
		default:
			server_cmd("amx_ban %s %d ^"Wallhack OpenGL^"", name, get_pcvar_num(g_BanTime) )
	}
				
	log_amx("Wallhack OpenGL verzija %s je pronadjena %s<%s><%s> ",g_PrecFile, name, ip, authid)
	g_PunishPlayer[id]=0
	set_pcvar_num(g_Enable,0) 
				
	//increment number in opengl list file
				
	new listfile[128]
	get_configsdir(listfile,127)
	format(listfile,127,"%s/openglfiles.txt",listfile)
			
	new upfile[36]
	formatex(upfile,35,"@%s",g_PrecFile)
				
	if(!file_exists(listfile)) 
	{
		server_print("[OpenglCheck] Lista ce se kreirati !!!!")
		
		write_file(listfile,g_PrecFile,0)
		write_file(listfile,"0",1)
		
		format(upfile,35,"1%s",upfile)
		write_file(listfile,upfile,2)
		
		return PLUGIN_HANDLED;
	}
				
	//loop list file to find and extract number for precached file
	new maxlst = file_size(listfile,1)
	new i,chkfile[36], pnumstr[5], pnum, pos, len
			
	for( i = 2 ; i < maxlst - 1 ; i++)
	{
		read_file(listfile,i,chkfile,35,len)
					
		if(strfind(chkfile,upfile) != -1 )
		{
			strtok(chkfile,pnumstr,4,chkfile,31,'@')
			pnum=str_to_num(pnumstr)
			pnum += 1
			format(upfile,35,"%d%s",pnum,upfile)
			pos = i
		}
	}
	if(pos)	//be sure to avoid damage file
		write_file(listfile,upfile,pos)
	return PLUGIN_HANDLED;
}



public opengl_list(id, level, cid)
{
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED;
	
	new listfile[128]
	get_configsdir(listfile,127)
	formatex(listfile,127,"%s/openglfiles.txt",listfile)
	
	new maxlst = file_size(listfile,1)
	new i, name[36], chkfile[64], pnum[5],len
	
	console_print(id,"---- Status of opengl files ----")
	console_print(id,"Current opengl file is %s",g_PrecFile)

	read_file(listfile,0,name,35,len)
	console_print(id,"Next opengl file is %s",name)
	
	read_file(listfile,1,name,35,len)
	
	if(strlen(name)<5)
		console_print(id,"ON")
	else
		console_print(id,"OFF : %s",name)
	
	for( i = 2 ; i < maxlst - 1 ; i++)
	{
		read_file(listfile,i,name,35,len)
		strtok(name,pnum,4,name,31,'@')
		format(chkfile,63,"%s/%s",g_Path,name)
		
		if(file_exists(chkfile))
			console_print(id,"%d. %s pronadjeno na  %s players",i-1,name,pnum)
		else
			console_print(id,"%d. %s je pronadjen na %s players * izbrisan fajl",i-1,name,pnum)
	}
	return PLUGIN_CONTINUE;
}

public opengl_set(id, level, cid)
{
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED;
	
	new listfile[128]
	
	get_configsdir(listfile,127)
	formatex(listfile,127,"%s/openglfiles.txt",listfile)
	
	
	if(!file_exists(listfile))
	{
		console_print(id,"[OpenglCheck] Lista OPENGL32 Fajlova ne postoji bice kreirana ")
		write_file(listfile,g_PrecFile,0)
		write_file(listfile,"0",1)
		return PLUGIN_HANDLED;
	}
	
	new arg[4];
	read_argv(1,arg,3);
	
	new lstmax = file_size(listfile,1)
	
	new pos = str_to_num(arg)
	
	if ( pos ==0 )
	{
		console_print(id,"[OpenglCheck] odabrao si")
		write_file(listfile,"0",1)
		return PLUGIN_HANDLED;
	}
		
	if ( (pos < 0) || ( pos > lstmax - 1 ) )
	{
		console_print(id,"[OpenglCheck] Los broj fajla")
		return PLUGIN_HANDLED;
	}
	
	new name[36], chkfile[64], pnum[5], len
	
	read_file(listfile,pos+1,name,35,len)
	strtok(name,pnum,4,name,31,'@')
	
	//check if file was not deleted from opengl32 dir
	format(chkfile,63,"%s/%s",g_Path,name)
	
	if(!file_exists(chkfile))
	{
		console_print(id,"[OpenglCheck] Los broj fajla je izbrisan")
		return PLUGIN_HANDLED;
	}
	
	write_file(listfile,name,1)
	console_print(id,"[OpenglCheck]Izabrao si %d da bude sledeci loadovan %s",pos,name)
	
	set_task(1.0,"load")
	return PLUGIN_CONTINUE;
}
/* AMXX-Studio Notes -  NE DIRAJ OVDE ISPOD
*{\\ rtf1\\ ansi\\ ansicpg1252\\ uc1\\ deff0\\ deflang1033\\ deflangfe1033{\\ fonttbl{\\ f0 Tahoma;}}\n\\ f0{\\ colortbl;}{\\ *\\ generator Wine Riched20 2.0.????;}\\ pard\\ sl-240\\ slmult1\\ li0\\ fi0\\ ri0\\ sa0\\ sb0\\ s-1\\ cfpat0\\ cbpat0\n\\ par}
*/
