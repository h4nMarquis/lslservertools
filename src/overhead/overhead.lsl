//	overhead.lsl
//	Copyright (C)2012 H4n Marquis
//	contact email: h4n@h4n.hostei.com

//	overhead.lsl is part of lslservertools.

//	lslservertools is free software: you can redistribute it and/or modify
//	it under the terms of the GNU General Public License as published by
//	the Free Software Foundation, either version 3 of the License, or
//	(at your option) any later version.

//	lslservertools is is distributed in the hope that it will be useful,
//	but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//	GNU General Public License for more details.

//	You should have received a copy of the GNU General Public License
//	along with Foobar.  If not, see <http://www.gnu.org/licenses/>.

//	Very short description:
//	This is the "overhead" part who have to be written in any
//	lslservertools script (redundant code).
//	I wrote it apart just to show you what and how much is the overhead,
//	other than a useful way to keep it tracked in the SCM.

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

//More 3 integer variables:
//1 to store the address used by the script
//1 to store the address used by the "client" script
//1 to store the chan used by the "client" script or
//to store the chan where the script is awaiting.
