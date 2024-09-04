# ECE-385-Final-Project-UIUC-Pokemon
We developed a custom Pokémon game set at the University of Illinois at Urbana-Champaign, featuring iconic campus buildings like the Electrical and Computer Engineering Building (ECEB), Foellinger Auditorium, and the Illini Union. The game includes university-themed characters such as Professor Zoufu, Dean Bashir, and Chancellor Jones. Leveraging the programming techniques from Lab 6.2, we implemented keyboard interactions and utilized the COE GitHub repository to access a color palette and sprite indexes for character and environment design. Key gameplay elements include exploring the map with real-time collision detection, entering the highlighted buildings to battle bosses, and an item shop where players can purchase power-ups using credits earned from victorious battles. Each win grants players two credits, enhancing the strategic component of the game. We did not use one sprite sheet for all characters and instead had separate sprites for everything.

## Software Design in C
Since all the game logic is implemented in System Verilog, we used C only to support the MAX3421E chip and to manage communication with it using the SPI protocol. The MicroBlaze processor reads in the keycodes with assistance from the MAX3421E. Based on the received keycode, it updates the position of the character and the frame on the VGA display. In battle mode, the system adjusts the cursor's position to allow move selection when it is the user's turn. In item shop mode, the cursor's position is updated to enable the user to select the item they wish to purchase.

## Hardware Design in SystemVerilog
### Map
We started with a generic Pokémon map found online and customized it by adding representations of the previously mentioned campus buildings to mirror the layout of our university (Fig 1). To create these images, we used Generative AI, feeding it photos of the actual buildings from Google Maps as a reference. We then refined and edited these AI-generated images using design tools like Canva and Piskel to ensure they fit seamlessly into our game’s aesthetic.

In our game, the total map size is 380x406, but to conserve memory, we opted to display only a 240x160 segment on the screen at any given time. This viewable area is strategically centered on the screen by offsetting `drawX` by 200 and `drawY` by 160. We also implemented checks to ensure these offsets remain within the screen's range. If these values exceed the screen boundaries, we set a flag called "offscreen" to determine whether to render the background or simply display black.

![init_map4](https://github.com/user-attachments/assets/2c585f95-aae4-4d27-95dd-ff94d2590ebe)
Fig 1: Entire Map for UIUC Pokemon

### Scrolling
The main idea behind our scrolling mechanism is centered on `FrameX` and `FrameY`, which specify the top-left corner of a visible 240x160 section on the screen relative to the larger 380x406 map. This concept was adapted from the techniques used in the `ball.sv` module from Lab 6.2 for updating the frame's position. To prevent the display from extending beyond the map's bounds, we incorporated boundary checks. Furthermore, collision detection based on the color palette at the character's location restricts movement to specific colors. When boundary or collision conditions are met, the values of `FrameX` and `FrameY` are not updated. These values, along with the adjusted `drawX` and `drawY`, are then used to calculate the ROM address, which determines the required colors on the overall map.

### Character Movement
We enhanced character animation in our game by incorporating 12 distinct sprites for character motion. To ensure smoother transitions between these sprites, we designed a separate state in our finite state machine (FSM) for each sprite. The transitions between states are dictated by the keycodes entered by the user, as outlined in our FSM logic.

Our rendering logic determines whether to draw the character or the background based on the position parameters. Specifically, the ball_on flag is set when `drawX` and `drawY` fall within the specified range, signaling that the character sprite should be rendered.

To manage these animations effectively, we utilize a dedicated sprite sheet that contains all 12 sprites. This setup not only organizes the visual assets efficiently but also streamlines the process of switching between sprites during gameplay.
