from lxml import etree
import traceback
from copy import deepcopy

# https://lxml.de/api/lxml.etree.XMLParser-class.html
# https://lxml.de/tutorial.html


   # <!-- 1500005370 bis einschl. 1500005499 wird jetzt erstmal für decision verwendet, später evlt umbauen, je nach dem ob decisns oder buttons genutzt werden -->
    # <!-- aktuell bis einschl. 1500005487 belegt  -->
  

  
    # ts.Interface.ToggleStateVisibility("DecisionQuest")
    # öffnet die zuletzt geöffnete DecisonQuest (bzw. schließt die die grad offen ist)
     # wenn keine aktiv ist, passiert nichts.
      # wenn eine andere aktiv ist, versucht es vergeblich die zuvor angezegite zu öffnen
   # theoretisch könnte man im MP dann AutoShowDecisionScreen nutzen und es für die falschen so automatisch schließen,
    # aber selbst die 100ms die es dann angezeigt wird bei jedem Spieler, nervt das schon, also weiterhin AutoShowDecisionScreen im MP weglassen
    

  # <!--  DecisionNotification vs ActionNotification -->
   # <!-- vorteil ist dass man kein Profile übergeben muss, ist QuestGiver -->
    # <!-- Und auch Kosten der Option sowie Buffs werden in Nachricht angezeigt. Kosten stören da etwas, aber ich will ja eh -->
     # <!-- keine Kosten der Optionen haben -->
  
  
  # <!-- DecisionOptionInfotip Asset muss Text und InfoTip als Property haben -->
  
  # <!-- Weder Questname noch DecisionFluffText supperten textembeds -.- -->
  # <!-- In DecisionOptionText gehts, aber je mehr Zeichen, desto mieser ist der text formatiert -->
  
   # <!-- kann man Human1 als QuestGiver eintragen (damit sein portrait zb automatisch bei der quest ist?) -->
   # Ja Humans können QuestGiver sein. Icon neben der Quest ist falsch, aber in der Quest ist Portrait korrekt (Decision kann aber nicht automaitsch korrektes Portrait nehmen..)
    # <!-- ...unkonwn nehmen: 116746 -->

    
    # auf 6 Aktione runterbrechen und die 7te ist dann "weitere"
     # wo ich zur Not dann weniger genutzte Aktionen die ich vllt doch noch zufügen will hinpacke
    
  # 1) Join War
  # 2) (AI) SupportFleet kann ein Button sein, der dann doch weiterführend ist größe/art der Flotte führt.
  # 2) (Human) Share Island Goods
  # 3) Gift Ship
  # 4) (AI) Spionage unterlassen
  # 5) (AI) Command Ally
   
  # Weitere:
    # - Pirate Demand: Quest anfragen um Pirate beim Aufbau zu helfen (mit cooldown), wo am ende pirate neues schiff für ihre flotte spawned
    
  
  # <!-- Kategorien: -->
   # <!-- - Schiffe -->
    # <!-- - Schiff verschenken -->
    # <!-- - kleine Hilfsflotte Militär -->
    # <!-- - kleine Hilfsflotte Handel -->
    # <!-- - (kleine Hilfsflotte Gemischt) -->
    # <!-- - große Hilfsflotte Militär -->
    # <!-- - große Hilfsflotte Handel -->
    # <!-- - (große Hilfsflotte Gemischt) -->
   # <!-- - Diplomatische Beziehungen -->
    # <!-- - Erkläre meinem Feind den Krieg -> Auch mit CharacterNotification wie bei GiftShip Arbeiten um auswählen zu können wem der Krieg erklärt werden soll -->
    # <!-- - Spionage unterlassen -->
       # AI bitten keine shares kaufen, keine airdrops/gute airdrops -> geht nicht wirklich in runtime umzusetzen...
   # <!-- - Quests -->
    # <!-- - Questcooldown resetten? -->
    # <!-- - Pirate DemandMoney: Quest anfragen um Pirate beim Aufbau zu helfen (mit cooldown), wo am ende pirate neues schiff für ihre flotte spawned  -->
   # <!-- Geld/Ressource -->
    # <!-- - Kredit erbitten über BuyShares umsetzen? ne, gibts ja schon indem man an Queen verkauft und ist echt miese Rate  -->
            # lieber ein besseres Kreditsystem machen, wobei nicht wirklich wichtig.. 
          # Insel Shares verschenken? Ne auch nicht nötig, nur für MP relevant und da kann man share auch kaufen und das Geld zurücküberweisen
    # Insellager freigeben (share goods, nur zwischen humans) 

    
  # Schutz versprechen (man wird automatisch in Kriege reingezogen) ?
  # Drohen ? Erhöht/Verringert Chance auf Erfolg bei anderen Aktionen, basierend auf Militärstärke?
    # Problem: wir können nur chance der Mod Aktionen ändern, nicht wirklich die von vanilla...
      # könnte höchstes Ruf durch Drohung erhöhen
    
  



  # <!-- UnlockRequirements der options aktualisieren sich life während man in der decision ist -->
  
  
  # <!-- costs to choose the option (but we dont want costs for most) -->
  # <!-- <HasDecisionCostBehavior>1</HasDecisionCostBehavior> -->
      # <!-- <Item> -->
        # <!-- <Action> -->
          # <!-- <Template>ActionAddGoodsToItemContainer</Template> -->
          # <!-- <Values> -->
            # <!-- <Action /> -->
            # <!-- <ActionAddGoodsToItemContainer> -->
              # <!-- <Goods> -->
                # <!-- <Item> -->
                  # <!-- <Good>1010017</Good> -->
                  # <!-- <Amount>-500</Amount> -->
                # <!-- </Item> -->
              # <!-- </Goods> -->
            # <!-- </ActionAddGoodsToItemContainer> -->
          # <!-- </Values> -->
        # <!-- </Action> -->
      # <!-- </Item> -->
  
  # <!-- as StarterMessage we will use _WelcomeToPlayer AudioText -->
   # <!-- which is also used in reaction <OpenActiveTradeMenu> -->
   # <!-- wobei wir auch die Pools nutzen könnten -->
    # <!-- <GUID>268903</GUID> <Name>Pool_ai01_WelcomeToPlayerPeace</Name> -->
    # <!-- <GUID>264838</GUID> <Name>Pool_ai01_WelcomeToPlayerWar</Name> -->
  
  # <!-- Ah da fällt mir auf: -->
    # <!-- Mit Participants im Krieg kann man keine Quest haben, oder?   -->
      # Erstaunlicherweise klappts scheinbar doch? 
       
       

GeneralDecision = """<ModOps>
  <ModOp Type="AddNextSibling" GUID="152264">
    <Asset>
      <Template>A7_QuestDecision</Template>
      <Values>
        <Standard>
          <GUID>{HEREAssetGUID}</GUID>
          <Name>Diplo {HEREGIVERPID} {HEREHUMANPID}</Name>
        </Standard>
        <Quest>
          <StarterMessage>
            <Notification>
              <IsBaseAutoCreateAsset>1</IsBaseAutoCreateAsset>
              <Values>
                <CharacterNotification>
                  <NotificationTextGroupFemale>519975235</NotificationTextGroupFemale>
                </CharacterNotification>
                <BaseNotification>
                  <NotificationTextGroup>-1080710421</NotificationTextGroup>
                  <NotificationMinDisplayTime>5000</NotificationMinDisplayTime>
                  <DisplayTimeout>30000</DisplayTimeout>
                  <NotificationPriority>100</NotificationPriority>
                </BaseNotification>
                <NotificationSubtitle>
                  <SubtitleGroup>{HERESubtitleGroupWelcomeToPlayer}</SubtitleGroup>
                </NotificationSubtitle>
              </Values>
            </Notification>
          </StarterMessage>
          <SuccessMessage>
            <SuppressMessage>1</SuppressMessage>
          </SuccessMessage>
          <FailureMessage>
            <SuppressMessage>1</SuppressMessage>
          </FailureMessage>
          <SelectionReminderMessage>
            <SuppressMessage>1</SuppressMessage>
          </SelectionReminderMessage>
          <AbortedManuallyMessage>
            <SuppressMessage>1</SuppressMessage>
          </AbortedManuallyMessage>
          <AbortedAutomaticallyMessage>
            <SuppressMessage>1</SuppressMessage>
          </AbortedAutomaticallyMessage>
          <InvitationMessage>
            <SuppressMessage>1</SuppressMessage>
          </InvitationMessage>
          <EscortShipSelectedMessage>
            <SuppressMessage>1</SuppressMessage>
          </EscortShipSelectedMessage>
          <ReminderMessage>
            <SuppressMessage>1</SuppressMessage>
          </ReminderMessage>
          <ResolveConfirmationMessage>
            <SuppressMessage>1</SuppressMessage>
          </ResolveConfirmationMessage>
          <InvitationSmugglerQuestMessage>
            <SuppressMessage>1</SuppressMessage>
          </InvitationSmugglerQuestMessage>
          <SmugglerQuestTradingStationReached>
            <SuppressMessage>1</SuppressMessage>
          </SmugglerQuestTradingStationReached>
          <StartInvitationGiveItemMessage>
            <SuppressMessage>1</SuppressMessage>
          </StartInvitationGiveItemMessage>
          <StartFollowShipMessage>
            <SuppressMessage>1</SuppressMessage>
          </StartFollowShipMessage>
          <OnQuestActive>
            <IsBaseAutoCreateAsset>1</IsBaseAutoCreateAsset>
            <Values>
              <ActionList>
                <Actions>
                  
                </Actions>
              </ActionList>
            </Values>
          </OnQuestActive>
          <QuestGiver>{HEREQUESTGIVER}</QuestGiver>
          <!-- important for lua to set DescriptionText to the Quest GUID -->
          <DescriptionText>{HEREAssetGUID}</DescriptionText>
          <StoryText>14539</StoryText>
          <QuestActivation>QuestStart</QuestActivation>
          <QuestCategory>RandomQuest</QuestCategory>
          <IsAbortable>1</IsAbortable>
          <CountForQuestLimit>0</CountForQuestLimit>
          <HasReminderMessage>0</HasReminderMessage>
          <QuestTimeLimit>0</QuestTimeLimit>
          <ConfirmOnReached>0</ConfirmOnReached>
          <QuestDifficulty>Easy</QuestDifficulty>
          <NeededProgressLevel>EarlyGame;EarlyMidGame;MidGame;LateMidGame;LateGame;EndGame</NeededProgressLevel>
          <QuestTrackerVisibility>Session</QuestTrackerVisibility>
          <QuestBookVisibility>SameAsQuestTracker</QuestBookVisibility>
          <CanBeActiveForMultipleParticipants>1</CanBeActiveForMultipleParticipants>
          <HasExclusiveQuestGiver>0</HasExclusiveQuestGiver>
          <KeepCheckingPreconditionsWhenRunning>1</KeepCheckingPreconditionsWhenRunning>
          <ResetPreconditionsAfterQuestWasTriggered>1</ResetPreconditionsAfterQuestWasTriggered>
          <QuestBookBackground>data/ui/2kimages/main/assets16/questbackground/bg_quest_smugglewithoutscanners_delivery_pickup.png</QuestBookBackground>
          <ReputationQuestFail>
            <ReputationFailList />
          </ReputationQuestFail>
          <QuestHints>
            <Item>
              <Text>128267</Text>
            </Item>
            <Item>
              <Text>128268</Text>
            </Item>
          </QuestHints>
        </Quest>
        <PreConditionList>
          <Condition>
            <Template>ConditionUnlocked</Template>
            <Values>
              <Condition />
              <ConditionUnlocked>
                <UnlockNeeded>{HERESELECTEDGUID}</UnlockNeeded>
              </ConditionUnlocked>
              <ConditionPropsNegatable>
                <NegateCondition>1</NegateCondition>
              </ConditionPropsNegatable>
            </Values>
          </Condition>
        </PreConditionList>
        <Text>
          <TextOverride>14539</TextOverride>
        </Text>
        <Reward>
          <RewardAssets />
          <RewardReputation />
          <PenaltyList />
        </Reward>
        <Objectives>
          <WinConditions>
            <Item>
              <Objective>
                <Template>DecisionObjective</Template>
                <Values>
                  <ConditionQuestObjective>
                    <TextCombinedContextValue>14539</TextCombinedContextValue>
                    <QuestTrackerIcon>data/ui/2kimages/main/icons/icon_diplomacy_tendency_good.png</QuestTrackerIcon>
                  </ConditionQuestObjective>
                  <ConditionQuestDecision>
                    <DecisionBG>data/ui/2kimages/main/assets16/decision_quest/bg_decision_quest_city_01.png</DecisionBG>
                    {HEREAutoShowDecisionScreen}
                    <DecisionList>
                      <Item>
                        <Decision>
                          <Template>ConditionDecision</Template>
                          <Values>
                            <Condition />
                            <ConditionDecision>
                              <DecisionFluffText>1500005267</DecisionFluffText>
                              <DecisionPortrait>{HEREPORTRAIT}</DecisionPortrait>
                              <DecisionOptionList>
                                <!-- Join War (AI/Human) -->
                                {HERE_JOINWAR_XML}
                                <!-- Support Fleet (AI) -->
                                {HERE_SUPPORTFLEET_XML}
                                <!-- Share Goods Access (Human) -->
                                {HERE_SHAREGOODS_XML}
                                <!-- Gift Ship (AI/Human) -->
                                {HERE_GIFTSHIP_XML}   
                                <!-- Command Ally (AI/Human) -->
                                {HERE_COMMANDALLY_XML}
                                <!-- if even more wanted, add them new category category below -->
                                <!-- ## Category 13107 Empty (mods can fill it and replace text) ## -->
                                <!-- <Item> -->
                                  <!-- <DecisionOption> -->
                                    <!-- <Template>ConditionDecisionOption</Template> -->
                                    <!-- <Values> -->
                                      <!-- <Condition /> -->
                                      <!-- <ConditionDecisionOption> -->
                                        <!-- <DecisionOptionText>13107</DecisionOptionText> -->
                                        <!-- <DecisionOptionInfotip>0</DecisionOptionInfotip> -->
                                        <!-- <ActionList> -->
                                          <!-- <IsBaseAutoCreateAsset>1</IsBaseAutoCreateAsset> -->
                                          <!-- <Values> -->
                                            <!-- <ActionList> -->
                                              <!-- <Actions> -->
                                                <!-- <Item> -->
                                                  <!-- <Action> -->
                                                    <!-- <Template>ActionBuff</Template> -->
                                                    <!-- <Values> -->
                                                      <!-- <Action /> -->
                                                      <!-- <ActionBuff> -->
                                                        <!-- <BuffAsset>501777</BuffAsset> -->
                                                        <!-- <AddBuff>0</AddBuff> -->
                                                        <!-- <BuffProcessingParticipant>1</BuffProcessingParticipant> -->
                                                      <!-- </ActionBuff> -->
                                                    <!-- </Values> -->
                                                  <!-- </Action> -->
                                                <!-- </Item> -->
                                              <!-- </Actions> -->
                                            <!-- </ActionList> -->
                                          <!-- </Values> -->
                                        <!-- </ActionList> -->
                                        <!-- <FollowUpDecisionList> -->
                                          <!-- <Item> -->
                                            <!-- <FollowUpDecision> -->
                                              <!-- <Template>ConditionDecision</Template> -->
                                              <!-- <Values> -->
                                                <!-- <Condition /> -->
                                                <!-- <ConditionDecision> -->
                                                  <!-- <DecisionFluffText>1500005267</DecisionFluffText> -->
                                                  <!-- <DecisionPortrait>{HEREPORTRAIT}</DecisionPortrait> -->
                                                  <!-- <DecisionOptionList> -->
                                                    
                                                    <!-- <Item> -->
                                                      <!-- <DecisionOption> -->
                                                        <!-- <Template>ConditionDecisionOption</Template> -->
                                                        <!-- <Values> -->
                                                          <!-- <Condition> -->
                                                            <!-- <LinkAllActionsToQuest>1</LinkAllActionsToQuest> -->
                                                          <!-- </Condition> -->
                                                          <!-- <ConditionDecisionOption> -->
                                                            <!-- <DecisionOptionText>6428</DecisionOptionText> -->
                                                            <!-- <HideDecisionPanelAfterChoice>1</HideDecisionPanelAfterChoice> -->
                                                          <!-- </ConditionDecisionOption> -->
                                                        <!-- </Values> -->
                                                      <!-- </DecisionOption> -->
                                                    <!-- </Item> -->
                                                  <!-- </DecisionOptionList> -->
                                                <!-- </ConditionDecision> -->
                                              <!-- </Values> -->
                                            <!-- </FollowUpDecision> -->
                                          <!-- </Item> -->
                                        <!-- </FollowUpDecisionList> -->
                                      <!-- </ConditionDecisionOption> -->
                                    <!-- </Values> -->
                                  <!-- </DecisionOption> -->
                                <!-- </Item> -->
                              </DecisionOptionList>
                            </ConditionDecision>
                          </Values>
                        </Decision>
                      </Item>
                    </DecisionList>
                  </ConditionQuestDecision>
                </Values>
              </Objective>
            </Item>
          </WinConditions>
        </Objectives>
        <QuestOptional>
          <HasStarterObject>None</HasStarterObject>
        </QuestOptional>
      </Values>
    </Asset>
    
  </ModOp>
  
  {HERE_ModOpSabotage}
  
</ModOps>
"""

# HERE_SUPPORTFLEET_XML
SupportFleet_xml = """<Item>
                                  <DecisionOption>
                                    <Template>ConditionDecisionOption</Template>
                                    <Values>
                                      <Condition />
                                      <ConditionDecisionOption>
                                        <DecisionOptionText>1500001288</DecisionOptionText>
                                        <DecisionOptionInfotip>1500003870</DecisionOptionInfotip>
                                        <ActionList>
                                          <IsBaseAutoCreateAsset>1</IsBaseAutoCreateAsset>
                                          <Values>
                                            <ActionList>
                                              <Actions>
                                                <Item>
                                                  <Action>
                                                    <Template>ActionBuff</Template>
                                                    <Values>
                                                      <Action />
                                                      <ActionBuff>
                                                        <BuffAsset>1500001288</BuffAsset>
                                                        <AddBuff>0</AddBuff>
                                                        <BuffProcessingParticipant>1</BuffProcessingParticipant>
                                                      </ActionBuff>
                                                    </Values>
                                                  </Action>
                                                </Item>
                                              </Actions>
                                            </ActionList>
                                          </Values>
                                        </ActionList>
                                        <FollowUpDecisionList>
                                          <Item>
                                            <FollowUpDecision>
                                              <Template>ConditionDecision</Template>
                                              <Values>
                                                <Condition />
                                                <ConditionDecision>
                                                  <DecisionFluffText>1500005331</DecisionFluffText>
                                                  <DecisionPortrait>{HEREPORTRAIT}</DecisionPortrait>
                                                  <DecisionOptionList>
                                                    {HERE_SMALLFLEET_XML}
                                                    {HERE_BIGFLEET_XML}
                                                    <!-- Add new supportfleet options to this -->
                                                    <Item>
                                                      <DecisionOption>
                                                        <Template>ConditionDecisionOption</Template>
                                                        <Values>
                                                          <Condition>
                                                            <LinkAllActionsToQuest>1</LinkAllActionsToQuest>
                                                          </Condition>
                                                          <ConditionDecisionOption>
                                                            <DecisionOptionText>6428</DecisionOptionText>
                                                            <HideDecisionPanelAfterChoice>1</HideDecisionPanelAfterChoice>
                                                          </ConditionDecisionOption>
                                                        </Values>
                                                      </DecisionOption>
                                                    </Item>
                                                  </DecisionOptionList>
                                                </ConditionDecision>
                                              </Values>
                                            </FollowUpDecision>
                                          </Item>
                                        </FollowUpDecisionList>
                                      </ConditionDecisionOption>
                                    </Values>
                                  </DecisionOption>
                                </Item>"""

# HERE_GIFTSHIP_XML
GiftShipxml = """<Item>
                                  <DecisionOption>
                                    <Template>ConditionDecisionOption</Template>
                                    <Values>
                                      <Condition>
                                        <LinkAllActionsToQuest>1</LinkAllActionsToQuest>
                                      </Condition>
                                      <ConditionDecisionOption>
                                        <DecisionOptionText>1500005300</DecisionOptionText>
                                        <DecisionOptionInfotip>1500005303</DecisionOptionInfotip>
                                        <ActionList>
                                          <IsBaseAutoCreateAsset>1</IsBaseAutoCreateAsset>
                                          <Values>
                                            <ActionList>
                                              <Actions>
                                                <Item>
                                                  <Action>
                                                    <Template>ActionBuff</Template>
                                                    <Values>
                                                      <Action />
                                                      <ActionBuff>
                                                        <BuffAsset>1500005300</BuffAsset>
                                                        <AddBuff>0</AddBuff>
                                                        <BuffProcessingParticipant>1</BuffProcessingParticipant>
                                                      </ActionBuff>
                                                    </Values>
                                                  </Action>
                                                </Item>
                                              </Actions>
                                            </ActionList>
                                          </Values>
                                        </ActionList>
                                        <HasNotification>1</HasNotification>
                                        <DecisionNotification>
                                          <Template>CharacterNotification_GiftShip_Serp</Template>
                                          <Values>
                                            <CharacterNotification>
                                              <ThirdpartyNotificationButtons>
                                                <Item>
                                                  <VectorElement>
                                                    <InheritedIndex>0</InheritedIndex>
                                                  </VectorElement>
                                                  <Command>[Unlock RelockNet(1500005600)];[Participants Participant(121) Profile SetCompanyName(g_DiploActions_Serp.t_ChangeOwnerOfSelectionToPID|{HEREGIVERPID}|false)];[Conditions RegisterTriggerForCurrentParticipant(1500005600)]</Command>
                                                </Item>
                                                <Item>
                                                  <VectorElement>
                                                    <InheritedIndex>1</InheritedIndex>
                                                  </VectorElement>
                                                </Item>
                                              </ThirdpartyNotificationButtons>
                                            </CharacterNotification>
                                            <NotificationSubtitle>
                                              <SubtitleGroup>{HERESUBTITLEGROUPPlyrGivesGift}</SubtitleGroup>
                                            </NotificationSubtitle>
                                          </Values>
                                        </DecisionNotification>
                                        <UnlockRequirements>
                                          <Item>
                                            <RequiredUnlock>1500005300</RequiredUnlock>
                                          </Item>
                                        </UnlockRequirements>
                                        <UnlockInfotipDescription>25415</UnlockInfotipDescription>
                                        <HasDecisionCostBehavior>0</HasDecisionCostBehavior>
                                        <HideDecisionPanelAfterChoice>1</HideDecisionPanelAfterChoice>
                                      </ConditionDecisionOption>
                                    </Values>
                                  </DecisionOption>
                                </Item>"""
# HERE_JOINWAR_XML
JoinWarxml = """<Item>
                                  <DecisionOption>
                                    <Template>ConditionDecisionOption</Template>
                                    <Values>
                                      <Condition>
                                        <LinkAllActionsToQuest>1</LinkAllActionsToQuest>
                                      </Condition>
                                      <ConditionDecisionOption>
                                        <DecisionOptionText>1500005259</DecisionOptionText>
                                        <DecisionOptionInfotip>1500005260</DecisionOptionInfotip>
                                        <ActionList>
                                          <IsBaseAutoCreateAsset>1</IsBaseAutoCreateAsset>
                                          <Values>
                                            <ActionList>
                                              <Actions>
                                                <Item>
                                                  <Action>
                                                    <Template>ActionBuff</Template>
                                                    <Values>
                                                      <Action />
                                                      <ActionBuff>
                                                        <BuffAsset>1500005259</BuffAsset>
                                                        <AddBuff>0</AddBuff>
                                                        <BuffProcessingParticipant>1</BuffProcessingParticipant>
                                                      </ActionBuff>
                                                    </Values>
                                                  </Action>
                                                </Item>
                                                <Item>
                                                  <Action>
                                                    <Template>ActionExecuteScript</Template>
                                                    <Values>
                                                      <Action />
                                                      <ActionExecuteScript>
                                                        <ScriptFileName>data/scripts_serp/events/onjoinwarrequest_{HEREHUMANPID}.lua</ScriptFileName>
                                                      </ActionExecuteScript>
                                                    </Values>
                                                  </Action>
                                                </Item>
                                              </Actions>
                                            </ActionList>
                                          </Values>
                                        </ActionList>
                                        <HasNotification>1</HasNotification>
                                        <DecisionNotification>
                                          <Template>CharacterNotification_DemandWarTo_Serp</Template>
                                          <Values>
                                            <CharacterNotification>
                                              <ThirdpartyNotificationButtons>
                                                <Item>
                                                  <VectorElement>
                                                    <InheritedIndex>0</InheritedIndex>
                                                  </VectorElement>
                                                  <Command>[Unlock RelockNet(1500005600)];[Participants Participant(121) Profile SetCompanyName(g_DiploActions_Serp.RequestJoinWarAgainstSelected|nil|{HEREGIVERPID}|nil)];[Conditions RegisterTriggerForCurrentParticipant(1500005600)]</Command>
                                                </Item>
                                                <Item>
                                                  <VectorElement>
                                                    <InheritedIndex>1</InheritedIndex>
                                                  </VectorElement>
                                                </Item>
                                              </ThirdpartyNotificationButtons>
                                            </CharacterNotification>
                                            <NotificationSubtitle />
                                          </Values>
                                        </DecisionNotification>
                                        <UnlockRequirements>
                                          <Item>
                                            <RequiredUnlock>1500005259</RequiredUnlock>
                                          </Item>
                                        </UnlockRequirements>
                                        <UnlockInfotipDescription>1500005326</UnlockInfotipDescription>
                                        <HasDecisionCostBehavior>0</HasDecisionCostBehavior>
                                        <HideDecisionPanelAfterChoice>1</HideDecisionPanelAfterChoice>
                                      </ConditionDecisionOption>
                                    </Values>
                                  </DecisionOption>
                                </Item>"""
                                
# HERE_COMMANDALLY_XML
CommandAllyxml = """<Item>
                                  <DecisionOption>
                                    <Template>ConditionDecisionOption</Template>
                                    <Values>
                                      <Condition>
                                        <LinkAllActionsToQuest>1</LinkAllActionsToQuest>
                                      </Condition>
                                      <ConditionDecisionOption>
                                        <DecisionOptionText>1500004014</DecisionOptionText>
                                        <DecisionOptionInfotip>1500004015</DecisionOptionInfotip>
                                        <ActionList>
                                          <IsBaseAutoCreateAsset>1</IsBaseAutoCreateAsset>
                                          <Values>
                                            <ActionList>
                                              <Actions>
                                                <Item>
                                                  <Action>
                                                    <Template>ActionBuff</Template>
                                                    <Values>
                                                      <Action />
                                                      <ActionBuff>
                                                        <BuffAsset>1500004014</BuffAsset>
                                                        <AddBuff>0</AddBuff>
                                                        <BuffProcessingParticipant>1</BuffProcessingParticipant>
                                                      </ActionBuff>
                                                    </Values>
                                                  </Action>
                                                </Item>
                                              </Actions>
                                            </ActionList>
                                          </Values>
                                        </ActionList>
                                        <HasNotification>1</HasNotification>
                                        <DecisionNotification>
                                          <Template>CharacterNotification_CreateSelectGroup_Serp</Template>
                                          <Values>
                                            <CharacterNotification>
                                              <ThirdpartyNotificationButtons>
                                                <Item>
                                                  <VectorElement>
                                                    <InheritedIndex>0</InheritedIndex>
                                                  </VectorElement>
                                                  <Command>[Unlock RelockNet(1500005600)][Participants Participant(121) Profile SetCompanyName(g_DiploActions_Serp.CreateSelectGroup|1|{HEREGIVERPID})];[Conditions RegisterTriggerForCurrentParticipant(1500005600)]</Command>
                                                </Item>
                                                <Item>
                                                  <VectorElement>
                                                    <InheritedIndex>1</InheritedIndex>
                                                  </VectorElement>
                                                  <Command>[Unlock RelockNet(1500005600)][Participants Participant(121) Profile SetCompanyName(g_DiploActions_Serp.CreateSelectGroup|2|{HEREGIVERPID})];[Conditions RegisterTriggerForCurrentParticipant(1500005600)]</Command>
                                                </Item>
                                              </ThirdpartyNotificationButtons>
                                            </CharacterNotification>
                                            <NotificationSubtitle>
                                              <SubtitleGroup></SubtitleGroup>
                                            </NotificationSubtitle>
                                          </Values>
                                        </DecisionNotification>
                                        <UnlockRequirements>
                                          <Item>
                                            <RequiredUnlock>1500004014</RequiredUnlock>
                                          </Item>
                                        </UnlockRequirements>
                                        <UnlockInfotipDescription>1500005307</UnlockInfotipDescription>
                                        <HasDecisionCostBehavior>0</HasDecisionCostBehavior>
                                        <HideDecisionPanelAfterChoice>1</HideDecisionPanelAfterChoice>
                                      </ConditionDecisionOption>
                                    </Values>
                                  </DecisionOption>
                                </Item>"""
                                
                                
# HERE_SMALLFLEET_XML
SmallFleetxml = """<Item>
                                                      <DecisionOption>
                                                        <Template>ConditionDecisionOption</Template>
                                                        <Values>
                                                          <Condition>
                                                            <LinkAllActionsToQuest>1</LinkAllActionsToQuest>
                                                          </Condition>
                                                          <ConditionDecisionOption>
                                                            <DecisionOptionText>1500003901</DecisionOptionText>
                                                            <DecisionOptionInfotip>1500003911</DecisionOptionInfotip>
                                                            <ActionList>
                                                              <IsBaseAutoCreateAsset>1</IsBaseAutoCreateAsset>
                                                              <Values>
                                                                <ActionList>
                                                                  <Actions>
                                                                    <Item>
                                                                      <Action>
                                                                        <Template>ActionExecuteScript</Template>
                                                                        <Values>
                                                                          <Action />
                                                                          <ActionExecuteScript>
                                                                            <ScriptFileName>data/scripts_serp/events/onfleetsmall_{HEREHUMANPID}.lua</ScriptFileName>
                                                                          </ActionExecuteScript>
                                                                        </Values>
                                                                      </Action>
                                                                    </Item>
                                                                    <Item>
                                                                      <Action>
                                                                        <Template>ActionStartQuest</Template>
                                                                        <Values>
                                                                          <Action />
                                                                          <ActionStartQuest>
                                                                            <Quest>{HERESMALLFLEETQUEST}</Quest>
                                                                            <InheritQuestArea>1</InheritQuestArea>
                                                                            <InheritQuestSession>1</InheritQuestSession>
                                                                            <InheritQuestObjects>1</InheritQuestObjects>
                                                                          </ActionStartQuest>
                                                                        </Values>
                                                                      </Action>
                                                                    </Item>
                                                                    <Item>
                                                                      <Action>
                                                                        <Template>ActionBuff</Template>
                                                                        <Values>
                                                                          <Action />
                                                                          <ActionBuff>
                                                                            <BuffAsset>1500001291</BuffAsset>
                                                                            <AddBuff>0</AddBuff>
                                                                            <BuffProcessingParticipant>1</BuffProcessingParticipant>
                                                                          </ActionBuff>
                                                                        </Values>
                                                                      </Action>
                                                                    </Item>
                                                                  </Actions>
                                                                </ActionList>
                                                              </Values>
                                                            </ActionList>
                                                            <UnlockRequirements>
                                                              <Item>
                                                                <RequiredUnlock>1500003901</RequiredUnlock>
                                                              </Item>
                                                            </UnlockRequirements>
                                                            <UnlockInfotipDescription>1500003917</UnlockInfotipDescription>
                                                            <HasDecisionCostBehavior>0</HasDecisionCostBehavior>
                                                            <HideDecisionPanelAfterChoice>1</HideDecisionPanelAfterChoice>
                                                          </ConditionDecisionOption>
                                                        </Values>
                                                      </DecisionOption>
                                                    </Item>"""
BigFleetxml = """<Item>
                                                      <DecisionOption>
                                                        <Template>ConditionDecisionOption</Template>
                                                        <Values>
                                                          <Condition>
                                                            <LinkAllActionsToQuest>1</LinkAllActionsToQuest>
                                                          </Condition>
                                                          <ConditionDecisionOption>
                                                            <DecisionOptionText>1500003902</DecisionOptionText>
                                                            <DecisionOptionInfotip>1500003916</DecisionOptionInfotip>
                                                            <ActionList>
                                                              <IsBaseAutoCreateAsset>1</IsBaseAutoCreateAsset>
                                                              <Values>
                                                                <ActionList>
                                                                  <Actions>
                                                                    <Item>
                                                                      <Action>
                                                                        <Template>ActionExecuteScript</Template>
                                                                        <Values>
                                                                          <Action />
                                                                          <ActionExecuteScript>
                                                                            <ScriptFileName>data/scripts_serp/events/onfleetbig_{HEREHUMANPID}.lua</ScriptFileName>
                                                                          </ActionExecuteScript>
                                                                        </Values>
                                                                      </Action>
                                                                    </Item>
                                                                    <Item>
                                                                      <Action>
                                                                        <Template>ActionStartQuest</Template>
                                                                        <Values>
                                                                          <Action />
                                                                          <ActionStartQuest>
                                                                            <Quest>{HEREBIGFLEETQUEST}</Quest>
                                                                            <InheritQuestArea>1</InheritQuestArea>
                                                                            <InheritQuestSession>1</InheritQuestSession>
                                                                            <InheritQuestObjects>1</InheritQuestObjects>
                                                                          </ActionStartQuest>
                                                                        </Values>
                                                                      </Action>
                                                                    </Item>
                                                                    <Item>
                                                                      <Action>
                                                                        <Template>ActionBuff</Template>
                                                                        <Values>
                                                                          <Action />
                                                                          <ActionBuff>
                                                                            <BuffAsset>1500001292</BuffAsset>
                                                                            <AddBuff>0</AddBuff>
                                                                            <BuffProcessingParticipant>1</BuffProcessingParticipant>
                                                                          </ActionBuff>
                                                                        </Values>
                                                                      </Action>
                                                                    </Item>
                                                                  </Actions>
                                                                </ActionList>
                                                              </Values>
                                                            </ActionList>
                                                            <UnlockRequirements>
                                                              <Item>
                                                                <RequiredUnlock>1500003902</RequiredUnlock>
                                                              </Item>
                                                            </UnlockRequirements>
                                                            <UnlockInfotipDescription>1500003918</UnlockInfotipDescription>
                                                            <HasDecisionCostBehavior>0</HasDecisionCostBehavior>
                                                            <HideDecisionPanelAfterChoice>1</HideDecisionPanelAfterChoice>
                                                          </ConditionDecisionOption>
                                                        </Values>
                                                      </DecisionOption>
                                                    </Item>"""
                                                    
# HERE_SHAREGOODS_XML                        
ShareGoodsxml = """<Item>
                                  <DecisionOption>
                                    <Template>ConditionDecisionOption</Template>
                                    <Values>
                                      <Condition>
                                        <LinkAllActionsToQuest>1</LinkAllActionsToQuest>
                                      </Condition>
                                      <ConditionDecisionOption>
                                        <DecisionOptionText>1500005356</DecisionOptionText>
                                        <DecisionOptionInfotip>1500005357</DecisionOptionInfotip>
                                        <ActionList>
                                          <IsBaseAutoCreateAsset>1</IsBaseAutoCreateAsset>
                                          <Values>
                                            <ActionList>
                                              <Actions>
                                                <Item>
                                                  <Action>
                                                    <Template>ActionBuff</Template>
                                                    <Values>
                                                      <Action />
                                                      <ActionBuff>
                                                        <BuffAsset>1500005356</BuffAsset>
                                                        <AddBuff>0</AddBuff>
                                                        <BuffProcessingParticipant>1</BuffProcessingParticipant>
                                                      </ActionBuff>
                                                    </Values>
                                                  </Action>
                                                </Item>
                                                <Item>
                                                  <Action>
                                                    <Template>ActionRegisterTrigger</Template>
                                                    <Values>
                                                      <Action />
                                                      <ActionRegisterTrigger>
                                                        <TriggerAsset>1500005355</TriggerAsset>
                                                      </ActionRegisterTrigger>
                                                    </Values>
                                                  </Action>
                                                </Item>
                                              </Actions>
                                            </ActionList>
                                          </Values>
                                        </ActionList>
                                        <HasDecisionCostBehavior>0</HasDecisionCostBehavior>
                                        <HideDecisionPanelAfterChoice>1</HideDecisionPanelAfterChoice>
                                      </ConditionDecisionOption>
                                    </Values>
                                  </DecisionOption>
                                </Item>"""


# HERE_ModOpSabotage  HERESUBTITLEGROUPNoSpiesAccept
ModOpSabotage="""<!-- No Spies Agreement -->
  <ModOp GUID="{HEREAssetGUID}" Type="add" Condition="#Sabotage_Serp" Path="/Values/Objectives/WinConditions/Item/Objective/Values/ConditionQuestDecision/DecisionList/Item/Decision/Values/ConditionDecision/DecisionOptionList">
    <Item>
      <DecisionOption>
        <Template>ConditionDecisionOption</Template>
        <Values>
          <Condition>
            <LinkAllActionsToQuest>1</LinkAllActionsToQuest>
          </Condition>
          <ConditionDecisionOption>
            <DecisionOptionText>1500004020</DecisionOptionText>
            <DecisionOptionInfotip>1500004022</DecisionOptionInfotip>
            <ActionList>
              <IsBaseAutoCreateAsset>1</IsBaseAutoCreateAsset>
              <Values>
                <ActionList>
                  <Actions>
                    <Item>
                      <Action>
                        <Template>ActionStartQuest</Template>
                        <Values>
                          <Action />
                          <ActionStartQuest>
                            <Quest>1500004035</Quest>
                            <UseCurrentSession>1</UseCurrentSession>
                          </ActionStartQuest>
                        </Values>
                      </Action>
                    </Item>
                    <!-- <Item> -->
                      <!-- <Action> -->
                        <!-- <Template>ActionAddResource</Template> -->
                        <!-- <Values> -->
                          <!-- <Action /> -->
                          <!-- <ActionAddResource> -->
                            <!-- <Resource>{HERE_NoSpiesProduct}</Resource> -->
                            <!-- <ResourceAmount>60</ResourceAmount> -->
                          <!-- </ActionAddResource> -->
                        <!-- </Values> -->
                      <!-- </Action> -->
                    <!-- </Item> -->
                    <Item>
                      <Action>
                        <Template>ActionBuff</Template>
                        <Values>
                          <Action />
                          <ActionBuff>
                            <BuffAsset>1500004020</BuffAsset>
                            <AddBuff>0</AddBuff>
                            <BuffProcessingParticipant>1</BuffProcessingParticipant>
                          </ActionBuff>
                        </Values>
                      </Action>
                    </Item>
                    <!-- <Item> -->
                      <!-- <Action> -->
                        <!-- <Template>ActionAddGoodsToItemContainer</Template> -->
                        <!-- <Values> -->
                          <!-- <Action /> -->
                          <!-- <ActionAddGoodsToItemContainer> -->
                            <!-- <Goods> -->
                              <!-- <Item> -->
                                <!-- <Good>1010017</Good> -->
                                <!-- <Amount>-10000</Amount> -->
                              <!-- </Item> -->
                            <!-- </Goods> -->
                          <!-- </ActionAddGoodsToItemContainer> -->
                        <!-- </Values> -->
                      <!-- </Action> -->
                    <!-- </Item> -->
                  </Actions>
                </ActionList>
              </Values>
            </ActionList>
            <!-- <HasNotification>1</HasNotification> -->
            <!-- <DecisionNotification> -->
              <!-- <Template>CharacterNotification</Template> -->
              <!-- <Values> -->
                <!-- <CharacterNotification> -->
                  <!-- <NotificationTextFemale>1500004022</NotificationTextFemale> -->
                <!-- </CharacterNotification> -->
                <!-- <BaseNotification> -->
                  <!-- <NotificationText>1500004022</NotificationText> -->
                  <!-- <NotificationAudioAsset>239732</NotificationAudioAsset> -->
                  <!-- <NotificationPriority>700</NotificationPriority> -->
                  <!-- <NotificationMinDisplayTime>120000</NotificationMinDisplayTime> -->
                  <!-- <DisplayTimeout>60000</DisplayTimeout> -->
                  <!-- <IsUnique>1</IsUnique> -->
                <!-- </BaseNotification> -->
                <!-- <NotificationSubtitle> -->
                  <!-- <SubtitleGroup>{HERESUBTITLEGROUPNoSpiesAccept}</SubtitleGroup> -->
                <!-- </NotificationSubtitle> -->
              <!-- </Values> -->
            <!-- </DecisionNotification> -->
            <UnlockRequirements>
              <Item>
                <RequiredUnlock>1500004020</RequiredUnlock>
              </Item>
            </UnlockRequirements>
            <UnlockInfotipDescription>1500004023</UnlockInfotipDescription>
            <!-- <HasDecisionCostBehavior>1</HasDecisionCostBehavior> -->
            <HideDecisionPanelAfterChoice>1</HideDecisionPanelAfterChoice>
          </ConditionDecisionOption>
        </Values>
      </DecisionOption>
    </Item>
  </ModOp>"""
                                                    
########################################################################################################
########################################################################################################
########################################################################################################

# Trigger Code to start the correct Quest
Trigger_Base = """<ModOps>
  <ModOp Type="addNextSibling" GUID="130248">
    <Asset>
      <Template>Trigger</Template>
      <Values>
        <Standard>
          <GUID>1500005346</GUID>
          <Name>Start Correct DecisionQuest after Target was Selected</Name>
        </Standard>
        <Trigger>
          <TriggerCondition>
            <IsBaseAutoCreateAsset>1</IsBaseAutoCreateAsset>
            <Values>
              <Condition>
                <SubConditionCompletionOrder>MutuallyExclusive</SubConditionCompletionOrder>
              </Condition>
              <ConditionAlwaysTrue />
            </Values>
          </TriggerCondition>
          <SubTriggers>
{Trigger_SPCondition}
{Trigger_MPCondition}
          </SubTriggers>
        </Trigger>
        <TriggerSetup>
          <AutoRegisterTrigger>0</AutoRegisterTrigger>
          <UsedBySecondParties>0</UsedBySecondParties>
        </TriggerSetup>
      </Values>
    </Asset>
    
  </ModOp>
  
</ModOps>
"""

Trigger_MPCondition = """            <Item>
              <SubTrigger>
                <Template>AutoCreateTrigger</Template>
                <Values>
                  <Trigger>
                    <TriggerCondition>
                      <Template>ConditionIsMultiplayer</Template>
                      <Values>
                        <Condition>
                          <SubConditionCompletionOrder>MutuallyExclusive</SubConditionCompletionOrder>
                        </Condition>
                        <ConditionIsMultiplayer />
                        <ConditionPropsNegatable />
                      </Values>
                    </TriggerCondition>
                    <SubTriggers>
{Trigger_MPWhichPlayer}
                    </SubTriggers>
                  </Trigger>
                </Values>
              </SubTrigger>
            </Item>"""

Trigger_MPWhichPlayer = """                      <Item>
                        <SubTrigger>
                          <Template>AutoCreateTrigger</Template>
                          <Values>
                            <Trigger>
                              <TriggerCondition>
                                <Template>ConditionUnlocked</Template>
                                <Values>
                                  <Condition>
                                    <SubConditionCompletionOrder>MutuallyExclusive</SubConditionCompletionOrder>
                                  </Condition>
                                  <ConditionUnlocked>
                                    <UnlockNeeded>{HEREHUMANPID_WHICHPLAYER}</UnlockNeeded>
                                  </ConditionUnlocked>
                                  <ConditionPropsNegatable />
                                </Values>
                              </TriggerCondition>
                              <SubTriggers>
{Trigger_SubTriggerCondition}
                              </SubTriggers>
                            </Trigger>
                          </Values>
                        </SubTrigger>
                      </Item>
"""
                
Trigger_SPCondition = """            <Item>
              <SubTrigger>
                <Template>AutoCreateTrigger</Template>
                <Values>
                  <Trigger>
                    <TriggerCondition>
                      <Template>ConditionIsMultiplayer</Template>
                      <Values>
                        <Condition>
                          <SubConditionCompletionOrder>MutuallyExclusive</SubConditionCompletionOrder>
                        </Condition>
                        <ConditionIsMultiplayer />
                        <ConditionPropsNegatable>
                          <NegateCondition>1</NegateCondition>
                        </ConditionPropsNegatable>
                      </Values>
                    </TriggerCondition>
                    <SubTriggers>
{Trigger_SubTriggerCondition}
                    </SubTriggers>
                  </Trigger>
                </Values>
              </SubTrigger>
            </Item>"""
                

Trigger_SubTriggerCondition = """                      <Item>
                        <SubTrigger>
                          <Template>AutoCreateTrigger</Template>
                          <Values>
                            <Trigger>
                              <TriggerCondition>
                                <Template>ConditionUnlocked</Template>
                                <Values>
                                  <Condition>
                                    <IsOptional>1</IsOptional>
                                  </Condition>
                                  <ConditionUnlocked>
                                    <UnlockNeeded>{HERESELECTEDGUID}</UnlockNeeded>
                                  </ConditionUnlocked>
                                  <ConditionPropsNegatable>
                                    <NegateCondition>1</NegateCondition>
                                  </ConditionPropsNegatable>
                                </Values>
                              </TriggerCondition>
                              <TriggerActions>
                                <Item>
                                  <TriggerAction>
                                    <Template>ActionStartQuest</Template>
                                    <Values>
                                      <Action />
                                      <ActionStartQuest>
                                        <Quest>{HEREAssetGUID}</Quest>
                                        <UseCurrentSession>1</UseCurrentSession>
                                      </ActionStartQuest>
                                    </Values>
                                  </TriggerAction>
                                </Item>
                              </TriggerActions>
                            </Trigger>
                          </Values>
                        </SubTrigger>
                      </Item>"""



PIDs = {
    "Human0":{"PID":0,"GUID":41},"Human1":{"PID":1,"GUID":600069},"Human2":{"PID":2,"GUID":600070},"Human3":{"PID":3,"GUID":42},
    "General_Enemy":{"PID":9,"GUID":44},"Neutral":{"PID":8,"GUID":34},"Third_party_01_Queen":{"PID":15,"GUID":75},
    "Second_ai_01_Jorgensen":{"PID":25,"GUID":47},"Second_ai_02_Qing":{"PID":26,"GUID":79},"Second_ai_03_Wibblesock":{"PID":27,"GUID":80},
    "Second_ai_04_Smith":{"PID":28,"GUID":81},"Second_ai_05_OMara":{"PID":29,"GUID":82},"Second_ai_06_Gasparov":{"PID":30,"GUID":83},
    "Second_ai_07_von_Malching":{"PID":31,"GUID":11},"Second_ai_08_Gravez":{"PID":32,"GUID":48},"Second_ai_09_Silva":{"PID":33,"GUID":84},
    "Second_ai_10_Hunt":{"PID":34,"GUID":85},"Second_ai_11_Mercier":{"PID":64,"GUID":220},
    "Third_party_03_Pirate_Harlow":{"PID":17,"GUID":73},"Third_party_04_Pirate_LaFortune":{"PID":18,"GUID":76},
    "Third_party_02_Blake":{"PID":16,"GUID":45},"Third_party_06_Nate":{"PID":22,"GUID":77},"Third_party_05_Sarmento":{"PID":19,"GUID":29},
    "Third_party_07_Jailor_Bleakworth":{"PID":23,"GUID":46},"Third_party_08_Kahina":{"PID":24,"GUID":78},"Africa_Ketema":{"PID":80,"GUID":119051},
    "Arctic_Inuit":{"PID":72,"GUID":237},
}
SupportedPIDs_All = [0,1,2,3,25,26,27,28,29,30,31,32,33,34,64,17,18,16,19,22,23,24,80,72,15]
SupportedPIDs_WarAndGiftShip = [0,1,2,3,25,26,27,28,29,30,31,32,33,34,64,17,18]
SupportedPIDs_2ndParty = [25,26,27,28,29,30,31,32,33,34,64]
SupportedPIDs_SmallFleet = [25,26,27,28,29,30,31,32,33,34,64,17,18,16,15,22]
SupportedPIDs_BigFleet = [25,26,27,28,29,30,31,32,33,34,64,17,18,15]
# HERESMALLFLEETQUEST
SmallFleetQuest = {
  25:1500001246,26:1500001248,27:1500001250,28:1500001252,29:1500001254,30:1500001256,31:1500001258,32:1500001260,33:1500001262,34:1500001264,64:1500001266,
  17:1500001268,18:1500001270,16:1500001272,22:1500001273,15:1500001274,
}
# HEREBIGFLEETQUESTT
BigFleetQuest = {
  25:1500001247,26:1500001249,27:15000012551,28:1500001253,29:1500001255,30:1500001257,31:1500001259,32:1500001261,33:1500001263,34:1500001265,64:1500001267,
  17:1500001269,18:1500001271,15:1500001275,
}
# HERESubtitleGroupWelcomeToPlayer für Ketema: <Name>AT_ADDON01_Ketema_Greeting02</Name>
SubtitleGWelcomeToPlayer = {
  25:-1897344337,26:-2054915462,27:1204150546,28:-177757999,29:-113388126,30:1612177457,31:1859688433,32:-1408914028,33:-393682872,34:751189787,64:736908306,
  17:981143564,18:298463984,16:1180219215,19:91574379,22:1791611884,23:-198684181,24:-268877076,80:-580342218,72:127840159,15:1807089449,
}

# HERESUBTITLEGROUPPlyrGivesGift
SubtitleGPlyrGivesGift = {
  25:367326729,26:-1486254691,27:-92643874,28:-1416836678,29:1931272306,30:-1079790644,31:-1933000792,32:-6487614,33:877584309,34:-1882704639,64:995704636,
  17:135175854,18:-1221452994,
}
# HERESELECTEDGUID
SelectionUnlocks = {
  0:1500005244,1:1500005245,2:1500005246,3:1500005247,
  25:1500005223,26:1500005224,27:1500005225,28:1500005226,29:1500005227,30:1500005228,31:1500005229,32:1500005230,33:1500005231,34:1500005232,64:1500005233,
  17:1500005234,18:1500005235,16:1500005236,19:1500005237,22:1500005238,23:1500005239,24:1500005240,80:1500005241,72:1500005242,15:1500005243,
}
SubtitleGAccepts = {
  25:244727316,26:-2005155339,27:-1567964067,28:-1933351358,29:1062778986,30:-577843668,31:996335328,32:21475824,33:-584564999,34:1416899689,64:-1743732589,
  17:-2135361874,18:2095539530,
}
NoSpiesProducts = {
  25:1500004024,26:1500004025,27:1500004026,28:1500004027,29:1500004028,30:1500004029,31:1500004030,32:1500004031,33:1500004032,34:1500004033,64:1500004034,
}

# <!-- Portrait GUIDs der KIs (für DecisionPortrait), die GUID des Participants zu nehmen geht leider nicht, also keins für Humans nehmen -->
  # <!-- siehe auch Anno1800 RDA unpacked\dataAlle\data\ui\2kimages\main\profiles -->
  # <!-- 100530,100663,100664,100665,100666,100667,100532,100531,100674,100587,110670 -->
  # <!-- third party: -->
  # <!-- queen:100668, Blake:100589, Harlow:100669, LaFortune:100670, Sarmento:100671, Eli:100631, Kahina:100673 General_Enemy:101894 -->
  # <!-- Nate:100672, Inuit:101019, africa_Ketema_portrait:120250,  Vasco Silva:112118 -->
  # <!-- Unknown_Silhouette:116746, GG_EnemyDark_Portrait:7925, campaign_character_01_demolition_expert (gefanger):101138 -->
Portraits = {
  0:0,1:0,2:0,3:0,
  25:100530,26:100663,27:100664,28:100665,29:100666,30:100667,31:100532,32:100531,33:100674,34:100587,64:110670,
  17:100669,18:100670,16:100589,19:100671,22:100672,23:100631,24:100673,80:120250,72:101019,15:100668,
}
WhichPlayerHumanUnlocks = {0:1500001613,1:1500001614,2:1500001615,3:1500001616}


Path = r"C:\Users\Serpens66\Documents\Anno 1800\mods\DiploActions_Serp\data\config\export\main\asset\Decisions"
resultfilename = "Decision_{HumanPID}_{TargetPID}.include.xml"

StartGUID = 1500005370
CurrentGUID = StartGUID

PIDToGUID = {}
for TargetPID in SupportedPIDs_All:
  for s,info in PIDs.items():
    if info["PID"] == TargetPID:
      PIDToGUID[TargetPID] = info["GUID"]
# print(PIDToGUID)

finalTrigger_MPWhichPlayer = ""
for HumanPID in range(5): # HumanPIDs
  isSP = False
  if HumanPID==4: # Singleplayer version, its Human0
    isSP = True
    HumanPID = 0
  else:
    CurrentTrigger_MPWhichPlayer = Trigger_MPWhichPlayer
    CurrentTrigger_MPWhichPlayer = CurrentTrigger_MPWhichPlayer.format(HEREHUMANPID_WHICHPLAYER=WhichPlayerHumanUnlocks[HumanPID],Trigger_SubTriggerCondition="{Trigger_SubTriggerCondition}")
  finalSubTriggers = ""
  for TargetPID in SupportedPIDs_All:
    if HumanPID!=TargetPID:
      if CurrentGUID==1500005500:
        print("ERROR 1500005500 ist bereits in Nutzung! Mehr GUIDs einplanen!")
        break       # .format() sucks, because it requires you to mention ALL {x} entries in the string -.-  so use replace() instead in most cases
      finalresultfilename = resultfilename.format(HumanPID=isSP and "SP" or HumanPID,TargetPID=TargetPID)
      finalGeneralDecision = GeneralDecision
      
      if TargetPID not in [0,1,2,3]: ## not human
        finalGeneralDecision = finalGeneralDecision.replace("{HERE_SUPPORTFLEET_XML}",SupportFleet_xml)
      if TargetPID in SupportedPIDs_WarAndGiftShip:
        finalGeneralDecision = finalGeneralDecision.replace("{HERE_GIFTSHIP_XML}",GiftShipxml)
        finalGeneralDecision = finalGeneralDecision.replace("{HERE_JOINWAR_XML}",JoinWarxml)
        finalGeneralDecision = finalGeneralDecision.replace("{HERE_COMMANDALLY_XML}",CommandAllyxml)
      if TargetPID in SupportedPIDs_2ndParty:
        finalGeneralDecision = finalGeneralDecision.replace("{HERE_ModOpSabotage}",ModOpSabotage)
      if TargetPID in SupportedPIDs_SmallFleet:
        finalGeneralDecision = finalGeneralDecision.replace("{HERE_SMALLFLEET_XML}",SmallFleetxml)
      if TargetPID in SupportedPIDs_BigFleet:
        finalGeneralDecision = finalGeneralDecision.replace("{HERE_BIGFLEET_XML}",BigFleetxml)
      if TargetPID in [0,1,2,3]: # only other humans
        finalGeneralDecision = finalGeneralDecision.replace("{HERE_SHAREGOODS_XML}",ShareGoodsxml)
      
      finalGeneralDecision = finalGeneralDecision.format(
        HEREAssetGUID=CurrentGUID,HEREGIVERPID=TargetPID,HEREHUMANPID=HumanPID,
        HERESubtitleGroupWelcomeToPlayer=SubtitleGWelcomeToPlayer.get(TargetPID,0),
        HERESELECTEDGUID=SelectionUnlocks[TargetPID],HEREPORTRAIT=Portraits[TargetPID],
        HEREQUESTGIVER=PIDToGUID[TargetPID],HERESUBTITLEGROUPPlyrGivesGift=SubtitleGPlyrGivesGift.get(TargetPID,0),
        HERESMALLFLEETQUEST=SmallFleetQuest.get(TargetPID,"ERROR"),HEREBIGFLEETQUEST=BigFleetQuest.get(TargetPID,"ERROR"),
        HERE_NoSpiesProduct=NoSpiesProducts.get(TargetPID,0),
        HERE_SUPPORTFLEET_XML="",HERE_COMMANDALLY_XML="",HERESUBTITLEGROUPNoSpiesAccept=SubtitleGAccepts.get(TargetPID,0),
        HERE_GIFTSHIP_XML="",HERE_JOINWAR_XML="",HERE_SMALLFLEET_XML="",HERE_BIGFLEET_XML="",HERE_SHAREGOODS_XML="",
        HERE_ModOpSabotage="",        # if it was not replaced yet, use empty text
        HEREAutoShowDecisionScreen=isSP and "<AutoShowDecisionScreen>1</AutoShowDecisionScreen>" or "",
      )
      
      print(r'<Include File="/data/config/export/main/asset/Decisions/{finalresultfilename}" />'.format(finalresultfilename=finalresultfilename))
      
      
      with open(f"{Path}/{finalresultfilename}", "w") as f:
        f.write(finalGeneralDecision)
      
      CurrentSubTrigger = Trigger_SubTriggerCondition
      CurrentSubTrigger = CurrentSubTrigger.format(HERESELECTEDGUID=SelectionUnlocks[TargetPID],HEREAssetGUID=CurrentGUID)
      
      finalSubTriggers += f"{CurrentSubTrigger}\n"
      
      CurrentGUID += 1
  if not isSP:
    CurrentTrigger_MPWhichPlayer = CurrentTrigger_MPWhichPlayer.format(Trigger_SubTriggerCondition=finalSubTriggers)
    finalTrigger_MPWhichPlayer += f"{CurrentTrigger_MPWhichPlayer}\n"
  else:
    finalTrigger_SPCondition = Trigger_SPCondition.format(Trigger_SubTriggerCondition=finalSubTriggers)
    
finalTrigger_MPCondition = Trigger_MPCondition.format(Trigger_MPWhichPlayer=finalTrigger_MPWhichPlayer)

finalTrigger = Trigger_Base.format(Trigger_SPCondition=finalTrigger_SPCondition,Trigger_MPCondition=finalTrigger_MPCondition)
print(r'<Include File="/data/config/export/main/asset/Decisions/TriggerDecision.include.xml" />')
with open(f"{Path}/TriggerDecision.include.xml", "w") as f:
  f.write(finalTrigger)

      

