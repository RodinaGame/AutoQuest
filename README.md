# AutoQuest

Auto accept and turn-in quests addon for World of Warcraft 1.12.1 (Vanilla / VanillaPlus)

## Version 1.1.1

### Features
- Automatically accepts available quests
- Automatically turns in completed quests
- Handles multiple quests from the same NPC correctly (prioritizes turn-ins, then accepts)
- Hold **Shift** to temporarily disable automation
- Works well with multi-boxing (share quest → all characters pick it up)
- Auto-selects reward only when there is 0 or 1 choice
- Properly closes quest/gossip windows after turn-in (no more stuck frames)

### Installation
1. Download / clone this repository
2. Place the `AutoQuest` folder into `Interface\AddOns`
3. Restart the game or `/reload`

### Update via bat-file
Use the provided `Update AutoQuest.bat` (place it anywhere, edit the path if needed).

### Changelog
**1.1.1**
- Fixed stuck quest window after turning in a quest on some characters
- Added forced close of Gossip/Quest frames after GetQuestReward

**1.1.0**
- Fixed incorrect behaviour when NPC offers multiple quests (skipping / partial taking)
- Improved detection of completable active quests via quest log
- Added proper versioning
- Safer fallback via GossipTitleButton / QuestTitleButton
- Print version on load

**1.0.0**
- Initial release
