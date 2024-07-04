#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

new money

new plr_money[33]
new plr_cur_money[33]
new bool:plr_prespawn[33]

new onoff,speed_per_sec

public plugin_init() {
	register_plugin("Money HUD Effect","0.9","Sh!nE")
	
	register_event("Money","update_money","b")
	
	onoff = register_cvar("amx_mhe_money","1")
	speed_per_sec = register_cvar("amx_mhe_money_speed","10")
	
	RegisterHam(Ham_Spawn,"player","player_prespawn",0)
	RegisterHam(Ham_Spawn,"player","player_spawn",1)
	
	money = get_user_msgid("Money")
	
	register_message(money,"hook_money")
}

public client_disconnect(id) {
	plr_money[id]=0
	plr_cur_money[id]=0
	plr_prespawn[id]=false
	
	remove_task(id)
}

public player_prespawn(id) { 
	if(get_pcvar_num(onoff) && is_user_connected(id)) {
		plr_prespawn[id]=true
		
		plr_money[id]=get_pdata_int(id,115,5)
		plr_cur_money[id]=0
		
		set_pdata_int(id,115,0,5)
		
		set_plr_money(id,0)
	}
}

public player_spawn(id) {
	if(get_pcvar_num(onoff) && is_user_connected(id)) {
		plr_prespawn[id]=false
		
		set_pdata_int(id,115,plr_money[id],5)
		
		set_plr_money(id,plr_money[id])
	}
}

public update_money(id) {
	if(!get_pcvar_num(onoff) || !is_user_connected(id) || plr_prespawn[id]) return PLUGIN_HANDLED
	
	new cur_money=read_data(1)
	
	if(cur_money!=plr_money[id]) {
		plr_money[id]=cur_money

		if(!task_exists(id)) set_task(0.1,"money_effect",id,_,_,"b")
		
		set_plr_money(id,plr_cur_money[id])
	}
	return PLUGIN_HANDLED
}

public hook_money(msg_id,msg_dest,id) {
	if(!get_pcvar_num(onoff)) return PLUGIN_CONTINUE
		
	new cash = get_msg_arg_int(1)
	
	if(plr_cur_money[id]!=cash) return PLUGIN_HANDLED
	
	return PLUGIN_CONTINUE
}

public money_effect(id) {
	static Add
	
	if(plr_cur_money[id]==plr_money[id]) {
		remove_task(id)
		plr_cur_money[id]=plr_money[id]
		
		return PLUGIN_HANDLED
	}
	else if(plr_cur_money[id] < plr_money[id]) {
		Add=(plr_money[id]-plr_cur_money[id])/get_pcvar_num(speed_per_sec)
		
		if(!Add) Add=1
		
		plr_cur_money[id]+=Add
	}
	else {
		Add=(plr_cur_money[id]-plr_money[id])/get_pcvar_num(speed_per_sec)
		
		if(!Add) Add=1
		
		plr_cur_money[id]-=Add
	}
	
	set_plr_money(id,plr_cur_money[id])
	
	return PLUGIN_CONTINUE
}

set_plr_money(id,Money,flash=0) {
	message_begin(MSG_ONE_UNRELIABLE,money,_,id)
	write_long(Money)
	write_byte(flash)
	message_end() 
}



