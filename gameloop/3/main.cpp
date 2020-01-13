#include <iostream>
#include <math.h>
#include <unistd.h>

#include <SFML/Graphics.hpp>
#include <SFML/System.hpp>

#include "thing.hpp"
#include "events.hpp"

using namespace sf;

int main(int argc, char* argv[]) {
   RenderWindow window(VideoMode(512, 512), "Gameloop Example 3");
   bool running = true;
   bool showfps = false;
   bool slowmode = false;

   Thing thing("../resources/sprite.jpg");
   Words fps;
   Words slow;
   slow._text.setPosition(0,32);
   slow.setString("(Slow mode)");

   Clock gameclock;
   Time MS_PER_FRAME = milliseconds(16);

   float angle = 0;
   gameclock.restart();

   Time lastTime = gameclock.getElapsedTime();
   while (running) {
      // GET TIME //////////////////////////////////////////////////////////////
      Time startOfFrame = gameclock.getElapsedTime();
      Time elapsed = startOfFrame - lastTime;

      // INPUT
      handleInput(window, running, showfps, slowmode);
      calculateFramerate(fps);

      angle += M_PI * elapsed.asSeconds();
      thing.setPosition(
         256 + 128*std::cos(angle),
         256 + 128*std::sin(angle)
      );

      if (slowmode == true) {
         sleep(milliseconds(50));
      }

      // RENDER
      window.clear(Color::Black);
      if (showfps == true) {
         window.draw(fps);
      }
      if (slowmode == true) {
         window.draw(slow);
      }
      window.draw(thing);
      window.display();

      lastTime = startOfFrame;
   }

   window.close();

   return 0;
}
