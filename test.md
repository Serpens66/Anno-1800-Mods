WIP quest tutorial, will be deleted when finished and uploaded to the anno 1800 modding-guide

# Properties/Values of Quests:
See templates.xml searching for "<Name>A7_Quest" to see the properties a normal quest has. See p-t.xml and search for <Name>Quest</Name> (there are multiple results, in current version it is in line 46508) and the other relevant properties.  
Properties/values I don't mention here should be self explanatory or already explained enough by the description in p-t.xml

#### `StarterMessage/SuccessMessage` 
and all those "Message" values:  
According to p-t.xml you can define a Notification here or set `SuppressMessage`: "Do not play any notification and do not fall back to PamSy configuration".  
If no message is defined here and `SuppressMessage` is not set to 1, the game automatically adds CharacterNotifications based on the "PaMSy" of the Questgiver.
Eg. the pirate Anne Harlow (`GUID 73`) is using: 
```xml
<ParticipantMessageObject>
  <ParticipantMessages>148</ParticipantMessages>
</ParticipantMessageObject>
```
while in the asset `GUID 148` are notifications defined that should be played in specific situations, eg. on "QuestSuccessful" and so on.  
So most of the time for generic quests it is enough to leave this "Message" values from the Quest empty or even better do completely skip them (not mention them at all in your code) since they are inherited from the templates anyways.

#### `OnQuestStart/OnQuestDeclined` 
and all those "On..." values followed by `ActionList`:  
Here you can add any Actions you want to be executed when the Quest reaches a specific status. Most names are self explanatory. Make sure to read the description in p-t.xml if you are not sure.  
Eg. `OnQuestStart` already happens as soon as the player is able to accept the Quest (eg. the "quest star" to accept a quest becomes visible), while `OnQuestActive` starts as soon as the player accepted the Quest.

#### `QuestGiver`
"This is the guys picture will be shown in the quest". As mentioned above this is also where the default messages will be taken from. A quest can not start, if the QuestGiver does not exist in the game (eg. Jorgensen can not start a quest if she is not part of the game). Most neutral QuestGivers like the farmers (`<GUID>86</GUID>`) are using the `Profile_Virtual_NeverOwnsObjects` template which has `<CreateModeMeta>AutoCreate_Always</CreateModeMeta>` defined to make sure they always exist in every game.

#### `StoryText/DescriptionText`:
"This is the fluff text of a quest." eg. an embellished story.  
"This is the description of a quest." telling the player what to do exactly in short. Not needed if the WinConditions are self explanatory already.

#### `MaxCallOut/MaxSolveCount/MaxAbortCount`:
Defaults to -1. "Maximum number that this quest can be triggered." / "Maximum number that this quest can be solved." / "Maximum number that this quest can be aborted."  
A value <= 0 means infinite calls are possible. Eg. use these to make sure eg. a QuestPool can only start your Quest once at all/until solved once. 

#### `CountForQuestLimit`:
Defaults to 1. "True if this quest counts for the global and the pool quest limits.". Set this to 0 if you don't want a quest to prevent other quests of the same pool to be started. I don't know if there really is a global limit and how much it is.

#### `PreActivationTimer/QuestTimeLimit`:
PreActivationTimer: "This timer cancelles a quest if the quest has not become active until the timer runs out." Eg. used for Quests that need to be accepted by the user first, eg. the ones popping up in the world with a star-icon spinning over them. If the user does not activate/accept the quest within PreActivationTimer, it is cancelled. Default will be 0 which disables this timer.  
QuestTimeLimit: Defaults to 1800000 ms. "If a time limit is set, the quest will fail if it is not completed within this time". Timer starts after the Quest was activated/accepted.

#### `QuestCategory`:
Defaults to MainQuest. "The category of the quest defines the internal behaviour of the quest.". Since we can neither change nor look at the "interal behaviour", we can only test a bit what this does exactly. See datasets.xml QuestCategory for all allowed values. But it might be best to always use "RandomQuest" here unless you want to add a new Quest to the vanilla Story Questline.

#### `QuestActivation`:
"Defines at which point this quest changes its status to "Activated". Only activated quests are visible in the Quest Tracker." For allowed values see datasets.xml QuestActivationTime.  
`ManualActivation` means the Quest will appear as acceptable Quest on the map eg. with the star-icon and the user can select and start it this way.  
`QuestStart` means the Quest will directly be active in the players Questlog without a choice to accept/decline, but of course the player might be able to abort it.  
`ConfirmationDialog` not tested by me, I assume it directly starts a notification if you want accept the quest or not.  

#### `IsAbortable`:
Defaults to 1. "If true, this quest can be aborted in the assignment center or the quest tracker". Allow to abort accepted/active quests or not.

#### `NeededProgressLevel`:
"This quest can only be triggered if the player progress level matches these checked levels." Defaults to `EarlyGame;EarlyMidGame;MidGame;LateMidGame;LateGame;EndGame` so all progresslevels are allowed by default.

