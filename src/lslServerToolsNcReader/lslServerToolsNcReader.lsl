//
//	lslServerToolsNcReader.lsl
//	Copyright (C)2012 H4n Marquis
//	contact email: h4n@h4n.hostei.com
    
//	This program is free software: you can redistribute it and/or modify
//	it under the terms of the GNU General Public License as published by
//	the Free Software Foundation, either version 3 of the License, or
//	(at your option) any later version.

//	This program is distributed in the hope that it will be useful,
//	but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//	GNU General Public License for more details.

//	You should have received a copy of the GNU General Public License
//	along with this program.  If not, see <http://www.gnu.org/licenses/>.

//	Very short description:
//	This is a very simple script server tool of my new suite of script
//	server tools. This one reads a notecard who has to be in the same
//	inventory folder (I mean same prim inventory) where this script is.

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
    
    if(((src != dst) || loopback) && (llGetListLength(payload) > 0))
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

integer checkNC(string ncName)
{
    integer iRet = -1;
    
    if(llGetInventoryType(ncName) == INVENTORY_NOTECARD)
    {
        iRet = 1;
    }
    else
    {
        iRet = 0;
    }
    return iRet;
}

integer scriptInterpeter (list cmdLine, integer iState)
{
    integer iRet = 0;
    string cmd = llList2String(cmdLine, 0);
    
    if(iState == 0)
    {
        if(cmd == "load")
        {
            if(llGetListLength(cmdLine) > 1)
            {
                noteCardName = llList2String(cmdLine, 1);
                state loading;
            }
        }
    }
    else if (iState == 1)
    {
        if(cmd == "next")
        {
            qId = llGetNotecardLine(noteCardName,iLine);
        }
    }
    else
    {
        if(cmd == "reset")
        {
            llResetScript();
        }
    }
    return iRet;
}

integer debug = 0;
integer myAddr = 0x00000001;
integer sourceAddr = 0x00000000;
integer clientChan = 0x00000000;
string noteCardName = "Default";
integer iLine = 0;
key qId;

default
{
    state_entry()
    {
        if(debug)
        {
            llOwnerSay("ncReader Default");
        }
    }
    link_message(integer sender_num, integer num, string str, key id)
    {
        if(debug)
        {
            llOwnerSay(str);
        }
        list lTmp = getMessage(str);
        integer destAddr = getDestination(lTmp);
        clientChan = num;
        if(checkDestination(destAddr,myAddr,num,clientChan))
        {
            sourceAddr = getSource(lTmp);
            lTmp = getPayload(lTmp);
            scriptInterpeter(lTmp,0);
        }
    }
}

state loading
{
    state_entry()
    {
        if(debug)
        {
            llOwnerSay("NcName \"" + noteCardName + "\"");
        }
        if(checkNC(noteCardName))
        {
            iLine = 0;
            qId = llGetNotecardLine(noteCardName,iLine);
        }
        else
        {
            llResetScript();
        }
    }
    dataserver(key queryid, string data)
    {
        if(queryid == qId)
        {
            if(data != EOF)
            {
                llMessageLinked(LINK_THIS,clientChan,composeMessage(myAddr, sourceAddr, [data],0),"");
                ++iLine;
            }
            else
            {
                llMessageLinked(LINK_THIS,clientChan,composeMessage(myAddr, sourceAddr, ["end"],0),"");
                state default;
            }
        }
    }
    link_message(integer sender_num, integer num, string str, key id)
    {
        list lTmp = getMessage(str);
        integer destAddr = getDestination(lTmp);
        if(checkDestination(destAddr,myAddr,num,clientChan))
        {
            sourceAddr = getSource(lTmp);
            lTmp = getPayload(lTmp);
            scriptInterpeter(lTmp,1);
        }
    }
}
