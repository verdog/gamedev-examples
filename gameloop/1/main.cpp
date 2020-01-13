#include <iostream>
#include <math.h>

#include <SFML/Graphics.hpp>
#include <SFML/System.hpp>

#include "thing.hpp"
#include "events.hpp"

int main(int argc, char* argv[]) {
   sf::RenderWindow window(sf::VideoMode(512, 512), "Gameloop Example 1");
   bool running = true;
   bool showfps = false;
   bool slowmode = false;

   Thing thing("../resources/sprite.jpg");
   Words fps;
   sf::Clock gameclock;
   float angle = 0;

   gameclock.restart();

   while (running) {
      // INPUT
      handleInput(window, running, showfps, slowmode);
      calculateFramerate(fps);

      angle += 0.1;
      thing.setPosition(
         256 + 128*std::cos(angle),
         256 + 128*std::sin(angle)
      );

      // RENDER
      window.clear(sf::Color::Black);
      if (showfps == true) {
         window.draw(fps);
      }
      window.draw(thing);
      window.display();
   }

   window.close();

   return 0;
}
