#include <amxmodx>
#include <engine>

#define PLUGIN "Jailbreak: Cachear"
#define VERSION "1.0"
#define AUTHOR "Peyote"

#define TASK_ID 352

new target[33], body
new bool:w_trakcie[33]

new tiempo, distancia

public plugin_init() 
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    
    register_clcmd("+cachear", "cachear")
    register_clcmd("-cachear", "_cachear")
    register_event("Damage", "Damage", "b", "2!=0")
    register_event("CurWeapon","CurWeapon","be", "1=1")
    register_event("ResetHUD", "Spawn", "be")
    register_dictionary("cachear.txt")
    tiempo = register_cvar("amx_tiempo", "4")
    distancia = register_cvar("amx_distancia", "40")
    register_clcmd("say /cachear", "Instrucciones")
}

public plugin_precache()
{
    precache_sound("weapons/c4_disarm.wav")
    precache_sound("weapons/c4_disarmed.wav")
}

public cachear(id)
{
    if(get_user_team(id) != 2)
    {
    ChatColor(id, "!g[JB] !yNecesitas ser nazi para cachear a alguien.")
    return PLUGIN_HANDLED
    }
    if(!is_user_alive(id))
    {
    ChatColor(id, "!g[JB] !yNecesitas estar vivo para cachear a alguien.")
    return PLUGIN_HANDLED
    }
    
    get_user_aiming(id, target[id], body, get_pcvar_num(distancia))
    
    if(!is_user_alive(target[id]))
    {
    ChatColor(id, "!g[JB] !yNo tienes ningun judio cerca para cachear.")
    return PLUGIN_HANDLED
    }
    if(get_user_team(target[id]) != 1)
    {
    ChatColor(id, "!g[JB] !yNo puedes cachear a nazis.")
    return PLUGIN_HANDLED
    }
    
    new p_tiempo = get_pcvar_num(tiempo)
    
    entity_set_float(id, EV_FL_maxspeed, -1.0)
    set_bartime(id, p_tiempo)
    w_trakcie[id] = true
    emit_sound(id, CHAN_WEAPON, "weapons/c4_disarm.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
    
    entity_set_float(target[id], EV_FL_maxspeed, -1.0)
    set_bartime(target[id], p_tiempo)
    w_trakcie[target[id]] = true
    
    set_task(get_pcvar_float(tiempo), "Pokaz_bronie", TASK_ID+id)
    
    return PLUGIN_HANDLED
}

public _cachear(id)
{
    if(get_user_team(id) != 2 || !w_trakcie[id])
        return PLUGIN_HANDLED
    
    entity_set_float(id, EV_FL_maxspeed, 250.0)
    set_bartime(id, 0)
    w_trakcie[id] = false
    remove_task(TASK_ID+id)
    
    if(!is_user_alive(target[id]))
        return PLUGIN_HANDLED
    
    entity_set_float(target[id], EV_FL_maxspeed, 250.0)
    set_bartime(target[id], 0)
    w_trakcie[target[id]] = false
    
    return PLUGIN_HANDLED
}


public Pokaz_bronie(id)
{
    
    id -= TASK_ID
    new weapons[32], numweapons
    new weaponname[33]
    new kastet[14]
    get_user_weapons(target[id], weapons, numweapons)
    format(kastet, 13, "cuchillo")
    ChatColor(id, "!g[Encontraste:]")
     
    for(new i=0; i<numweapons; i++)
    {
        
        get_weaponname(weapons[i], weaponname, 32)
        replace_all(weaponname, 32, "weapon_", "")
        replace_all(weaponname, 32, "knife", kastet)
        ChatColor(id, weaponname)
    }
    _cachear(id)
    emit_sound(id, CHAN_WEAPON, "weapons/c4_disarmed.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
}

public Damage(id)
{
    if(w_trakcie[id])
        _cachear(id)
}

public CurWeapon(id)
{
    if(w_trakcie[id])
        entity_set_float(id, EV_FL_maxspeed, -1.0)
}

public Spawn(id)
{
    w_trakcie[id] = false
}

public Instrucciones(id)
{
    ChatColor(id, "!g[JB] !yPara cachear a alguien tienes que bindear !g+cachear desde la consola.")
    ChatColor(id, "!g[JB] !yUna vez bindeada solo tendras que ponerte delante de un judio para cachearlo.")
    ChatColor(id, "!g[JB] !yEjemplo: !gbind v +cachear")
}


public set_bartime(id, czas)
{
    message_begin(MSG_ONE, get_user_msgid("BarTime"), _, id)
    write_short(czas)
    message_end()
}


/** Stocks and Functions **/
// Color Chat!
stock ChatColor(const id, const input[], any:...)
{
    new count = 1, players[32]
    static msg[191]
    vformat(msg, 190, input, 3)
    
    replace_all(msg, 190, "!g", "^4") // Green Color
    replace_all(msg, 190, "!y", "^1") // Default Color
    replace_all(msg, 190, "!team", "^3") // Team Color
    replace_all(msg, 190, "!team2", "^0") // Team2 Color
    
    if (id) players[0] = id; else get_players(players, count, "ch")
    {
        for (new i = 0; i < count; i++)
        {
            if (is_user_connected(players[i]))
            {
                message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i])
                write_byte(players[i]);
                write_string(msg);
                message_end();
            }
        }
    }
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang3082\\ f0\\ fs16 \n\\ par }
*/
