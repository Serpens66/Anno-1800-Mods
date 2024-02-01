WIP quest tutorial, will be deleted when finished and uploaded to the anno 1800 modding-guide

TODO: das packen zu allgemein Quests: The same Quest and also the same Trigger can be started/triggered multiple times at once. So make sure to only start/register them once at the same time.

"Defaults to" is based on the default values defined in properties.xml. There may be other values defined in the template you are using (if defined nowhere the values will be 0).

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

#### `StoryText/DescriptionText/AlternativeRewardTitle/QuestHints`:
StoryText: "This is the fluff text of a quest." eg. an embellished story.  
DescriptionText: "This is the description of a quest." telling the player what to do exactly in short. Not needed if the WinConditions are self explanatory already.  
AlternativeRewardTitle: "An alternative headline for the rewards". Defaults to GUID 2653 ("Reward"). So use it if you think this word does not fit for your Quest.
QuestHints: Add Text GUIDs here for short hints how to solve the Quest like "Search near X" or mention the session name where to look and stuff like this.

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
QuestSessionDependencies: "If not empty, the quest can only be triggered if **one** of the specified sessions is loaded". I think if nothing else is defined and the quest is started via a QuestPool, this is also the Quest the session will be active in.  
QuestBlockedSessions: "If not empty, the quest can not be triggered in one of the specified sessions".  
Both also accept Regions. 

#### `QuestDifficulty`:
"This is the balanced difficulty of this quest". Defaults to Easy. Allowed values: Easy, Medium or Hard. These are mostly relevant for (money) reward balancing you can find in RewardBalancing GUID 140501.  

#### `KeepCheckingPreconditionsWhenRunning`:
"If true, the quest keeps checking the preconditions and will abort automatically if they are not met any longer". Defaults to 0. This is eg. especially helpful for Quests involving QuestGivers you can have different treaties with. Eg. you can add a PreCondition that the player must at least have TradeRights with the QuestGiver and set KeepCheckingPreconditionsWhenRunning=1 to automatically abort the active Quest if this is no longer the case.  
**Note**: `KeepCheckingPreconditionsWhenRunning` does only check the PreConditions of the Quest itself, not the ones from the executing QuestPool.  
The game does already cancels Quests to players you declare war to, but this is bugged since it only cancels one Quest. If there are multiple they are not all cancelled, so it is better to also include this as PreCondition if practicable.

#### `ReputationQuestFail/ReputationQuestDeclined/Reward-RewardReputation`:
Adding a list with `ReputationParticipant` "The participant that rewards reputation" and `ReputationAmount` "The amount of reputation that is rewarded. This number can be negative to create a reputation loss". So you can make the player loose reputation when a quest fails, but also gain reputation with other AIs.
Reward/RewardReputation is defined outside of the Quest property, but works the same and is awared on Success of the Quest.

#### `ResetPreconditionsAfterQuestWasTriggered`:
"If true, the interal state of all preconditions will be reset. This is especially important for ConditionEvent which otherwise endlessly remembers any received event". Defaults to 0. I think this is only relevant if your PreCondition contain ConditionEvent like SessionEnter an such events. If you use such an event and leave this value 0, only "Entering the Session" once is enough to have the PreCondition true always, also for the next time the same Quest might start. If you set it to 1 instead, you must enter the Session everytime again to again allow the Quest to be started.  
So most of the time this is not relevant for you.

#### `RespectRelatedQuestSession`:
"If true, this quest tries to spawn in the same session as another quest that is configured in the preconditions. We try to determine the correct quest out of all conditions given. An assert will be thrown if we don't manage to find a quest but this flag is set". Better define the sessions in different way to be sure, eg. in QuestSessionDependencies if started via a Pool or with QuestSession if started via ActionStartQuest.

#### `HasStarterSpeechBubble/StarterSpeechBubble/HasSuccessSpeechBubble/SuccessSpeechBubble`:
Did not use this yet. Feel free to add how to use this if you know more about it.

#### `CanBeActiveForMultipleParticipants`:
"Only takes effect in quest pools. Checking this will stop preventing the quest from being called from the pool, while another player has this quest running". Defaults to 0, but set it to 1 if you only want one human player to have the same Quest active at the same time.


