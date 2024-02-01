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

#### `StoryText/DescriptionText/AlternativeRewardTitle`:
StoryText: "This is the fluff text of a quest." eg. an embellished story.  
DescriptionText: "This is the description of a quest." telling the player what to do exactly in short. Not needed if the WinConditions are self explanatory already.  
AlternativeRewardTitle: "An alternative headline for the rewards". Defaults to GUID 2653 ("Reward"). So use it if you think this word does not fit for your Quest.

#### `MaxCallOut/MaxSolveCount/MaxAbortCount`:
"Maximum number that this quest can be triggered." / "Maximum number that this quest can be solved." / "Maximum number that this quest can be aborted."  
Defaults to -1. A value <= 0 means infinite calls are possible. Eg. use these to make sure eg. a QuestPool can only start your Quest once at all/until solved once. 

#### `CountForQuestLimit`:
"True if this quest counts for the global and the pool quest limits.". Defaults to 1. Set this to 0 if you don't want a quest to prevent other quests of the same pool to be started. I don't know if there really is a global limit and how much it is.

#### `PreActivationTimer/QuestTimeLimit`:
PreActivationTimer: "This timer cancelles a quest if the quest has not become active until the timer runs out." Eg. used for Quests that need to be accepted by the user first, eg. the ones popping up in the world with a star-icon spinning over them. If the user does not activate/accept the quest within PreActivationTimer, it is cancelled. Default will be 0 which disables this timer.  
QuestTimeLimit: Defaults to 1800000 ms. "If a time limit is set, the quest will fail if it is not completed within this time". Timer starts after the Quest was activated/accepted.

#### `QuestCategory`:
"The category of the quest defines the internal behaviour of the quest.". Defaults to MainQuest. Since we can neither change nor look at the "interal behaviour", we can only test a bit what this does exactly. See datasets.xml QuestCategory for all allowed values. But it might be best to always use "RandomQuest" here unless you want to add a new Quest to the vanilla Story Questline.

#### `QuestActivation`:
"Defines at which point this quest changes its status to "Activated". Defaults to QuestStart. Only activated quests are visible in the Quest Tracker." For allowed values see datasets.xml QuestActivationTime.  
`ManualActivation` means the Quest will appear as acceptable Quest on the map eg. with the star-icon and the user can select and start it this way.  
`QuestStart` means the Quest will directly be active in the players Questlog without a choice to accept/decline, but of course the player might be able to abort it.  
`ConfirmationDialog` not tested by me, I assume it directly starts a notification if you want accept the quest or not.  

#### `IsAbortable`:
Defaults to 1. "If true, this quest can be aborted in the assignment center or the quest tracker". Allow to abort accepted/active quests or not.

#### `NeededProgressLevel`:
"This quest can only be triggered if the player progress level matches these checked levels." Defaults to `EarlyGame;EarlyMidGame;MidGame;LateMidGame;LateGame;EndGame` so all progresslevels are allowed by default.

#### `LatencyTimer/DelayTimer`:
LatencyTimer: "Latency before a quest can start after all other preconditions are fulfilled. The latency starts again if a single precondition check fails during the countdown. This needs to be checked over the whole duration and is EXPENSIVE for game performance".  
DelayTimer: "Delay the quest after the preconditions were fulfilled once. The preconditions will be checked once again after the delay finished. This is a CHEAPER alternative to the latency timer in terms of performance".  
Use one of these, at best DelayTimer, if you want the PreConditions of the Quest to be fullfilled for a specific amount of time before the Quest is allowed to appear.

#### `QuestTrackerVisibility/QuestBookVisibility`:
QuestTrackerVisibility: "Defines when this quest will be visible in the quest tracker." Defaults to Session (so only visible in the session the Quest is active in). See datasets.xml QuestTrackerVisibility.   
QuestBookVisibility : "Defines when this quest will be visible in the quest book." Defaults to SameAsQuestTracker. See datasets.xml QuestBookVisibility.  

#### `ConfirmOnReached/CustomizeConfirmOnReachedCondition/ConfirmOnReachedCondition`:
ConfirmOnReached: "After solving the quest stays in quest tracker and needs to be confirmed by player". Defaults to 0.  
CustomizeConfirmOnReachedCondition: "If true, a custom confirmOnReached condition can be configured for this quest specifically". Defaults to 0.  
ConfirmOnReachedCondition: "Use this to provide a custom configuration for the resolve confirmation for this quest". Needs CustomizeConfirmOnReachedCondition set to 1 to be used. Also see p-t.xml and vanilla usage of it for more info how to use. It is not needed for basic quests.  

#### `HasExclusiveQuestGiver`:
"Optional quests are only started if no other exclusive quest is already running with the same quest giver". Defaults to 1. Most of the time you should set this to 0 if you don't want to block other quests from the same QuestGiver.

#### `QuestBlackList`:
I don't know what this does, it is neither used in vanilla nor explained in p-t.xml. I assume quests listed here can not be active at the same time? But one needs to test.

#### `QuestSessionDependencies/QuestBlockedSessions`:
QuestSessionDependencies: "If not empty, the quest can only be triggered if **one** of the specified sessions is loaded".  
QuestBlockedSessions: "If not empty, the quest can not be triggered in one of the specified sessions".  
Both also accept Regions. 

#### `QuestDifficulty`:
"This is the balanced difficulty of this quest". Defaults to Easy. Allowed values: Easy, Medium or Hard. These are mostly relevant for (money) reward balancing you can find in RewardBalancing GUID 140501.  

#### `KeepCheckingPreconditionsWhenRunning`:
"If true, the quest keeps checking the preconditions and will abort automatically if they are not met any longer". Defaults to 0. This is eg. especially helpful for Quests involving QuestGivers you can have different treaties with. Eg. you can add a PreCondition that the player must at least have TradeRights with the QuestGiver and set KeepCheckingPreconditionsWhenRunning=1 to automatically abort the active Quest if this is no longer the case.  
**Note**: `KeepCheckingPreconditionsWhenRunning` does only check the PreConditions if the Quest itself, not the ones from the executing QuestPool.


