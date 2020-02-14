/* First, save the file !   -   Sublime AMXX Editor v1.9 */

#include <amxmodx>

#pragma semicolon 1

new Trie:_hashList;

new const
   _getResult[][][] = { 
      { "#Cstrike_Chat_CT",         "^x01(Counter-Terrorist)^x01"},
      { "#Cstrike_Chat_CT_Dead",    "^x01*DEAD* (Counter-Terrorist)^x01"},
      { "#Cstrike_Chat_All",        "^x03"},
      { "#Cstrike_Chat_Spec",       "^x01(Spectator)^x01"},
      { "#Cstrike_Chat_T",          "^x01(Terrorist)^x01"},
      { "#Cstrike_Chat_T_Dead",     "^x01*DEAD* (Terrorist)^x01"},
      { "#Cstrike_Chat_AllDead",    "^x01*DEAD*^x01"},
      { "#Cstrike_Chat_AllSpec",    "^x01*SPEC*^x01"}
   }
;

public plugin_end( )       TrieDestroy( _hashList );
public plugin_precache()   register_message(get_user_msgid("SayText"),"sayText_LastBuild_Hook");

public plugin_init(){
   
   register_plugin("Some shit", "1.0", "Spawner & SkillartzHD");
   
   _hashList = TrieCreate();
   for(new i; i < sizeof _getResult; i++)
      TrieSetString(  _hashList, _getResult[i][0], _getResult[i][1] );
   
}

public sayText_LastBuild_Hook(  ){
   
   // Isn't is user connected (->ingame) already checked?
   new _getMessage[ 192 ];
   read_args(_getMessage, charsmax(_getMessage));
   
   new _getType[ 24 ], _userName[ 32 ], _output[ 34 ];
   
   get_msg_arg_string(2, _getType, charsmax(_getType));
   get_user_name( get_msg_arg_int(1), _userName, charsmax(_userName) );
   TrieGetString( _hashList, _getType, _output, charsmax(_output) );
   
   replace(_getMessage, charsmax(_getMessage), "^"", "");
   format(_getMessage, charsmax(_getMessage), "%s ^x03%s : ^x01%s", _output,  _userName, _getMessage);
   
   !equali(_getType,"#Cstrike_Name_Change") ? set_msg_arg_string( 2, _getMessage ) : 1;  //#'" Somehow there is a unknown bug changing name which displace name :" xx, so this line code will fix it.
   
}
