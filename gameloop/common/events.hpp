#include <time.h>
#include <string>
#include <deque>
#include <iostream>

#include <SFML/Window.hpp>
#include "thing.hpp"

void handleInput(sf::Window &w, bool &running, bool &showfps, bool &slowmode) {
    sf::Event event;
      while (w.pollEvent(event)) {
         if (event.type == sf::Event::Closed) {
            running = false;
         } else if (event.type == sf::Event::KeyPressed) {
            if (event.key.code == sf::Keyboard::Escape) {
               running = false;
            } else if (event.key.code == sf::Keyboard::F) {
               showfps = !showfps;
            } else if (event.key.code == sf::Keyboard::S) {
               slowmode = !slowmode;
            }
         }
      }
    return;
}

void calculateFramerate(Words &text) {
   static sf::Clock clock;
   static std::deque<float> last;
   
   float result = 1.f / clock.getElapsedTime().asSeconds();

   if (last.size() >= 64) {
      last.pop_front();
   }
   last.push_back(result);

   float average = 0;

   for (const auto &f : last) {
      average += f;
   }
   average /= last.size();
   text.setString(std::to_string(average));

   clock.restart();
}
