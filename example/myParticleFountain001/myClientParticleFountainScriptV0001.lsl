/*
    myClientParticleFountainScriptV0001
    Copyright (C) 2012 H4n Marquis
    contact email: h4n@h4n.hostei.com
    
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

    Very short description:
    This is a very simple script to show my new script server tools.
*/
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

myNcSetup(string ncLine)
{
    string msgToSend = composeMessage(myAddr,partAddr,[ncLine],0);
    if(debug)
    {
        llOwnerSay("Message to send \"" + msgToSend + "\"");
    }
    llMessageLinked(LINK_ALL_OTHERS,partChan,msgToSend,"");
}

myResetScript()
{
    llMessageLinked(LINK_SET,0xFFFFFFFF,composeMessage(myAddr, 0xFFFFFFFF, ["RESET"],0),"");
    llResetScript();
}

integer debug = 0;
integer haltOnError = 1;
string lastError = "";

integer myAddr = 0x40000000;

integer ncReaderChan = 0x00000001;
integer ncReaderAddr = 0x00000001;
integer partChan = 0x00000001;
integer partAddr = 0x00000002;

string ncName = "BlueFountain";

default
{
    state_entry()
    {
        if(debug)
        {
            llOwnerSay("Script setup");
        }
        llSetText("", <0.0,0.0,0.0>, 1.0);
        string msg = composeMessage(myAddr, ncReaderAddr, ["load", ncName],0);
        if(debug)
        {
            llOwnerSay("Msg=\"" + msg + "\"");
        }
        llMessageLinked(LINK_THIS,ncReaderChan,msg,"");
    }
    
    link_message(integer sender_num, integer num, string str, key id)
    {
        list lTmp = getMessage(str);
        integer destAddr = getDestination(lTmp);
        integer sourceAddr = 0x00000000;
        string reply = "";
        if(checkDestination(destAddr,myAddr,num,ncReaderChan))
        {
            sourceAddr = getSource(lTmp);
            if(sourceAddr == ncReaderAddr)
            {
                lTmp = getPayload(lTmp);
                reply = llList2String(lTmp,0);
                if (reply != "end")
                {
                    if(debug)
                    {
                        llOwnerSay("Received Notecard Line = \"" + reply + "\"");
                    }
                    myNcSetup(reply);
                    llMessageLinked(LINK_THIS,ncReaderChan,composeMessage(myAddr, sourceAddr, ["next"],0),"");
                }
                else
                {
                    if(debug)
                    {
                        llOwnerSay("End of notecard reached");
                    }
                    state on;
                }
            }
            else if(haltOnError)
            {
                lastError = "State default, unexpected Messagge from \"" + (string)sourceAddr + "\"";
                if(debug)
                {
                    llOwnerSay(lastError);
                }
                state halted;
            }
        }
    }
    on_rez( integer start_param )
    {
        myResetScript();
    }
    changed( integer change )
    {
        if(change & CHANGED_INVENTORY)
        {
            myResetScript();
        }
    }
}

state halted
{
    state_entry()
    {
        string msgToShow = lastError + "\nDebug and reset script by hand!";
        llSetText(msgToShow, <1.0,0.0,0.0>, 1.0);
    }
}

state off
{
    state_entry()
    {
        string msgToSend = composeMessage(myAddr,partAddr,["OFF"],0);
        llMessageLinked(LINK_ALL_OTHERS,partChan,msgToSend,"");
    }
    touch_start(integer num_detected)
    {
        state on;
    }
    on_rez( integer start_param )
    {
        myResetScript();
    }
    changed( integer change )
    {
        if(change & CHANGED_INVENTORY)
        {
            myResetScript();
        }
    }
}

state on
{
    state_entry()
    {
        string msgToSend = composeMessage(myAddr,partAddr,["ON"],0);
        llMessageLinked(LINK_ALL_OTHERS,partChan,msgToSend,"");
    }
    touch_start(integer num_detected)
    {
        state off;
    }
    on_rez( integer start_param )
    {
        myResetScript();
    }
    changed( integer change )
    {
        if(change & CHANGED_INVENTORY)
        {
            myResetScript();
        }
    }
}