# ECE-385-Final-Project-UIUC-Pokemon
We developed a custom Pokémon game set at the University of Illinois at Urbana-Champaign, featuring iconic campus buildings like the Electrical and Computer Engineering Building (ECEB), Foellinger Auditorium, and the Illini Union. The game includes university-themed characters such as Professor Zoufu, Dean Bashir, and Chancellor Jones. Leveraging the programming techniques from Lab 6.2, we implemented keyboard interactions and utilized the COE GitHub repository to access a color palette and sprite indexes for character and environment design. Key gameplay elements include exploring the map with real-time collision detection, entering the highlighted buildings to battle bosses, and an item shop where players can purchase power-ups using credits earned from victorious battles. Each win grants players two credits, enhancing the strategic component of the game. We did not use one sprite sheet for all characters and instead had separate sprites for everything.

## Software Design in C
Since all the game logic is implemented in System Verilog, we used C only to support the MAX3421E chip and to manage communication with it using the SPI protocol. The MicroBlaze processor reads in the keycodes with assistance from the MAX3421E. Based on the received keycode, it updates the position of the character and the frame on the VGA display. In battle mode, the system adjusts the cursor's position to allow move selection when it is the user's turn. In item shop mode, the cursor's position is updated to enable the user to select the item they wish to purchase.

## Hardware Design in SystemVerilog
### Map
We started with a generic Pokémon map found online and customized it by adding representations of the previously mentioned campus buildings to mirror the layout of our university (Fig 1). To create these images, we used Generative AI, feeding it photos of the actual buildings from Google Maps as a reference. We then refined and edited these AI-generated images using design tools like Canva and Piskel to ensure they fit seamlessly into our game’s aesthetic.

In our game, the total map size is 380x406, but to conserve memory, we opted to display only a 240x160 segment on the screen at any given time. This viewable area is strategically centered on the screen by offsetting `drawX` by 200 and `drawY` by 160. We also implemented checks to ensure these offsets remain within the screen's range. If these values exceed the screen boundaries, we set a flag called "offscreen" to determine whether to render the background or simply display black.

<img src="https://github.com/user-attachments/assets/2c585f95-aae4-4d27-95dd-ff94d2590ebe" width="500">

Fig 1: Entire Map for UIUC Pokemon

### Scrolling
The main idea behind our scrolling mechanism is centered on `FrameX` and `FrameY`, which specify the top-left corner of a visible 240x160 section on the screen relative to the larger 380x406 map. This concept was adapted from the techniques used in the `ball.sv` module from Lab 6.2 for updating the frame's position. To prevent the display from extending beyond the map's bounds, we incorporated boundary checks. Furthermore, collision detection based on the color palette at the character's location restricts movement to specific colors. When boundary or collision conditions are met, the values of `FrameX` and `FrameY` are not updated. These values, along with the adjusted `drawX` and `drawY`, are then used to calculate the ROM address, which determines the required colors on the overall map.

### Character Movement
We enhanced character animation in our game by incorporating 12 distinct sprites for character motion. To ensure smoother transitions between these sprites, we designed a separate state in our finite state machine (FSM) for each sprite. The transitions between states are dictated by the keycodes entered by the user, as outlined in our FSM logic.

Our rendering logic determines whether to draw the character or the background based on the position parameters. Specifically, the ball_on flag is set when `drawX` and `drawY` fall within the specified range, signaling that the character sprite should be rendered.

To manage these animations effectively, we utilize a dedicated sprite sheet that contains all 12 sprites. This setup not only organizes the visual assets efficiently but also streamlines the process of switching between sprites during gameplay.

### Battle
When the player's character approaches specific coordinates on the map, which represent the entrance to one of the three mentioned buildings, the game transitions into battle mode (Fig 2). Initially, we display the boss associated with that particular building, with different bosses appearing based on the location. Additionally, we created a sprite sheet for dialogue boxes, presenting unique dialogues for each boss to enhance the narrative. There is a pause built into the state using counters to give players time to absorb the scene before the actual battle commences.

We crafted unique Pokémon for the player and each professor using generative AI, by inputting detailed prompts that encapsulate the distinctive traits we associate with each professor. To display these pokemons, we utilized separate sprite sheets for each Pokémon (Fig 3).

During the battle, players can choose from various moves, each accompanied by distinct animations. The moves include:
- Attack: Inflicts damage on the opponent.
- Shower: Heals the player.
- Stun: Either successfully incapacitates the opponent, causing them to lose a turn, or backfires and damages the player.
- Drop Class: Allows the player to exit the battle.

We use 4 states when the user can toggle between each move using WASD to get the information about them and can press enter to select the move. Three of the states that display animations are mapped to its own next state to display the respective animation. Each move's animation is rendered smoothly, using separate sprite sheets, with each sprite displayed for(120 clock cycles)/(number of sprites on the sheet)  to ensure fluid motion.

The opponent's response is randomized, choosing between attack, stun, or heal. This randomization is achieved by multiplying two large numbers each clock cycle and taking the result modulo 3. The opponent's moves are animated using similar logic with their own sprite sheets. All of the opponent's logic is done in one state.

The battle alternates between player and opponent moves until the health of either drops below zero, leading to an exit screen. Depending on whose health depletes first, a win or lose screen is displayed, featuring the same boss with tailored dialogue to reflect the battle's outcome. Once a battle is won, the credits of the user will be updated by 2 and this will be reflected on the hex display of the FPGA.

![battle_map3](https://github.com/user-attachments/assets/f160299c-0277-4e80-816f-4b7b18ce533c)

Fig 2: Battle Background


<img src="https://github.com/user-attachments/assets/705ddae0-b09f-4ca5-bf7d-7d26a79f09b6" width="192"> <img src="https://github.com/user-attachments/assets/4b14c017-e1ed-4f48-ae07-e953e63b32aa" width="192"> <img src="https://github.com/user-attachments/assets/6ac882cf-ad02-46ba-9b15-76a804029dfe" width="192"> <img src="https://github.com/user-attachments/assets/8afa1435-5cdc-4ad8-a375-a55622d5588e" width="192">

Fig 4: Pokemons used in game



### Item Shop
The item shop (Fig 4) serves as a hub for obtaining upgrades, especially since the final boss presents a significant challenge. Upon entering the shop, players have the option to purchase from a selection of three different items, with each item priced at one credit.

- Attack Doubler: Doubles the user’s attack by 2
- Stun Guarantee: Guarantees that the stun will happen
- Deodorant: Gives full health to the user

When in the item shop, we have three distinct states in our FSM to facilitate the selection process, allowing players to easily toggle between items while making their choices. When a purchase is made by pressing enter, the credit count on the hex display decreases by one. Additionally, this display is utilized to indicate the quantity of each power-up the player currently possesses. It's important to note that players are limited to buying only one of each type of power-up, and purchases are not possible without sufficient credits. All three of the above states map to 3 distinct states where the above computation happens. Exiting the shop is as simple as pressing the escape key.

Once equipped with these power-ups, players can deploy them during battles by pressing the space bar instead of the enter key when their cursor is on a desired move. We streamlined the integration of power-ups into the game mechanics without adding separate states, directly modifying health values based on the specific power-up used.

<img src="https://github.com/user-attachments/assets/467a1da0-f187-4433-a716-66a1edf25a3f" width="360">

Fig 4: Item Shop

## Game FSM
The FSM below does not encapsulate all the states but rather represents overarching game logic and important transitions.

![image](https://github.com/user-attachments/assets/46e06532-ca3f-4847-a7de-630da9864c82)

## Conclusion
In conclusion, we successfully developed a Pokémon-themed game set at the University of Illinois at Urbana-Champaign, featuring battles against bosses modeled after university professors. Our game includes sophisticated features like map scrolling, dynamic battle animations, multiple sprites and health bars. We also introduced an item shop where players can acquire power-ups to enhance their gameplay experience. While the development process was both enjoyable and challenging, we devoted significant time to perfecting the randomization of moves and the mechanics behind the stun feature. Overall, this project not only tested our technical skills but also provided a highly engaging and educational experience.

## References
These are resources or tools that helped us build this project:

- https://www.spriters-resource.com/game_boy_advance/pokemonfireredleafgreen/
- https://www.piskelapp.com/
- https://www.canva.com/ 
