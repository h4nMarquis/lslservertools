//    lslServerToolsParticle.lsl
//    Copyright (C)2012 H4n Marquis
//    contact email: h4n@h4n.hostei.com
    
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.

//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.

//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <http://www.gnu.org/licenses/>.

//    Very short description:
//    This is a very simple script server tool of my new suite of script
//    server tools. This one makes the prim where it is inside his
//    inventory to emit particles. Very useful to use along with
//    myServerNcReaderV0001, see my example (myParticleFountain001).

list getMessage(string s)
{
    list lRet = [];
    
    lRet = llCSV2List(s);
    if(llGetListLength(lRet) <= 2)
    {
        lRet = [];
    }
    return lRet;
}

integer getSource(list msg)
{
    integer iRet = -1;
    
    if(llGetListLength(msg) > 2)
    {
        iRet = (integer)llList2String(msg,0);
    }
    else
    {
        iRet = 0x00000000;
    }
    return iRet;
}

integer getDestination(list msg)
{
    integer iRet = -1;
    
    if(llGetListLength(msg) > 2)
    {
        iRet = (integer)llList2String(msg,1);
    }
    else
    {
        iRet = 0x00000000;
    }
    return iRet;
}

list getPayload(list msg)
{
    list lRet = [];
    
    if(llGetListLength(msg) > 2)
    {
        lRet = llList2List(msg,2,-1);
    }
    else
    {
        lRet = [];
    }
    return lRet;
}

integer checkDestination(integer dest, integer me, integer chan, integer myChan)
{
    integer iRet = 0;
        
    if(((dest & me) > 0) && ((chan & myChan) > 0))
    {
        iRet = 1;
    }
    else
    {
        iRet = 0;
    }
    return iRet;
}

string composeMessage(integer src, integer dst, list payload, integer loopback)
{
    string sRet = "";
    
    if(((!(src & dst)) || loopback) && (llGetListLength(payload) > 0))
    {
        sRet = (string)src;
        sRet += "," + (string)dst;
        sRet += "," + llList2CSV(payload);
    }
    else
    {
        sRet = "";
    }
    return sRet;
}

scriptInterpreter(string msg, integer st)
{
    list cmdP = [];
    string cmd = "";
    string sParam = "";
    integer i = 0;
    integer iCmdP = 0;
    integer value = 0;
    if(llStringLength(msg) > 0)
    {
        if(debug)
        {
            llOwnerSay(msg);
        }
        cmdP = llParseStringKeepNulls(msg,["|","=",":"],[]);
        iCmdP = llGetListLength(cmdP);
        if(iCmdP > 0)
        {
            cmd = llList2String(cmdP,0);
            if(debug)
            {
                llOwnerSay(cmd);
            }
            if(llToUpper(cmd) == "RESET")
            {
                llResetScript();
            }
            else if(llToUpper(cmd) == "DEBUG")
            {
                debug = 1;
            }
            else if((llToUpper(cmd) == "ON") && (st == 0))
            {
                state on;
            }
            else if((llToUpper(cmd) == "OFF") && (st == 1))
            {
                state default;
            }
            else if((llToUpper(cmd) == "PSYS_PART_FLAGS") && (iCmdP > 1))
            {
                for(i = 1;i < iCmdP;++i)
                {
                    sParam = llToUpper(llList2String(cmdP,i));
                    value = 0;
                    if(debug)
                    {
                        llOwnerSay("SParam = \"" + sParam + "\"");
                    }
                    if(sParam == "PSYS_PART_BOUNCE_MASK")
                    {
                        value = PSYS_PART_BOUNCE_MASK;
                    }
                    else if(sParam == "PSYS_PART_EMISSIVE_MASK")
                    {
                        value = PSYS_PART_EMISSIVE_MASK;
                    }
                    else if(sParam == "PSYS_PART_FOLLOW_SRC_MASK")
                    {
                        value = PSYS_PART_FOLLOW_SRC_MASK;
                    }
                    else if(sParam == "PSYS_PART_FOLLOW_VELOCITY_MASK")
                    {
                        value = PSYS_PART_FOLLOW_VELOCITY_MASK;
                    }
                    else if(sParam == "PSYS_PART_INTERP_COLOR_MASK")
                    {
                        value = PSYS_PART_INTERP_COLOR_MASK;
                    }
                    else if(sParam == "PSYS_PART_INTERP_SCALE_MASK")
                    {
                        value = PSYS_PART_INTERP_SCALE_MASK;
                    }
                    else if(sParam == "PSYS_PART_TARGET_LINEAR_MASK")
                    {
                        value = PSYS_PART_TARGET_LINEAR_MASK;
                    }
                    else if(sParam == "PSYS_PART_TARGET_POS_MASK")
                    {
                        value = PSYS_PART_TARGET_POS_MASK;
                    }
                    else if(sParam == "PSYS_PART_WIND_MASK")
                    {
                        value = PSYS_PART_WIND_MASK;
                    }
                    if(debug)
                    {
                        llOwnerSay("scriptPSYSPATFLAGS before or = \"" + (string)scriptPSYSPARTFLAGS + "\"");
                        llOwnerSay("value before or = \"" + (string)value + "\"");
                    }
                    scriptPSYSPARTFLAGS = scriptPSYSPARTFLAGS | value;
                    if(debug)
                    {
                        llOwnerSay("scriptPSYSPATFLAGS after or = \"" + (string)scriptPSYSPARTFLAGS + "\"");
                    }
                }
                if(st == 1)
                {
                    llParticleSystem([PSYS_PART_FLAGS,scriptPSYSPARTFLAGS,
                    PSYS_SRC_PATTERN,scriptPSYSSRCPATTERN] + scriptPartValuesParams);
                }
            }
            else if((llToUpper(cmd) == "PSYS_SRC_PATTERN") && (iCmdP == 2))
            {
                sParam = llToUpper(llList2String(cmdP,1));
                value = 0;
                if(sParam == "PSYS_SRC_PATTERN_ANGLE")
                {
                    value = PSYS_SRC_PATTERN_ANGLE;
                }
                else if(sParam == "PSYS_SRC_PATTERN_ANGLE_CONE")
                {
                    value = PSYS_SRC_PATTERN_ANGLE_CONE;
                }
                else if(sParam == "PSYS_SRC_PATTERN_ANGLE_CONE_EMPTY")
                {
                    value = PSYS_SRC_PATTERN_ANGLE_CONE_EMPTY;
                }
                else if(sParam == "PSYS_SRC_PATTERN_DROP")
                {
                    value = PSYS_SRC_PATTERN_DROP;
                }
                else if(sParam == "PSYS_SRC_PATTERN_EXPLODE")
                {
                    value = PSYS_SRC_PATTERN_EXPLODE;
                }
                scriptPSYSSRCPATTERN = value;
                if(st == 1)
                {
                    llParticleSystem([PSYS_PART_FLAGS,scriptPSYSPARTFLAGS,
                        PSYS_SRC_PATTERN,scriptPSYSSRCPATTERN] + scriptPartValuesParams);
                }
            }
            else if((llToUpper(cmd) == "PSYS_PART_START_ALPHA") && (iCmdP == 2))
            {
                sParam = llList2String(cmdP,1);
                scriptPartValuesParams = scriptPartValuesParams
                    + [PSYS_PART_START_ALPHA,(float)sParam];
                if(st == 1)
                {
                    llParticleSystem([PSYS_PART_FLAGS,scriptPSYSPARTFLAGS,
                        PSYS_SRC_PATTERN,scriptPSYSSRCPATTERN] + scriptPartValuesParams);
                }
            }
            else if((llToUpper(cmd) == "PSYS_PART_END_ALPHA") && (iCmdP == 2))
            {
                sParam = llList2String(cmdP,1);
                scriptPartValuesParams = scriptPartValuesParams
                    + [PSYS_PART_END_ALPHA,(float)sParam];
                if(st == 1)
                {
                    llParticleSystem([PSYS_PART_FLAGS,scriptPSYSPARTFLAGS,
                        PSYS_SRC_PATTERN,scriptPSYSSRCPATTERN] + scriptPartValuesParams);
                }
            }
            else if((llToUpper(cmd) == "PSYS_PART_START_COLOR") && (iCmdP == 2))
            {
                sParam = llList2String(cmdP,1);
                scriptPartValuesParams = scriptPartValuesParams
                    + [PSYS_PART_START_COLOR,(vector)sParam];
                if(st == 1)
                {
                    llParticleSystem([PSYS_PART_FLAGS,scriptPSYSPARTFLAGS,
                        PSYS_SRC_PATTERN,scriptPSYSSRCPATTERN] + scriptPartValuesParams);
                }
            }
            else if((llToUpper(cmd) == "PSYS_PART_END_COLOR") && (iCmdP == 2))
            {
                sParam = llList2String(cmdP,1);
                scriptPartValuesParams = scriptPartValuesParams
                    + [PSYS_PART_END_COLOR,(vector)sParam];
                if(st == 1)
                {
                    llParticleSystem([PSYS_PART_FLAGS,scriptPSYSPARTFLAGS,
                        PSYS_SRC_PATTERN,scriptPSYSSRCPATTERN] + scriptPartValuesParams);
                }
            }
            else if((llToUpper(cmd) == "PSYS_PART_START_SCALE") && (iCmdP == 2))
            {
                sParam = llList2String(cmdP,1);
                scriptPartValuesParams = scriptPartValuesParams
                    + [PSYS_PART_START_SCALE,(vector)sParam];
                if(st == 1)
                {
                    llParticleSystem([PSYS_PART_FLAGS,scriptPSYSPARTFLAGS,
                        PSYS_SRC_PATTERN,scriptPSYSSRCPATTERN] + scriptPartValuesParams);
                }
            }
            else if((llToUpper(cmd) == "PSYS_PART_END_SCALE") && (iCmdP == 2))
            {
                sParam = llList2String(cmdP,1);
                scriptPartValuesParams = scriptPartValuesParams
                    + [PSYS_PART_END_SCALE,(vector)sParam];
                if(st == 1)
                {
                    llParticleSystem([PSYS_PART_FLAGS,scriptPSYSPARTFLAGS,
                        PSYS_SRC_PATTERN,scriptPSYSSRCPATTERN] + scriptPartValuesParams);
                }
            }
            else if((llToUpper(cmd) == "PSYS_PART_MAX_AGE") && (iCmdP == 2))
            {
                sParam = llList2String(cmdP,1);
                scriptPartValuesParams = scriptPartValuesParams
                    + [PSYS_PART_MAX_AGE,(float)sParam];
                if(st == 1)
                {
                    llParticleSystem([PSYS_PART_FLAGS,scriptPSYSPARTFLAGS,
                        PSYS_SRC_PATTERN,scriptPSYSSRCPATTERN] + scriptPartValuesParams);
                }
            }
            else if((llToUpper(cmd) == "PSYS_SRC_MAX_AGE") && (iCmdP == 2))
            {
                sParam = llList2String(cmdP,1);
                scriptPartValuesParams = scriptPartValuesParams
                    + [PSYS_SRC_MAX_AGE,(float)sParam];
                if(st == 1)
                {
                    llParticleSystem([PSYS_PART_FLAGS,scriptPSYSPARTFLAGS,
                        PSYS_SRC_PATTERN,scriptPSYSSRCPATTERN] + scriptPartValuesParams);
                }
            }
            else if((llToUpper(cmd) == "PSYS_SRC_ACCEL") && (iCmdP == 2))
            {
                sParam = llList2String(cmdP,1);
                scriptPartValuesParams = scriptPartValuesParams
                    + [PSYS_SRC_ACCEL,(vector)sParam];
                if(st == 1)
                {
                    llParticleSystem([PSYS_PART_FLAGS,scriptPSYSPARTFLAGS,
                        PSYS_SRC_PATTERN,scriptPSYSSRCPATTERN] + scriptPartValuesParams);
                }
            }
            else if((llToUpper(cmd) == "PSYS_SRC_ANGLE_BEGIN") && (iCmdP == 2))
            {
                sParam = llList2String(cmdP,1);
                scriptPartValuesParams = scriptPartValuesParams
                    + [PSYS_SRC_ANGLE_BEGIN,(float)sParam];
                if(st == 1)
                {
                    llParticleSystem([PSYS_PART_FLAGS,scriptPSYSPARTFLAGS,
                    PSYS_SRC_PATTERN,scriptPSYSSRCPATTERN] + scriptPartValuesParams);
                }
            }
            else if((llToUpper(cmd) == "PSYS_SRC_ANGLE_END") && (iCmdP == 2))
            {
                sParam = llList2String(cmdP,1);
                scriptPartValuesParams = scriptPartValuesParams
                    + [PSYS_SRC_ANGLE_END,(float)sParam];
                if(st == 1)
                {
                    llParticleSystem([PSYS_PART_FLAGS,scriptPSYSPARTFLAGS,
                        PSYS_SRC_PATTERN,scriptPSYSSRCPATTERN] + scriptPartValuesParams);
                }
            }
            else if((llToUpper(cmd) == "PSYS_SRC_BURST_PART_COUNT") && (iCmdP == 2))
            {
                sParam = llList2String(cmdP,1);
                scriptPartValuesParams = scriptPartValuesParams
                    + [PSYS_SRC_BURST_PART_COUNT,(integer)sParam];
                if(st == 1)
                {
                    llParticleSystem([PSYS_PART_FLAGS,scriptPSYSPARTFLAGS,
                        PSYS_SRC_PATTERN,scriptPSYSSRCPATTERN] + scriptPartValuesParams);
                }
            }
            else if((llToUpper(cmd) == "PSYS_SRC_BURST_RADIUS") && (iCmdP == 2))
            {
                sParam = llList2String(cmdP,1);
                scriptPartValuesParams = scriptPartValuesParams
                    + [PSYS_SRC_BURST_RADIUS,(float)sParam];
                if(st == 1)
                {
                    llParticleSystem([PSYS_PART_FLAGS,scriptPSYSPARTFLAGS,
                        PSYS_SRC_PATTERN,scriptPSYSSRCPATTERN] + scriptPartValuesParams);
                }
            }
            else if((llToUpper(cmd) == "PSYS_SRC_BURST_RATE") && (iCmdP == 2))
            {
                sParam = llList2String(cmdP,1);
                scriptPartValuesParams = scriptPartValuesParams
                    + [PSYS_SRC_BURST_RATE,(float)sParam];
                if(st == 1)
                {
                    llParticleSystem([PSYS_PART_FLAGS,scriptPSYSPARTFLAGS,
                        PSYS_SRC_PATTERN,scriptPSYSSRCPATTERN] + scriptPartValuesParams);
                }
            }
            else if((llToUpper(cmd) == "PSYS_SRC_BURST_SPEED_MIN") && (iCmdP == 2))
            {
                sParam = llList2String(cmdP,1);
                scriptPartValuesParams = scriptPartValuesParams
                    + [PSYS_SRC_BURST_SPEED_MIN,(float)sParam];
                if(st == 1)
                {
                    llParticleSystem([PSYS_PART_FLAGS,scriptPSYSPARTFLAGS,
                        PSYS_SRC_PATTERN,scriptPSYSSRCPATTERN] + scriptPartValuesParams);
                }
            }
            else if((llToUpper(cmd) == "PSYS_SRC_BURST_SPEED_MAX") && (iCmdP == 2))
            {
                sParam = llList2String(cmdP,1);
                scriptPartValuesParams = scriptPartValuesParams
                    + [PSYS_SRC_BURST_SPEED_MAX,(float)sParam];
                if(st == 1)
                {
                    llParticleSystem([PSYS_PART_FLAGS,scriptPSYSPARTFLAGS,
                        PSYS_SRC_PATTERN,scriptPSYSSRCPATTERN] + scriptPartValuesParams);
                }
            }
            else if((llToUpper(cmd) == "PSYS_SRC_OMEGA") && (iCmdP == 2))
            {
                sParam = llList2String(cmdP,1);
                scriptPartValuesParams = scriptPartValuesParams
                    + [PSYS_SRC_OMEGA,(vector)sParam];
                if(st == 1)
                {
                    llParticleSystem([PSYS_PART_FLAGS,scriptPSYSPARTFLAGS,
                        PSYS_SRC_PATTERN,scriptPSYSSRCPATTERN] + scriptPartValuesParams);
                }
            }
            else if((llToUpper(cmd) == "PSYS_SRC_TARGET_KEY") && (iCmdP == 2))
            {
                sParam = llList2String(cmdP,1);
                scriptPartValuesParams = scriptPartValuesParams
                    + [PSYS_SRC_TARGET_KEY,(key)sParam];
                if(st == 1)
                {
                    llParticleSystem([PSYS_PART_FLAGS,scriptPSYSPARTFLAGS,
                        PSYS_SRC_PATTERN,scriptPSYSSRCPATTERN] + scriptPartValuesParams);
                }
            }
            else if((llToUpper(cmd) == "PSYS_SRC_TEXTURE") && (iCmdP == 2))
            {
                sParam = llList2String(cmdP,1);
                scriptPartValuesParams = scriptPartValuesParams
                    + [PSYS_SRC_TEXTURE,sParam];
                if(st == 1)
                {
                    llParticleSystem([PSYS_PART_FLAGS,scriptPSYSPARTFLAGS,
                        PSYS_SRC_PATTERN,scriptPSYSSRCPATTERN] + scriptPartValuesParams);
                }
            } 
        }
    }
}

integer debug = 0;
integer haltOnError = 1;
string lastError = "";

integer myAddr = 0x00000002;
integer anyChan = 0xFFFFFFFF;

integer scriptPSYSPARTFLAGS = 0;
integer scriptPSYSSRCPATTERN = 0;
list scriptPartValuesParams = [];

default
{
    state_entry()
    {
        if(debug)
        {
            llOwnerSay("Particle A reset");
        }
        llParticleSystem([]);
    }
    
    link_message(integer sender_num, integer num, string str, key id)
    {
        list lTmp = getMessage(str);
        integer destAddr = getDestination(lTmp);
        integer sourceAddr = 0x00000000;
        string reply = "";
        if(debug)
        {
            llOwnerSay("Particle A Message received = \"" + str + "\"");
        }
        if(checkDestination(destAddr,myAddr,num,anyChan))
        {
            lTmp = getPayload(lTmp);
            reply = llList2String(lTmp,0);
            if(debug)
            {
                llOwnerSay("Received Command = \"" + reply + "\"");
            }
            scriptInterpreter(reply, 0);
        }
    }
}

state on
{
    state_entry()
    {
        if(debug)
        {
            llOwnerSay("Particle A going ON");
            llOwnerSay(llList2CSV([PSYS_PART_FLAGS,scriptPSYSPARTFLAGS,
            PSYS_SRC_PATTERN,scriptPSYSSRCPATTERN] + scriptPartValuesParams));
        }
        llParticleSystem([PSYS_PART_FLAGS,scriptPSYSPARTFLAGS,
            PSYS_SRC_PATTERN,scriptPSYSSRCPATTERN] + scriptPartValuesParams);
    }
    
    link_message(integer sender_num, integer num, string str, key id)
    {
        list lTmp = getMessage(str);
        integer destAddr = getDestination(lTmp);
        integer sourceAddr = 0x00000000;
        string reply = "";
        if(debug)
        {
            llOwnerSay("Particle A Message received = \"" + str + "\"");
        }
        if(checkDestination(destAddr,myAddr,num,anyChan))
        {
            lTmp = getPayload(lTmp);
            reply = llList2String(lTmp,0);
            if(debug)
            {
                llOwnerSay("Received Command = \"" + reply + "\""); 
            }
            scriptInterpreter(reply, 1);
        }
    }
}