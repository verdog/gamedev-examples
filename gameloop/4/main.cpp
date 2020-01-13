#include <iostream>
#include <math.h>
#include <unistd.h>

#include <SFML/Graphics.hpp>
#include <SFML/System.hpp>

#include "thing.hpp"
#include "events.hpp"

using namespace sf;

int main(int argc, char* argv[]) {
   RenderWindow window(VideoMode(512, 512), "Gameloop Example 4");
   bool running = true;
   bool showfps = false;
   bool slowmode = false;

   Thing thing("../resources/sprite.jpg");
   Words fps;
   Words slow;
   slow._text.setPosition(0,32);
   slow.setString("(Slow mode)");

   Clock gameclock;
   Time MS_PER_UPDATE = milliseconds(16);

   float angle = 0;
   gameclock.restart();

   Time lastTime = gameclock.getElapsedTime();
   Time lag = milliseconds(0);
   while (running) {
      // GET TIME //////////////////////////////////////////////////////////////
      Time startOfFrame = gameclock.getElapsedTime();
      Time elapsed = startOfFrame - lastTime;
      lastTime = startOfFrame;
      lag += elapsed;

      // INPUT
      handleInput(window, running, showfps, slowmode);
      calculateFramerate(fps);

      while (lag >= MS_PER_UPDATE) {
         angle += 0.05;
         thing.setPosition(
            256 + 128*std::cos(angle*2.2),
            256 + 128*std::sin(angle)
         );
         lag -= MS_PER_UPDATE;
      }

      if (slowmode == true) {
         sleep(milliseconds(200));
      }

      // RENDER
      float percent = lag/MS_PER_UPDATE;

      window.clear(Color::Black);
      if (showfps == true) {
         window.draw(fps);
      }
      if (slowmode == true) {
         window.draw(slow);
      }
      window.draw(thing);
      window.display();
   }

   window.close();

   return 0;
}
