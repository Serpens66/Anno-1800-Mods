WIP quest tutorial, will be deleted when finished and uploaded to the anno 1800 modding-guide

# Properties/Values of Quests:
See templates.xml searching for "<Name>A7_Quest" to see the properties a normal quest has. See p-t.xml and search for <Name>Quest</Name> (there are multiple results, in current version it is in line 46508) and the other relevant properties.

#### `StarterMessage/SuccessMessage` 
and all those "Message" values: According to p-t.xml you can define a Notification here or set SuppressMessage=1.
SuppressMessage: "Do not play any notification and do not fall back to PamSy configuration". 
If no message is defined here and SupressMessage is not set to 1, the game automatically adds characternotifications based on the "PaMSy" of the Questgiver.
Eg. the pirate Anne Harlow is using: 
```xml
<ParticipantMessageObject>
  <ParticipantMessages>148</ParticipantMessages>
</ParticipantMessageObject>
```
while the asset GUID 148 is notifications defined that should be played in specific situations, eg. on "QuestSuccessful" and so on.  
So most of the time for generic quests it is enough to leave this "Message" values from the Quest empty or even better do completely skip them (not mention them at all in your code) since they are inherited from the templates anyways.

