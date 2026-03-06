---  

# 🛡️ **KAIJU NO. 8**
---  

## **OPERATION: DEFENSE CORP** > **Complete Visual Guide · How to Play and Solutions** > Contains detailed instructions, menu screenshots, step-by-step walkthrough, and all game secrets.

---

### 📑 Index
* [1. How to run the game?](#1-how-to-run-the-game)
* [2. The title screen](#2-the-title-screen)
* [3. How the interactive menu works](#3-how-the-interactive-menu-works)
* [4. The status bar — what does it tell you?](#4-the-status-bar--what-does-it-tell-you)
* [5. The complete map — 5 locations, 15 zones](#5-the-complete-map--5-locations-15-zones)
* [6. All items and where to find them](#6-all-items-and-where-to-find-them)
* [7. Quick solution — 6 steps to win](#7-quick-solution--6-steps-to-win)
* [8. Full walkthrough — all items](#8-full-walkthrough--all-items)
* [9. The final combat explained](#9-the-final-combat-explained)
* [10. System responses when you make a mistake](#10-system-responses-when-you-make-a-mistake)
* [11. Frequently Asked Questions](#11-frequently-asked-questions)

---
# 🚀 1. How to run the game?
---  

Before playing, you need to grant execution permissions to the file.  
Open a terminal in the folder where you saved the file and run:

**Step 1 — Grant execution permissions (only the first time)** `chmod +x kaiju_no8.sh`

**Step 2 — Launch the game** `./kaiju_no8.sh`

**Direct alternative with Bash** `bash kaiju_no8.sh`

---

## ✓ System Requirements

- 🐧 **Linux with Bash 4.0 or higher** (Ubuntu, Debian, Fedora, Arch, etc.)

- 🖥️ **Terminal with color support** (most have it by default)

- 📦 **No additional installation required**
---
# 🎮 2. The Title Screen
---  

Upon starting the game, you will see the **Kaiju No. 8 ASCII logo** in bright red and a presentation message.  
This screen explains the premise: you are **Kafka Hibino** and you must stop a **kaiju threatening the city of Tachikawa**.

### WHAT YOU WILL SEE AT STARTUP


██╗  ██╗ █████╗ ██╗  ██╗   ██╗   ██╗ ...
(Large ASCII Logo in red)

╔══ OPERATION: DEFENSE CORP — v2.0 ══╗
You are Kafka Hibino, a member of the Defense Corp.
→ Choose the menu options by typing their number.

Press **ENTER** to begin.

#### The game will take you directly to the first playable zone:  
#### **Defense Corp Base Main Entrance.**

---  
# 3. How the interactive menu works  
---  

This game operates using a numbered menu system. In every zone you visit, the game will automatically show you what you can do. You just need to type the number of the option you want to choose and press ENTER.  
Real in-game menu example  

┌─ WHAT DO YOU DO? ──────────────────────────────  
1)  📋  Take the Class-S Tactical Manual ★
2)  🔫  Go to the Armory
3)  ✈️   Go to the Hangar
4)  🔙  Return to Base
5)  🎒  View inventory
  
 └────────────────────────────────────────────────

  HIBINO ▶ Choose [1-5]: _

In this example, if you want to take the manual, you type 1 and press ENTER. It's that simple.  

The meaning of the colors in the menu  
Each type of option has a different color so you know what it does at a glance:  

| Color | Meaning |
| :---: | :--- |
| 🟡 **Yellow** | Pick up an item from the environment |
| ⚪ **White** | Move to a zone within the same location |
| 🔵 **Blue** | Travel to a completely different location |
| 🔴 **Red** | Combat action (attack the enemy) |
| ⚫ **Grey** | View your inventory, map, or help |  

#### Can I type text instead of numbers?  
Yes. If you prefer to type commands instead of using the menu, they also work:  

| TEXT | EQUIVALENT TO... |
| :--- | :--- |
| `inventory` (or `inv`) | View your collected items |
| `map` | View the tactical map with all locations |
| `help` (or `?`) | View the game's quick manual |
| `exit` (or `quit`) | End the game |  

`⚠ Important
If you type something the game doesn't understand, a character from the anime
will respond with a funny message. There are 15 different random phrases!
The game will remind you to use the numbered menu.`

---
# **4. The status bar — what does it tell you?** ---  
---  

At the top of each screen, there is a status bar with a black background that always shows you key information:
``  📍 Defense Corp Base  ›  Armory   🎒 Items: 2   👣 Steps: 7  ``

| ELEMENT | WHAT IT INDICATES |
| :--- | :--- |
| 📍 **Name** | The location where you are right now |
| › **Zone** | The specific sub-zone within that location |
| 🎒 **Items: N** | How many items you have in your inventory (maximum 10) |
| 👣 **Steps: N** | How many actions you have taken since the start |

---  
# 🗺️ 5. The Complete Map  
---  

> **5 locations, 15 zones.** The game has 5 main locations. Each one contains 3 internal zones. You can move freely between all of them without any restriction (except for the *Lair*, where you need the **Essence** to win).

---

## 🏢 LOCATION 1: Defense Corp Base
*Starting point of the game. Safe zone with basic equipment.*
* ▸ **Main Entrance** — Here you find the `Class-S Tactical Manual`
* ▸ **Armory** — `Anti-Kaiju Rifle` and `Corp Light Armor`
* ▸ **Hangar** — Reno Ichikawa gives you the key hint of the game.

## 🏙️ LOCATION 2: Tachikawa City
*City under kaiju alert. It has useful supplies.*
* ▸ **Underground Market** — `Regeneration Potion` and `Sonic Grenade`
* ▸ **Hospital** — `Field Medkit` and confirmed hint of the **Essence**.
* ▸ **Rooftop** — Panoramic view with ASCII art of the city.

## ☠️ LOCATION 3: Northern Contaminated Zone
> ### ✨ KEY ZONE
> *Devastated area. The item needed to win the game is located here.*
* ▸ **Ruins** — `Anti-Corrosion Shield` among the debris.
* ★ **Laboratory** — **CRYSTALLIZED KAIJU ESSENCE** 💎 (key item)
* ▸ **Crater** — Impact zone with ASCII art of the kaiju crater.

## ⚔️ LOCATION 4: Elite Headquarters
*Base of the top soldiers. Powerful weapons and important briefings.*
* ▸ **Command Room** — Mina Ashiro briefs you on Kaiju No. 9.
* ▸ **Dojo** — Training with Hoshina (Dojo ASCII art).
* ▸ **Elite Arsenal** — `Type-X Kaiju-Fiber Katana` and `92nd Percentile Suit`.

## 👹 LOCATION 5: Final - Kaiju Lair
> ### 🔥 FINAL ZONE
> *Final destination. Do not enter the Core without the Crystallized Essence.*
* ▸ **Lair Entrance** — Access with ominous ASCII art of the lair.
* ▸ **Deep Tunnel** — Warns you if the Essence is missing.
* ★ **Kaiju Core** — **WHERE KAIJU NO. 9 IS DEFEATED** 🏆

---
# 🎒 6. Items and Equipment Guide  
---

> There are **10 items** in total. Only one is mandatory to win (marked with ★). The rest are optional but will greatly facilitate the final combat.

| ICON | ITEM | WHERE AND HOW TO GET IT |
| :---: | :--- | :--- |
| 📋 | **Class-S Tactical Manual** | `Base` → `Entrance` → Option 1 |
| ⚔️ | **Type-07 Anti-Kaiju Rifle** | `Base` → `Armory` → Option 1 |
| 🛡️ | **Corp Light Armor** | `Base` → `Armory` → Option 2 |
| 💊 | **Kaiju Regeneration Potion** | `Tachikawa` → `Market` → Option 1 |
| 💣 | **Anti-Kaiju Sonic Grenade** | `Tachikawa` → `Market` → Option 2 |
| 💊 | **Corp Field Medkit** | `Tachikawa` → `Hospital` → Option 1 |
| 🛡️ | **Anti-Corrosion Shield** | `Contaminated Zone` → `Ruins` → Option 1 |
| ⭐ | ★ **CRYSTALLIZED KAIJU ESSENCE** | `Contaminated Zone` → `Laboratory` → Option 1 |
| ⚔️ | **Type-X Kaiju-Fiber Katana** | `Elite HQ` → `Elite Arsenal` → Option 1 |
| 🛡️ | **Reinforced 92nd Percentile Suit** | `Elite HQ` → `Elite Arsenal` → Option 2 |

---

### ⚠️ CRITICAL MISSION ADVISORY
> [!IMPORTANT]
> **★ THE ESSENCE IS THE ONLY MANDATORY ITEM**
>
> Without the **Crystallized Kaiju Essence**, *Kaiju No. 9* is completely invulnerable. With it (and only with it), you can damage its core and successfully complete the mission.
---  
# ⚡ 7. Quick Solution — 6 Steps to Win  
---  

> If you want to complete the game in the most direct way possible, follow these exact 6 steps. On each screen, the menu will guide you with the available options.

### 🚀 MINIMUM ROUTE — 6 ACTIONS
`Start` → `Contaminated Zone` → `Laboratory` → `Take Essence` → `Lair` → `Core` → `Attack`

| # | WHAT YOU SEE ON SCREEN | WHAT YOU DO |
| :---: | :--- | :--- |
| **1** | You are at **Defense Corp Base — Entrance** | Choose the **BLUE** option 🔵: `Travel → Northern Contaminated Zone` |
| **2** | You are in **Northern Contaminated Zone** (main menu) | Choose the **WHITE** option ⚪: `Abandoned Laboratory ★` |
| **3** | You see the chest labeled **ESSENCE** | Choose the **YELLOW** option 🟡: `TAKE CRYSTALLIZED KAIJU ESSENCE` |
| **4** | `★★★ KEY ITEM OBTAINED! ★★★` appears | Choose the **BLUE** option 🔵: `Travel → Final Kaiju Lair` |
| **5** | You are at the **Final Kaiju Lair** | Choose the **WHITE** option ⚪: `★ Kaiju Core ← FINAL BATTLE` |
| **6** | You see **Kaiju No. 9** and the attack option | Choose the **RED** option 🔴: `★ ATTACK Kaiju No. 9!` |

---

### ✓ Final Result
> [!TIP]
> **GUARANTEED VICTORY**
> By following these steps, the animated combat sequence begins and **Kaiju No. 9** is defeated. The **VICTORY** screen will appear with your final score based on the number of steps taken.
 
---
# 🏆 8. Full Walkthrough — All Items  
---  

> This route covers all 5 locations in logical order, collects all **10 items**, and leads you to the final battle with the best possible equipment.

---

### 🏢 PHASE 1 — Defense Corp Base
*Safe starting zone and point of departure.*

| ZONE | WHAT TO DO |
| :--- | :--- |
| **Main Entrance** | Take the `Class-S Tactical Manual` (option 🟡). Then go to the **Armory**. |
| **Armory** | Take the `Type-07 Anti-Kaiju Rifle` and the `Corp Light Armor` (options 🟡). |
| **Hangar** | Speak with **Reno Ichikawa** to update your objective: "The Essence is in the Contaminated Zone." |

> [!TIP]
> **💡 After the Hangar:** The menu will enable a direct **BLUE** 🔵 option to the *Contaminated Zone*.

---

### 🏙️ PHASE 2 — Tachikawa City
*Optional. Contains 3 support items and additional hints.*

| ZONE | WHAT TO DO |
| :--- | :--- |
| **Underground Market** | Take the `Kaiju Regeneration Potion` and the `Anti-Kaiju Sonic Grenade` (options 🟡). |
| **Emergency Hospital** | Obtain the `Corp Field Medkit` (option 🟡) and receive a hint about the Essence. |
| **Rooftop** | Enjoy the city **ASCII art** and confirm the Kaiju's direction to the north. |

---

### ☠️ PHASE 3 — Northern Contaminated Zone ★ KEY ZONE
*The most important zone: contains the item required to win.*

| ZONE | WHAT TO DO |
| :--- | :--- |
| **Ruins** | Take the `Anti-Corrosion Shield` (option 🟡). Then proceed to the **Laboratory**. |
| ★ **Laboratory** | Choose: `★ TAKE CRYSTALLIZED KAIJU ESSENCE`. The message will appear: *KEY ITEM OBTAINED!* |
| **Central Crater** | Visual zone featuring the Kaiju impact **ASCII art**. |

> [!IMPORTANT]
> **⭐ Upon obtaining the Essence:** The Laboratory menu will automatically change to offer a direct **BLUE** 🔵 route to the *Final Lair*.

---

### ⚔️ PHASE 4 — Elite Headquarters
*Recommended to obtain the best combat gear.*

| ZONE | WHAT TO DO |
| :--- | :--- |
| **Command Room** | Briefing with **Mina Ashiro** regarding Kaiju No. 9 (Percentile >96%). |
| **Dojo** | Training with **Hoshina** (detailed ASCII art). He will send you to the **Arsenal**. |
| **Elite Arsenal** | Take the `Type-X Kaiju-Fiber Katana` and the `Reinforced 92nd Percentile Suit` (options 🟡). |

---

### 👹 PHASE 5 — Final Kaiju Lair ★ FINAL BATTLE
*Ensure you are carrying the **Crystallized Essence** before entering.*

| ZONE | WHAT TO DO |
| :--- | :--- |
| **Lair Entrance** | If you don't have the Essence, the game will allow you to go back and find it. If you have it, advance to the **Tunnel**. |
| **Deep Tunnel** | The game verifies your inventory. With the Essence, the **RED** 🔴 option appears: `★ ADVANCE TO THE CORE`. |
| ★ **Kaiju Core** | **FINAL COMBAT:** Choose the **RED** 🔴 option: `★ ATTACK Kaiju No. 9 with the Essence!` |

---
# ⚔️ 9. The final combat explained  
---  


When you choose **'Attack'** in the *Kaiju Core* with the **Essence** in your inventory, an animated combat sequence is triggered. Here is what happens step by step:

| # | MOMENT | WHAT YOU SEE ON SCREEN |
| :---: | :--- | :--- |
| **1** | **Raise the Essence** | The screen shows the Essence glowing with `INTENSE BLUE LIGHT` 🔹 |
| **2** | **The kaiju reacts** | **Kaiju No. 9** roars. Its core reacts to the Essence's energy. |
| **3** | **ATTACK!** | The text `!!ATTACK!!` appears in **RED** 🔴. The Essence penetrates its armor. |
| **4** | **Rifle Bonus** | *If carrying the Rifle:* `PRECISION SHOT` message 🎯 |
| **5** | **Katana Bonus** | *If carrying the Katana:* `FINAL SLASH` message 🗡️ |
| **6** | **VICTORY** | The `!!! KAIJU NO. 9 ELIMINATED !!!` banner appears with stars 🌟 |
| **7** | **End Screen** | The victory screen is displayed with the item count (**N/10**). |

---

> [!TIP]
> **💡 Combat bonus items**
> The Rifle and the Katana are not required to win, but if you carry them, they add special lines of text to the final combat animation. With all **10 items**, the sequence is as epic as possible. 🏆

---
# ⚠️ 10. System responses when you make a mistake  
---  

> If you type something that is neither a menu number nor a recognized command, the game responds with one of **15 random messages**. All of them feature references to the anime universe. Try making a mistake to see them all!

| CHARACTER | WHAT THEY SAY |
| :--- | :--- |
| **Kafka Hibino** | `'Is that a kaiju or a number?'` |
| **Kaiju No. 8** | `'...even I don't know what you meant by that.'` |
| **Suit AI** | `Input not recognized. Use the menu numbers.` |
| **Mina Ashiro** | Points at your keyboard. `'What was THAT?'` |
| **Mid-level Kaijus** | They laugh at you from the shadows. |
| **Soshiro Hoshina** | `'That makes no strategic sense whatsoever.'` |
| **Percentile System** | `Input percentile: 0.0%. Use the menu.` |
| **Leno Ichikawa** | `'I don't even understand that with the Corp manual!'` |
| **Reno Ichikawa** | Searches for that command... it's not in the regulations. |
| **Kikoru Shinomiya** | `'It looks like someone skipped training.'` |
| **Corp Alert** | `'Unknown Kaiju'... it's just you typing weird things.` |
| **Corp Radio** | `Are you speaking in kaiju language?` |
| **Combat Log** | `That input caused more damage than a Level 9 Kaiju.` |
| **Tachikawa Waves** | They laugh at your attempt. |
| **Director Shinomiya** | `'That is... unacceptable, soldier.'` |

---

> [!NOTE]
> This list is randomized, so you'll have to try several times to see them all in the game! 🎮
---  
# ❓ 11. Frequently Asked Questions
---  

**Can I explore in any order?**
> Yes, movement is completely free. There is no mandatory order. You can go to the *Lair* directly from the beginning, although without the **Essence**, you won't be able to win.

**What happens if I enter the Core without the Essence?**
> The game does not end. The **Kaiju Core** menu will show options to go back and find it. *Kaiju No. 9* will repel you with a roar, but there is no `game over`. You can leave and get it at any time.

**How many items are there in total?**
> There are **10 items**. Only **1 is mandatory** (the *Crystallized Essence*). The other 9 are optional, and some add extra lines of dialogue in the final combat.

**Can the game break if I type something weird?**
> No. The input system is designed to handle any text. If the game doesn't understand what you type, it will respond with a random character message and remind you to use the numbered menu.

**Is there a way to see the map at any time?**
> Yes. You can always type `map` or choose the 🗺️ option from the menu. The map shows the 5 locations, their zones, and marks in **red** where you are currently located.

**How do I know how many items I'm missing?**
> Type `inventory` or choose the 🎒 option from the menu. Below your items, your **current objective** will always appear: if you already have the Essence, it will tell you to go to the core; if not, it will remind you where to find it.

**Can I play the game more than once?**
> Of course! The game does not save progress between sessions. Every time you run the script, the adventure starts from scratch so you can try to beat your step record.

---

> [!TIP]
> **Have more questions?** Check the **Quick Solution** section to see the direct path to victory. 🏆
