README

Howto upload all in a virtual world of your choiche:

1) Use Imprudence Viewer (I have exported all with that viewer so... ...use
it if you wish to import them smooth and round)

2) Open the viewer, log in a VW of your choiche, go to a sandbox or somewhere
else you are able to rez.

3) File->Import+Upload, then choose myParticleFountain001/myParticleFountain001
file

4) Wait until the object is fully rezzed (it could take sometime).

5) Select it in edit mode, if you are not already in it, to do it right click
over the rezzed object, then Edit... from the pie menu.

6) Here it comes the hard part:

6a) Click unlick button

6b) left shift + left click over the platform (myParticleFountain001 prim)

6c) left shift + left click over the platform (myParticleFountain001 prim),
this assures that myParticleFountain001 prim is the root prim. This is very
important. You know who is the "root prim" because it is the only yellow
outlined prim when all the object is selected in edit mode, other object
prims are outlined in blue.

7) Ok now it is time to drop the right scripts and other things in the right
prim inventory.

8) To be able to select (and edit one prim in a multi prim object) you have to
have checked the check button "Edit linked parts", if it is not already
checked it is time to do it.

9) left click over myParticleFountain001 (the platform) to select and edit it.

10) left click on tab "Content" and start to drag and drop inside it:

10a) notecard "COPYING"

10b) notecard "BlueFountain"

10c) script "myServerNcReaderV0001"

10d) script "myClientParticleFountainScriptV0001"

11) left click over one of the myParticleEmitter001 (one of the cone) to
select and edit it.

12) left click on tab "Content" and start to drag and drop inside it:

12a) notecard "COPYING"

12b) script "myServerParticleScriptV0001"

11) left click over the other myParticleEmitter001 (the other cone and last
prim) to select and edit it.

12) left click on tab "Content" and start to drag and drop inside it:

12a) notecard "COPYING"

12b) script "myServerParticleScriptV0001"

13) nearly done!

14) Uncheck the check button "Edit linked parts".

15) Left click somewhere other than the object to deselect it.

16) Right click over the object and left click over the "Take" from the pie
menu.

17) Hey you done it, right now you should have the object in your inventory.

18) Rez again the object and watch it working!

Touch it (touch the myParticleFountain001 the platform) to toggle on and off.

See you...
