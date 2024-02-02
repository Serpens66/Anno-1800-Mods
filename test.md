WIP quest tutorial, will be deleted when finished and uploaded to the anno 1800 modding-guide



"Defaults to" is based on the default values defined in properties.xml. There may be other values defined in the template you are using (if defined nowhere the values will be 0).

# Properties/Values of Questpools:
(Again take a look at p-t.xml and search for `<Name>QuestPool</Name>` (the one that has "DisabledByDefault" directly below it) to see all allowed values and some description)

QuestPools are a helper construct to automatically start quests on regular basis if PreConditions are fullfilled. Eg. if you made like 10 Quests that simply should be chosen randomly if preconditions are fullfilled (just like the games Random Quests) you can put your Quests in a pool and define how often the pool should start up to how many quests at once and so on. It also supports adding QuestLines into the pool instead of Quests directly to make sure they are started one after the other.

A Pool will automatically start the Quests as soon as the PreConditions of the Pool and of the first Quest of the Questlines are met. There is no need to add this pool somewhere else or to activate it. If you set DisabledByDefault=1 in a pool it will be disabled (not starting any quests) and need to be enabled first with ActionSetQuestPoolEnablement and IsQuestPoolEnabled=1. But enabling/disabling pools with ActionSetQuestPoolEnablement is only needed if you are not able to include it as PreCondition (this vanilla pool is eg. disabled when the player looses the continental island).  
Some QuestPools are also added to AI player assets, like `<QuestPool>150082</QuestPool>` is added to Jorgensen. This is not mandatory, as far as I know this only means that Quests are offered at the lighthouse of the AI and you don't have to define the starting point of a Quest in the Quest itself.

#### `DisabledByDefault`:
Disabled Pools do not start Quests. Defaults to 0. For basic usage, just leave this at 0 and don't mess with Enabling/Disabling QuestPools. Most of the time the PreConditions you can define for Pools/Quests are more then enough. Eg. the vanilla game disables the QuestPool for Cape-Quests if the player looses the continental island. An alternative would be to add "owning the continental island" into the PreConditions of the Pool. There may be cases where disabling/enabling Pools is better, but they are rare (use ActionSetQuestPoolEnablement and IsQuestPoolEnabled=1 to enable a disabled pool).

#### `Quests/Groups/SubPools`:
Lists inlucding Quests/Groups/SubPools, you can define a Weight for each of them to have some more likely to be chosen.    
`Quests`: can be directly the Quest GUIDs you want to include or `QuestLine` objects to make sure they are automatically played one after the other.  
`Groups`: When you search for the `GUID -616566410` you will find it to be a Group GUID above alot of Assets being Quests from Jorgensen and used in a QuestPool. This is a easy way to automatically include all Quests within that Group, but it is not very clear for the reader and modder. Because it also means you must take care **where to put** your own quest to avoid accidently adding it to such a existing group!  
`SubPools`: Pools can even include other Pools. Eg. you want a Pool to start some random Quests, but you have many Quests of different categories and want different cooldowns for them. Then you can order them into different SubPools with their own Cooldowns and start them with a TopLevel Pool. Eg. the TopLevel Pool calls a Quest once every 30 minutes and your SubPools have a PoolCooldown of 60 minutes, to make sure the same category of Quest is not chosen two times in a row.  

#### `IsMainStoryPool`:
Defaults to 0. Not really sure what this does, but I assume it should only be used for vanilla story Quests, so better don't touch this.

#### `IsTopLevel`:
*"If true, this pool will be used directly to select quests and does not depent on a parent pool to be chosen."* Defaults to 0. Relevant because Pools can even include other pools. Only the TopLevel pool (the one that is not included within other pools) should have this set to 1 and it means that this pool is the one responsible to start the quests (while lower-level pools wait for "instructions" from their higher pool).

#### `QuestLimit`:
*"The max number of quests that this pool can call simultaneously"*. Defaults to 1. So the amount of quests that can be active at the same time started from this pool (if PreConditions are met). 
 
#### `PoolCooldown/CooldownOnQuestStart/CooldownOnQuestEnd/QuestCooldown/AffectedByCooldownFactor`:
`PoolCooldown`: *"Defines the time the pool is blocked after calling a quest"*. Defaults to 120000 ms. Eg. if you want to trigger any quest of the pool once every 30 minutes or so, enter a time in ms here. Use a cooldown of 0 if you want all quests to directly be triggered as soon as all PreConditions are met.  
`CooldownOnQuestStart`: *"Starts the pool cooldown if no pool cooldown is running and a quest started"*. I think "Quest started" in this case is already true as soon as the Quest is triggered by the Pool, even if it is only currently offered on the map and the player still has to click and activate the Quest. (TODO: test if CooldownOnQuestStart=0 and CooldownOnQuestEnd=0 this means the PoolCooldown does nothing?)   
`CooldownOnQuestEnd`: *"Starts the pool cooldown if no pool cooldown is running and a quest ended"*. "OnQuestEnd", so it does not matter if it succeeded or failed. (I'm not sure about discarded/aborted.. test it and add the info here). Keep in mind that this could have weird side effects, since the Cooldown is only started if cooldown is not already running. Eg. if you set it to 30 minutes and the user finishes the Quest in 29 minutes, 1 minute later the Pool can start another Quest. But if the user needs 31 minutes instead, there will be another Cooldown of 30 minutes.  
`QuestCooldown`: *"A quest of this pool is blocked for this time when it was resolved."*. Defaults to 300000 ms. So if you want to make sure the same quest is not chosen again too soon, if you allow a quest to be active multiple times. Set it to 0 if you don't want such a cooldown. This has no effect in Pools only including SubPools.  
`AffectedByCooldownFactor`: *"When true, the cooldown will be affected by the cooldown multiplier of the quest frequencies in the difficulty settings"*. Defaults to 1. I assume this affects both the Pool and the Quest Cooldown? Not sure.  

#### `QuestSessionDependencies`:
`QuestSessionDependencies`: *"If any sessions will be linked here, than this pool does only select new quests if **one** of the given sessions is currently running"*. Also supports Region.   

#### `QuestPoolCooldownMultiplierList`:
No description and never used from the game, but looking at p-t.xml `<Name>QuestPoolCoodownMultiplier</Name>` looks like one can make a Pool to multiply his Cooldown based on the Happiness of a specific population to make Quests appear more often. Not tested if this works. If you test it, please update this text.  

#### `QuestPoolActionCallbacks`:
Here you can define Actions eg. on success or on discard and so on of Quests started via this Pool. You can also define these actions within the Quests itself, but if you want them to be the same for all quests of this pool, define it here. In vanilla there is eg. often code to remove the Quest-Offer-Ship (the one with a star above) if the Quest is discarded (rejected from the user before it really starts).  

#### `PreConditionList`:
Here you can define Conditions that must be true for the Pool to start Quests. As long as they are not true, the pool does not start Quests. You can also define PreConditions for individual Quests in the Quests themself.  

